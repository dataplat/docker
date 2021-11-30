# get it from the base image that matches your architecture
FROM golang

# clone the go-sqlcmd repo
RUN git clone --depth 1 https://github.com/microsoft/go-sqlcmd

# change directories and compile sqlcmd to /tmp/sqlcmd
RUN cd go-sqlcmd && \
    go build -o /tmp/sqlcmd ./cmd/sqlcmd

# just to reiterate that it's at /tmp/sqlcmd
RUN ls /tmp/sqlcmd

# if you want to look around
ENTRYPOINT /bin/sh