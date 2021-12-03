
# compile sqlcmd using go

The included Dockerfile:

* runs the golang base image that matches your architecture
* clones the microsoft/go-sqlcmd repo
* compiles sqlcmd to /tmp/sqlcmd

A similar method was used to compile `sqlcmd` which is not included in SQL Server Edge ARM64 container, as SQL client tools are not available for ARM.

Note: This method is no longer required for getting sqlcmd on ARM, because ARM is now included in the [go-sqlcmd release](https://github.com/microsoft/go-sqlcmd/releases). Nevertheless, it's an interesting and useful technique.

## get started

Here's how you make it run and copy the resulting sqlcmd file

```
# clone this repo
git clone --depth 1 https://github.com/sqlcollaborative/docker
cd docker/samples/compile-go-sqlcmd

# build the container
docker build -t tempcontainer --no-cache .

# run it interactively to look around
docker run -it tempcontainer

# run it non-interactively
docker run -d --name tempcontainer tempcontainer

# copy a file
docker cp tempcontainer:/tmp/sqlcmd .

# stop and remove your container
docker rm -f tempcontainer
```
