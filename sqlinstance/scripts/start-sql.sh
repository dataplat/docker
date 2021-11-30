# load up environment variables
export $(xargs < /tmp/sapassword.env)
export $(xargs < /tmp/sqlcmd.env)
export PATH=$PATH:/opt/mssql-tools/bin

# set the configs
cp /tmp/mssql.conf /var/opt/mssql/mssql.conf

# check for arm64 which does not support sqlcmd
arch=$(lscpu | awk '/Architecture:/{print $2}')
if [ "$arch" = "aarch64" ]; then
    mkdir /opt/mssql-tools /opt/mssql-tools/bin
    cp /tmp/sqlcmd /opt/mssql-tools/bin
    chmod +x /opt/mssql-tools/bin/sqlcmd
fi

# startup, wait for it to finish starting
# then run the setup script
/opt/mssql/bin/sqlservr & sleep 20 & /tmp/configure.sh