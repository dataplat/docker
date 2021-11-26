# from image passed in dockerfile (either arm or x64)
ARG IMAGE
ARG FINALIMAGE
ARG BUILD_DATE

# get the latest SQL container
FROM $IMAGE as builder

# add an argument that will later help designate the stocked sql server
ARG PRIMARYSQL

# label the container
LABEL io.dbatools.version="1.0.0"
LABEL io.dbatools.build-date=$BUILD_DATE
LABEL io.dbatools.schema-version=1.0
LABEL vendor="dbatools"
LABEL maintainer="clemaire@dbatools.io"

# switch to root to a bunch of stuff that requires elevated privs
USER root

# copy scripts and make bash files executable
# also create a shared directory and make it writable by mssql
RUN mkdir /dbatools-setup /shared
WORKDIR /dbatools-setup
# use copy instead of add, it's safer
COPY sql scripts /dbatools-setup/
# put as much as possible on one line to reduce image size
RUN chmod +x /dbatools-setup/*.sh; chown mssql /shared

# write a file that designates the primary server
# this is used in a later step to load up the server
RUN if [ $PRIMARYSQL ]; then touch /dbatools-setup/primary; fi

# run a rootless container
USER mssql
# run initial setup scripts then start the service for good
RUN /bin/bash /dbatools-setup/initial-start.sh

#This is the final stage, and we copy artifacts from "builder"
FROM $IMAGE
COPY --from=builder /shared /shared
COPY --from=builder /var/opt/mssql /var/opt/mssql

ENTRYPOINT /opt/mssql/bin/sqlservr