EAPI=8

inherit acct-user

DESCRIPTION="User for dev-db/mssql"
ACCT_USER_ID=715
ACCT_USER_GROUPS=( mssql )
ACCT_USER_HOME=/var/opt/mssql
ACCT_USER_HOME_PERMS=0700
ACCT_USER_SHELL=/bin/bash

acct-user_add_deps
