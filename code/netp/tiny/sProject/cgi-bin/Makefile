CC = gcc
CFLAGS = -Wall -O2 -I $(CSAPP_INC) -I

CSAPP_INC = ../../../include
CSAPP_SRC = ../../../src
LDLIBS = -lpthread


all: $(CSAPP_SRC)/csapp.o $(PROGS) subtitles 
$(PROGS): $(CSAPP_SRC)/ csapp.o
$(CSAPP_SRC)/csapp.o: $(CSAPP_SRC)/csapp.c $(CSAPP_INC)/csapp.h 

subtitles: subtitles.c
	$(CC) $(CFLAGS) -o subtitles subtitles.c

clean:
	rm -f subtitles *~
