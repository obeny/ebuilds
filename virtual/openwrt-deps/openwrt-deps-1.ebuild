EAPI=8

DESCRIPTION="OpenWRT development dependencies"
HOMEPAGE="http://github.com/obeny/ebuilds"

LICENSE="metapackage"
SLOT="0"
IUSE=""
KEYWORDS="amd64"

RDEPEND="
	dev-embedded/u-boot-tools
	sys-fs/squashfs-tools[lzma]
"
