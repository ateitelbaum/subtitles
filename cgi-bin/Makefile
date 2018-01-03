CC = gcc
CFLAGS = -Wall -O2 -I $(CSAPP_INC) -I

LIBBINCLUDE = ../libxml2/include/libxml2
LIBB = ../libxml2/lib
CFLAGS= -I $(LIBBINCLUDE)

LIBS=""
all: subtitles  

subtitles: subtitles.c
	gcc -Wall -O2 -I ../../../../include -I . $(CFLAGS) -L ../libxml2/lib  subtitles.c ../../../../src/csapp.o -lpthread -lxml2 -o subtitles 


clean:
	rm -f subtitles *~
