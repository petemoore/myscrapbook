#!/bin/bash -exv

function record {
    MONTH="${1}"
    DAY="${2}"
    START_HOUR="${3}"
    START_MINUTE="${4}"
    STOP_HOUR="${5}"
    STOP_MINUTE="${6}"
    CHANNEL="${7}"
    STOUT="$(mktemp -t technisat_out.XXXXXXXXXX)"
    STERR="$(mktemp -t technisat_err.XXXXXXXXXX)"
    curl \
            --retry 50 \
            --retry-max-time 300 \
            -L \
            'http://192.168.2.102/main.html?d41d8cd98f00b204e9800998ecf8427e_newhddtimer=New+DVR+timer' \
            -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
            -H 'Accept-Encoding: gzip, deflate' \
            -H 'Accept-Language: en-US,en;q=0.5' \
            -H 'Connection: keep-alive' \
            -H 'Host: 192.168.2.102' \
            -H 'Referer: http://192.168.2.102/main.html?d41d8cd98f00b204e9800998ecf8427e_newhddtimer=New+DVR+timer' \
            -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:37.0) Gecko/20100101 Firefox/37.0' \
            -H 'Content-Type: application/x-www-form-urlencoded' \
            -H 'Cookie: _ga=GA1.1.226162785.1427714524' \
            --data-urlencode "service_1=${CHANNEL}" \
            --data-urlencode "date=${MONTH}/${DAY}" \
            --data-urlencode "start=${START_HOUR}:${START_MINUTE}" \
            --data-urlencode "stop=${STOP_HOUR}:${STOP_MINUTE}" \
            --data-urlencode "repeat=0" \
            --data-urlencode "type=6" \
            --data-urlencode "d41d8cd98f00b204e9800998ecf8427e_set_newtimer=Accept" >"${STOUT}" 2>"${STERR}"
    set +xv
    echo "Standard out"
    echo "============"
    cat "${STOUT}"
#    cat "${STOUT}" | sed -n '/DOCTYPE/,$p' > xxx${xxx}.html
#    open xxx${xxx}.html
#            -s \
#            -i \
#            -v \
    let xxx+=1
    echo
    echo "Standard error"
    echo "=============="
    cat "${STERR}"
    echo
    rm "${STOUT}"
    rm "${STERR}"
    set -xv
}

# record MONTH DAY START_HOUR START_MINUTE STOP_HOUR STOP_MINUTE
# record 04 26 11 08 13 03

xxx=1

# record 04 28 13 57 15 03 232
# record 04 28 15 57 19 03 232
# record 04 28 19 27 21 03 232
# record 04 29 10 57 13 03 232
# record 04 29 13 57 19 03 232
# record 04 29 19 57 21 03 232
# record 04 30 13 57 15 03 232
# record 04 30 19 27 21 03 232
# record 05 01 01 07 03 13 232
# record 05 01 10 57 13 03 232
# record 05 01 13 57 19 03 232
# record 05 01 19 57 22 03 232
# record 05 02 10 57 13 03 232
# record 05 02 13 57 17 30 227
# record 05 02 17 31 18 33 232
# record 05 02 19 57 22 33 232
# record 05 03 14 57 19 03 232
# record 05 03 19 57 00 03 232
# record 05 04 13 57 19 03 232
record 07 04 19 57 00 03 232
