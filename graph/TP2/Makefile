CC      = gcc

CFLAGS  = -Wall -Wextra -pedantic
CFLAGS += -D_XOPEN_SOURCE=500
CFLAGS += -g

all: creePs

creePs : Q8.o graphe.o

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o

allclean: clean
	-rm -f Q8
