#!/usr/bin/env python
# encoding: utf-8
'''
Python module to generate a skeleton weekly update report for my blog
'''

import sys
import os

from optparse import OptionParser

def main(argv=None):
    '''Command line options.'''
    
    program_name = os.path.basename(sys.argv[0])
 
 
    if argv is None:
        argv = sys.argv[1:]
    try:
        # setup option parser
        parser = OptionParser()
        parser.add_option("-i", "--in", dest="infile", help="set input path [default: %default]", metavar="FILE")
        parser.add_option("-o", "--out", dest="outfile", help="set output path [default: %default]", metavar="FILE")
        parser.add_option("-v", "--verbose", dest="verbose", action="count", help="set verbosity level [default: %default]")
        
        # set defaults
        parser.set_defaults(outfile="./out.txt", infile="./in.txt")
        
        # process options
        (opts, args) = parser.parse_args(argv)
        
        if opts.verbose > 0:
            print("verbosity level = %d" % opts.verbose)
        if opts.infile:
            print("infile = %s" % opts.infile)
        if opts.outfile:
            print("outfile = %s" % opts.outfile)
            
        # MAIN BODY #
        
    except Exception, e:
        indent = len(program_name) * " "
        sys.stderr.write(program_name + ": " + repr(e) + "\n")
        sys.stderr.write(indent + "  for help use --help")
        return 2


if __name__ == "__main__":
    sys.exit(main())