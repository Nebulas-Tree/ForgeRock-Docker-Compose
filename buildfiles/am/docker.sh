#!/usr/bin/env bash

# Setup fake group
getent group fakegroup >/dev/null || addgroup --gid ${GID:-1000} fakegroup && chgrp -R fakegroup /root && chmod -R g=rXs /root

# Copy all custom treenodes into AM
cp -urf /tmp/treenodes/* ${CATALINA_HOME}/webapps/am/WEB-INF/lib/

# Trust all directory certificates specified in DIRECTORIES with space as delimiter
IFS=' '
read -ra ARR_DIRECTORIES <<< "${DIRECTORIES}"
for DIRECTORY in "${ARR_DIRECTORIES[@]}"; do
    until openssl s_client -connect "${DIRECTORY}" -showcerts >/dev/null 2>/dev/null; do
      >&2 echo "Waiting for ${DIRECTORY} to start..."
      sleep 5
    done
    echo "" | openssl s_client -connect "${DIRECTORY}" -showcerts 2>/dev/null | openssl x509 -out /tmp/cert
    keytool -importcert -alias "${DIRECTORY}" -file /tmp/cert -trustcacerts -keystore ${JAVA_HOME}/jre/lib/security/cacerts -storetype JKS -storepass changeit -noprompt
    echo -e "\t- ${DIRECTORY}"
done

# Show bootstrap.sh guide if not set up
if [[ ! -f /root/am/install.log ]]; then
    echo `
        until [[ "$(cat ${CATALINA_HOME}/logs/catalina.out | grep 'org.apache.catalina.startup.Catalina.start')" != "" ]];
        do
          sleep 5
        done
        echo -e "\n\nRun 'docker exec ${HOSTNAME} ./bootstrap.sh (PASSWORD) (DS/CFG HOSTNAME) (IDS HOSTNAME [OPTIONAL])' to quickly bootstrap using Amster."
    ` & 2>/dev/null
fi

# Start Tomcat and AM
startup.sh
tail -f ${CATALINA_HOME}/logs/catalina.out
