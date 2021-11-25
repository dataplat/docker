
# rebuild the whole thing
docker-compose down
docker builder prune -a -f
docker-compose up --force-recreate --build -d

# create a shared network
docker network create localnet

# created shared drive
docker volume create shared

# Expose engine and endpoint then setup a shared path for migrations
docker run -p 14333:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 --network localnet -d dbatools/sqlinstance
# Expose second engine and endpoint on different port
docker run -p 14334:1433 --volume shared:/shared:z --name mssql2 --hostname mssql2 --network localnet -d dbatools/sqlinstance2

docker exec -it mssql1 ls -l /

Start-Sleep 10

$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

$PSDefaultParameterValues["*:SqlInstance"] = "localhost:14333"
$PSDefaultParameterValues["*:Source"] = "localhost:14333"
$PSDefaultParameterValues["*:Destination"] = "localhost:14334"
$PSDefaultParameterValues["*:Primary"] = "localhost:14333"
$PSDefaultParameterValues["*:Mirror"] = "localhost:14334"
$PSDefaultParameterValues["*:SqlCredential"] = $cred
$PSDefaultParameterValues["*:SourceSqlCredential"] = $cred
$PSDefaultParameterValues["*:DestinationSqlCredential"] = $cred
$PSDefaultParameterValues["*:PrimarySqlCredential"] = $cred
$PSDefaultParameterValues["*:MirrorSqlCredential"] = $cred
$PSDefaultParameterValues["*:WitnessSqlCredential"] = $cred
$PSDefaultParameterValues["*:Confirm"] = $false
$PSDefaultParameterValues["*:SharedPath"] = "/shared"

$newdb = New-DbaDatabase
$params = @{
    Database = $newdb.Name
    Force    = $true
}

Invoke-DbaDbMirroring @params

