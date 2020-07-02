FROM httpd

ADD web-agent*.zip /usr/local
USER root
WORKDIR /usr/local
RUN apt-get update && apt-get install -y unzip iputils-ping && apt-get clean && \
	\
	# install the apache web agent \
	unzip web-agent*.zip -d /usr/local && \
	rm web-agent*.zip && \
	\
	# create password file for web agent \
	echo password > web_agents/passwdfile && \
	chmod 400 web_agents/passwdfile && \
	\
	# configure web agent \
	# https://backstage.forgerock.com/docs/openam-web-policy-agents/4.1/web-pa-guide/#silent-apache-agent-installation \
	web_agents/apache24_agent/bin/agentadmin --s \
	  apache2/conf/httpd.conf \
	  http://subscribers.example.com:8080/am \
	  http://fec.example.com:80 \
	  /subscribers \
	  webagent \
	  web_agents/passwdfile \
	  --changeOwner \
	  --acceptLicence \
	  --forceInstall
