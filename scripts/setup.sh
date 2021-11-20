#run the setup script to create the DB and the schema in the DB
#do this in a loop because the timing for when the SQL instance is ready is indeterminate
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

/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P dbatools.IO -d master -i /tmp/create-admin.sql

if [ -f "/tmp/primary" ]; then
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -i /tmp/restore-db.sql
    /opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -i /tmp/create-objects.sql
fi

/opt/mssql-tools/bin/sqlcmd -S localhost -U sqladmin -P dbatools.IO -d master -i /tmp/create-endpoint.sql

