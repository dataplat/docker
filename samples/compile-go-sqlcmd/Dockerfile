FROM golang

RUN git clone --depth 1 https://github.com/microsoft/go-sqlcmd
WORKDIR /go/go-sqlcmd
RUN go build -o /tmp/sqlcmd ./cmd/sqlcmd
#RUN /tmp/sqlcmd
ENTRYPOINT /bin/sh
