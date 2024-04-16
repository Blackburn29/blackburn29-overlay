# Copyright 2024 Blake LaFleur <blake.k.lafleur@gmail.com>
# Distributed under the terms of the GNU General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.

EAPI=8

inherit linux-info desktop wrapper

DESCRIPTION="Save time and effort maintaining your IDEs, by downloading a patch or a set of patches instead of the full package download. Everything updates in the background while you never stop coding."
HOMEPAGE="https://www.jetbrains.com/toolbox-app/"

LICENSE="
	|| ( jetbrains_business-4.0 jetbrains_individual-4.2 jetbrains_educational-4.0 jetbrains_classroom-4.2 jetbrains_opensource-4.2 )
	Apache-1.1 Apache-2.0 BSD BSD-2 CC0-1.0 CDDL CPL-1.0 GPL-2-with-classpath-exception GPL-3 ISC LGPL-2.1 LGPL-3 MIT MPL-1.1 OFL PSF-2 trilead-ssh UoI-NCSA yFiles yourkit
"

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

SRC_BUILD="30876"
SRC_URI="https://download.jetbrains.com/toolbox/${PN}-${PV}.${SRC_BUILD}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}"/"${P}"."${SRC_BUILD}"


src_install() {
	dobin jetbrains-toolbox

	newicon "${FILESDIR}"/icon.svg "${PN}".svg
	make_desktop_entry "${PN}" "JetBrains Toolbox" "${PN}" "Development;IDE;"
}
