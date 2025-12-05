; hw3.asm - читає число з консолі, кладе його в AX (молодші 16 біт EAX),
; друкує число і повідомляє, чи воно просте.
; NASM, Linux x86 (elf32)

section .data
    prompt       db "Enter number: ",0
    msg_number   db "Number: ",0
    msg_prime    db " -> Prime",0
    msg_notprime db " -> Not prime",0
    newline      db 0x0A

section .bss
    inbuf   resb 64
    outbuf  resb 32

section .text
    global _start

; --- syscalls ---
write_sys:
    mov eax,4
    int 0x80
    ret

read_sys:
    mov eax,3
    int 0x80
    ret

; --- str2int: ECX=buf, EDX=len -> EAX=result, EBX=ok(1/0) ---
str2int:
    xor eax,eax        ; result = 0
    xor ebx,ebx        ; ok = 0
    mov esi,ecx        ; ptr
    mov ecx,edx        ; len

.s_loop:
    cmp ecx,0
    je .s_done
    mov dl,[esi]       ; символ у DL
    cmp dl,0x0A        ; newline -> стоп
    je .s_done
    cmp dl,'0'
    jb .s_done
    cmp dl,'9'
    ja .s_done

    sub dl,'0'         ; DL = digit (0..9)
    movzx edi,dl       ; EDI = digit
    imul eax,eax,10    ; EAX = EAX * 10
    add eax,edi        ; EAX += digit
    mov ebx,1          ; ok = 1

    inc esi
    dec ecx
    jmp .s_loop

.s_done:
    ret

; --- int2str: EAX=number -> ECX=ptr, EDX=len (string in outbuf) ---
int2str:
    mov ebx,10
    lea edi,[outbuf+31]
    mov byte [edi],0
    xor esi,esi        ; len = 0

    cmp eax,0
    jne .conv
    dec edi
    mov byte [edi],'0'
    mov ecx,edi
    mov edx,1
    ret

.conv:
    xor edx,edx
    div ebx             ; EAX = EAX/10, EDX = remainder
    add dl,'0'
    dec edi
    mov [edi],dl
    inc esi
    test eax,eax
    jnz .conv

    mov ecx,edi
    mov edx,esi
    ret

; --- is_prime: EAX=n -> EAX=1 (prime) / 0 (not) ---
is_prime:
    push ebx
    push ecx
    push edx

    mov ebx,eax        ; n
    cmp ebx,2
    jl .notp
    cmp ebx,2
    je .prime

    ; якщо парне -> не просте
    mov eax,ebx
    xor edx,edx
    mov ecx,2
    div ecx
    test edx,edx
    je .notp

    mov ecx,3
.loop_check:
    mov eax,ecx
    mul ecx             ; eax = ecx*ecx
    cmp eax,ebx
    jg .prime           ; якщо d^2 > n -> просте

    mov eax,ebx
    xor edx,edx
    div ecx
    test edx,edx
    je .notp

    add ecx,2
    jmp .loop_check

.prime:
    mov eax,1
    pop edx
    pop ecx
    pop ebx
    ret

.notp:
    mov eax,0
    pop edx
    pop ecx
    pop ebx
    ret

; --- main ---
_start:
    ; 1) prompt
    mov ebx,1
    mov ecx,prompt
    mov edx,14
    call write_sys

    ; 2) read line
    mov ebx,0
    mov ecx,inbuf
    mov edx,64
    call read_sys        ; EAX = bytes read

    ; 3) parse -> EAX = number, EBX = ok
    mov ecx,inbuf
    mov edx,eax
    call str2int
    cmp ebx,1
    jne .bad_input

    ; 4) число в EAX (AX — молодші 16 біт)
    push eax

    ; 5) print "Number: "
    mov ebx,1
    mov ecx,msg_number
    mov edx,8
    call write_sys

    ; 6) print number string
    mov eax,[esp]
    call int2str         ; ECX=ptr, EDX=len
    mov ebx,1
    call write_sys

    ; 7) prime check
    mov eax,[esp]
    call is_prime
    cmp eax,1
    je .print_prime

.print_not:
    mov ebx,1
    mov ecx,msg_notprime
    mov edx,12
    call write_sys
    jmp .after

.print_prime:
    mov ebx,1
    mov ecx,msg_prime
    mov edx,9
    call write_sys

.after:
    add esp,4
    mov ebx,1
    mov ecx,newline
    mov edx,1
    call write_sys

    ; exit
    mov eax,1
    xor ebx,ebx
    int 0x80

.bad_input:
    mov ebx,1
    mov ecx,msg_notprime
    mov edx,12
    call write_sys
    mov eax,1
    xor ebx,ebx
    int 0x80