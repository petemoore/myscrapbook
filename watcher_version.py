#!/usr/bin/env python

import os
import sys
import glob
import time

import site
site.addsitedir(os.path.join(os.path.dirname(os.path.realpath(__file__)), "../lib/python"))

from mozdevice import droid, devicemanager
from sut_lib import checkDeviceRoot, waitForDevice, log


def main(argv):

    if (len(argv) < 2):
        print "usage: installWatcher.py <ip address>"
        sys.exit(1)

    ip_addr = argv[1]

    dm = droid.DroidSUT(ip_addr)
    if not dm:
        log.error("could not get device manager!")
        return 1
    devRoot = checkDeviceRoot(dm)

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
