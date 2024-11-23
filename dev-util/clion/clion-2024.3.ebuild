# Copyright 2024 Blake LaFleur <blake.k.lafleur@gmail.com>
# Distributed under the terms of the GNU General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.

EAPI=8

inherit desktop wrapper

DESCRIPTION="A cross-platform IDE for C and C++"
HOMEPAGE="https://www.jetbrains.com/clion/"

LICENSE="|| ( JetBrains-business JetBrains-educational JetBrains-classroom JetBrains-individual )"
LICENSE+=" 0BSD Apache-2.0 BSD BSD-2 CC0-1.0 CC-BY-2.5 CC-BY-3.0 CC-BY-4.0 CDDL-1.1 CPL-1.0 EPL-1.0 GPL-2"
LICENSE+=" GPL-2-with-classpath-exception ISC JSON LGPL-2.1 LGPL-3 LGPL-3+ libpng MIT MPL-1.1 MPL-2.0"
LICENSE+=" OFL-1.1 public-domain unicode Unlicense W3C ZLIB ZPL"

SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror splitdebug"
IUSE="wayland"
QA_PREBUILT="opt/${P}/*"
RDEPEND="
	dev-libs/libdbusmenu
	dev-debug/lldb
	sys-process/audit
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

SRC_URI_PN="CLion"
SRC_URI="https://download-cdn.jetbrains.com/cpp/${SRC_URI_PN}-${PV}.tar.gz -> ${P}.tar.gz"

src_unpack() {
	cp "${DISTDIR}"/${P}.tar.gz "${WORKDIR}" || die
	mkdir -p "${P}"
	tar xf "${P}".tar.gz --strip-components=1 -C ./"${P}"
	rm -rf "${P}".tar.gz
}

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
		echo "-Dawt.toolkit.name=WLToolkit" >> bin/clion64.vmoptions

		elog "Experimental wayland support has been enabled via USE flags"
		elog "You may need to update your JBR runtime to the latest version"
		elog "https://github.com/JetBrains/JetBrainsRuntime/releases"
	fi
}

src_install() {
	local dir="/opt/${P}"

	insinto "${dir}"
	doins -r *

	fperms 755 "${dir}"/bin/{"${PN}",restarter,clion}
	fperms 755 "${dir}"/bin/{"${PN}",format,inspect,ltedit,remote-dev-server}.sh
	fperms 755 "${dir}"/bin/fsnotifier

	fperms 755 "${dir}"/bin/clang/linux/x64/bin/{clangd,clang-format,clang-tidy,clazy-standalone,llvm-symbolizer}
	fperms 755 "${dir}"/bin/cmake/linux/x64/bin/{cmake,cpack,ctest}
	fperms 755 "${dir}"/bin/gdb/linux/x64/bin/{gcore,gdb,gdb-add-index,gdbserver}
	fperms 755 "${dir}"/bin/lldb/linux/x64/bin/{lldb,lldb-argdumper,LLDBFrontend,lldb-server}
	fperms 755 "${dir}"/bin/ninja/linux/x64/ninja

	fperms 755 "${dir}"/jbr/bin/{java,javac,javadoc,jcmd,jdb,jfr,jhsdb,jinfo,jmap,jps,jrunscript,jstack,jstat,keytool,rmiregistry,serialver}
	fperms 755 "${dir}"/jbr/lib/{chrome-sandbox,jcef_helper,jexec,jspawnhelper}

	fperms 755 "${dir}"/plugins/clion-radler/DotFiles/linux-x64/Rider.Backend
	fperms 755 "${dir}"/plugins/gateway-plugin/lib/remote-dev-workers/remote-dev-worker-linux-amd64
	fperms 755 "${dir}"/plugins/python-ce/helpers/{pockets/autolog.py,pycodestyle-2.10.0.py,pycodestyle.py,pydev/pydevd_attach_to_process/linux_and_mac/compile_linux.sh,typeshed/scripts/generate_proto_stubs.sh,typeshed/scripts/sync_tensorflow_protobuf_stubs.sh}
	fperms 755 "${dir}"/plugins/remote-dev-server/{bin/launcher.sh,selfcontained/bin/xkbcomp,selfcontained/bin/Xvfb}
	fperms 755 "${dir}"/plugins/tailwindcss/server/tailwindcss-language-server


	make_wrapper "${PN}" "${dir}"/bin/"${PN}"
	newicon bin/"${PN}".svg "${PN}".svg
	make_desktop_entry "${PN}" "${SRC_URI_PN} ${PVR}" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-${PN}-inotify-watches.conf" || die
}
