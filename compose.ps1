docker-compose down; docker-compose up --build -d
"y" | docker system prune -a
"y" | docker volume prune 

$containers = docker container ls --format "{{json .}}" | ConvertFrom-Json

$dockersql1 = $containers | Where-Object Names -eq dockersql1
$dockersql2 = $containers | Where-Object Names -eq dockersql2

docker commit $dockersql1.ID dbatools/sqlinstance
docker commit $dockersql2.ID dbatools/sqlinstance2

docker-compose down

# create a shared network
docker network create localnet

# setup two containers and expose ports
docker run -p 1433:1433 -p 5022:5022 --network localnet --hostname dockersql1 --name dockersql1 -d dbatools/sqlinstance
docker run -p 14333:1433 -p 5023:5023  --network localnet --hostname dockersql2 --name dockersql2 -d dbatools/sqlinstance2


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
