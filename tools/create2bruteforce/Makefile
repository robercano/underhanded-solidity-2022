CC = gcc
LD = ld

CFLAGS = -Wall -c -Ofast
LDFLAGS=-Ofast

OBJS = create2bruteforce.o keccak.o

.PHONY: all clean

create2bruteforce: create2bruteforce.o keccak.o
	$(CC) $(LDFLAGS) $(OBJS) -o create2bruteforce

%.o:%.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	-$(RM) *.o
	-$(RM) tests/*.o
	-$(RM) keccak
	-$(RM) keccak_tiny
