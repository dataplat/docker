# Update package lists
apt-get update

# Install libunwind8 and libssl1.0
# Regex is used to ensure that we do not install libssl1.0-dev, as it is a variant that is not required
apt-get install '^libssl1.0.[0-9]$' libunwind8 -y

###################################
# Download and extract PowerShell

# Grab the latest tar.gz
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.0/powershell-7.2.0-linux-arm32.tar.gz

# Make folder to put powershell
mkdir /bin/powershell

# Unpack the tar.gz file
tar -xvf ./powershell-7.2.0-linux-arm32.tar.gz -C /bin/powershell

# Start PowerShell
/bin/powershell/pwsh /tmp/setup-arm.ps1