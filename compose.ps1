<#
This script helps demonstrate how our images on docker hub are built. 

Some commands, like docker push, require special permissions.

# Clean up!
This is super destructive as it will remove all images and containers and volumes. You probably don't want to run this.

docker-compose down
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker rmi $(docker images -q)
"y" | docker system prune -a
"y" | docker volume prune 
"y" | docker builder prune -a

#>
# rebuild the whole thing with no caches

docker-compose down
docker volume prune -f
docker image prune -f
docker builder prune -a -f
docker-compose up --force-recreate --build --remove-orphans -d
    
# push out to docker hub
docker push dbatools/sqlinstance:latest-amd64
docker push dbatools/sqlinstance2:latest-amd64

# Remove manifest cache
Remove-Item $HOME/.docker/manifests -Recurse -Force

# Create manifests that support  multiple architectures
docker manifest create dbatools/sqlinstance:latest --amend dbatools/sqlinstance:latest-amd64 --amend dbatools/sqlinstance:latest-arm64
docker manifest create dbatools/sqlinstance2:latest --amend dbatools/sqlinstance2:latest-amd64 --amend dbatools/sqlinstance2:latest-arm64

# view it if you want
docker manifest inspect docker.io/dbatools/sqlinstance:latest
docker manifest inspect docker.io/dbatools/sqlinstance2:latest

# push out to docker
docker manifest push docker.io/dbatools/sqlinstance:latest --purge
docker manifest push docker.io/dbatools/sqlinstance2:latest --purge
