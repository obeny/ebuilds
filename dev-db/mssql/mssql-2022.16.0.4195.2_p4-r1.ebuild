# https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list
# https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022

EAPI=8
inherit unpacker systemd

PLEVEL="${PV##*_p}"
MY_PV="${PV/_p*}"
MY_PV=$(ver_cut 2-5)

#USE="-* minimal sasl ssl" emerge -1 openldap:0/2.5 --buildpkgonly
OPENLDAP_COMPAT_VER="2.5.19-1"

DESCRIPTION="Microsoft SQL RDBMS"
HOMEPAGE="https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-setup"
SRC_URI="
    https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022/pool/main/m/mssql-server/mssql-server_${MY_PV}-${PLEVEL}_amd64.deb
    http://obeny.obeny.net/gentoo_distfiles/openldap-${OPENLDAP_COMPAT_VER}.gpkg.tar
"
S="${WORKDIR}"

LICENSE="MSSQL"
SLOT="0/2022"

KEYWORDS="~amd64"
IUSE="logrotate systemd"

RESTRICT="bindist strip mirror"
QA_PREBUILT="*"

BDEPEND=""
DEPEND="
	sys-process/numactl
	app-crypt/mit-krb5
	sys-auth/sssd

	systemd? (
		sys-apps/systemd
		sys-process/audit
	)
"
RDEPEND="
	acct-user/mssql
	acct-group/mssql

	${DEPEND}
"

PATCHES="
	${FILESDIR}/${PN}-drop_checkinstall.patch
"

src_prepare() {
	default

	# adapt for openrc
	if use !systemd; then
		eapply "${FILESDIR}/${PN}-openrc.patch"
	fi

	# override default log directory
	sed -i -e 's%/var/opt/mssql/log%/var/log/mssql%' opt/mssql/lib/mssql-conf/mssqlconfhelper.py || die "log location update failed!"
	sed -i -e 's%TimeoutSec=30min%Timeoutsec=120%' lib/systemd/system/mssql-server.service || die "SystemD 'TimeoutSec' update failed!"
}

src_install() {
	# Install base files
	insinto /opt/mssql
	doins -r "${S}"/opt/mssql/bin
	chmod 0755 "${D}"/opt/mssql/bin/*

	# Add legacy openldap libraries
	insinto /opt/mssql/lib
	doins -r "${S}"/openldap-"${OPENLDAP_COMPAT_VER}"/image/usr/lib64/lib*.so.*

	# Install files
	insinto /opt/mssql/lib
	doins -r "${S}"/opt/mssql/lib/{*.sfp,*.so*}
	doins -r "${S}"/opt/mssql/lib/loc
	chmod 0755 "${D}"/opt/mssql/lib/*.so*
	insinto /opt/mssql/lib/mssql-conf
	doins -r "${S}"/opt/mssql/lib/mssql-conf/{*.py,*.sh,*.txt}
	doins -r "${S}"/opt/mssql/lib/mssql-conf/loc
	chmod 0755 "${D}"/opt/mssql/lib/mssql-conf/{*.py,*.sh}

	# Create data directories (see: checkinstall.sh)
	keepdir var/opt/mssql/.system
	keepdir var/opt/mssql/data
	keepdir var/log/mssql
	chown -R mssql:mssql "${D}"/var/{opt/mssql,log/mssql}
	chmod 770 "${D}"/var/{opt/mssql,log/mssql}

	if use !systemd; then
		newinitd "${FILESDIR}"/mssql.initd mssql-server
	else
		systemd_newunit "${S}"/lib/systemd/system/mssql-server.service mssql-server.service

	fi

	# Install config
	insinto /etc/mssql
	doins "${FILESDIR}"/mssql.conf
	chown -R mssql:mssql "${D}"/etc/mssql
	chmod -R 770 "${D}"/etc/mssql
	ln -s /etc/mssql/mssql.conf "${D}"/var/opt/mssql/mssql.conf

	if use logrotate; then
		insinto /etc/logrotate.d
		newins "${FILESDIR}/${PN}.logrotate" "${PN}"
	fi
}

pkg_postinst() {
	einfo
	elog "Run following command to configure DB instance:"
	elog "\"/opt/mssql/bin/mssql-conf setup\""
	elog "if this is a new install."
	einfo
}
