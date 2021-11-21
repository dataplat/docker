# load up environment variables
export $(xargs < /tmp/sapassword.env)

# set the configs
cp /tmp/mssql.conf /var/opt/mssql/mssql.conf 

# startup, wait for it to finish starting
# then run the setup script

arch=$(lscpu | awk '/Architecture:/{print $2}')
if [ "$arch" = "aarch64" ]; then
    /opt/mssql/bin/sqlservr & sleep 10 & /tmp/setup-arm.sh
 else
    /opt/mssql/bin/sqlservr & sleep 10 & /tmp/setup.sh
fi

# kill the sqlservr process so that it 
# can be started again infinitely by docker
pkill sqlservr