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

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/JetBrains Rider-${PV}"

QA_PREBUILT="opt/${P}/*"

RESHARPER_DIR="lib/ReSharperHost"

src_prepare() {
	default

	local remove_me=( "${RESHARPER_DIR}"/windows* "${RESHARPER_DIR}"/linux*-arm* "${RESHARPER_DIR}"/macos* )

	rm -rv "${remove_me[@]}" || die

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

	fperms 755 "${dir}"/bin/fsnotifier
	fperms 755 "${dir}"/bin/{rider,format,inspect,ltedit,remote-dev-server}.sh

	fperms 755 "${dir}"/"${RESHARPER_DIR}"/linux-x64/{Rider.Backend,JetBrains.Debugger.Worker,JetBrains.ProcessEnumerator.Worker,clang-format,jb_zip_unarchiver}
	fperms 755 "${dir}"/"${RESHARPER_DIR}"/linux-x64/dotnet/dotnet

	fperms 755 "${dir}"/jbr/bin/{java,javac,javadoc,jcmd,jdb,jfr,jhsdb,jinfo,jmap,jps,jrunscript,jstack,jstat,keytool,rmiregistry,serialver}
	fperms 755 "${dir}"/jbr/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}

	make_wrapper "${PN}" "${dir}/bin/${PN}.sh"
	newicon "bin/${PN}.svg" "${PN}.svg"
	make_desktop_entry "${PN}" "Rider ${VER}" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-${PN}-inotify-watches.conf" || die
}
