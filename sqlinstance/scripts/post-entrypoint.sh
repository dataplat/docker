# if an environment variable for newdb exists, create it
if [ -n "${MSSQL_DB+1}" ]; then
    # load up environment variables
    export SQLCMDSERVER=localhost
    export SQLCMDUSER=sqladmin
    export SQLCMDPASSWORD=dbatools.IO
    export PATH=$PATH:/opt/mssql-tools/bin

    # wait for sql to be ready
    for i in {1..30};
    do
        sqlcmd -S localhost -d master -Q "SELECT @@VERSION"
        if [ $? -ne 0 ];then
            sleep 2
        fi
    done

    # create the db if it doesn't exist already
    sqlcmd -S localhost -d master -Q "IF DB_ID (N'${MSSQL_DB}') IS NULL CREATE DATABASE ${MSSQL_DB};"
fi

# keep it going
sleep infinity