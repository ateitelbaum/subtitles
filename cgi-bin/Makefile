CC = gcc
CFLAGS = -Wall -O2 -I $(CSAPP_INC) -I

all: subtitles  

subtitles: subtitles.c
	gcc -Wall -O2 -I ../../../../include -I . subtitles.c ../../../../src/csapp.o -lpthread -o subtitles


clean:
	rm -f subtitles *~
