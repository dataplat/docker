Describe "Integration Tests" -Tag "IntegrationTests" {
    BeforeAll {
        $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

        $PSDefaultParameterValues["*:Confirm"] = $false
    }

    It "creates migrates from one instance to another" {
        $params = @{
            Source                   = "localhost"
            SourceSqlCredential      = $cred
            Destination              = "localhost:14333"
            DestinationSqlCredential = $cred
            BackupRestore            = $true
            SharedPath               = "/shared"
            Exclude                  = "LinkedServers", "Credentials", "BackupDevices", "ExtendedEvents"
            Force                    = $true
        }

        $results = Start-DbaMigration @params
        $results.Name | Should -Contain "Northwind"
        $results | Where-Object Name -eq "Northwind" | Select-Object -ExpandProperty Status | Should -Be "Successful"
    }
}