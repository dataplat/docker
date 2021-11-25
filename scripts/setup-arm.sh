###################################
# Download and extract PowerShell

# Grab the latest tar.gz
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.0/powershell-7.2.0-linux-arm64.tar.gz

# Make folder to put powershell
mkdir /dbatools-setup/powershell

# Unpack the tar.gz file
tar -xvf ./powershell-7.2.0-linux-arm64.tar.gz -C /dbatools-setup/powershell

# Execute script
/dbatools-setup/powershell/pwsh /dbatools-setup/setup-arm.ps1
