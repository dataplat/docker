###################################
# Download and extract PowerShell

# Grab the latest tar.gz
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.0/powershell-7.2.0-linux-arm64.tar.gz

# Make folder to put powershell
mkdir /app/powershell

# Unpack the tar.gz file
tar -xvf ./powershell-7.2.0-linux-arm64.tar.gz -C /app/powershell

# Execute script
/app/powershell/pwsh /app/setup-arm.ps1
