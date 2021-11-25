# load up environment variables
export $(xargs < /dbatools-setup/sapassword.env)

# set the configs
cp /dbatools-setup/mssql.conf /var/opt/mssql/mssql.conf 

# check for arm64 which does not support sqlcmd
arch=$(lscpu | awk '/Architecture:/{print $2}')

# startup, wait for it to finish starting
# then run the setup script

if [ "$arch" = "aarch64" ]; then
    /opt/mssql/bin/sqlservr & sleep 10 & /dbatools-setup/setup-arm.sh
 else
    /opt/mssql/bin/sqlservr & sleep 10 & /dbatools-setup/setup.sh
fi

# kill the sqlservr process so that it 
# can be started again infinitely by docker
pkill sqlservr