.model small

.code
public lower_cap_let_even_ind

lower_let proc
    ; сделать букву строчной
    add dl, 32

    ret
lower_let endp

lower_let_even_ind proc
    ; сделать заглавную букву строчной
    push ax

    mov al, dl
    sub al, 'A'
    test al, 1
    jnz skip_even
    call lower_let

    skip_even:
        pop ax
        ret
lower_let_even_ind endp

lower_cap_let_even_ind proc
    ; сделать заглавную букву с четной позицией в алфавите строчной
    cmp dl, 'A'
    jb skip_cap
    cmp dl, 'Z'
    ja skip_cap
    call lower_let_even_ind

    skip_cap:
        ret
lower_cap_let_even_ind endp

end
