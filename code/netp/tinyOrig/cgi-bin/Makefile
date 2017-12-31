CC = gcc
CFLAGS = -O2 -Wall -I ..

all: adder subtracter subtitles

adder: adder.c
	$(CC) $(CFLAGS) -o adder adder.c

subtracter: subtracter.c
	$(CC) $(CFLAGS) -o subtracter subtracter.c

subtitles: subtitles.c
	$(CC) $(CFLAGS) -o subtitles subtitles.c


clean:
	rm -f adder *~
	rm -f subtracter *~
	rm -f subtitles *~
