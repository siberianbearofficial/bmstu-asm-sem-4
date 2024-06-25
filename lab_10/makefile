CC = gcc

NASM_SRCS = main.asm
NASM_FLAGS = -f elf64

C_SRCS = root.c
C_HEADERS = root.h
C_FLAGS = -std=c99 -c -masm=intel -fPIE

LINK_GTK = $(shell pkg-config --libs gtk+-3.0)
LINK_FLAGS = -L/usr/lib/x86_64-linux-gnu $(LINK_GTK) -no-pie -lm

OUT = main.exe

all: link

comp_nasm:
	nasm $(NASM_FLAGS) $(NASM_SRCS)

comp_c:
	$(CC) $(C_FLAGS) $(C_SRCS)

link: comp_nasm comp_c
	$(CC) *.o $(LINK_FLAGS) -o $(OUT)

clean:
	rm -f *.o *.exe
