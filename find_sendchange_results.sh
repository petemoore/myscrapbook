#!/bin/bash

ssh kmoir@dev-master01 'sqlite3 /builds/buildbot/kmoir/test2/master/state.sqlite "select '\''http://dev-master01.build.scl1.mozilla.com:8036/builders/'\'' || br.buildername || '\''/builds/'\''  || b.number, br.results from buildrequests br, builds b where br.buildsetid in (4,5,6,7,8,9) and b.brid=br.id order by buildername"'
