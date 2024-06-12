#include "util.h"

#define SYS_WRITE 4
#define STDOUT 1
#define SYS_OPEN 5
#define O_RDWR 2
#define SYS_SEEK 19
#define SEEK_SET 0
#define SHIRA_OFFSET 0x291

extern void system_call(int syscall, int arg1, int arg2, int arg3);

int main(int argc, char* argv[], char* envp[]) {
    /* 0a */
    int i;
    for (i = 1; i < argc; i++) {
        char* arg = argv[i];
        int len = 0;

        /* Calculate the length of the argument string */
        while (arg[len] != '\0') {
            len++;
        }

        /* Print the argument string to stdout */
        system_call(SYS_WRITE, STDOUT, (int)arg, len);
        system_call(SYS_WRITE, STDOUT, (int)"\n", 1);
    }
    /* 0a */

    return 0;
}
