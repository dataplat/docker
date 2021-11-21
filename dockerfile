ARG IMAGE

# get the latest SQL container
FROM $IMAGE

# add an argument that will later help designate the primary sql server
# which needs to have a bunch of objects like databases and logins added to it
ARG PRIMARYSQL

# switch to root to a bunch of stuff that requires elevated privs
USER root

# copy scripts and make bash files executable
ADD sql /tmp
ADD scripts /tmp
RUN chmod +x /tmp/initial-start.sh
RUN chmod +x /tmp/setup.sh

# write a file that designates the primary server
# this is used in a later step to load up the server
RUN if [ $PRIMARYSQL ]; then touch /tmp/primary; fi

# run initial setup scripts then start the service for good
USER mssql
RUN /bin/bash /tmp/initial-start.sh
ENTRYPOINT /opt/mssql/bin/sqlservr