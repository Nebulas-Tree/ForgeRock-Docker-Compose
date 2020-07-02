#!/usr/bin/env bash
CATALINA_OPTS="-server -Xmx2g -XX:MetaspaceSize=256m -XX:MaxMetaspaceSize=256m -XX:+UseConcMarkSweepGC"
CATALINA_PID="$CATALINA_BASE/bin/catalina.pid"
