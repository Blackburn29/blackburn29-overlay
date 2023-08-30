# Copyright 2022 Blake LaFleur <blake.k.lafleur@gmail.com>
# Distributed under the terms of the GNU General Public License as published by the Free Software Foundation;
# either version 2 of the License, or (at your option) any later version.

EAPI=8

inherit desktop eutils

DESCRIPTION="The Universal Driver package and toolset for printing on Kyocera-based printers"
HOMEPAGE="hyoceradocumentsolutions.co.uk"
SRC_URI="https://www.kyoceradocumentsolutions.co.uk/content/download-center/gb/drivers/all/Linux_Universal_Driver_zip.download.zip"

LICENSE="GPL-2 kyocera-mita-ppds"
SLOT="0"
KEYWORDS="~amd64"
IUSE="-gui"

DEPEND=""
RDEPEND="net-print/cups
	net-print/cups-filters
	dev-python/PyPDF3
	dev-python/reportlab"

BDEPEND=""

S="${WORKDIR}"

PPD_DIRECTORY=usr/share/cups/model/kyocera
FILTER_DIRECTORY=usr/lib/cups/filter

src_prepare() {
	default

	local revision=$(echo $PR | cut -c 2-)
	tar -xvf "KyoceraLinuxPackages-${revision}.tar.gz" "Debian/Global/kyodialog_amd64/kyodialog_${PV}-0_amd64.deb" --strip-components=3
	ar x "kyodialog_${PV}-0_amd64.deb"
	rm "kyodialog_${PV}-0_amd64.deb"

	tar -xvf data.tar.gz
	tar -xvf control.tar.gz
	rm -rf *.gz

	local remove_me=( "usr/share/kyocera${PV}/Python" "etc/" "conffiles" "debian-binary" "md5sums" "postrm" "postinst" "preinst" "control" )

	if ! use gui ; then
		remove_me+=( "usr/bin/knmd" "usr/bin/kyodialog${PV}" "usr/share/applications" "usr/share/doc" )
	fi

	rm -rv "${remove_me[@]}" || die

	mkdir -p $PPD_DIRECTORY
	mv usr/share/kyocera"${PV}"/ppd"${PV}"/*.ppd $PPD_DIRECTORY
	rm -rv usr/share/kyocera*
}

src_install() {
	doins -r *

	if use gui ; then
		chmod 755 "${D}""/usr/bin/kyodialog${PV}"
	fi

	chmod 755 "${D}"/usr/bin/kyoPPDWrite_H
	chmod 755 "${D}"/"$FILTER_DIRECTORY"/*
}
