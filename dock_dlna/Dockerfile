FROM alpine
MAINTAINER juacrumar juacrumar@lairen.eu

# Define variables
ARG NAME=DockerServer
ARG USER=jeeves
ARG CONF=/home/$USER/minidlna.conf
ENV CONF=$CONF

# Install all necessary packages
RUN apk update && apk upgrade && apk add minidlna --no-cache

# Increase the maximum user watches for inotify
RUN echo "fs.inotify.max_user_watches=524288" > /etc/sysctl.d/90-inotify.conf

RUN adduser -D -h /home/$USER -u 1000 $USER
COPY minidlna.conf $CONF

# Substitute the above variables into the configuration file
RUN sed -i "s/DOCKERNAME/$NAME/g" $CONF && sed -i "s/DOCKERUSER/$USER/g" $CONF

# Drop privileges, the group is mapped to 166536
# because I'm summing 165536 to whatever happens in docker
RUN addgroup --gid 166536 lowperm && adduser $USER lowperm && chown 1000:1000 -R /var/lib/minidlna /home/$USER && chmod g+wr -R /var/lib/minidlna /home/$USER
USER $USER

ENTRYPOINT /usr/sbin/minidlnad -f $CONF -P /tmp/dlna.pid -S
