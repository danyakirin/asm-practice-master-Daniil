  section .data
       msg db "Hello from Assembly!", 0Ah
       len equ $ - msg

   section .text
       global _start

   _start:
       mov eax, 4      ; syscall write
       mov ebx, 1      ; stdout
       mov ecx, msg
       mov edx, len
       int 0x80

       mov eax, 1      ; syscall exit
       xor ebx, ebx
       int 0x80