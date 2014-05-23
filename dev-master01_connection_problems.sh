#!/bin/bash
ssh -oConnectTimeout=20 -oBatchMode=yes -oStrictHostKeyChecking=no cltbld@dev-master01 '
    ps -ef | sed -n '\''s/.*\/builds\/buildbot\/\(.*\)\/bin\/buildbot start .*/\1/p'\'' | sort -u | while read master
    do
        cat "/builds/buildbot/${master}/master/twistd.log" | sed -n '\''s/^.*,\([0-9\.]*\)\].*Unhandled Error.*/\1/p'\'' | sort -u | while read IP
        do
            nslookup "${IP}"
        done | sed -n "s/.*name = \\(.*\\)\\.\$/\\1 ${master/\//\\/}/p" | sort -u
    done
' 2>/dev/null | while read device master
do
    echo "Master '${master}' reports that one or more slaves on '${device}' were not authorised to connect"
    ssh -oConnectTimeout=10 -oBatchMode=yes -oStrictHostKeyChecking=no "cltbld@${device}" '
        ps -ef | sed -n '\''s/.*--py[t]hon[= ]\([^ ]*\)\/buildbot\.tac.*/\1/p'\'' | while read slavedir
        do
            grep "unauthorized login; check slave name and password" "${slavedir}/twistd.log" &>/dev/null && echo FAILED "${slavedir}" || echo OK "${slavedir}"
        done | while read status slavedir
        do
            if [ "${status}" = 'FAILED' ]
            then
                echo "    Slave '\''${slavedir}'\'' on '\'"${device}"\'' reports it was not authorised to connect to master '\'"${master}"\''"
                sed -n -e '\''s/^\(slavename\|passwd\|port\|buildmaster_host\).*/        &/p'\'' "${slavedir}/buildbot.tac"
            else
                echo "    Slave log '\''${slavedir}/twistd.log'\'' on '\'"${device}"\'' has no account of this problem"
            fi
        done
    ' </dev/null 2>/dev/null || echo '    Could not connect to slave'
done
