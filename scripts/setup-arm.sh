###################################
# Download and extract PowerShell

# Grab the latest tar.gz
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.0/powershell-7.2.0-linux-arm64.tar.gz

# Make folder to put powershell
mkdir /tmp/powershell

# Unpack the tar.gz file
tar -xvf ./powershell-7.2.0-linux-arm64.tar.gz -C /tmp/powershell

# Start PowerShell
/tmp/powershell/pwsh /tmp/setup-arm.ps1
