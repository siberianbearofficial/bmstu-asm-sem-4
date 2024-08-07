bits 64
global main
global steps_buffer

%define GTK_WIN_POS_CENTER 1
%define GTK_WIN_WIDTH 210
%define GTK_WIN_HEIGHT 290

extern exit
extern gtk_init
extern gtk_main
extern g_object_set
extern gtk_main_quit
extern gtk_window_new
extern gtk_widget_show
extern g_signal_connect
extern gtk_window_set_title
extern g_signal_connect_data
extern gtk_window_set_position
extern gtk_settings_get_default
extern gtk_widget_set_size_request
extern gtk_window_set_default_size

extern gtk_widget_show_all


extern gtk_layout_new
extern gtk_layout_put

extern gtk_label_new
extern gtk_label_set_text

extern gtk_container_add

extern gtk_entry_new
extern gtk_entry_set_placeholder_text
extern gtk_entry_set_text
extern gtk_entry_get_text

extern gtk_button_new_with_label

extern g_ascii_strtod
extern g_ascii_dtostr

extern root_str

section .bss
    window: resq 1
    layout: resq 1
    entry_1: resq 1
    entry_2: resq 1
    entry_3: resq 1
    calc_btn: resq 1
    result_label_text: resq 1
    result_label: resq 1


section .rodata
    signal:
    .destroy: db "destroy", 0
    .clicked: db "clicked", 0
    title: db "Корень", 0
    task_text: db "cos(x^3 + 7)", 0
    btn_result_text: db "Найти корень", 0
    result: db "Результат: ", 0
    a_input_ph: db "a", 0
    b_input_ph: db "b", 0
    steps_input_ph: db "steps", 0

section .data
    steps_buffer: db 1000 dup(0)

    start: dq 1
    end: dq 1
    step_count: dq 1

    PADDING_START equ 20
    PADDING_TOP equ 20
    GAP equ 45

section .text

    _destroy_window:
        jmp gtk_main_quit  ; вызываем gtk_main_quit для завершения приложения


    _clicked_calc_btn:
        push rbp

        ; достаем текст a
        mov rdi, qword [ rel entry_1 ]
        call gtk_entry_get_text
        mov qword [ rel start ], rax

        ; достаем текст b
        mov rdi, qword [ rel entry_2 ]
        call gtk_entry_get_text
        mov qword [ rel end ], rax

        ; достаем текст steps
        mov rdi, qword [ rel entry_3 ]
        call gtk_entry_get_text
        mov qword [ rel step_count ], rax

        ; проводим основные вычисления
        mov rdi, qword [ rel start ]
        mov rsi, qword [ rel end ]
        mov rdx, qword [ rel step_count ]
        call root_str

        ; устанавливаем текст result_label для отображения в интерфейсе
        mov rdi, qword [ rel result_label ]
        mov rsi, steps_buffer
        call gtk_label_set_text

        pop rbp
        ret

    main:
        push rbp

        mov rbp, rsp
        xor rdi, rdi
        xor rsi, rsi
        call gtk_init  ; rdi и rsi = 0 - нет аргументов командной строки

        ; создаем новое окно, указатель кладем в window
        xor rdi, rdi
        call gtk_window_new
        mov qword [ rel window ], rax

        mov rdi, qword [ rel window ]
        mov rsi, title
        call gtk_window_set_title  ; устанавливаем заголовок

        mov rdi, qword [ rel window ]
        mov rsi, GTK_WIN_WIDTH
        mov rdx, GTK_WIN_HEIGHT
        call gtk_window_set_default_size  ; устанавливаем размер

        mov rdi, qword [ rel window ]
        mov rsi, GTK_WIN_POS_CENTER
        call gtk_window_set_position  ; устанавливаем позицию

        ; обработка события закрытия окна, связываем сигнал с функцией _destroy_window
        mov rdi, qword [ rel window ]
        mov rsi, signal.destroy
        mov rdx, _destroy_window
        xor rcx, rcx
        xor r8d, r8d
        xor r9d, r9d
        call g_signal_connect_data

        ; создаем GtkLayout для размещения других виджетов
        xor rdi, rdi
        xor rsi, rsi
        call gtk_layout_new
        mov qword [ rel layout ], rax

        ; добавляем layout в главное окно
        mov rsi, qword [ rel layout ]
        mov rdi, qword [ rel window ]
        call gtk_container_add

        ; текст задачи
        mov rdi, task_text
        call gtk_label_new

        mov rsi, rax
        mov rdi, qword [ rel layout ]
        mov rdx, PADDING_START
        mov rcx, PADDING_TOP
        call gtk_layout_put

        ; поле ввода для a
        xor rdi, rdi
        call gtk_entry_new
        mov qword [ rel entry_1 ], rax

        mov rdi, qword [ rel entry_1 ]
        mov rsi, a_input_ph
        call gtk_entry_set_placeholder_text  ; подсказка для ввода

        mov rdi, qword [ rel layout ]
        mov rsi, qword [ rel entry_1 ]
        mov rdx, PADDING_START
        mov rcx, PADDING_TOP + GAP
        call gtk_layout_put

        ; поле ввода для b
        xor rdi, rdi
        call gtk_entry_new
        mov qword [ rel entry_2 ], rax

        mov rdi, qword [ rel entry_2 ]
        mov rsi, b_input_ph
        call gtk_entry_set_placeholder_text  ; подсказка для ввода

        mov rdi, qword [ rel layout ]
        mov rsi, qword [ rel entry_2 ]
        mov rdx, PADDING_START
        mov rcx, PADDING_TOP + 2 * GAP
        call gtk_layout_put

        ; поле ввода для steps
        xor rdi, rdi
        call gtk_entry_new
        mov qword [ rel entry_3 ], rax

        mov rdi, qword [ rel entry_3 ]
        mov rsi, steps_input_ph
        call gtk_entry_set_placeholder_text  ; подсказка для ввода

        mov rdi, qword [ rel layout ]
        mov rsi, qword [ rel entry_3 ]
        mov rdx, PADDING_START
        mov rcx, PADDING_TOP + 3 * GAP
        call gtk_layout_put

        ; кнопка для запуска вычислений
        mov rdi, btn_result_text
        call gtk_button_new_with_label
        mov qword [ rel calc_btn ], rax

        mov rdi, qword [ rel layout ]
        mov rsi, qword [ rel calc_btn ]
        mov rdx, PADDING_START
        mov rcx, PADDING_TOP + 4 * GAP
        call gtk_layout_put

        ; связываем сигнал clicked с функцией _clicked_calc_btn для обработки нажатия на кнопку
        mov rdi, qword [ rel calc_btn ]
        mov rsi, signal.clicked
        mov rdx, _clicked_calc_btn
        xor rcx, rcx
        xor r8d, r8d
        xor r9d, r9d
        call g_signal_connect_data

        ; результат (подпись)
        mov rdi, result
        call gtk_label_new
        mov qword [ rel result_label_text ], rax

        mov rdi, qword [ rel layout ]
        mov rsi, qword [ rel result_label_text ]
        mov rdx, PADDING_START
        mov rcx, PADDING_TOP + 5 * GAP
        call gtk_layout_put

        ; поле для вывода результата
        xor rdi, rdi
        call gtk_label_new
        mov qword [ rel result_label ], rax

        mov rdi, qword [ rel layout ]
        mov rsi, qword [ rel result_label ]
        mov rdx, PADDING_START + 100
        mov rcx, PADDING_TOP + 5 * GAP
        call gtk_layout_put

        ; отображение всех виджетов
        mov rdi, qword [ rel window ]
        call gtk_widget_show_all

        call gtk_main  ; запуск основного цикла

        pop rbp

        ret
