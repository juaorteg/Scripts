section .data

msg   db    "Hello, world!"

section .text

global _start

_start:

; write() call

mov eax, 4
mov ebx, 1
mov ecx, msg
mov edx, 13
int 0x80

; exit() call

mov eax, 1
mov ebx, 0
int 0x80
