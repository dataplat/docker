# load up environment variables
export $(xargs < /tmp/sapassword.env)
export $(xargs < /tmp/sqlcmd.env)
export PATH=$PATH:/opt/mssql-tools/bin

# set the configs
cp /tmp/mssql.conf /var/opt/mssql/mssql.conf

# startup, wait for it to finish starting
# then run the setup script
/opt/mssql/bin/sqlservr & sleep 20 & /tmp/configure.sh