NASM_CC = nasm
NASM_CC_OPTIONS = -fmacho64

CC = clang
CC_OPTIONS = -c

NASM_SRCS = $(wildcard *.asm)
C_SRCS = $(wildcard *.c)

OUT = main.exe

all: link

comp_nasm:
	$(NASM_CC) $(NASM_CC_OPTIONS) $(NASM_SRCS)

comp_c:
	$(CC) $(CC_OPTIONS) $(C_SRCS)

link: comp_nasm comp_c
	$(CC) -o $(OUT) *.o

clean:
	$(RM) -f *.o $(OUT)
