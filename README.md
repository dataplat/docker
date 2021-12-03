# docker

This repo holds the Docker compose code that was used to create the images featured on [dbatools.io/docker](https://dbatools.io/docker). 

It's intended not only to help test out dbatools, but to also explore the creation of SQL Server-based containers for your own environment. The compose code is heavily commented and the repo is a work in progress as I'm also learning. Suggestions for improvement are welcome!

To read about the things I learned while creating these containers, along with tips and tricks, [visit the wiki](https://github.com/potatoqualitee/docker/wiki).

## Get started

To get started and see the containers built in real-time, first clone this repo, then build the base images and containers using `docker-compose`. You can also use `docker compose` without the dash if you use Docker Desktop, as explained on '[Difference between "docker compose" and "docker-compose"](https://stackoverflow.com/questions/66514436/difference-between-docker-compose-and-docker-compose).'

```shell
git clone https://www.github.com/potatoqualitee/docker
cd docker\sqlinstance
docker-compose up -d
```

This will pull the SQL Server images from Microsoft's repo, then add a bunch of test objects (databases, logins, jobs, etc) using bash and sql files in this repo, and then make them available for you to connect to on the default port 1433 for the first instance and port 14333 for the second instance.

Note:  If you're using ARM architecture (Apple M1 or Raspberry Pi), none of the High Availability commands will work, as ARM is only supported by SQL Edge, which is limited.

## Time to play 🎉

Now we are setup to test commands against your two containers! You can login via [SQL Server Management Studio](https://sqlps.io/dl) or [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download?view=sql-server-2017) if you’d like to take a look first. The server name is `localhost` for the first instance and `localhost,14333` for the second instance), the username is `sqladmin` and the password is `dbatools.IO`

![image](https://user-images.githubusercontent.com/8278033/142866226-35a5113b-4297-4e66-9c32-4d02e2f0a0d0.png)

Note that dbatools supports both using commas and colons to designate a port. When you use a comma, however, you must also use quotes: `'localhost,14333'`. When using dbatools, we recommend just using `localhost:14333`.

```powershell
$cred = Get-Credential sqladmin
Connect-DbaInstance -SqlInstance localhost, localhost:14333 -SqlCredential $cred
```
If you'd like to test more commands, check out [dbatools and docker (updated!)](https://dbatools.io/docker)

To stop the containers, run the following command in the docker\sqlinstance directory:

```shell
docker compose down
```

And if you'd like to remove the persisent volume it created for the containers to share data, use `--volumes`

```shell
docker compose down --volumes
```

## Remove everything

If you want to uninstall, or start from a "clean" installation, docker compose can remove all the containers and volumes in one command.

```shell
docker builder prune -a -f
docker compose down --remove-orphans --volumes
docker rmi $(docker images -q "dbatools\/*")
```

## Resources

Some of the best resources I found included:

* [Top 20 Dockerfile best practices (sysdig)](https://sysdig.com/blog/Dockerfile-best-practices)
* [Multi-arch build and images, the simple way](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/)

Repos
* [dbafromthecold/SqlServerAndContainersGuide](https://github.com/dbafromthecold/SqlServerAndContainersGuide/tree/master/Code/6.DockerCompose/Advanced)
* [twright-msft/mssql-node-docker-demo-app](https://github.com/twright-msft/mssql-node-docker-demo-app)
* [jessfraz/Dockerfiles](https://github.com/jessfraz/Dockerfiles)
* [edemaine/kadira-compose](https://github.com/edemaine/kadira-compose)
* [vicrem/mssql](https://github.com/vicrem/mssql/blob/master/docker-compose.yml)
* [microsoft/go-sqlcmd](https://github.com/microsoft/go-sqlcmd/)
* [microsoft/mssql-docker](https://github.com/microsoft/mssql-docker/tree/master/linux/preview/examples/mssql-customize)

