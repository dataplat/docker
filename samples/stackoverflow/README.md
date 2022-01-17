# StackOverflow

This Docker compose has three instances -- the first two are the dbatools instances and the third one is a non-customized version of 2019 with a 10 GB StackOverflow database.

## Get started

To get started and see the containers built in real-time, first clone this repo, then build the base images and containers using `docker-compose`. You can also use `docker compose` without the dash if you use Docker Desktop, as explained on '[Difference between "docker compose" and "docker-compose"](https://stackoverflow.com/questions/66514436/difference-between-docker-compose-and-docker-compose).'

```shell
git clone https://www.github.com/potatoqualitee/docker
cd docker\samples\stackoverflow
docker-compose up -d
```

The first time this runs it'll take like 10 minutes, but each subsequent time will be faster.
