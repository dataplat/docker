
# create a credential
$password = ConvertTo-SecureString -String dbatools.IO -AsPlainText -Force
$cred = New-Object PSCredential -ArgumentList "sqladmin", $password

$params = @{
    Source                   = "localhost"
    SourceSqlCredential      = $cred
    Destination              = "localhost:14333"
    DestinationSqlCredential = $cred
    BackupRestore            = $true
    SharedPath               = "/shared"
    Exclude                  = "LinkedServers", "Credentials", "BackupDevices"
}

Start-DbaMigration @params

$PSDefaultParameterValues['*:EnableException'] = $true

Remove-DbaDatabase -SqlInstance localhost:14333 -SqlCredential $cred -Database Northwind, pubs -Confirm:$false

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

if (-not $isMacOS) {
    # execute the command
    New-DbaAvailabilityGroup @params
}

# Test mirroring
$newdb = New-DbaDatabase -SqlInstance localhost -SqlCredential $cred

$params = @{
    Primary              = "localhost"
    PrimarySqlCredential = $cred
    Mirror               = "localhost:14333"
    MirrorSqlCredential  = $cred
    Database             = $newdb.Name
    SharedPath           = "/shared"
    Force                = $true
    Verbose              = $false
}

Invoke-DbaDbMirroring @params


# stop and remove the containers and images
docker compose down
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
"y" | docker system prune -a
"y" | docker volume prune 

<#
    Test to ensure the containers work, 
    as they are expected to work at dbatools.io/docker
#>

# create a shared network
docker network create localnet

# Expose engine then setup a shared path for migrations
docker run -p 1433:1433 --volume shared:/shared:z --hostname mssql1 --name mssql1 --network localnet -d dbatools/sqlinstance

# Expose second engine on different port and use the same shared path
docker run -p 14333:1433 --volume shared:/shared:z --hostname mssql2 --name mssql2 --network localnet -d dbatools/sqlinstance2

Start-Sleep 10

# create a credential
$password = ConvertTo-SecureString -String dbatools.IO -AsPlainText -Force
$cred = New-Object PSCredential -ArgumentList "sqladmin", $password

$params = @{
    Source                   = "localhost"
    SourceSqlCredential      = $cred
    Destination              = "localhost:14333"
    DestinationSqlCredential = $cred
    BackupRestore            = $true
    SharedPath               = "/shared"
    Exclude                  = "LinkedServers", "Credentials", "BackupDevices"
}

Start-DbaMigration @params | Out-GridView

Remove-DbaDatabase -SqlInstance localhost:14333 -SqlCredential $cred -Database Northwind, pubs -Confirm:$false

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

# Test mirroring
$newdb = New-DbaDatabase -SqlInstance localhost -SqlCredential $cred

$params = @{
    Primary              = "localhost"
    PrimarySqlCredential = $cred
    Mirror               = "localhost:14333"
    MirrorSqlCredential  = $cred
    Database             = $newdb.Name
    SharedPath           = "/shared"
    Force                = $true
    Verbose              = $false
}

Invoke-DbaDbMirroring @params
