<#
This script helps demonstrate how our images on docker hub are built. 

Some commands, like docker push, require special permissions.
#>

<# 
Clean up! This is super destructive as it will remove all images and containers and volumes. 
You probably don't want to run this.

docker-compose down
"y" | docker system prune -a
"y" | docker volume prune 
"y" | docker builder prune -a

#>
# rebuild the whole thing
docker-compose down
docker builder prune -a -f
docker-compose up --force-recreate --build -d

# Sleep for 10 then import some reg

Start-Sleep 10 
    
# push out to docker hub
docker push dbatools/sqlinstance:latest-amd64
docker push dbatools/sqlinstance2:latest-amd64

docker manifest create dbatools/sqlinstance:latest --amend dbatools/sqlinstance:latest-amd64 --amend dbatools/sqlinstance:latest-arm64
docker manifest create dbatools/sqlinstance2:latest --amend dbatools/sqlinstance2:latest-amd64 --amend dbatools/sqlinstance2:latest-arm64

#docker manifest inspect docker.io/dbatools/sqlinstance:latest
#docker manifest inspect docker.io/dbatools/sqlinstance2:latest

docker manifest push docker.io/dbatools/sqlinstance:latest
docker manifest push docker.io/dbatools/sqlinstance2:latest


# stop and remove the containers and images
docker-compose down
docker image rm --force dbatools/sqlinstance
docker image rm --force dbatools/sqlinstance2
docker image rm --force dbatools/sqlinstance:latest-amd64
docker image rm --force dbatools/sqlinstance2:latest-amd64
# give it a good ol prune again
# "y" | docker system prune -a

<#
    Test to ensure the containers work, 
    as they are expected to work at dbatools.io/docker
#>

# create a shared network
docker network create localnet

# created shared drive
docker volume create shared

# Expose engine and endpoint then setup a shared path for migrations
docker run -p 14333:1433 --volume shared:/shared:z --name mssql1 --network localnet -d dbatools/sqlinstance:latest-amd64
# Expose second engine and endpoint on different port
docker run -p 14334:1433 --volume shared:/shared:z --name mssql2 --network localnet -d dbatools/sqlinstance2:latest-amd64

# --volume shared:/shared:z

Start-Sleep 10

# create a shared network
docker network create localnet

# created shared drive
docker volume create shared

# Expose engine and endpoint then setup a shared path for migrations
docker run -p 14333:1433 --name mssql1 --network localnet --mount 'source=shared,target=/shared' -d dbatools/sqlinstance:latest-amd64
# Expose second engine and endpoint on different port
docker run -p 14334:1433 --name mssql2 --network localnet --mount 'source=shared,target=/shared' -d dbatools/sqlinstance2:latest-amd64

Start-Sleep 10

# create a credential
$password = ConvertTo-SecureString -String dbatools.IO -AsPlainText -Force
$cred = New-Object PSCredential -ArgumentList "sqladmin", $password

$params = @{
    Source                   = "localhost:14333"
    SourceSqlCredential      = $cred
    Destination              = "localhost:14334"
    DestinationSqlCredential = $cred
    BackupRestore            = $true
    SharedPath               = "/shared"
    Exclude                  = "LinkedServers", "Credentials", "BackupDevices"
}

Start-DbaMigration @params | Out-GridView

Get-DbaDatabase | Remove-DbaDatabase -SqlInstance localhost:14334 -SqlCredential $cred -Database Northwind, pubs -Confirm:$false

# setup a powershell splat
$params = @{
    Primary                = "localhost:14333"
    PrimarySqlCredential   = $cred
    Secondary              = "localhost:14334"
    SecondarySqlCredential = $cred
    Name                   = "test-ag"
    Database               = "pubs"
    ClusterType            = "None"
    SeedingMode            = "Automatic"
    FailoverMode           = "Manual"
    Confirm                = $false
}

# execute the command
New-DbaAvailabilityGroup @params


$password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

$PSDefaultParameterValues["*:SqlInstance"] = "localhost"
$PSDefaultParameterValues["*:Source"] = "localhost"
$PSDefaultParameterValues["*:Destination"] = "localhost:14333"
$PSDefaultParameterValues["*:Primary"] = "localhost"
$PSDefaultParameterValues["*:Mirror"] = "localhost:14333"
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

