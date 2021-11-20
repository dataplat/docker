# get it
# build from the Ubuntu 18.04 image
FROM ubuntu:18.04
ARG PRIMARYSQL

# switch to root
USER root

# copy scripts and make them executable
ADD sql /tmp
ADD scripts /tmp
RUN chmod +x /tmp/initial-start.sh
RUN chmod +x /tmp/install-mssql.sh
RUN chmod +x /tmp/change-hostname.sh
RUN chmod +x /tmp/setup.sh

# run installer
RUN /bin/bash /tmp/install-mssql.sh

# write a file that designates the primary server
# this is used in a later step to load up the server
RUN if [ $PRIMARYSQL ]; then touch /tmp/primary; fi
#RUN /bin/bash /tmp/change-hostname.sh

# run initial scripts then start the service for good
USER mssql
RUN /bin/bash /tmp/initial-start.sh
CMD /opt/mssql/bin/sqlservr