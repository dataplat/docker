# get it
FROM mcr.microsoft.com/mssql/server
ARG PRIMARYSQL

# switch to root to do some housecleaning
USER root

# enable agent and HA
RUN /opt/mssql/bin/mssql-conf set sqlagent.enabled true
RUN /opt/mssql/bin/mssql-conf set hadr.hadrenabled  1

# copy sql
ADD sql /tmp
ADD scripts /tmp

# copy setup files and make them executable
COPY sqlserver.env /tmp/sqlserver.env
RUN chmod +x /tmp/initial-start.sh
RUN chmod +x /tmp/change-hostname.sh
RUN chmod +x /tmp/setup.sh

# write a file that designates the primary server
# this is used in a later step to load up the server
RUN if [ $PRIMARYSQL ]; then touch /tmp/primary; fi
#RUN /bin/bash /tmp/change-hostname.sh

# run initial scripts then start the service for good
USER mssql
RUN /bin/bash /tmp/initial-start.sh
CMD /opt/mssql/bin/sqlservr