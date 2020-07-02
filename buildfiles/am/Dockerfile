FROM tomcat:jdk8-adoptopenjdk-openj9
ADD AM*.war $CATALINA_HOME/webapps/am.war
COPY setenv.sh $CATALINA_HOME/bin/setenv.sh
RUN echo "fs.file-max=65536\nfs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
WORKDIR /root
ADD Amster*.zip .
RUN apt-get update && apt-get install -y unzip && apt-get clean && \
	unzip Amster*.zip -d /root && \
	rm Amster*.zip
COPY bootstrap.sh .
COPY docker.sh .
CMD ./docker.sh
