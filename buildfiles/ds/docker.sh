#!/usr/bin/env bash

params=()
if [[ ! -f /root/.opendj/instance.loc ]]; then
    rm -f instance.loc

    if [[ "${TYPE}" == "directory"* ]]; then
        # Directory server
        params+=(
            directory-server \
            --instancePath "/root/.opendj" \
            --monitorUserDn "uid=Monitor" \
            --monitorUserPassword ${DS_MONITOR_PASS} \
            --ldapPort 389 \
            --enableStartTls \
            --ldapsPort 636 \
            --httpPort 80 \
            --httpsPort 443 \
        )

        # Config store
        [[ "${TYPE}" == *"cfg"* || "${TYPE}" == *"config"* ]] && params+=(
            --profile am-config \
            --set am-config/amConfigAdminPassword:${DS_CONFIG_PASS} \
            --set am-config/baseDn:ou=am-config,${DS_BASEDN} \
        )
        # CTS
        [[ "${TYPE}" == *"cts"* || "${TYPE}" == *"tokens"* ]] && params+=(
            --profile am-cts \
            --set am-cts/amCtsAdminPassword:${DS_CTS_PASS} \
            --set am-cts/baseDn:ou=tokens,${DS_BASEDN} \
        )
        # User store
        [[ "${TYPE}" == *"ids"* || "${TYPE}" == *"user"* ]] && params+=(
            --profile am-identity-store \
            --set am-identity-store/amIdentityStoreAdminPassword:${DS_IDS_PASS} \
            --set am-identity-store/baseDn:ou=identities,${DS_BASEDN} \
        )

        # Custom keystore
        if [[ ! -z ${KEYSTORE_TYPE} && ! -z ${KEYSTORE_PASS} && ! -z ${KEYSTORE_CERT} ]]; then
            [[ "${KEYSTORE_TYPE}" == 'pkcs12' ]] && params+=(--usePkcs12KeyStore)
            [[ "${KEYSTORE_TYPE}" == 'jceks' ]] && params+=(--useJceKeyStore)
            [[ "${KEYSTORE_TYPE}" == 'jks' ]] && params+=(--useJavaKeyStore)
            params+=(
                /usr/local/opendj/keystore \
                --keyStorePassword ${KEYSTORE_PASS} \
                --certNickname ${KEYSTORE_CERT} \
            )
        fi
    elif [[ "${TYPE}" == "replication"* ]]; then
        # Replication only
        params+=(
            replication-server \
            --replicationPort 8989 \
        )

        # Custom trust store
        if [[ ! -z ${KEYSTORE_TYPE} && ! -z ${KEYSTORE_PASS} && ! -z ${KEYSTORE_CERT} ]]; then
            [[ "${KEYSTORE_TYPE}" == 'pkcs12' ]] && params+=(--usePkcs12TrustStore)
            [[ "${KEYSTORE_TYPE}" == 'jceks' ]] && params+=(--useJceTrustStore)
            [[ "${KEYSTORE_TYPE}" == 'jks' ]] && params+=(--useJavaTrustStore)
            params+=(
                /usr/local/opendj/keystore \
                --trustStorePassword ${KEYSTORE_PASS} \
            )
        fi
    fi

    # Common parameters
    params+=(
        --rootUserDn "cn=Directory Manager" \
        --rootUserPassword ${DS_ROOT_PASS} \
        --hostname ${HOSTNAME} \
        --adminConnectorPort 4444 \
        --productionMode \
        --acceptLicense \
        --doNotStart
    )
    ./setup "${params[@]}"
    echo "./setup ${params[@]}"

    # Tweaks and hardening
    bin/dsconfig set-password-policy-prop \
        --offline \
        --policy-name "Default Password Policy" \
        --set skip-validation-for-administrators:true \
        --no-prompt
    bin/dsconfig set-connection-handler-prop \
        --offline \
        --handler-name LDAPS \
        --set ssl-protocol:TLSv1.2 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_256_GCM_SHA384 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_128_GCM_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_256_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA \
        --no-prompt
    bin/dsconfig set-administration-connector-prop \
        --offline \
        --set ssl-protocol:TLSv1.2 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_256_GCM_SHA384 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_128_GCM_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_256_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA \
        --no-prompt
    bin/dsconfig set-crypto-manager-prop \
        --offline \
        --set ssl-protocol:TLSv1.2 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_256_GCM_SHA384 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_128_GCM_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_256_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA \
        --set ssl-cipher-suite:TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA \
        --no-prompt

    cp instance.loc /root/.opendj/instance.loc
else
    cp /root/.opendj/instance.loc instance.loc
fi

# Start DS
bin/start-ds --noDetach &

# Setup replication
if [[ "${TYPE}" == *"replication"* ]]; then
    until bin/status -h ${MASTER_HOST} -p 4444 --bindPassword ${MASTER_ROOT_PASS} -s --trustAll --no-prompt > /dev/null; do
      >&2 echo "Waiting for master to start..."
      sleep 5
    done

    params=(
        configure \
        --host1 ${MASTER_HOST} \
        --port1 4444 \
        --bindDn1 "cn=Directory Manager" \
        --bindPassword1 ${MASTER_ROOT_PASS} \
        --host2 ${SLAVE_HOST:-$HOSTNAME} \
        --port2 4444 \
        --bindDn2 "cn=Directory Manager" \
        --bindPassword2 ${DS_ROOT_PASS} \
        --replicationPort1 8989 \
        --secureReplication1 \
        --replicationPort2 8989 \
        --secureReplication2 \
        --baseDn ou=am-config,${DS_BASEDN} \
        --baseDn ou=identities,${DS_BASEDN} \
        --baseDn ou=tokens,${DS_BASEDN} \
        --baseDn uid=Monitor \
        --adminUid "cn=Directory Manager" \
        --adminPassword ${MASTER_ROOT_PASS} \
        --no-prompt --trustAll
    )
    bin/dsreplication "${params[@]}"
    echo "bin/dsreplication ${params[@]}"

    params=(
        initialize \
        --hostSource ${MASTER_HOST} \
        --portSource 4444 \
        --hostDestination ${SLAVE_HOST:-$HOST} \
        --portDestination 4444 \
        --baseDn ou=am-config,${DS_BASEDN} \
        --baseDn ou=identities,${DS_BASEDN} \
        --baseDn ou=tokens,${DS_BASEDN} \
        --baseDn uid=Monitor \
        --adminUid "cn=Directory Manager" \
        --adminPassword ${MASTER_ROOT_PASS} \
        --no-prompt --trustAll
    )
    bin/dsreplication "${params[@]}"
    echo "bin/dsreplication ${params[@]}"
fi

# Setup fake group
getent group fakegroup >/dev/null || addgroup --gid ${GID:-1000} fakegroup && chgrp -R fakegroup /root && chmod -R g=rXs /root

# Keep Docker container alive
tail -f /dev/null
