# https://packages.microsoft.com/config/ubuntu/22.04/mssql-server-2022.list
# https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022

EAPI=8
inherit unpacker

PLEVEL="${PV##*_p}"
MY_PV="${PV/_p*}"
MY_PV=$(ver_cut 2-5)

DESCRIPTION="Microsoft SQL RDBMS"
HOMEPAGE="https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-setup"
SRC_URI="https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022/pool/main/m/mssql-server/mssql-server_${MY_PV}-${PLEVEL}_amd64.deb"
S="${WORKDIR}"

LICENSE="MSSQL"
SLOT="0"

KEYWORDS="~amd64"
IUSE="logrotate systemd"

RESTRICT="bindist strip mirror"
QA_PREBUILT="*"

BDEPEND=""
DEPEND="
	sys-process/numactl
	app-crypt/mit-krb5
	sys-auth/sssd

	net-nds/openldap:0/2.5

	systemd? ( sys-apps/systemd )
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
	sed -i -e 's%/var/opt/mssql/log%/var/log/mssql%' opt/mssql/lib/mssql-conf/mssqlconfhelper.py || die "Sed failed!"
}

src_install() {
	# Install base files
	insinto /opt/mssql
	doins -r "${S}"/opt/mssql/bin
	chmod 0755 "${D}"/opt/mssql/bin/*

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
