NASM_flags = -f elf32
cgg_flags = -m32 -Wall -ansi -c -nostdlib -fno-stack-protector
ld_flags = -m elf_i386

task = task0
O_files = start.o main.o util.o

# Default target
all: $(task)

# Assemble the glue code
start.o: start.s
	nasm $(NASM_flags) start.s -o start.o

# Compile the main.c file
main.o: main.c
	gcc $(cgg_flags) main.c -o main.o

# Compile the util.c file
util.o: util.c
	gcc $(cgg_flags) util.c -o util.o

# Link everything together
$(task): $(O_files)
	ld $(ld_flags) $(O_files) -o $(task)

# Clean up generated files
clean:
	rm -f $(task) $(O_files)

.PHONY: all clean
