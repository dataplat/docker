# load up environment variables
export $(xargs < /tmp/sqlserver.env)

# startup, wait for it to finish starting, then run the setup script
/opt/mssql/bin/sqlservr & sleep 10 & /tmp/setup.sh

# kill the sqlservr process so that it can be started again infinitely by docker
# systemctl restart mssql-server.service not available
pkill sqlservr