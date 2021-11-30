
# compile sqlcmd using go

The included Dockerfile:

* runs the golang base image that matches your architecture
* clones the microsoft/go-sqlcmd repo
* compiles sqlcmd to /tmp/sqlcmd

Here's how you make it run and copy the resulting sqlcmd file

```
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