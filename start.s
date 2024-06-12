section .data
    hello db 'hello world', 0xA  ; our dear string and a linefeed
    helloLen equ $-hello         ; length of the string

section .text
global _start
global system_call
extern main

_start:
    ; Print "hello world"
    mov edx, helloLen   ; message length
    mov ecx, hello      ; message to write
    mov ebx, 1          ; file descriptor (stdout)
    mov eax, 4          ; system call number (sys_write)
    int 0x80            ; call kernel

    ; Prepare arguments for main function call
    pop    dword ecx    ; ecx = argc
    mov    esi, esp     ; esi = argv

    ; Calculate the size of argv in bytes
    mov     eax, ecx    ; put the number of arguments into eax
    shl     eax, 2      ; compute the size of argv in bytes
    add     eax, esi    ; add the size to the address of argv 
    add     eax, 4      ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    ; Call main function
    call    main        ; int main( int argc, char *argv[], char *envp[] )

    ; Exit the program
    mov     ebx, eax    ; store the return value of main in ebx (exit status)
    mov     eax, 1      ; system call for sys_exit
    int     0x80        ; call kernel
        
system_call:
    push    ebp             ; Save caller state
    mov     ebp, esp
    sub     esp, 4          ; Leave space for local var on stack
    pushad                  ; Save some more caller state

    mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
    mov     ebx, [ebp+12]   ; Next argument...
    mov     ecx, [ebp+16]   ; Next argument...
    mov     edx, [ebp+20]   ; Next argument...
    int     0x80            ; Transfer control to operating system
    mov     [ebp-4], eax    ; Save returned value...
    popad                   ; Restore caller state (registers)
    mov     eax, [ebp-4]    ; place returned value where caller can see it
    add     esp, 4          ; Restore caller state
    pop     ebp             ; Restore caller state
    ret                     ; Back to caller

