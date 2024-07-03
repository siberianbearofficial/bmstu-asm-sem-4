.model tiny

.code
    org 100h                            ; отступ для заголовка

main:
    jmp init

    is_inited       db 1                ; установлен ли резидент
    cur_speed       db 1Fh              ; начальная скорость автоповтора ввода (минимальная - 2 с/с)
    cur_time        db 0                ; время в секундах

inc_input_speed proc near
    mov ah, 02h
    int 1Ah                             ; получаем текущее время с помощью BIOS прерывания 1Ah

    cmp dh, cur_time
    je skip_speed_change                ; если время (количество секунд в таймере компьютера) не изменилось, пропускаем изменение скорости

    mov cur_time, dh                    ; если время увеличилось, то заносим его в переменную
    dec cur_speed                       ; уменьшаем скорость автоповтора ввода

    cmp cur_speed, 1Fh
    jbe set_speed

    mov cur_speed, 1Fh

    set_speed:
        mov al, 0F3h                    ; команда для настройки автоповтора
        out 60h, al
        mov al, cur_speed               ; устанавливаем новую скорость автоповтора
        out 60h, al

    skip_speed_change:
        ; прямой переход к старому обработчику прерывания
        db 0EAh ; байт-код прямого перехода
        handler_segment dw 0
        handler_addr dw 0

inc_input_speed endp

init:
    ; ah = 35h, al = 1Ch - получаем адрес текущего обработчика прерывания таймера (1Ch) в es:bx
    mov ax, 351Ch
    int 21h

    ; если программа запускается не в первый раз, то выходим
    cmp es:is_inited, 1
    je exit

    mov handler_segment, bx
    mov handler_addr, es

    ; ah = 25h, al = 1Ch - заменяем вектор 1Ch в таблице векторов прерываний на свой из dx
    mov ax, 251Ch
    mov dx, offset inc_input_speed
    int 21h

    ; сообщение об установке
    mov dx, offset init_msg
    mov ah, 09h
    int 21h

    ; завершаем программу резидентной (всё, начиная с адреса метки init, будет освобождено из памяти)
    mov dx, offset init
    int 27h

exit:
    ; сообщение о завершении
    mov dx, offset exit_msg
    mov ah, 09h
    int 21h

    mov al, 0F3h        ; команда для настройки автоповтора
    out 60h, al
    mov al, 0           ; восстанавливаем стандартные значения (период 30.0, задержку 250 мс)
    out 60h, al

    ; восстанавливаем старый обработчик прерывания
    mov dx, es:handler_segment
    mov ds, es:handler_addr
    mov ax, 251Ch
    int 21h

    ; освобождаем память
    mov ah, 49h
    int 21h

    ; завершаем программу
    mov ax, 4c00h
    int 21h

    init_msg db 'Started.', '$', 10, 13
    exit_msg db 'Finished.', '$', 10, 13

end main
