#!/usr/bin/env python
#
# Convert a png file into text with terminal-based
# colors that approximate what was in the png file.
#
# This color conversion doesn't know about the
# grayscale part of the 256-color palette, so that
# shades of gray won't be converted optimally.
#

import os
import png
import sys

# Some of the conversion code here is taken from:
# https://gist.github.com/MicahElliott/719710

# Default color levels for the color cube
cubelevels = [0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff]
# Generate a list of midpoints of the above list
snaps = [(x + y) / 2 for x, y in zip(cubelevels, [0] + cubelevels)[1:]]

last_color = None

def pr_color(r, g, b):
  global last_color
  # Using list of snap points, convert RGB value to cube indexes
  r, g, b = map(lambda x: len(tuple(s for s in snaps if s < x)), (r, g, b))
  color = r * 36 + g * 6 + b + 16
  if last_color != color:
    os.system('tput setab ' + str(r * 36 + g * 6 + b + 16))
    last_color = color
  sys.stdout.write(' ')
  sys.stdout.flush()

if __name__ == '__main__':

  if len(sys.argv) < 2:
    print('Usage: convert.py [png file]')
    exit()

  r = png.Reader(sys.argv[1])
  data = r.read()
  pixels = data[2]
  for row in pixels:
    for i in xrange(0, len(row), 4):
      r, g, b = row[i], row[i + 1], row[i + 2]
      pr_color(r, g, b)
    print('')
