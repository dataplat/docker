# run the setup script to create the DB and the schema in the DB
# do this in a loop because the timing for when the SQL instance is ready is indeterminate
for i in {1..50};
do
    sqlcmd -d master -Q "SELECT @@VERSION"
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
sqlcmd -d master -i /tmp/create-admin.sql

export SQLCMDUSER=sqladmin

# rename the server
sqlcmd -d master -Q "EXEC sp_dropserver 'buildkitsandbox'"

# if it's the primary server, restore pubs and northwind and create a bunch of objects
if [ -f "/tmp/primary" ]; then
    sqlcmd -d master -Q "EXEC sp_addserver 'mssql1', local"
    sqlcmd -d master -i /tmp/restore-db.sql
    sqlcmd -d master -i /tmp/create-objects.sql
    sqlcmd -d master -i /tmp/create-regserver.sql
else
    sqlcmd -d master -Q "EXEC sp_addserver 'mssql2', local"
fi

# import the certificate and create endpoint 
sqlcmd -d master -i /tmp/create-endpoint.sql