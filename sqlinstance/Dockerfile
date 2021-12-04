###
#
#   temp/builder image: add users, logins, databases, etc
#
###

# get the latest SQL container and set it as the builder image
FROM dbatools/mssqlbase as builder

# designate the stocked sql server
ARG PRIMARYSQL

# switch to root to a bunch of stuff that requires elevated privs
USER root

# set the pwd and chown to the service account
WORKDIR /tmp
RUN chown mssql /tmp

# copy scripts and make bash files executable
# use copy instead of add, it's safer apparently
COPY sql scripts /tmp/
RUN chmod +x /tmp/*.sh

# convert CRLF to LF in case Windows or VS Code changed it
RUN find . -type f \( -name "*.sql" -o -name "*.env" -o -name "*.sh" \) -exec sed -i 's/\r$//' {} \;

# write a file that designates the primary server
RUN if [ $PRIMARYSQL ]; then touch /tmp/primary; fi

# switch to user mssql or the container will fail
USER mssql

# run initial setup scripts
RUN /bin/bash /tmp/start-sql.sh

###
#
#   final image: grab the good stuff, label
#   the image, and startup the sql instance
#
###

# copy the required changed files from "builder"
# and use it to start from scratch
FROM dbatools/mssqlbase
COPY --from=builder /var/opt/mssql /var/opt/mssql
COPY --from=builder /opt/mssql-tools/bin /opt/mssql-tools/bin

# make a shared dir with the proper permissions
USER root
RUN  mkdir /shared; chown mssql /shared

# run a rootless container
USER mssql
ENTRYPOINT /opt/mssql/bin/sqlservr

# label the container
LABEL org.opencontainers.image.vendor="dbatools"
LABEL org.opencontainers.image.title="dbatools"
LABEL org.opencontainers.image.url=https://dbatools.io/docker
LABEL org.opencontainers.image.version=1.0
LABEL org.label-schema.description="SQL Server instances with a sample objects, including Northwind and pubs. Ideal for test migrations."
LABEL org.opencontainers.image.authors="Chrissy LeMaire <clemaire@dbatools.io>"
LABEL org.opencontainers.image.documentation=https://github.com/potatoqualitee/docker/blob/main/README.md
LABEL org.opencontainers.image.source=https://github.com/potatoqualitee/docker
