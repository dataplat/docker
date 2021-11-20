# create the mssql user
useradd -u 10001 mssql
 
# installing SQL Server
apt-get update && apt-get install -y wget software-properties-common apt-transport-https
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2019.list)"
apt-get update && apt-get install -y mssql-server
 
# creating directories
mkdir /var/opt/sqlserver
mkdir /var/opt/sqlserver/data
mkdir /var/opt/sqlserver/log
mkdir /var/opt/sqlserver/backup
 
# set permissions on directories
chown -R mssql:mssql /var/opt/sqlserver
chown -R mssql:mssql /var/opt/mssql

# installing SQL Server
add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/18.04/prod.list)"
apt-get update
ACCEPT_EULA=Y apt-get install -y mssql-server mssql-tools unixodbc-dev

# enable agent and HA
/opt/mssql/bin/mssql-conf set sqlagent.enabled true
/opt/mssql/bin/mssql-conf set hadr.hadrenabled  1