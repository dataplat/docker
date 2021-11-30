# from image passed in Dockerfile (either arm or x64)
ARG IMAGE

# ARM doesn't yet support sqlcmd, so we need to build it
# start with the golang base image which will be discarded
# later in the build process
FROM golang as sqlcmdbuilder

# clone the go-sqlcmd repo
RUN git clone --depth 1 https://github.com/microsoft/go-sqlcmd

# change directories and compile sqlcmd to /tmp/sqlcmd
RUN cd go-sqlcmd && go build -o /tmp/sqlcmd ./cmd/sqlcmd

# Moving on...
# get the latest SQL container and set it as the builder image
FROM $IMAGE as builder

# copy sqlcmd from the golang builder image
COPY --from=sqlcmdbuilder /tmp /tmp

# add an argument that will later help designate the stocked sql server
ARG PRIMARYSQL

# switch to root to a bunch of stuff that requires elevated privs
USER root

# copy scripts and make bash files executable
# also create a shared directory and make it writable by mssql
WORKDIR /tmp
RUN chown mssql /tmp

# use copy instead of add, it's safer apparently
COPY sql scripts /tmp/
RUN chmod +x /tmp/*.sh

# convert CRLF to LF in case Windows or VS Code changed it
RUN find . -type f \( -name "*.sql" -o -name "*.env" -o -name "*.sh" \) -exec sed -i 's/\r$//' {} \;

# write a file that designates the primary server
# this is used in a later step to load up the server
RUN if [ $PRIMARYSQL ]; then touch /tmp/primary; fi

# switch to user mssql or the container will fail
USER mssql

# run initial setup scripts
RUN /bin/bash /tmp/start-sql.sh

# discard all that builder data then just copy the required changed files from "builder"
FROM $IMAGE
COPY --from=builder /var/opt/mssql /var/opt/mssql
COPY --from=builder /opt/mssql-tools/bin /opt/mssql-tools/bin

# label the container
LABEL org.opencontainers.image.vendor="dbatools"
LABEL org.opencontainers.image.title="dbatools"
LABEL org.opencontainers.image.url=https://dbatools.io/docker
LABEL org.opencontainers.image.version=1.0
LABEL org.label-schema.description="SQL Server instances with a sample objects, including Northwind and pubs. Ideal for test migrations."
LABEL org.opencontainers.image.authors="Chrissy LeMaire <clemaire@dbatools.io>"
LABEL org.opencontainers.image.documentation=https://github.com/potatoqualitee/docker/blob/main/README.md
LABEL org.opencontainers.image.source=https://github.com/potatoqualitee/docker

# make a shared dir with the proper permissions
USER root
RUN  mkdir /shared; chown mssql /shared

# run a rootless container
USER mssql
ENTRYPOINT /opt/mssql/bin/sqlservr