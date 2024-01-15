AS_ARM = /usr/bin/arm-linux-gnueabihf-as
LD_ARM = /usr/bin/arm-linux-gnueabihf-ld
CFLAGS = -march=armv2a -mno-thumb-interwork -Wall -O1
LD_FLAGS = -Bstatic -fix-v4bx

all : test_add

test_add : test_add.o
	${LD_ARM} ${LD_FLAGS} -T sections.lds -o test_add test_add.o

test_add.o : test_add.s
	${AS_ARM} -c test_add.s -o test_add.o

clean :
	rm -f test_add *.o