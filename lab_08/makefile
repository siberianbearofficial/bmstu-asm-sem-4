CC = clang
CC_OPTIONS = -c

C_SRCS = $(wildcard *.c)

OUT = main.exe

all: link

comp_c:
	$(CC) $(CC_OPTIONS) $(C_SRCS)

link: comp_c
	$(CC) -o $(OUT) *.o

clean:
	$(RM) -f *.o $(OUT)
