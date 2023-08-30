# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Pidgen plugin for Amazon Chime"
HOMEPAGE="https://github.com/awslabs/pidgin-chime"
SRC_URI="https://github.com/awslabs/pidgin-chime/archive/v${PVR}.tar.gz} -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="${RDEPEND}"
RDEPEND="
	net-im/purple-events
	net-libs/libsoup
	dev-libs/json-glib
	dev-libs/protobuf-c
"

src_prepare() {
	default
	./autogen.sh
}

src_compile() {
	default
	emake
}
