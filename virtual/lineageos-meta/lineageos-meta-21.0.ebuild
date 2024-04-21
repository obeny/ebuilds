EAPI=8

DESCRIPTION="Metapackage to install packages needed to build LineageOS"
HOMEPAGE="http://github.com/obeny/ebuilds"

LICENSE="metapackage"
SLOT="0"
IUSE=""
KEYWORDS="amd64"

RDEPEND="
	dev-vcs/git-lfs

	app-arch/lzop
	app-arch/lzip
	media-gfx/imagemagick
	media-gfx/pngcrush
	sys-process/schedtool

	net-analyzer/netcat
	sys-apps/pv
"
