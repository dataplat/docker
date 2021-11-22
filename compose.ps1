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
# create a credential
$password = ConvertTo-SecureString -String dbatools.IO -AsPlainText -Force
$cred = New-Object PSCredential -ArgumentList "sqladmin", $password

Import-DbaRegServer -SqlInstance localhost -SqlCredential $cred -Path .\sql\cms.regsrvr

# now to commit the images!
$containers = docker container ls --format "{{json .}}" | ConvertFrom-Json

$dockersql1 = $containers | Where-Object Names -eq dockersql1
$dockersql2 = $containers | Where-Object Names -eq dockersql2



docker commit $dockersql1.ID dbatools/sqlinstance:latest-amd64
docker commit $dockersql2.ID dbatools/sqlinstance2:latest-amd64
    
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

# setup two containers and expose ports
docker run -p 1433:1433 --network localnet --name dockersql1 -d dbatools/sqlinstance
docker run -p 14333:1433 --network localnet --name dockersql2 -d dbatools/sqlinstance2

Start-Sleep 10

# create a credential
$password = ConvertTo-SecureString -String dbatools.IO -AsPlainText -Force
$cred = New-Object PSCredential -ArgumentList "sqladmin", $password

# setup a powershell splat
$params = @{
    Primary                = "localhost"
    PrimarySqlCredential   = $cred
    Secondary              = "localhost:14333"
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
