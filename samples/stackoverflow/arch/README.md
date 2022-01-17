# The best SQL Server for each platform

Make an alias image for Microsoft's SQL Server images. For x64, use SQL Server 2019 because it supports more things like HA. 

For ARM, use SQL Server Edge because SQL Server 2019 doesn't have an ARM image.

* [Linux supported features](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-editions-and-components-2019)
* [Edge supported features](https://docs.microsoft.com/en-us/azure/azure-sql-edge/features)

Add this image to Docker Hub to make builds and deployments simpler.

My notes for pushing to Docker Hub:

```
# build dat
docker buildx build -t dbatools/mssqlbase:latest-amd64 ./amd64
docker buildx build -t dbatools/mssqlbase:latest-arm64 ./arm64

docker push dbatools/mssqlbase:latest-arm64
docker push dbatools/mssqlbase:latest-amd64

# Create manifests that support  multiple architectures
docker manifest create dbatools/mssqlbase:latest --amend dbatools/mssqlbase:latest-amd64 --amend dbatools/mssqlbase:latest-arm64

# view it if you want
docker manifest inspect docker.io/dbatools/mssqlbase:latest

# push out to docker
docker manifest push docker.io/dbatools/mssqlbase:latest --purge
```