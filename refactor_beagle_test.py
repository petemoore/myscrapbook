#!/usr/bin/env python

import sys
sys.path.append('/Users/pmoore/git/mozharness/configs/vcs_sync')
import pprint

import beagle
with open('before', 'w') as f:
    f.write(pprint.pformat(beagle.config))

import beagle2
with open('after', 'w') as f:
    f.write(pprint.pformat(beagle2.config))
