section .data
    msg_prefix db "Result: ", 0
    newline    db 0x0A

section .bss
    buffer     resb 16

section .text
    global _start

; int2str: EAX=число → ECX=адреса рядка, EDX=довжина
int2str:
    mov ebx, 10
    lea edi, [buffer + 15]
    mov byte [edi], 0
    xor esi, esi

    cmp eax, 0
    jne .convert
    dec edi
    mov byte [edi], '0'
    mov ecx, edi
    mov edx, 1
    ret

.convert:
    .loop:
        xor edx, edx
        div ebx
        add dl, '0'
        dec edi
        mov [edi], dl
        inc esi
        test eax, eax
        jnz .loop

    mov ecx, edi
    mov edx, esi
    ret

_start:
    mov eax, 1234567
    call int2str

    ; print "Result: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_prefix
    mov edx, 8
    int 0x80

    ; print number
    mov eax, 4
    mov ebx, 1
    int 0x80

    ; newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80
