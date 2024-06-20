section .text
    global _my_strnmove

_my_strnmove:
    ; Входные параметры:
    ; di - destptr
    ; si - srcptr
    ; dx - num
    ; Выходные параметры:
    ; ax - destptr
    push rdi
    push rsi
    push rdx

    ; Если адреса назначения и источника равны, можно ничего не копировать
    cmp rdi, rsi
    je .done

    ; Если destptr > srcptr, то копируем с конца, чтобы избежать перезаписи данных
    mov rcx, rdx
    cmp rdi, rsi
    jb .forward_copy
    jmp .backward_copy

.backward_copy:
    ; Копирование с конца
    lea rsi, [rsi + rcx - 1]  ; Устанавливаем rsi на конец блока источника
    lea rdi, [rdi + rcx - 1]  ; Устанавливаем rdi на конец блока назначения
    std                       ; Устанавливаем направление копирования назад
    rep movsb                 ; Копируем байты
    cld                       ; Сбрасываем направление копирования

    jmp .done

.forward_copy:
    ; Копирование с начала
    cld                       ; Устанавливаем направление копирования вперед
    rep movsb                 ; Копируем байты

    jmp .done

.done:
    mov byte [rdi], 0         ; добавляем \0 в конец строки

    pop rdx
    pop rsi
    pop rdi

    mov rax, rdi              ; di снова содержит destptr, возвращаем через ax

    ret
