NASM_flags = -f elf32
CC_flags = -m32 -Wall -ansi -c -nostdlib -fno-stack-protector
LD_flags = -m elf_i386

task = task0
O_files = start.o main.o util.o

# Default target
all: $(task)

# Assemble the glue code
start.o: start.s
	nasm $(NASM_flags) start.s -o start.o

# Compile the main.c file
main.o: main.c util.h
	gcc $(CC_flags) main.c -o main.o

# Compile the util.c file
util.o: util.c util.h
	gcc $(CC_flags) util.c -o util.o

# Link everything together
$(task): $(O_files)
	ld $(LD_flags) $(O_files) -o $(task)

clean:
	rm -f $(task) $(O_files)

.PHONY: all clean
