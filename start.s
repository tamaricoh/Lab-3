section .data
    hello db 'Hello world!', 0xA  ; our dear string and a linefeed
    helloLen equ $-hello         ; length of the string
    msg db 'Command-line arguments:', 0xA, 0
    msg_len equ $ - msg
    newline db 10,0           ; newline character followed by null terminator
    infile: dd 0               ; file descriptor for input file, initially 0 (stdin)
    outfile: dd 1              ; file descriptor for output file, initially 1 (stdout)

section .bss
    input_buffer:  resb 512       ; reserve 512 bytes for input buffer
    
section .text
global _start
global system_call
extern strlen
extern strncmp

_start:

    ; Print "Hello world!"
    mov     edx, helloLen   ; message length
    mov     ecx, hello      ; message to write
    mov     ebx, 1          ; file descriptor (stdout)
    mov     eax, 4          ; system call number (sys_write)
    int     0x80            ; call kernel

    pop     dword ecx        ; ecx = argc
    mov     esi,esp          ; esi = argv
    mov     eax,ecx         ; put the number of arguments into eax
    shl     eax,2           ; compute the size of argv in bytes
    add     eax,esi         ; add the size to the address of argv 
    add     eax,4           ; skip NULL at the end of argv
    push    dword eax       ; char *envp[]
    push    dword esi       ; char* argv[]
    push    dword ecx       ; int argc

    call main               ; call the main function

    mov     ebx,0           ; prepare for exit
    mov     eax,1           ; system call number (sys_exit)
    int     0x80            ; call kernel
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

main:
    push    ebp             ; Save caller state
    mov     ebp, esp
    mov     edi, 0

    call check_args
    
    mov     eax, 3
    mov     ebx, [infile]
    mov     ecx, input_buffer
    mov     edx, 512
    int     0x80

    mov     esi, ecx

    ; call encode

    ret

check_args:
    push    ecx 
    mov     ecx, [esi+4*edi]
    
;     call checkInFlag
;     call checkOutFlag

    push    ecx
    call strlen
    mov     edx, eax
    pop     ecx
    mov     eax, 4
    mov     ebx, 1
    int     0x80

    push    dword 1
    push    dword newline
    push    dword 1
    push    dword 4
    call system_call
    add     esp, 4*4

    pop     ecx 
    inc     edi
    cmp     edi,ecx
    jne check_args
    ret

; checkInFlag:
;     cmp word [ecx], '-'+(256*'i')
;     je changeInput
;     ret

; changeInput:
;     push ecx
;     add ecx, 2
;     mov eax, 5
;     mov ebx, ecx
;     mov ecx, 0
;     int 0x80
;     mov [infile], eax
;     pop ecx
;     ret

; checkOutFlag:
;     cmp word [ecx], '-'+(256*'o')
;     je changeOutput
;     ret

; changeOutput:
;     push ecx
;     add ecx, 2
;     mov eax, 8
;     mov ebx, ecx
;     mov ecx, 0777
;     int 0x80
;     mov [outfile], eax
;     pop ecx
;     ret

; encode:
;     mov bl, byte[esi]    
;     cmp bl, 0x00        
;     jne checkCapital

;     push ecx
;     call strlen
;     mov edx, eax
;     pop eax

;     mov eax, 4
;     mov ebx, [outfile]
;     int 0x80

;     mov eax, 6
;     mov ebx, [infile]   
;     int 0x80

;     mov eax, 6
;     mov ebx, [outfile]  
;     int 0x80

;     ret

; nonAlph:
;     inc esi
;     jmp encode

; increment:
;     inc bl
;     mov byte[esi], bl 
;     inc esi
;     jmp encode

; checkSmallLetter:
;     cmp bl, 'z'
;     jg nonAlph
;     call increment    

; checkCapital:
;     cmp bl, 'A'
;     jl nonAlph
;     cmp bl, 'Z'
;     jg checkSmallLetter
;     call increment





; _start:
;     ; Print "Hello world!"
;     mov edx, helloLen   ; message length
;     mov ecx, hello      ; message to write
;     mov ebx, 1          ; file descriptor (stdout)
;     mov eax, 4          ; system call number (sys_write)
;     int 0x80            ; call kernel

;     ; Print "Command-line arguments:" message
;     mov edx, msg_len    ; message length
;     mov ecx, msg        ; message to write
;     mov ebx, 1          ; file descriptor (stdout)
;     mov eax, 4          ; system call number (sys_write)
;     int 0x80            ; call kernel

;     ; Prepare arguments for main function call
;     pop ecx             ; argc
;     mov esi, esp        ; save initial address of argv

;     ; Check if there are any arguments
;     cmp ecx, 1
;     jle .no_arguments

;     ; Print each argument
;     mov edx, ecx        ; number of arguments
;     mov ebx, esi        ; argv
;     add ebx, 4          ; move to argv[1] (skip program name)
;     mov eax, 4          ; syscall number for sys_write

; .print_arguments_loop:
;     ; Load address of argument string
;     mov edi, [ebx]      ; argv[i]

;     ; Print the argument string
;     mov ebx, 1          ; file descriptor for stdout
;     mov ecx, edi        ; pointer to the argument string
;     int 0x80            ; call kernel

;     ; Print newline
;     mov edx, 1          ; message length (1 byte for newline)
;     mov ecx, newline    ; message to write
;     int 0x80            ; call kernel

;     ; Move to the next argument
;     add ebx, 4          ; move to the next argument
;     dec edx             ; decrement argument counter
;     jnz .print_arguments_loop ; loop until all arguments are printed

; .no_arguments:
;     ; Exit the program
;     xor ebx, ebx        ; exit status
;     mov eax, 1          ; system call for sys_exit
;     int 0x80            ; call kernel

; system_call:
;     push    ebp             ; Save caller state
;     mov     ebp, esp
;     sub     esp, 4          ; Leave space for local var on stack
;     pushad                  ; Save some more caller state

;     mov     eax, [ebp+8]    ; Copy function args to registers: leftmost...        
;     mov     ebx, [ebp+12]   ; Next argument...
;     mov     ecx, [ebp+16]   ; Next argument...
;     mov     edx, [ebp+20]   ; Next argument...
;     int     0x80            ; Transfer control to operating system
;     mov     [ebp-4], eax    ; Save returned value...
;     popad                   ; Restore caller state (registers)
;     mov     eax, [ebp-4]    ; place returned value where caller can see it
;     add     esp, 4          ; Restore caller state
;     pop     ebp             ; Restore caller state
;     ret                     ; Back to caller

