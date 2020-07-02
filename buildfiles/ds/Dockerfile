FROM adoptopenjdk/openjdk8-openj9:alpine-slim
EXPOSE 389
EXPOSE 636
EXPOSE 80
EXPOSE 443
EXPOSE 4444
EXPOSE 8989

WORKDIR /usr/local
ADD DS*.zip .
RUN apk add bash && \
    echo -e "fs.file-max=65536\nfs.inotify.max_user_watches=524288" >> /etc/sysctl.conf && \
    unzip DS*.zip && \
	rm DS*.zip

WORKDIR /usr/local/opendj

HEALTHCHECK --start-period=30s CMD bin/status -h localhost -p 4444 --bindPassword ${DS_ROOT_PASS} --trustAll

ADD keystore .
ADD docker.sh .
CMD ./docker.sh
