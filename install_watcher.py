#!/usr/bin/env python

import os
import sys
import glob
import time

import site
site.addsitedir(os.path.join(os.path.dirname(os.path.realpath(__file__)), "../lib/python"))

from mozdevice import droid, devicemanager
from sut_lib import checkDeviceRoot, waitForDevice, log


def install(dm, devRoot, app_file_local_path, package):
    source = app_file_local_path
    filename = os.path.basename(source)
    target = os.path.join(devRoot, filename)

    log.info("Pushing new apk to the device: %s" % target)
    status = dm.pushFile(source, target)

    dm.shellCheckOutput(["dd", "if=%s" % target, "of=/data/local/watcher.apk"], root=True)
    dm.shellCheckOutput(["chmod", "666", "/data/local/watcher.apk"], root=True)

    log.info("Uninstalling %s" % package)
    try:
        dm.uninstallApp(package)
        log.info('uninstallation successful')
    except devicemanager.DMError, e:
        log.info('uninstallation failed -- maybe not installed? '+str(e))

    osversion = dm.getInfo('os')['os'][0].split()[0]
    if osversion == 'pandaboard-eng':
        log.info('installing %s on panda' % target)
        status = dm._runCmds([{'cmd': 'exec su -c "export LD_LIBRARY_PATH=/vendor/lib:/system/lib; pm install /data/local/watcher.apk; am start -a android.intent.action.MAIN -n com.mozilla.watcher/.WatcherMain"'}]).split('\n')
    else:
        log.info('installing %s on tegra' % target)
        status = dm._runCmds([{'cmd': 'exec su -c "pm install /data/local/watcher.apk; am start -a android.intent.action.MAIN -n com.mozilla.watcher/.WatcherMain"'}]).split('\n')

    if len(status) > 2 and status[1].strip() == 'Success':
        log.info('-' * 42)
        log.info('installation successful')
    else:
        log.error('installApp() failed: %s' % status)
        return 1

    time.sleep(15)
    return 0


def main(argv):

    if (len(argv) < 3):
        print "usage: installWatcher.py <ip address> <localfilename>"
        sys.exit(1)

    ip_addr = argv[1]
    path_to_main_apk = argv[2]

    dm = droid.DroidSUT(ip_addr)
    if not dm:
        log.error("could not get device manager!")
        return 1
    devRoot = checkDeviceRoot(dm)

    if install(dm, devRoot, path_to_main_apk, "com.mozilla.watcher"):
        log.error("install failed")
        return 1

    dm.reboot()
    waitForDevice(dm)

    # we can't use the following dm.getFile method, since only Watcher runtime user has read access
    # to this file, so we need to be root to read it, hence the slightly more convoluted version
    # using dm._runCmds below...
    # cannot use -> print dm.getFile('/data/data/com.mozilla.watcher/files/version.txt')
    status = dm._runCmds([{'cmd': 'exec su -c "cat /data/data/com.mozilla.watcher/files/version.txt"'}]).split('\n')
    log.info('Watcher version: %s' % status)
    return 0

if __name__ == '__main__':
    # Stop buffering! (but not while testing)
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)
    sys.exit(main(sys.argv))
