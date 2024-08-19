# Copyright 2024 Blake LaFleur <blake.k.lafleur@gmail.com>
# Distributed under the terms of the GNU General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.

EAPI=8

inherit linux-info desktop wrapper

DESCRIPTION="Save time and effort maintaining your IDEs, by downloading a patch or a set of patches instead of the full package download. Everything updates in the background while you never stop coding."
HOMEPAGE="https://www.jetbrains.com/toolbox-app/"

LICENSE="|| ( JetBrains-business JetBrains-educational JetBrains-classroom JetBrains-individual )"

SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror splitdebug"
IUSE="
	dbus
	gtk
"
QA_PREBUILT="opt/${P}/*"
RDEPEND="
	sys-fs/fuse:0
	media-libs/mesa
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
	media-libs/fontconfig
"

CONFIG_CHECK="FUSE_FS"

SRC_URI="https://download.jetbrains.com/toolbox/${PN}-${PV}.tar.gz -> ${P}.tar.gz"

src_unpack() {
	cp "${DISTDIR}"/${P}.tar.gz "${WORKDIR}" || die
	mkdir -p "${P}"
	tar xf "${P}".tar.gz --strip-components=1 -C ./"${P}"
	rm -rf "${P}".tar.gz
}

src_install() {
	dobin jetbrains-toolbox

	newicon "${FILESDIR}"/icon.svg "${PN}".svg
	make_desktop_entry "${PN}" "JetBrains Toolbox" "${PN}" "Development;IDE;"
}
