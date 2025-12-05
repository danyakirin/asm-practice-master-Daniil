section .data
    msg db "Result: ",0
    nl  db 0x0A

section .bss
    buf resb 16

section .text
    global _start

; int2str: EAX=число → ECX=адреса, EDX=довжина
int2str:
    mov ebx,10
    lea edi,[buf+15]
    mov byte [edi],0
    xor esi,esi
.loop:
    xor edx,edx
    div ebx
    add dl,'0'
    dec edi
    mov [edi],dl
    inc esi
    test eax,eax
    jnz .loop
    mov ecx,edi
    mov edx,esi
    ret

_start:
    mov eax,1234
    call int2str

    ; print "Result: "
    mov eax,4
    mov ebx,1
    mov ecx,msg
    mov edx,8
    int 0x80

    ; print number
    mov eax,4
    mov ebx,1
    int 0x80

    ; newline
    mov eax,4
    mov ebx,1
    mov ecx,nl
    mov edx,1
    int 0x80

    ; exit
    mov eax,1
    xor ebx,ebx
    int 0x80
