FROM alpine
MAINTAINER juacrumar juacrumar@lairen.eu

ARG USER=jeeves

# Expose the port that we will use for radicale
EXPOSE 5467

RUN apk update && apk upgrade && apk add radicale --no-cache
COPY config /

#RUN adduser -D -u 1000 $USER

#RUN chown 1000:1000 -R /mnt/


#ENTRYPOINT radicale -C /config

# Download the latest version from github
# RUN wget https://github.com/scarlehoff/websito/archive/refs/heads/master.zip && unzip master.zip && rm -rf master.zip websito-master/.git*
# 
# # Now install the npm stuff
# WORKDIR websito-master
# RUN npm i  && npm cache clean --force
# 
# RUN apk del npm make g++
# 
# ENTRYPOINT ./bin/www
