# dbatools-docker

What an adventure! Seven days ago, I decided to build [our Docker images](https://hub.docker.com/orgs/dbatools/repositories) the proper way, using `docker compose` or `docker build`. 

## How did I do it previously?

Let me say first that the non-proper way I did initially it was more than good enough. I even got kudos from people I think are super cool, like [Steph Locke](https://twitter.com/TheStephLocke/status/1440749918818209793)! So if you are just diving into containers, keep diving in the way that works for you.

The way I did it previously, however, ended up creating a much larger base image than it needed to be, adding about 600MB total. That's because I:

* Pulled a SQL Server 2017 container
* Added a bunch of things, like sample databases such as pubs and Northwind, fake logins, common agent jobs and more
* Tested if they worked with our limited (at the time) Linux support
* Figured out how certificate authentication worked in SQL Server using these Linux containers
* Dropped the things that didn't work as to avoid disappointing people
* Added, tested, and dropped even more things
* Finally got it right after several days
* Committed all of that to the container, resulting in a 600MB container layer
* Pushed it out to Docker Hub then wrote a blog post about it

While this method worked well enough, [Shawn Melton](https://github.com/wsmelton) suggested I do it in a repeatable way using `docker compose`. By that time, however, I'd moved on to  something else and decided to add that task to my todo list.

It stayed there, for four years, until last week when our database certificate expired and our tests started failing. Instead of doing just a quick fix, I figured now was finally a good time to learn Docker Compose 🐳 

## That was fun

I've learned a _ton_ along the way and even added support for platform combinations that didn't exist back in 2017, like SQL Server and ARM.

Here are the highlights of things I learned in the past week:

* You can easily serve multiple architectures under the same tag (`dbatools/sqlinstance:latest`), like x86, x64 and ARM.
* Everything you do on a container before pushing it out to Docker Hub increases the size, including deleting a file because that instruction is kept in a layer. This makes it easy to bloat an image but there are ways around that.
* SQL Server Edge, which runs on ARM systems like Apple M1 and Raspberry pi, doesn't support `sqlcmd` but it does support PowerShell and dbatools!
* [/var/opt/mssql/mssql.conf](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-mssql-conf#mssql-conf-format) is awesome and can replace a lot of manual config settings.
* Using COPY is safer than ADD, but ADD is used a lot in tutorials.
* The last command in a Dockerfile should be an ENTRYPOINT and not a CMD. It makes it easier for end-user to interact in a way that I don't understand just yet.
* `docker-compose` is out and `docker compose` is in
* Environmental variables don't work *inside* the container, so you need to [import them]()
* VOLUMEs are tricky and if you don't do them right, you can end up leaving a lot of garbage for your end-users.

![image](https://user-images.githubusercontent.com/8278033/143769486-78fdb5ce-34a0-4c2a-93bc-eb68addad725.png)


Some of the best resources I found included:

* [Top 20 Dockerfile best practices (sysdig)](https://sysdig.com/blog/Dockerfile-best-practices)
* [Multi-arch build and images, the simple way](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/)

Repos
* [dbafromthecold
/
SqlServerAndContainersGuide](https://github.com/dbafromthecold/SqlServerAndContainersGuide/tree/master/Code/6.DockerCompose/Advanced)
* [twright-msft
/
mssql-node-docker-demo-app](https://github.com/twright-msft/mssql-node-docker-demo-app)
* [jessfraz/Dockerfiles](https://github.com/jessfraz/Dockerfiles)
* [edemaine/kadira-compose](https://github.com/edemaine/kadira-compose)

https://github.com/microsoft/go-sqlcmd/
https://github.com/microsoft/mssql-docker/issues/2
https://github.com/microsoft/mssql-docker/tree/master/linux/preview/examples/mssql-customize

https://stackoverflow.com/a/59485924/2610398

wget https://github.com/microsoft/go-sqlcmd/archive/refs/heads/main.zip
unzip main.zip
pushd /tmp/go-sqlcmd-main
/usr/local/go/bin/go build -o /tmp/sqlcmd ./cmd/sqlcmd
popd
/tmp/sqlcmd


# grab powershell from the dotnet sdk container
# there's no powershell tag yet for arm64
# also how cool is this??
COPY --from=golang:stretch /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"