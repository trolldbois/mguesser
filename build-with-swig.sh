#!/bin/bash
#
#
#    pHash, the open source perceptual hash library
#    Copyright (C) 2008-2009 Aetilius, Inc.
#    All rights reserved.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Evan Klinger - eklinger@phash.org
#    David Starkweather - dstarkweather@phash.org
#    
#    swig interface by Loic Jaquemet - loic.jaquemet@gmail.com
#
# 
# @see http://realmike.org/python/swig_linux.htm for autotools integration
#
# if pHash is in /usr/local....
# export LD_LIBRARY_PATH=/usr/local/lib
#
# you will need a build pHash tree
# apt-get install swig python-dev imagemagick graphicsmagick
# 
#
rm -f pHash.py pHash.pyc pHash_wrap.cpp pHash_wrap.o

echo " swigging.... "
swig -classic -I../../src/ -I/usr/include -c++ -python -o pHash_wrap.cpp pHash.i
if [ $? -ne 0 ]; then
 exit 1
fi

echo "building ..."
gcc -fPIC -I/usr/include/python2.5 -I../../src/ -c pHash_wrap.cpp -o pHash_wrap.o
if [ $? -ne 0 ]; then
 exit 1
fi

#OBJECTS="../../src/audiophash.o  ../../src/cimgffmpeg.o  ../../src/pHash.o  ../../src/ph_fft.o"
OBJECTS=""

echo "making lib" 
g++ -shared pHash_wrap.o $OBJECTS -lpHash -o _pHash.so
if [ $? -ne 0 ]; then
 exit 1
fi

echo "testing "
python -c  '
import pHash
print pHash.ph_about()
'
if [ $? -ne 0 ]; then
 exit 1
fi

echo 'install'
cp pHash.py _pHash.so /usr/local/lib/python2.5/site-packages/

