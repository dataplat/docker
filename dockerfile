# from image passed in dockerfile (either arm or x64)
ARG IMAGE

# get the latest SQL container and set it as the builder image
# builder images let you do a bunch of work that you can discard
# then just keep the results
FROM $IMAGE as builder

# add an argument that will later help designate the stocked sql server
ARG PRIMARYSQL

# label the container
LABEL io.dbatools.version="1.0.0"
LABEL io.dbatools.schema-version=1.0
LABEL maintainer="clemaire@dbatools.io"

# switch to root to a bunch of stuff that requires elevated privs
USER root

# copy scripts and make bash files executable
# also create a shared directory and make it writable by mssql
WORKDIR /tmp
RUN chown mssql /tmp
# use copy instead of add, it's safer apparently
COPY sql scripts /tmp/
# put as much as possible on one line to reduce image size
RUN chmod +x /tmp/*.sh

# write a file that designates the primary server
# this is used in a later step to load up the server
RUN if [ $PRIMARYSQL ]; then touch /tmp/primary; fi

# switch to user mssql or the container will fail
USER mssql
# run initial setup scripts then start the service for good
RUN /bin/bash /tmp/initial-start.sh

# Discard all that builder data then just copy the required changed files from "builder"
FROM $IMAGE
COPY --from=builder /var/opt/mssql /var/opt/mssql

# make a shared dir with the proper permissions
USER root
RUN  mkdir /shared; chown mssql /shared

# run a rootless container
USER mssql
ENTRYPOINT /opt/mssql/bin/sqlservr