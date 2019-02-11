CC      = gcc

CFLAGS  = -Wall -Wextra -pedantic
CFLAGS += -D_XOPEN_SOURCE=500
CFLAGS += -g

all: parcoursProfondeur

parcoursProfondeur : parcoursProfondeur.o graphe.o

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	-rm -f *.o

allclean: clean
	-rm -f plusCourteChaine
