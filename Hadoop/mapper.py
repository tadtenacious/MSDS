#!/usr/bin/env python3
"""mapper.py"""

import sys
import io
import re

input_stream = io.TextIOWrapper(sys.stdin.buffer, encoding='latin-1')

#for line in sys.stdin:
for line in input_stream:
    line = line.strip()
    #words = line.split()
    words = re.findall(r'[A-Za-z]+',line)
    for word in words:
        print('{};{}'.format(word.lower(),1))
