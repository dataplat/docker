###################################
# Download and extract PowerShell

# Download powershell and extract
wget -qO - https://github.com/PowerShell/PowerShell/releases/download/v7.2.0/powershell-7.2.0-linux-arm64.tar.gz | tar zxvf - -C /dbatools-setup/powershell

# Execute script
/dbatools-setup/powershell/pwsh /dbatools-setup/setup-arm.ps1
