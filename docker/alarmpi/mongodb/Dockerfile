FROM actuit/rpi-base-archlinux-aarch64:1.0.0
MAINTAINER Mike Ray <mike.ray@btinternet.com>


# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mongodb && \
    useradd -r -g mongodb mongodb

RUN pacman -Sy --noconfirm --noprogressbar


RUN pacman -S --noconfirm --noprogressbar \
    mongodb mongodb-tools \
    python python-pip dmidecode


RUN mkdir -p /data/db /data/configdb && \
    chown -R mongodb:mongodb /data/db /data/configdb

VOLUME /data/db /data/configdb

RUN pip3 install docker pymongo

RUN rm -rf /var/lib/pacman/local/* && \
    rm -rf /var/lib/pacman/sync/*

COPY su-exec /
COPY numactl /


COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 27017


CMD ["mongod"]


