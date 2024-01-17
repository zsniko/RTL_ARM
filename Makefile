AS_ARM = /usr/bin/arm-linux-gnueabihf-as
LD_ARM = /usr/bin/arm-linux-gnueabihf-ld
CFLAGS = -march=armv2a -mno-thumb-interwork -Wall -O1
LD_FLAGS = -Bstatic -fix-v4bx

all : test_pgcd

test_pgcd : test_pgcd.o
	${LD_ARM} ${LD_FLAGS} -T sections.lds -o test_pgcd test_pgcd.o

test_pgcd.o : test_pgcd.s
	${AS_ARM} -c test_pgcd.s -o test_pgcd.o

clean :
	rm -f test_pgcd *.o