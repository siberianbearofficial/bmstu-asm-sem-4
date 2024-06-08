.model tiny
.dosseg
.data
    msg dw "oo", "ll"
    msg2 db "help"
.code
.startup
    mov ah, 09h
    db '$'
    mov dx, offset msg
    int 21h
    mov ah, 4ch
    int 21h
end