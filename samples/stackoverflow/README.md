# StackOverflow

This Docker compose has three instances -- the first two are the dbatools instances and the third one is a barebones version of 2019 with a 10 GB StackOverflow database.

## Get started

To get started and see the containers built in real-time, first clone this repo, then build the base images and containers using `docker-compose`. You can also use `docker compose` without the dash if you use Docker Desktop, as explained on '[Difference between "docker compose" and "docker-compose"](https://stackoverflow.com/questions/66514436/difference-between-docker-compose-and-docker-compose).'

```shell
git clone https://www.github.com/potatoqualitee/docker
cd docker\samples\stackoverflow
docker-compose up -d
```

The first time this runs it'll take like 10 minutes, but each subsequent time will be faster.

## Logging in

All three instances can be logged into by using the `sqladmin` as the username and `dbatools.IO` as the password.

| Instance   | Port | User databases | SSMS |  dbatools |
|:----------|:-------------|:------|:------|:------|
| mssql1 | 1433 | Northwind, pubs | localhost | localhost |
| mssql2 | 14333 | N/A | localhost,14333 | localhost:14333 or 'localhost,14333' |
| mssql3 | 14334 | StackOverflow | localhost,14334 | localhost:14334 or 'locahost,14334' |

![image](https://user-images.githubusercontent.com/8278033/162917740-96e379fb-541e-4c22-8107-841c4de84767.png)

### PowerShell

```powershell
# Set credential
$cred = Get-Credential sqladmin

# First instance
$server1 = Connect-DbaInstance -SqlInstance localhost -SqlCredential $cred

# Second instance
$server2 = Connect-DbaInstance -SqlInstance localhost:14333 -SqlCredential $cred

# Third instance with StackOverflow Database
$server3 = Connect-DbaInstance -SqlInstance localhost:14334 -SqlCredential $cred
```

### SSMS

![image](https://user-images.githubusercontent.com/8278033/162914519-b8e312fe-8e47-414a-8fe2-6123acf80084.png)

