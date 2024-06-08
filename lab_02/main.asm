StkSeg SEGMENT PARA STACK 'STACK'
DB 200h DUP (?)
StkSeg ENDS
;
DataS SEGMENT WORD 'DATA'
HelloMessage DB 13 ; курсор поместить в начало строки
DB 10 ; перевести курсор на новую строку
DB 'Hello, world !' ; текст сообщения
DB '$' ; ограничитель для функции DOS
DataS ENDS
;
Code SEGMENT WORD 'CODE'
ASSUME CS:Code, DS:DataS
DispMsg:
    mov ax, DataS ; загрузка в AX адреса сегмента данных
    mov ds, ax ; установка DS
    mov dx, offset HelloMessage ; DS:DX - адрес строки
    mov ah, 09h ; выдать на дисплей строку
    mov cx, 3
    label1:
        int 21h ; вызов функции DOS
        loop label1
    mov ah, 07h ; ввести символ без эха
    int 21h ; вызов функции DOS
    mov ah, 4Ch ; завершить процесс
    int 21h ; вызов функции DOS
Code ENDS
;
END DispMsg ; точка входа
