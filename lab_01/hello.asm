.model tiny
.dosseg
.data
    msg db "Hello, World!", 0dh, 0ah, '$'
.code
.startup
    mov ah, 09h
    mov dx, offset msg
    int 21h
    mov ah, 4ch
    int 21h
end