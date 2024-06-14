#include "util.h"

#define SYS_WRITE 4
#define STDOUT 1
#define SYS_OPEN 5
#define O_RDWR 2
#define SYS_SEEK 19
#define SEEK_SET 0
#define SHIRA_OFFSET 0x291

extern void system_call(int syscall, int arg1, int arg2, int arg3);
extern void infection();
extern void infector(char *filename);

int main(int argc, char* argv[], char* envp[]) {
    if (argc < 2) {
        /* Print an error message and exit with code 0x55 if no file name is provided */
        system_call(4, 1, (int)"Usage: ./program_name filename", 34);
        system_call(1, 0x55, 0, 0);
    }

    /* Print the file name provided in the command-line argument */
    system_call(4, 1, (int)"File name: ", 11);
    system_call(4, 1, (int)argv[1], strlen(argv[1]));
    system_call(4, 1, (int)"\n", 1); 
    
    /* Call the assembly functions (stubs) */
    infection();
    infector(argv[1]);

    system_call(4, 1, (int)"File name: ", 11);
    
    

    /* 0a */
    /*
    int i;
    for (i = 1; i < argc; i++) {
        char* arg = argv[i];
        int len = 0;

        * Calculate the length of the argument string *
        while (arg[len] != '\0') {
            len++;
        }

        * Print the argument string to stdout *
        system_call(SYS_WRITE, STDOUT, (int)arg, len);
        system_call(SYS_WRITE, STDOUT, (int)"\n", 1);
    }
    */
    /* 0a */

    return 0;
}

