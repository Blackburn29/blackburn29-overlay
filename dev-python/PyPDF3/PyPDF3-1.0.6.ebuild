# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{8..13} )

inherit distutils-r1

SAMPLE_COMMIT=bedcbe077c4898e1b97c6c6f81d937f5048b4630
DESCRIPTION="Python library to work with PDF files"
HOMEPAGE="
	https://pypi.org/project/PyPDF3/
	https://github.com/sfneal/PyPDF3/
"
SRC_URI="
	https://github.com/sfneal/PyPDF3/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86"
# 150+ tests require network, too many to deselect
PROPERTIES="test_network"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	' 3.8 3.9)
"
BDEPEND="
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# rely on -Werror
	tests/test_utils.py::test_deprecate_no_replacement
	tests/test_workflows.py::test_orientations
)

src_unpack() {
	default
}
