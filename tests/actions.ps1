Describe "Integration Tests" -Tag "IntegrationTests" {
    BeforeAll {
        $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

        $PSDefaultParameterValues["*:Confirm"] = $false
    }

    It "creates an availability group" {
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
        (New-DbaAvailabilityGroup @params).AvailabilityDatabases.Name | Should -Be "pubs"
    }
    
    It "sets up a mirror" {
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

        Invoke-DbaDbMirroring @params | Select-Object -ExpandProperty Status | Should -Be "Success"
        Get-DbaDbMirror | Select-Object -ExpandProperty MirroringPartner | Should -Be "TCP://mssql2:5022"
    }
}