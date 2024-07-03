# Разбор кода

**Внимание!** Этот код разрабатывался под **Ubuntu, x86-64**.

Код на языке ассемблера для архитектуры x86-64 использует библиотеку GTK для создания графического интерфейса.
Давайте разберем его шаг за шагом, чтобы понять, как происходит работа с GTK и какие функции вызываются.

## Инициализация

```asm
main:
    push rbp
    mov rbp, rsp
    xor rdi, rdi
    xor rsi, rsi
    call gtk_init
```

В самом начале вызывается функция `gtk_init`, которая инициализирует библиотеку GTK. Параметры `rdi` и `rsi` установлены
в ноль, что соответствует отсутствию аргументов командной строки.

## Создание окна

```asm
    xor rdi, rdi
    call gtk_window_new

    mov qword [ rel window ], rax
    mov rdi, qword [ rel window ]
    mov rsi, title
    call gtk_window_set_title

    mov rdi, qword [ rel window ]
    mov rsi, GTK_WIN_WIDTH
    mov rdx, GTK_WIN_HEIGHT
    call gtk_window_set_default_size

    mov rdi, qword [ rel window ]
    mov rsi, GTK_WIN_POS_CENTER
    call gtk_window_set_position
```

Создается новое окно с помощью `gtk_window_new`, и возвращаемый указатель сохраняется в переменной `window`. Затем
устанавливаются его заголовок, размер и позиция.

## Обработка сигнала закрытия окна

```asm
    mov rdi, qword [ rel window ]
    mov rsi, signal.destroy
    mov rdx, _destroy_window
    xor rcx, rcx
    xor r8d, r8d
    xor r9d, r9d
    call g_signal_connect_data
```

Для обработки события закрытия окна (`destroy`) используется `g_signal_connect_data`, которая связывает сигнал с
функцией `_destroy_window`, которая вызывает `gtk_main_quit` для завершения приложения.

## Создание макета и добавление его в окно

```asm
    xor rdi, rdi
    xor rsi, rsi
    call gtk_layout_new
    mov qword [ rel layout ], rax

    mov rsi, qword [ rel layout ]
    mov rdi, qword [ rel window ]
    call gtk_container_add
```

Создается новый виджет `GtkLayout`, который используется для размещения других виджетов, и добавляется в главное окно.

## Добавление виджетов (меток и полей ввода)

Добавление подписи с текстом задачи:

```asm
    mov rdi, task_text
    call gtk_label_new

    mov rsi, rax
    mov rdi, qword [ rel layout ]
    mov rdx, PADDING_START
    mov rcx, PADDING_TOP
    call gtk_layout_put
```

Создание и размещение первого поля ввода (для `a`):

```asm
    xor rdi, rdi
    call gtk_entry_new
    mov qword [ rel entry_1 ], rax

    mov rdi, qword [ rel entry_1 ]
    mov rsi, a_input_ph
    call gtk_entry_set_placeholder_text

    mov rdi, qword [ rel layout ]
    mov rsi, qword [ rel entry_1 ]
    mov rdx, PADDING_START
    mov rcx, PADDING_TOP + GAP
    call gtk_layout_put
```

Повторяется для второго и третьего полей ввода (`b` и `steps`):

```asm
    xor rdi, rdi
    call gtk_entry_new
    mov qword [ rel entry_2 ], rax

    mov rdi, qword [ rel entry_2 ]
    mov rsi, b_input_ph
    call gtk_entry_set_placeholder_text

    mov rdi, qword [ rel layout ]
    mov rsi, qword [ rel entry_2 ]
    mov rdx, PADDING_START
    mov rcx, PADDING_TOP + 2 * GAP
    call gtk_layout_put

    xor rdi, rdi
    call gtk_entry_new
    mov qword [ rel entry_3 ], rax

    mov рди, qword [ rel entry_3 ]
    mov rsi, steps_input_ph
    call gtk_entry_set_placeholder_text

    mov рди, qword [ rel layout ]
    mov рsi, qword [ rel entry_3 ]
    mov rdx, PADDING_START
    mov rcx, PADDING_TOP + 3 * GAP
    call gtk_layout_put
```

## Кнопка и её обработка

Создание и размещение кнопки:

```asm
    mov rdi, btn_result_text
    call gtk_button_new_with_label
    mov qword [ rel calc_btn ], rax

    mov рди, qword [ rel layout ]
    mov рsi, qword [ rel calc_btn ]
    mov rdx, PADDING_START
    mov rcx, PADDING_TOP + 4 * GAP
    call gtk_layout_put

    mov рди, qword [ rel calc_btn ]
    mov рsi, signal.clicked
    mov рdx, _clicked_calc_btn
    xor rcx, rcx
    xor r8d, r8d
    xor r9d, r9d
    call g_signal_connect_data
```

Здесь создается кнопка и связывается её сигнал `clicked` с функцией `_clicked_calc_btn`, которая обрабатывает нажатие на
кнопку.

## Подписи для результата

Создание и размещение меток для отображения результата:

```asm
    mov рди, result
    call gtk_label_new
    mov qword [ rel result_label_text ], rax

    mov рди, qword [ rel layout ]
    mov рsi, qword [ rel result_label_text ]
    mov rdx, PADDING_START
    mov rcx, PADDING_TOP + 5 * GAP
    call gtk_layout_put

    xor рди, рdi
    call gtk_label_new
    mov qword [ rel result_label ], rax

    mov рди, qword [ rel layout ]
    mov рsi, qword [ rel result_label ]
    mov rdx, PADDING_START + 100
    mov rcx, PADDING_TOP + 5 * GAP
    call gtk_layout_put
```

## Отображение всех виджетов и запуск основного цикла

```asm
    mov рdi, qword [ rel window ]
    call gtk_widget_show_all

    call gtk_main

    pop rbp
    ret
```

Вызывается `gtk_widget_show_all` для отображения всех виджетов, после чего начинается главный цикл GTK с
помощью `gtk_main`.

## Обработчики событий

Функция для обработки нажатия на кнопку:

```asm
_clicked_calc_btn:
    push rbp

    mov рdi, qword [ rel entry_1 ]
    call gtk_entry_get_text
    mov qword [ rel start ], rax

    mov рdi, qword [ rel entry_2 ]
    call gtk_entry_get_text
    mov qword [ rel end ], rax

    mov рdi, qword [ rel entry_3 ]
    call gtk_entry_get_text
    mov qword [ rel step_count ], rax

    mov рdi, qword [ rel start ]
    mov рsi, qword [ rel end ]
    mov рdx, qword [ rel step_count ]
    call root_str

    mov рdi, qword [ rel result_label ]
    mov рsi, steps_buffer
    call gtk_label_set_text

    pop rbp
    ret
```

Эта функция получает текст из полей ввода, сохраняет их значения, вызывает функцию `root_str` для вычисления результата
и обновляет текст подписи с результатом.

Функция для обработки закрытия окна:

```asm
_destroy_window:
    jmp gtk_main_quit
```

Эта функция вызывает `gtk_main_quit` для завершения приложения, когда окно закрывается.

## Заключение

Код инициализирует GTK, создает окно с несколькими виджетами (подписи, поля ввода, кнопка), настраивает их свойства и
позиции, а также обрабатывает события. Приложение завершает свою работу, когда пользователь закрывает окно.

`gtk_main()` — это основная функция цикла обработки событий в библиотеке GTK. Когда вы вызываете `gtk_main()`, она
запускает цикл, который обрабатывает события, такие как нажатия клавиш, движения мыши, сигналы от виджетов и другие
события системы.

# Принцип работы gtk_main

1. **Инициализация**:
   Перед вызовом `gtk_main()` обычно вызываются функции инициализации GTK, такие как `gtk_init()`
   или `gtk_init_check()`, которые подготавливают библиотеку к работе.

2. **Цикл обработки событий**:
   Когда вызывается `gtk_main()`, программа входит в цикл обработки событий, который выполняется до тех пор, пока не
   будет вызвана функция `gtk_main_quit()`. В этом цикле происходит следующее:

    - **Ожидание событий**: Цикл ожидает поступления событий из системы, таких как пользовательский ввод, таймеры,
      сетевые события и другие.
    - **Обработка событий**: Когда событие поступает, GTK определяет, какой виджет должен его обработать, и вызывает
      соответствующие обработчики событий.
    - **Обновление интерфейса**: Если событие требует перерисовки окна или его частей (например, если виджет был
      изменен), GTK добавляет это задание в очередь перерисовки.

3. **Перерисовка интерфейса**:
   Перерисовка интерфейса в GTK происходит не сразу, как только событие требует изменений. Вместо этого изменения
   добавляются в очередь задач. Когда очередь задач достигает определенного состояния, происходит "микротик" цикла, в
   котором:

    - **Очищение очереди перерисовки**: GTK берет задачи из очереди и выполняет их. Это может включать перерисовку
      виджетов, обновление данных, выполнение анимаций и т.д.
    - **Обновление экрана**: Все виджеты, которые нуждаются в перерисовке, обновляются на экране, обеспечивая плавный и
      синхронный интерфейс.

## Когда происходит перерисовка

Перерисовка интерфейса происходит в следующих случаях:

- **Явные изменения**: Когда виджет явно изменяется в коде (например, изменяется текст кнопки или изменяется ее размер),
  виджет маркируется как "нуждающийся в перерисовке".
- **Системные события**: Когда система сообщает, что окно нуждается в перерисовке (например, при сворачивании и
  разворачивании окна или при его перекрытии другим окном).
- **Таймеры и анимации**: Если используются таймеры или анимации, которые требуют регулярного обновления интерфейса.

## Почему перерисовка не происходит сразу

Перерисовка не происходит мгновенно по нескольким причинам:

1. **Оптимизация производительности**: Перерисовка может быть ресурсозатратной операцией. Сгруппировав несколько
   изменений в одну перерисовку, GTK минимизирует количество операций отрисовки.
2. **Плавность интерфейса**: Вместо того чтобы сразу реагировать на каждое изменение, GTK выполняет перерисовку в
   определенные моменты, обеспечивая более плавный и предсказуемый интерфейс.
3. **Асинхронная обработка**: Это позволяет более эффективно обрабатывать пользовательский ввод и другие события, не
   блокируя основной цикл обработки событий частыми перерисовками.

Таким образом, `gtk_main()` и цикл обработки событий обеспечивают эффективное и плавное обновление пользовательского
интерфейса в приложениях на GTK.
