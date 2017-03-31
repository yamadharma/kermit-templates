#!/usr/bin/env python
# $Id: fixbbl.py,v 1.2 2000/02/27 22:57:35 fms Exp fms $
# by Frank Stajano, http://www.uk.research.att.com/~fms/, http://i.am/fms/
# (c) AT&T Laboratories Cambridge
# development started 2000-02-27

""" This is a crude hack to fix a bibtex bug that comes up using
package url. The bug is that, when the url is "long", it gets split
into shorter lines by a %. One might expect this % to just eat up the
newline that follows it and disappear; unfortunately, however, it
instead appears in the printed document.

This utility strips away the % and rejoins the lines together. It
should be run on the .bbl file after bibtex generates it and before
latex uses it. (Yeah, I don't use the stupid mixed capitals. So?)

USAGE:
     python fixbbl.py paper.bbl
         Rewrite paper.bbl as follows. Any line ending in % has the %
         stripped and is joined to the next line. The original file is left
         in paper.bbl.bak. If a previous .bak file existed, it is overwritten.

     python fixbbl.py
         Works as a filter on stdin/stdout, if that's what you like.

(NB: if #! works on your system, you probably know that you can leave
out the 'python' in the above, after chmodding the script.)

"""

# This code, for what it's worth, is released under the same licence
# as python. (Basically you can do what you like with this file,
# except suing me.)

import os
import sys

def main():
     # boring argument parsing
     arguments = sys.argv[1:]
     if len(arguments) == 0:
         input = sys.stdin
         output = sys.stdout
     elif len(arguments) == 1:
         f = arguments[0]
         fbak = f + ".bak"
         if os.path.exists(fbak):
             os.remove(fbak)
         os.rename(f, fbak)
         input = open(fbak)
         output = open(f, "w")
     else:
         print __doc__
         sys.exit()

     # real work
     while 1:
         l = input.readline()
         if not l:
             break
         if len(l) >=2 and l[-2:] == "%\n":
             output.write(l[:-2])
         else:
             output.write(l)

if __name__ == "__main__":
     main()
