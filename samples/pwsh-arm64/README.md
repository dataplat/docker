
# run pwsh in an arm64 container

The included Dockerfile:

* grabs a minimal dotnet container as the base
* copies just pwsh from the larger sdk image

Here's how to get started:

```
# clone this repo
git clone --depth 1 https://github.com/sqlcollaborative/docker
cd docker/samples/pwsh-arm64

# build the container
docker build -t pwsh --no-cache .

# run it interactively to look around
# remove the container once you're done
docker run -it pwsh -rm
```