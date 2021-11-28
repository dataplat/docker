
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
