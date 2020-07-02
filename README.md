## Instructions
1. (If required) Reset AM and DS
2. Run `docker-compose up --build`

## Useful Linux commands
- Get main IP address: ip route get $(ip route show 0.0.0.0/0 | grep -oP 'via \K\S+') | grep -oP 'src \K\S+'
- Reset AM and DS: sudo rm -rf volumes/am/.openamcfg volumes/am/am volumes/cfg* volumes/cts*
- Bootstrap AM using Amster: docker exec am.example.com ./bootstrap.sh Strn9Psswrd cfg.example.com
- Running interactive Amster: docker exec -it am.example.com ./amster

## Default Directory DNs ##
### Also see `configurator_summary_details.png`
### config settings
```
cfg.example.com 636
ou=am-config,dc=example,dc=com
uid=am-config,ou=admins,ou=am-config,dc=example,dc=com
```
### identities settings
```
cfg.example.com 636
ou=identities,dc=example,dc=com
uid=am-identity-bind-account,ou=admins,ou=identities,dc=example,dc=com
```
### cts settings
```
cts.example.com:636
ou=tokens,dc=example,dc=com
uid=openam_cts,ou=admins,ou=famrecords,ou=openam-session,ou=tokens,dc=example,dc=com
```