CC = clang
SRC_32 = float_32.c
SRC_64 = double_64.c

SRC = double_64.o float_32.o measure.o sinus.o main.o


all: auto_m80387 m80387 no_m80387

asm : $(SRC_32) $(SRC_64)
	$(CC) -O0 -S  -fverbose-asm $(SRC_32)
	$(CC) -O0 -S  -fverbose-asm $(SRC_32) -m80387
	$(CC) -O0 -S  -fverbose-asm $(SRC_32) -mno-80387
	$(CC) -O0 -S  -fverbose-asm $(SRC_64)
	$(CC) -O0 -S  -fverbose-asm $(SRC_64) -m80387
	$(CC) -O0 -S  -fverbose-asm $(SRC_64) -mno-80387

%.o : %.c
	$(CC) -O0 -c $^

auto_m80387: $(SRC)
	$(CC) $^ -lstdc++ -o auto_m80387.exe

m80387: $(SRC)
	$(CC) $^ -lstdc++ -o m80387.exe

no_m80387: $(SRC)
	$(CC) $^ -lstdc++ -o no_m80387.exe

clean:
	$(RM) -rf *.asm *.o *.exe
