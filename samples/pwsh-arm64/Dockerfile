# Make the base image the smaller 200MB image
FROM mcr.microsoft.com/dotnet/nightly/runtime:3.1-bionic-arm64v8

# Copy just what you need from the big SDK image
COPY --from=mcr.microsoft.com/dotnet/sdk:3.1-bionic-arm64v8 /usr/share/powershell /bin

# run powershell
ENTRYPOINT pwsh