#!/bin/bash -e

if ! [ -r "/home/pmoore/passwords.py" ]
then
    echo "You need to be able to read the file passwords.py in the home directory of pmoore to run this script"
    exit 65
fi

http_port="${1}"
if [ -z "${1}" ]
then
    echo "Please specify an http port, e.g. 8444." >&2
    exit 1
fi

user="$(id -nu)"
group="$(id -ng)"

# stop buildbot process(es) for the current user, if any are running...
echo "Stopping buildbot processes for user ${user}"
eval "$(ps -o args -u "${user}" | sed -n 's/buildbot st[a]rt /buildbot stop /p')"

# test ports are free
for port_offset in -1000 0 1000 -999 1 1001
do
    nc -z localhost "$((http_port + port_offset))" && echo "ERROR: port $((http_port + port_offset)) in use! Exiting" && exit 1
done

echo -n "*ROOT* "
su root -c "rm -rf '/builds/buildbot/${user}'; mkdir -p '/builds/buildbot/${user}'; chown '${user}:${group}' '/builds/buildbot/${user}'"
rm -rf "/builds/buildbot/${user}/"*
cd "/builds/buildbot/${user}"
hg clone 'https://hg.mozilla.org/users/john.hopkins_mozillamessaging.com/misc'
# cat 'misc/buildbot-scripts/create-staging-master' | sed 's/esr10/esr17/g' > create-staging-master
cat 'misc/buildbot-scripts/create-staging-master' > create-staging-master
rm -rf 'misc'
chmod u+x "create-staging-master"
'./create-staging-master' "-u=${user}" '-b=/builds/buildbot' '--master-kind=build' "--http-port=${http_port}" || true
'./create-staging-master' "-u=${user}" '-b=/builds/buildbot' '--master-kind=test'  "--http-port=$((http_port + 1))" || true
# cp /home/pmoore/passwords.py "/builds/buildbot/${user}/build1/master/passwords.py"
cd build1
make checkconfig
make start || grep 'configuration update complete' master/twistd.log || exit 64
# ssh root@slavealloc "PASSWORD=\"\$(cat db-credentials | sed -n 's/.*\/\/buildslaves:\(.*\)@devtools-rw-vip.*/\1/p')\"; echo 'nickname,fqdn,http_port,pb_port,datacenter,pool' > '${user}.csv'; echo 'sm-${user}-build,dev-master01.build.scl1.mozilla.com,${http_port},$((http_port + 1000)),scl1,staging-pers' >> '${user}.csv'; '/tools/slavealloc/bin/slavealloc' dbimport -D \"mysql://buildslaves:\${PASSWORD}@10.22.70.59/buildslaves\" --master-data '${user}.csv'"
