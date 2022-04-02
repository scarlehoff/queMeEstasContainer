FROM alpine
MAINTAINER juacrumar juacrumar@lairen.eu

# Expose the express port
EXPOSE 3000

RUN apk update && apk upgrade && apk add nodejs-current npm python3 make g++ --no-cache

# Download the latest version from github
RUN wget https://github.com/scarlehoff/websito/archive/refs/heads/master.zip && unzip master.zip && rm -rf master.zip websito-master/.git*

# Now install the npm stuff
WORKDIR websito-master
RUN npm i  && npm cache clean --force

RUN apk del npm make g++

ENTRYPOINT ./bin/www
