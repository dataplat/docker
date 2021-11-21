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
try {
    Connect-DbaInstance -SqlCredential $credsa
} catch {
    Start-Sleep 5
}
# create sqladmin password and disable sa
Invoke-DbaQuery -SqlCredential $credsa -File /tmp/create-admin.sql

# rename the server
Invoke-DbaQuery -Query "EXEC sp_dropserver 'buildkitsandbox'"

# import the certificate and create endpoint 
Invoke-DbaQuery -File /tmp/create-endpoint.sql

# if it's the primary server, restore pubs and northwind and create a bunch of objects
if ((Test-Path "/tmp/primary")) {
    Invoke-DbaQuery -Query "EXEC sp_addserver 'dockersql1', local"
    Invoke-DbaQuery -File /tmp/restore-db.sql
    Invoke-DbaQuery -File /tmp/create-objects.sql
} else {
    Invoke-DbaQuery -Query "EXEC sp_addserver 'dockersql2', local"
}