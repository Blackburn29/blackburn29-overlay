# Copyright 2020 Blake LaFleur <blake.k.lafleur@gmail.com>
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop eutils

DESCRIPTION="PrusaSlicer takes 3D models (STL, OBJ, AMF) and converts them into G-code."
HOMEPAGE="https://github.com/prusa3d/PrusaSlicer"
SRC_URI="https://github.com/prusa3d/PrusaSlicer/releases/download/version_2.4.0/PrusaSlicer-2.4.0+linux-x64-202112211614.tar.bz2 -> ${P}.tar.bz2"

LICENSE="AGPL-3 CC-BY-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}"
QA_PREBUILT="opt/${P}/*"

src_unpack() {
	#tar -xf "${P}.tar.bz2" --strip-components=1
	unpack ${A}
	mv Prusa*/* . && rm -rf PrusaSlicer*/
}

src_install() {
	local dir="/opt/${P}"
	insinto "${dir}"
	doins -r *

	fperms 755 "${dir}/bin/prusa-slicer"

	make_wrapper "${PN}"  "${dir}/bin/prusa-slicer"
	newicon "resources/icons/PrusaSlicer_128px.png" "${PN}.png"
	make_desktop_entry "${PN}" "Prusa Slicer ${VER}" "${PN}" "Graphics;3DGraphics"
}
