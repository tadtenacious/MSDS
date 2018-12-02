#!/usr/bin/env python3
from datetime import datetime
import os
import re
words = dict()
def process_line(line,dct):
    words = [i.strip().lower() for i in re.findall(r'[A-Za-z]+',line)]
    for word in words:
        dct[word] = dct.get(word,0) + 1
    return
def process_file(path, dct):
    with open(path,'r',encoding='latin-1') as f:
        for line in f.readlines():
            process_line(line,dct)
    return
def main():
    files = os.listdir('all_guten')
    for file in files:
        path = os.path.join('all_guten',file)
        process_file(path, words)
    with open('wc_py.csv','w') as o:
        o.write('Word;Count\n')
        for k,v in words.items():
            o.write('{};{}\n'.format(k,v))
    return
if __name__=='__main__':
    start = datetime.now()
    print('Started at {}'.format(start))
    main()
    end = datetime.now()
    print('Completed at {}'.format(end))
    diff = end - start
    print('Completed in {}'.format(diff))
