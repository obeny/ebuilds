EAPI=8

inherit desktop

DESCRIPTION="A mesh slicer to generate G-code for fused-filament-fabrication (3D printers)"
HOMEPAGE="https://github.com/supermerill/SuperSlicer/"
SRC_URI="
	https://github.com/supermerill/SuperSlicer/releases/download/${PV}/SuperSlicer_${PV}_linux64_240701.tar.zip
"

LICENSE="AGPL-3 Boost-1.0 GPL-2 LGPL-3 MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="strip"
QA_PREBUILT="*"

src_unpack() {
	default

	tar xf SuperSlicer*.tar || die
	rm -f SuperSlicer*.tar

	mkdir "${S}" || die
	mv ./{bin,resources,superslicer} "${S}" || die
}

src_install() {
	dodir "/opt"
	cp -R "${S}/" "${D}/opt" || die "Install failed!"
	
	# fix .desktop exec location
	sed --expression "/^Exec=/s:@SLIC3R_APP_CMD@:/opt/${PN}-${PV}/bin/superslicer:" "${FILESDIR}/Slic3r.desktop.in" > SuperSlicer.desktop ||
		die "fixing of exec location on .desktop failed"

	# fix .desktop icon location
	sed --in-place --expression "/^Icon=/s:@SLIC3R_APP_KEY@:/opt/${PN}-${PV}/SuperSlicer.png:" SuperSlicer.desktop ||
		die "fixing of exec location on .desktop failed"

	domenu SuperSlicer.desktop

	insinto "/opt/${PN}-${PV}"
	newins "${FILESDIR}/SuperSlicer.png" SuperSlicer.png
}
