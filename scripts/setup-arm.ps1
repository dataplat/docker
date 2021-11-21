# arm doesn't support sqlcmd but it supports powershell!
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Module dbatools

# create a secure string with password "dbatools.IO"
$password = ConvertTo-SecureString -String "dbatools.IO" -AsPlainText -Force

# create a credential with a securestring
$credsa = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sa", $password
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

# add to defaults
$PSDefaultParameterValues["*Dba*:SqlInstance"] = "localhost"
$PSDefaultParameterValues["*Dba*:SqlCredential"] = $cred
$PSDefaultParameterValues["*Dba*:Database"] = "master"

# This likely won't be needed since installing powershell and dbatools takes enough time
try {
    Connect-DbaInstance -SqlCredential $credsa
} catch {
    Start-Sleep 5
}

$PSDefaultParameterValues["*Dba*:ErrorAction"] = "SilentlyContinue"

# create sqladmin login and disable sa
Invoke-DbaQuery -SqlCredential $credsa -File /tmp/create-admin.sql

# rename the server
Invoke-DbaQuery -Query "EXEC sp_dropserver 'buildkitsandbox'"

# if it's the primary server, restore pubs and northwind and create a bunch of objects
if ((Test-Path "/tmp/primary")) {
    Invoke-DbaQuery -Query "EXEC sp_addserver 'dockersql1', local"
    Invoke-DbaQuery -File /tmp/restore-db.sql
    Invoke-DbaQuery -File /tmp/create-objects.sql
    Import-DbaRegServer -SqlInstance localhost -SqlCredential $cred -Path /tmp/cms.regsrvr
} else {
    Invoke-DbaQuery -Query "EXEC sp_addserver 'dockersql2', local"
}

# import the certificate and create endpoint 
Invoke-DbaQuery -File /tmp/create-endpoint.sql