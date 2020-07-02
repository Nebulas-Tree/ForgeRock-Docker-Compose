#!/usr/bin/env bash

# Check number of variables
if [[ $# -lt 2 ]]; then
	echo "Usage: $0 (PASSWORD) (DS/CFG HOSTNAME) (IDS HOSTNAME [OPTIONAL])"
	exit 1
fi

# Execute Amster install-openam
./amster <<< "install-openam \
  --serverUrl http://${HOSTNAME}:8080/am \
  --adminPwd $1 \
  --acceptLicense \
  --cfgDir /root/am \
  --cfgStore dirServer \
  --cfgStoreHost $2 \
  --cfgStorePort 636 \
  --cfgStoreDirMgr uid=am-config,ou=admins,ou=am-config,${DS_BASEDN} \
  --cfgStoreRootSuffix ou=am-config,${DS_BASEDN} \
  --cfgStoreSsl SSL \
  --userStoreType LDAPv3ForOpenDS \
  --userStoreHost ${3:-$2} \
  --userStorePort 636 \
  --userStoreDirMgr uid=am-identity-bind-account,ou=admins,ou=identities,${DS_BASEDN} \
  --userStoreRootSuffix ou=identities,${DS_BASEDN} \
  --userStoreDirMgrPwd $1 \
  --userStoreSsl SSL
:exit"
