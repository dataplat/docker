# get it
FROM mcr.microsoft.com/mssql/server:2019-latest
ARG PRIMARYSQL

# switch to root
USER root

# copy scripts and make them executable
ADD sql /tmp
ADD scripts /tmp
RUN chmod +x /tmp/initial-start.sh
RUN chmod +x /tmp/setup.sh

# update options
RUN /opt/mssql/bin/mssql-conf set sqlagent.enabled true
RUN /opt/mssql/bin/mssql-conf set hadr.hadrenabled  1

# write a file that designates the primary server
# this is used in a later step to load up the server
RUN if [ $PRIMARYSQL ]; then touch /tmp/primary; fi

# run initial scripts then start the service for good
USER mssql
RUN /bin/bash /tmp/initial-start.sh
CMD /opt/mssql/bin/sqlservr