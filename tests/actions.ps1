Describe "Integration Tests" -Tag "IntegrationTests" {
    BeforeAll {
        $password = ConvertTo-SecureString "dbatools.IO" -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "sqladmin", $password

        $PSDefaultParameterValues["*:Primary"] = "localhost"
        $PSDefaultParameterValues["*:Mirror"] = "localhost:14333"
        $PSDefaultParameterValues["*:PrimarySqlCredential"] = $cred
        $PSDefaultParameterValues["*:MirrorSqlCredential"] = $cred
        $PSDefaultParameterValues["*:Confirm"] = $false
        $PSDefaultParameterValues["*:SharedPath"] = "/shared"
        $global:ProgressPreference = "SilentlyContinue"
    }

    It "sets up a mirror" {
        $newdb = New-DbaDatabase
        $params = @{
            Database = $newdb.Name
            Force    = $true
        }

        Invoke-DbaDbMirroring @params | Select-Object -ExpandProperty Status | Should -Be "Success"
        Get-DbaDbMirror | Select-Object -ExpandProperty MirroringPartner | Should -Be "TCP://mssql2:5022"
    }
}