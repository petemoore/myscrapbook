#!/bin/bash -exv

function record {
    START_MONTH="${1}"
    START_DAY="${2}"
    START_HOUR="${3}"
    START_MINUTE="${4}"
    STOP_HOUR="${5}"
    STOP_MINUTE="${6}"
curl 'http://192.168.2.102/main.html?_newhddtimer=New+DVR+timer' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.5' -H 'Connection: keep-alive' -H 'Host: 192.168.2.102' -H 'Referer: http://192.168.2.102/main.html?_newhddtimer=New+DVR+timer' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:37.0) Gecko/20100101 Firefox/37.0' -H 'Content-Type: application/x-www-form-urlencoded' --data "service_1=232&date=${MONTH}%2F${DAY}&start=${START_HOUR}%3A${START_MINUTE}&stop=${STOP_HOUR}%3A${STOP_MINUTE}&repeat=0&type=6&d41d8cd98f00b204e9800998ecf8427e_set_newtimer=Accept"
}
