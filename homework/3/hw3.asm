; --- str2int: ECX=buf, EDX=len -> EAX=result, EBX=ok(1/0) ---
str2int:
    xor eax, eax        ; result = 0
    xor ebx, ebx        ; ok = 0
    mov esi, ecx        ; ptr
    mov ecx, edx        ; len

.s_loop:
    cmp ecx, 0
    je .s_done
    mov dl, [esi]       ; символ у DL
    cmp dl, 0x0A        ; newline -> стоп
    je .s_done
    cmp dl, '0'
    jb .s_done
    cmp dl, '9'
    ja .s_done

    sub dl, '0'         ; DL = digit (0..9)
    movzx edi, dl       ; EDI = digit
    imul eax, eax, 10   ; EAX = EAX * 10
    add eax, edi        ; EAX += digit
    mov ebx, 1          ; ok = 1

    inc esi
    dec ecx
    jmp .s_loop

.s_done:
    ret

