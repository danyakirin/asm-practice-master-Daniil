section .data
    newline db 0x0A
    msg_prefix db "Result: ", 0

section .bss
    buffer resb 16     ; буфер для числа у вигляді рядка

section .text
    global _start

; -------------------------------
; int2str: перетворює число в рядок
; Вхід:  EAX = число, ESI = адреса буфера
; Вихід: EAX = адреса рядка
; -------------------------------
int2str:
    push ebp
    mov  ebp, esp
    push esi
    push edi
    push ebx
    push ecx
    push edx

    mov  edi, esi          ; вказівник для запису
    mov  ebx, 10           ; дільник = 10

    ; якщо число == 0
    cmp  eax, 0
    jne  .check_neg
    mov  byte [edi], '0'
    inc  edi
    mov  byte [edi], 0
    mov  eax, esi
    jmp  .done

.check_neg:
    ; якщо число < 0
    cmp  eax, 0
    jge  .digits
    neg  eax
    mov  byte [edi], '-'
    inc  edi

.digits:
    mov  ecx, edi          ; початок цифр

.extract_loop:
    xor  edx, edx
    div  ebx               ; ділимо на 10
    add  dl, '0'           ; залишок → ASCII
    mov  [edi], dl
    inc  edi
    cmp  eax, 0
    jne  .extract_loop

    ; розворот цифр
    mov  esi, ecx
    lea  edx, [edi-1]

.rev_loop:
    cmp  esi, edx
    jge  .terminate
    mov  al, [esi]
    mov  ah, [edx]
    mov  [esi], ah
    mov  [edx], al
    inc  esi
    dec  edx
    jmp  .rev_loop

.terminate:
    mov  byte [edi], 0     ; завершення рядка
    mov  eax, [ebp+8]      ; повертаємо адресу буфера

.done:
    pop  edx
    pop  ecx
    pop  ebx
    pop  edi
    pop  esi
    pop  ebp
    ret

; -------------------------------
; Демонстрація роботи
; -------------------------------
_start:
    mov  eax, 1234567
    mov  esi, buffer
    call int2str

    ; вивести "Result: "
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_prefix
    mov  edx, 8
    int  0x80

    ; вивести число
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, buffer
    mov  edx, 0
.len_loop:
    cmp  byte [ecx+edx], 0
    je   .have_len
    inc  edx
    jmp  .len_loop
.have_len:
    int  0x80

    ; новий рядок
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, newline
    mov  edx, 1
    int  0x80

    ; завершення програми
    mov  eax, 1
    xor  ebx, ebx
    int  0x80
