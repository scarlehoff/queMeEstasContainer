FROM alpine
MAINTAINER juacrumar juacrumar@lairen.eu

# Expose the express port
EXPOSE 3000

RUN apk update && apk upgrade && apk add nodejs-current npm python3 make g++ git --no-cache

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT /entrypoint.sh
