


#DEFS=-DUDM_GUESSER_STANDALONE -DLMDIR=\"./maps\" -DMGUESSER_VERSION=\"0.4-swig\"
DEFS=-DUDM_GUESSER_STANDALONE -DLMDIR=\"/usr/local/share/mguesser/maps\" -DMGUESSER_VERSION=\"0.4-swig\"
CFLAGS=-Wall -g $(DEFS)
OBJECTS=guesser.o crc32.o utils.o 
LIBS=-lm
CC=cc


all: mguesser 

swig: mguesser 
	swig -I./ -I/usr/include -python -o mguesser_wrap.c mguesser.i
	gcc $(CFLAGS) -fPIC -I/usr/include/python2.5 -I./ -c mguesser_wrap.c -o mguesser_wrap.o
	g++ -shared mguesser_wrap.o $(OBJECTS) -o _mguesser.so

swigtest:
	echo "testing "
	python -c  '
	import pHash
	print pHash.ph_about()
	'

install: all swiginstall

#dont forget to delete 
swiginstall:
	echo 'install'
	cp mguesser.py _mguesser.so /usr/local/lib/python2.5/site-packages/
	mkdir -p /usr/local/share/mguesser
	cp -a maps /usr/local/share/mguesser/

libmguesser:
	gcc -shared -Wl,-soname,libmguesser.so.1 -o libmguesser.so.1.0.1 guesser.o crc32.o utils.o $(LIBS)
  	
mguesser: guesser.o crc32.o utils.o Makefile
	$(CC) $(CFLAGS) $(LIBS) guesser.o crc32.o utils.o -o mguesser
 


guesser.o: guesser.c
	$(CC) $(CFLAGS) -c guesser.c

crc32.o: crc32.c
	$(CC) $(CFLAGS) -c crc32.c

utils.o: utils.c
	$(CC) $(CFLAGS) -c utils.c


clean:
	rm -f mguesser *.o *.pyc
	rm -f mguesser_wrap.c
	rm -f libmguesser.so.1.0.1 _mguesser.so