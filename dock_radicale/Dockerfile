FROM alpine
MAINTAINER juacrumar juacrumar@lairen.eu

ARG USER=jeeves

# Expose the port that we will use for radicale
EXPOSE 5467

RUN apk update && apk upgrade && apk add radicale --no-cache
COPY config /

RUN adduser -D -u 1000 $USER
USER $USER

ENTRYPOINT radicale -C config
