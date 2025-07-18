# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake udev linux-info

DESCRIPTION="Provides library functionality for FIDO 2.0"
HOMEPAGE="https://github.com/Yubico/libfido2"
SRC_URI="https://github.com/Yubico/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0/1"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~m68k ~mips ppc ~ppc64 ~riscv ~s390 ~sparc x86"
IUSE="hidapi nfc smartcard static-libs test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/libcbor:=
	dev-libs/openssl:=
	sys-libs/zlib:=
	virtual/libudev:=
	hidapi? ( dev-libs/hidapi )
	smartcard? ( sys-apps/pcsc-lite )
"
RDEPEND="
	${DEPEND}
	acct-group/plugdev
"
BDEPEND="app-text/mandoc"

PATCHES=(
	"${FILESDIR}"/${PN}-1.12.0-cmakelists.patch
)

pkg_pretend() {
	CONFIG_CHECK="
		~USB_HID
		~HIDRAW
	"

	check_extra_config
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_EXAMPLES=OFF
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DBUILD_TESTS=$(usex test)
		-DNFC_LINUX=$(usex nfc)
		-DUSE_PCSC=$(usex smartcard)
		-DUSE_HIDAPI=$(usex hidapi)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	udev_newrules udev/70-u2f.rules 70-libfido2-u2f.rules
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
