# load up environment variables
export $(xargs < /tmp/sapassword.env)

# set the configs
cp /tmp/mssql.conf /var/opt/mssql/mssql.conf 

# check for arm64 which does not support sqlcmd
arch=$(lscpu | awk '/Architecture:/{print $2}')

# startup, wait for it to finish starting
# then run the setup script

if [ "$arch" = "aarch64" ]; then
    /opt/mssql/bin/sqlservr & sleep 10 & /tmp/pwsh /tmp/setup-arm.ps1
 else
    /opt/mssql/bin/sqlservr & sleep 10 & /tmp/setup.sh
fi
