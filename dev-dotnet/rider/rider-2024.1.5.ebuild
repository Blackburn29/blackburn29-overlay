# Copyright 2024 Blake LaFleur <blake.k.lafleur@gmail.com>
# Distributed under the terms of the GNU General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.

EAPI=8

inherit desktop wrapper

DESCRIPTION="A cross-platform .NET IDE based on the IntelliJ platform and ReSharper."
HOMEPAGE="https://www.jetbrains.com/rider/"
SRC_URI="https://download-cf.jetbrains.com/rider/JetBrains.Rider-${PV}.tar.gz"

LICENSE="|| ( jetbrains_business-3.1 jetbrains_individual-4.1 jetbrains_education-3.2 jetbrains_classroom-4.1 jetbrains_open_source-4.1 )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CDDL CPL-1.0 GPL-2-with-classpath-exception GPL-3 ISC LGPL-2.1 LGPL-3 MIT MPL-1.1 OFL PSF-2 trilead-ssh UoI-NCSA yFiles yourkit
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="wayland"
RDEPEND="
	dev-libs/libdbusmenu
	dev-debug/lldb
	media-libs/mesa[X(+)]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
"

S="${WORKDIR}/JetBrains Rider-${PV}"

QA_PREBUILT="opt/${P}/*"

RESHARPER_DIR="lib/ReSharperHost"
PLUGIN_DIR="plugins"

src_prepare() {
	default

	declare -a remove_arches=(\
		arm64 \
		aarch64 \
		macos \
		windows- \
		win- \
	)

	# Remove all unsupported ARCH
	for arch in "${remove_arches[@]}"
	do
		echo "Removing files for $arch"
		find . -name "*$arch*" -exec rm -rf {} \; || true
	done

	if use wayland; then
		echo "-Dawt.toolkit.name=WLToolkit" >> bin/rider64.vmoptions

		elog "Experimental wayland support has been enabled via USE flags"
		elog "You may need to update your JBR runtime to the latest version"
		elog "https://github.com/JetBrains/JetBrainsRuntime/releases"
	fi
}

src_install() {
	local dir="/opt/${P}"

	insinto "${dir}"
	doins -r *

	fperms 755 "${dir}"/bin/{repair,fsnotifier}
	fperms 755 "${dir}"/bin/{remote-dev-server,inspect,rider,format,ltedit,jetbrains_client}.sh

	fperms 755 "${dir}"/"${RESHARPER_DIR}"/linux-x64/{Rider.Backend,JetBrains.Debugger.Worker,JetBrains.ProcessEnumerator.Worker,clang-format,jb_zip_unarchiver}
	fperms 755 "${dir}"/"${RESHARPER_DIR}"/linux-x64/dotnet/dotnet

	fperms 755 "${dir}"/"${PLUGIN_DIR}"/cidr-debugger-plugin/bin/lldb/linux/x64/bin/{lldb,lldb-server,lldb-argdumper,LLDBFrontend}
	fperms 755 "${dir}"/"${PLUGIN_DIR}"/dotCommon/DotFiles/linux-x64/JetBrains.Profiler.PdbServer
	fperms 755 "${dir}"/"${PLUGIN_DIR}"/remote-dev-server/selfcontained/bin/{xkbcomp,Xvfb}
	fperms 755 "${dir}"/"${PLUGIN_DIR}"/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-linux-amd64

	fperms 755 "${dir}"/jbr/bin/{java,javac,javadoc,jcmd,jdb,jfr,jhsdb,jinfo,jmap,jps,jrunscript,jstack,jstat,keytool,rmiregistry,serialver}
	fperms 755 "${dir}"/jbr/lib/{chrome-sandbox,cef_server,jcef_helper,jexec,jspawnhelper}

	make_wrapper "${PN}" "${dir}/bin/${PN}.sh"
	newicon "bin/${PN}.svg" "${PN}.svg"
	make_desktop_entry "${PN}" "Rider ${VER}" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-${PN}-inotify-watches.conf" || die
}
