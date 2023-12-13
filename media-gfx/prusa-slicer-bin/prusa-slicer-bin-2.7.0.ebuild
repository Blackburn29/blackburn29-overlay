# Copyright 2023 Blake LaFleur <blake.k.lafleur@gmail.com>
# Distributed under the terms of the GNU General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.

EAPI=8

inherit desktop wrapper

SRC_TIMESTAMP="202311231454"

DESCRIPTION="PrusaSlicer takes 3D models (STL, OBJ, AMF) and converts them into G-code."
HOMEPAGE="https://github.com/prusa3d/PrusaSlicer"

LICENSE="AGPL-3 CC-BY-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gtk"

SRC_URI="https://github.com/prusa3d/PrusaSlicer/releases/download/version_${PVR}/PrusaSlicer-${PVR}+linux-x64-GTK3-${SRC_TIMESTAMP}.tar.bz2 -> ${P}.tar.bz2"

DEPEND=""
RDEPEND="
	${DEPEND}
	media-libs/glu
"
BDEPEND=""

S="${WORKDIR}"
QA_PREBUILT="opt/${P}/*"

src_unpack() {
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
