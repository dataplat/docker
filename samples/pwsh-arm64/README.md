
# run pwsh in an arm64 container

PowerShell does not yet have an arm64 tag for `mcr.microsoft.com/powershell`. To use PowerShell on your Apple M1 or Raspberry Pi, you can build this project.

The included Dockerfile:

* grabs a minimal dotnet container as the base
* copies just pwsh from the larger sdk image

Here's how to get started:

```
# clone this repo
git clone --depth 1 https://github.com/sqlcollaborative/docker
cd docker/samples/pwsh-arm64

# build the container
docker build -t pwsh .

# run it interactively to look around
# remove the container once you're done
docker run -it pwsh -rm
```