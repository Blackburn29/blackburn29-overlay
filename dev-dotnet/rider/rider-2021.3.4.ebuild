# Copyright 1999-2020 Blake LaFleur <blake.k.lafleur@gmail.com>
# Ebuild script heavily based on the work of bombo82
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils

DESCRIPTION="A cross-platform .NET IDE based on the IntelliJ platform and ReSharper."
HOMEPAGE="https://www.jetbrains.com/rider/"
SRC_URI="https://download-cf.jetbrains.com/rider/JetBrains.Rider-${PV}.tar.gz"

LICENSE="|| ( jetbrains_business-3.1 jetbrains_individual-4.1 jetbrains_education-3.2 jetbrains_classroom-4.1 jetbrains_open_source-4.1 )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CDDL CPL-1.0 GPL-2-with-classpath-exception GPL-3 ISC LGPL-2.1 LGPL-3 MIT MPL-1.1 OFL PSF-2 trilead-ssh UoI-NCSA yFiles yourkit
"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/JetBrains Rider-${PV}"

QA_PREBUILT="opt/${P}/*"

src_prepare() {
	default

	local remove_me=()

	use amd64 || remove_me+=( lib/pty4j-native/linux/x86_64)
	use x86 || remove_me+=( lib/pty4j-native/linux/x86)

	rm -rv "${remove_me[@]}" || die
}

src_install() {
	local dir="/opt/${P}"

	insinto "${dir}"
	doins -r *
	fperms 755 "${dir}"/bin/${PN}.sh

	if use amd64; then
		fperms 755 "${dir}"/bin/fsnotifier
		fperms 755 "${dir}"/lib/ReSharperHost/linux-x64/dotnet/dotnet
	fi
	if use x86; then
		fperms 755 "${dir}"/bin/fsnotifier
	fi

	fperms 755 "${dir}"/jbr/bin/{jaotc,java,javac,jdb,jjs,jrunscript,keytool,pack200,rmid,rmiregistry,serialver,unpack200}

	make_wrapper "${PN}" "${dir}/bin/${PN}.sh"
	newicon "bin/${PN}.svg" "${PN}.svg"
	make_desktop_entry "${PN}" "Rider ${VER}" "${PN}" "Development;IDE;"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	dodir /usr/lib/sysctl.d/
	echo "fs.inotify.max_user_watches = 524288" > "${D}/usr/lib/sysctl.d/30-${PN}-inotify-watches.conf" || die
}
