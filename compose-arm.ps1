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
docker-compose -f ./docker-compose-arm.yml up --force-recreate --build -d

# now to commit the images!
$containers = docker container ls --format "{{json .}}" | ConvertFrom-Json

$dockersql1 = $containers | Where-Object Names -eq dockersql1
$dockersql2 = $containers | Where-Object Names -eq dockersql2

docker commit $dockersql1.ID dbatools/sqlinstance:latest-arm64
docker commit $dockersql2.ID dbatools/sqlinstance2:latest-arm64

# push out to docker hub
docker push dbatools/sqlinstance:latest-arm64
docker push dbatools/sqlinstance2:latest-arm64

# Create manifests that support  multiple architectures
docker manifest create dbatools/sqlinstance:latest --amend dbatools/sqlinstance:latest-amd64 --amend dbatools/sqlinstance:latest-arm64
docker manifest create dbatools/sqlinstance2:latest --amend dbatools/sqlinstance2:latest-amd64 --amend dbatools/sqlinstance2:latest-arm64

# view it if you want
# docker manifest inspect docker.io/dbatools/sqlinstance:latest
# docker manifest inspect docker.io/dbatools/sqlinstance2:latest

# push out to docker!
docker manifest push docker.io/dbatools/sqlinstance:latest
docker manifest push docker.io/dbatools/sqlinstance2:latest

# stop and remove the containers and images
docker-compose down
docker image rm --force dbatools/sqlinstance
docker image rm --force dbatools/sqlinstance2
docker image rm --force dbatools/sqlinstance:latest-arm64
docker image rm --force dbatools/sqlinstance2:latest-arm64
# give it a good ol prune again
# "y" | docker system prune -a

<#
    Test to ensure the containers work
#>

# Create network for nodes to talk to each other
docker network create localnet

# Expose engine and endpoint then setup a shared path for migrations
docker run -p 1433:1433 --volume /tmp:/sharedpath --network localnet --hostname dockersql1 --name dockersql1 -d dbatools/sqlinstance
# Expose second engine and endpoint on different port
docker run -p 14333:1433 --volume /tmp:/sharedpath  --network localnet --hostname dockersql2 --name dockersql2 -d dbatools/sqlinstance2

# let it finish starting
Start-Sleep 10

$params = @{
    Source                   = "localhost"
    SourceSqlCredential      = $cred
    Destination              = "localhost:14333"
    DestinationSqlCredential = $cred
    BackupRestore            = $true
    SharedPath               = "/sharedpath"
    Exclude                  = "LinkedServers", "Credentials", "CentralManagementServer", "BackupDevices"
}

Start-DbaMigration @params