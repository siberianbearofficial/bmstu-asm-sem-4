.model small

.stack 100h

.data
    SEP equ ' '

.code
print_sym proc
    ; вывод символа из dl
    push ax

    mov ah, 02h
    int 21h

    pop ax
    ret
print_sym endp

print_sep proc
    ; вывод разделителя
    push dx

    mov dl, SEP
    call print_sym

    pop dx
    ret
print_sep endp

main proc
    mov cx, 0
    label1:
        mov dl, ch
        call print_sym

        mov dl, cl
        call print_sym

        call print_sep

        loop label1

    mov ax, 4C00h
    int 21h
main endp

end main
