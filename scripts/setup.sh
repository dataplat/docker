# run the setup script to create the DB and the schema in the DB
# do this in a loop because the timing for when the SQL instance is ready is indeterminate
for i in {1..50};
do
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P dbatools.IO -d master -Q "SELECT @@VERSION"
    if [ $? -eq 0 ]
    then
        echo "ready.."
        break
    else
        echo "not ready yet..."
        sleep 1
    fi
done

# create sqladmin password and disable sa
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P dbatools.IO -d master -i /app/create-admin.sql

# rename the server
/opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -Q "EXEC sp_dropserver 'buildkitsandbox'"

# if it's the primary server, restore pubs and northwind and create a bunch of objects
if [ -f "/app/primary" ]; then
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -Q "EXEC sp_addserver 'mssql1', local"
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -i /app/restore-db.sql
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -i /app/create-objects.sql
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -i /app/create-regserver.sql
else
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -Q "EXEC sp_addserver 'mssql2', local"
fi

# import the certificate and create endpoint 
/opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -i /app/create-endpoint.sql