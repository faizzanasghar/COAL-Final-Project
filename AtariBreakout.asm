[org 0x0100]

jmp main_entry_point

column_colors:  db 0x40, 0x60, 0x20, 0xE0, 0x50, 0x30, 0x90, 0xB0, 0xC0, 0x70
brick_map:      times 40 db 1

paddle_x        dw 35
paddle_y        dw 22
paddle_width    dw 9
paddle_color    db 0x1F

ball_x          dw 40
ball_y          dw 12
ball_dx         dw 0
ball_dy         dw 1
ball_color      db 0x0E

lives           db 3
score           dw 0
bricks_left     db 40
game_over       db 0
exit_flag       db 0

key_left        db 0
key_right       db 0

old_isr_off     dw 0
old_isr_seg     dw 0

double_line:   db '================================================',0
single_line:   db '------------------------------------------------',0
plus_line:     db '++++++++++++++++++++++++++++++++++++++++++++++++',0
star_simple:   db '*********************************************',0

title_line1:   db '|==============================================|',0
title_line2:   db '|          BRICK BREAKER GAME                  |',0
title_line3:   db '|          ATARI CLASSIC                       |',0
title_line4:   db '|==============================================|',0

dev_title:     db '          DEVELOPED BY          ',0
dev_name1:     db '      MUHAMMAD FAIZAN ASGHAR        ',0
dev_name2:     db '          AHMAD HASSAN              ',0

game_info:     db '     UNDER SUPERVISION OF      ',0
objective:     db "           MA'AM GUL-E-ZAHRA   ",0

ctrl_title:    db '         [ CONTROLS ]            ',0
ctrl_left:     db '   LEFT ARROW  : Move Left       ',0
ctrl_right:    db '   RIGHT ARROW : Move Right      ',0
ctrl_exit:     db '   ESC         : Exit Game       ',0

start_title:   db '        [ GET READY! ]           ',0
start_prompt:  db '   PRESS ENTER TO START GAME     ',0
start_hint:    db '    >> Press ENTER now! <<       ',0

border_line:    db '================================================',0
star_line:      db '************************************************',0
dash_line:      db '------------------------------------------------',0
game_over_text: db '        G A M E   O V E R        ',0
go_score_text:  db '     FINAL  SCORE:              ',0
go_lives_text:  db '     LIVES  LEFT :              ',0
go_prompt:      db '   PRESS ANY KEY TO CONTINUE    ',0
win_text:       db '      C O N G R A T U L A T I O N S     ',0
win_message:    db '         Y O U   W I N !           ',0
win_score_text: db '     YOUR  SCORE:                 ',0
win_prompt:     db '   PRESS ANY KEY TO CONTINUE    ',0
play_again_q:   db '   PLAY AGAIN? (Y/N)   ',0
play_again_opt: db '   Y = YES     N = NO  ',0

show_front_page:
    call CLRSCR
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov cx, 2000
    mov ax, 0x1020
    cld
    rep stosw
    push 2
    push 15
    push 0x1E
    push double_line
    call printstr
    push 4
    push 15
    push 0x1E
    push title_line1
    call printstr
    push 5
    push 15
    push 0x1F
    push title_line2
    call printstr
    push 6
    push 15
    push 0x1B
    push title_line3
    call printstr
    push 7
    push 15
    push 0x1E
    push title_line4
    call printstr
    push 9
    push 15
    push 0x1B
    push single_line
    call printstr
    push 11
    push 15
    push 0x1F
    push dev_title
    call printstr
    push 12
    push 15
    push 0x1F
    push dev_name1
    call printstr
    push 13
    push 15
    push 0x1F
    push dev_name2
    call printstr
    push 14
    push 15
    push 0x1B
    push game_info
    call printstr
    push 15
    push 15
    push 0x1B
    push objective
    call printstr
    push 17
    push 15
    push 0x1E
    push single_line
    call printstr
    push 18
    push 15
    push 0x1F
    push ctrl_title
    call printstr
    push 19
    push 15
    push 0x1B
    push ctrl_left
    call printstr
    push 20
    push 15
    push 0x1B
    push ctrl_right
    call printstr
    push 21
    push 15
    push 0x1B
    push ctrl_exit
    call printstr
    push 22
    push 15
    push 0x1E
    push plus_line
    call printstr
    push 23
    push 15
    push 0x1F
    push start_title
    call printstr
    push 24
    push 15
    push 0x9E
    push start_prompt
    call printstr
    push 25
    push 15
    push 0x1E
    push start_hint
    call printstr
    push 26
    push 15
    push 0x1D
    push double_line
    call printstr
    mov ah, 00h
    int 16h
    cmp al, 0x0D
    je start_game
    cmp al, 0x1B
    je exit_game
    jmp show_clean_front_page
start_game:
    ret
exit_game:
    call CLRSCR
    mov ax, 0x4C00
    int 0x21

show_game_over:
    call unhook_keyboard
    call CLRSCR
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov cx, 2000
    mov ax, 0x4020
    cld
    rep stosw
    call beep_lose
    push 2
    push 15
    push 0x4F
    push border_line
    call printstr
    push 5
    push 15
    push 0x4E
    push game_over_text
    call printstr
    push 7
    push 15
    push 0x4F
    push dash_line
    call printstr
    push 9
    push 15
    push 0x4F
    push go_score_text
    call printstr
    push 9
    push 33
    push 0x4E
    call display_final_score
    push 11
    push 15
    push 0x4F
    push go_lives_text
    call printstr
    push 11
    push 33
    push 0x4E
    call display_final_lives
    push 13
    push 15
    push 0x4F
    push border_line
    call printstr
    push 16
    push 15
    push 0x4E
    push go_prompt
    call printstr
    push 18
    push 15
    push 0x4F
    push star_line
    call printstr
    mov ah, 00h
    int 16h
    call ask_play_again
    ret

show_win_simple:
    call unhook_keyboard
    call CLRSCR
    mov ax, 0xb800
    mov es, ax
    mov di, 0
    mov cx, 2000
    mov ax, 0x2020
    cld
    rep stosw
    push 2
    push 15
    push 0x2F
    push star_line
    call printstr
    push 5
    push 15
    push 0x2E
    push win_text
    call printstr
    push 7
    push 15
    push 0x2E
    push win_message
    call printstr
    push 9
    push 15
    push 0x2F
    push dash_line
    call printstr
    push 11
    push 15
    push 0x2F
    push win_score_text
    call printstr
    push 11
    push 33
    push 0x2E
    call display_final_score
    push 13
    push 15
    push 0x2F
    push star_line
    call printstr
    push 16
    push 15
    push 0x2E
    push win_prompt
    call printstr
    push 18
    push 15
    push 0x2F
    push border_line
    call printstr
    mov ah, 00h
    int 16h
    call ask_play_again
    ret

display_final_score:
    push bp
    mov bp, sp
    pusha
    mov ax, [bp+4]
    mov bx, [bp+6]
    mov cx, [bp+8]
    mov ax, cx
    mov di, 80
    mul di
    add ax, bx
    shl ax, 1
    mov di, ax
    mov ax, 0xb800
    mov es, ax
    mov ax, [score]
    mov bl, 100
    div bl
    add al, '0'
    mov ah, [bp+4]
    mov [es:di], ax
    add di, 2
    mov al, ah
    xor ah, ah
    mov bl, 10
    div bl
    add al, '0'
    mov ah, [bp+4]
    mov [es:di], ax
    add di, 2
    mov al, ah
    add al, '0'
    mov ah, [bp+4]
    mov [es:di], ax
    popa
    pop bp
    ret 6

display_final_lives:
    push bp
    mov bp, sp
    pusha
    mov ax, [bp+4]
    mov bx, [bp+6]
    mov cx, [bp+8]
    mov ax, cx
    mov di, 80
    mul di
    add ax, bx
    shl ax, 1
    mov di, ax
    mov ax, 0xb800
    mov es, ax
    mov al, [lives]
    add al, '0'
    mov ah, [bp+4]
    mov [es:di], ax
    popa
    pop bp
    ret 6

ask_play_again:
    push 20
    push 15
    push 0x4F
    push dash_line
    call printstr
    push 21
    push 15
    push 0x4E
    push play_again_q
    call printstr
    push 22
    push 15
    push 0x4F
    push play_again_opt
    call printstr
get_choice:
    mov ah, 00h
    int 16h
    cmp al, 'Y'
    je yes_choice
    cmp al, 'y'
    je yes_choice
    cmp al, 'N'
    je no_choice
    cmp al, 'n'
    je no_choice
    jmp get_choice
yes_choice:
    mov byte [lives], 3
    mov word [score], 0
    mov byte [bricks_left], 40
    mov byte [game_over], 0
    mov cx, 40
    mov si, brick_map
reset_bricks_loop:
    mov byte [si], 1
    inc si
    loop reset_bricks_loop
    ret
no_choice:
    call CLRSCR
    mov ax, 0x4C00
    int 0x21

main_entry_point:
    push cs
    pop ds
    call show_front_page
    call CLRSCR
    call draw_hud
    call draw_all_bricks_multicolor
    call hook_keyboard
    call draw_paddle
    call draw_ball
    jmp game_loop

game_over_screen:
    call show_game_over
    call CLRSCR
    call draw_hud
    call draw_all_bricks_multicolor
    call hook_keyboard
    call draw_paddle
    call draw_ball
    jmp game_loop

win_screen:
    call show_win_simple
    call CLRSCR
    call draw_hud
    call draw_all_bricks_multicolor
    call hook_keyboard
    call draw_paddle
    call draw_ball
    jmp game_loop

CLRSCR:
    push ax
    push es
    push di
    push cx
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x0720
    mov cx, 2000
    cld
    rep stosw
    pop cx
    pop di
    pop es
    pop ax
    ret

strlen:
    push bp
    mov bp, sp
    push cx
    push es
    push di
    les di, [bp+4]
    mov cx, 0xffff
    xor al, al
    repne scasb
    mov ax, 0xffff
    sub ax, cx
    dec ax
    pop di
    pop es
    pop cx
    pop bp
    ret 2

printstr:
    push bp
    mov bp, sp
    push es
    push ax
    push si
    push di
    push cx
    push ds
    mov ax, [bp+4]
    push ax
    call strlen
    cmp ax, 0
    jz exit_print
    mov cx, ax
    mov ax, 0xb800
    mov es, ax
    mov ax, 80
    mul byte [bp+10]
    add ax, [bp+8]
    shl ax, 1
    mov di, ax
    mov si, [bp+4]
    mov ax, [bp+6]
    mov ah, al
    cld
next_char:
    lodsb
    stosw
    loop next_char
exit_print:
    pop ds
    pop cx
    pop di
    pop si
    pop ax 
    pop es
    pop bp
    ret 8

draw_all_bricks_multicolor:
    push es
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    mov ax, 0xb800
    mov es, ax
    mov dh, 2
    mov dl, 0
    call draw_brick_row_multicolor
    mov dh, 4
    mov dl, 0
    call draw_brick_row_multicolor
    mov dh, 6
    mov dl, 0
    call draw_brick_row_multicolor
    mov dh, 8
    mov dl, 0
    call draw_brick_row_multicolor
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    ret

draw_brick_row_multicolor:
    push es
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    mov ax, 0xb800
    mov es, ax
    mov al, dh
    mov ah, 0
    mov bx, 80
    mul bx
    mov di, ax
    shl di, 1
    mov cx, 10
    mov bl, 0
draw_brick_loop:
    push bx
    mov bh, 0
    mov al, [column_colors + bx]
    mov ah, al
    pop bx
    push cx
    mov cx, 7
    mov al, 0x20
draw_brick_char:
    stosw
    loop draw_brick_char
    pop cx
    mov ax, 0x0020
    stosw
    inc bl
    loop draw_brick_loop
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    ret

draw_hud:
    push es
    push ax
    push bx
    push di
    push si
    push dx
    mov ax, 0xb800
    mov es, ax
    mov di, 4
    mov si, txt_lives
    mov ah, 0x0F
print_lives_txt:
    lodsb
    cmp al, 0
    je print_lives_val
    mov [es:di], ax
    add di, 2
    jmp print_lives_txt
print_lives_val:
    mov al, [lives]
    add al, '0'
    mov [es:di], ax
    mov di, 40
    mov si, txt_score
    mov ah, 0x0F
print_score_txt:
    lodsb
    cmp al, 0
    je print_score_val
    mov [es:di], ax
    add di, 2
    jmp print_score_txt
print_score_val:
    mov ax, [score]
    mov bl, 100
    div bl
    add al, '0'
    mov [es:di], al
    inc di
    mov byte [es:di], 0x0F
    inc di
    mov al, ah
    xor ah, ah
    mov bl, 10
    div bl
    add al, '0'
    mov [es:di], al
    inc di
    mov byte [es:di], 0x0F
    inc di
    mov al, ah
    add al, '0'
    mov [es:di], al
    inc di
    mov byte [es:di], 0x0F
    pop dx
    pop si
    pop di
    pop bx
    pop ax
    pop es
    ret

draw_paddle:
    push es
    push ax
    push bx
    push cx
    push di
    mov ax, 0xb800
    mov es, ax
    mov ax, [paddle_y]
    mov bx, 80
    mul bx
    add ax, [paddle_x]
    shl ax, 1
    mov di, ax
    mov cx, [paddle_width]
    mov ah, [paddle_color]
    mov al, 219
d_pad_loop:
    mov [es:di], ax
    add di, 2
    loop d_pad_loop
    pop di
    pop cx
    pop bx
    pop ax
    pop es
    ret

clear_paddle:
    push es
    push ax
    push bx
    push cx
    push di
    mov ax, 0xb800
    mov es, ax
    mov ax, [paddle_y]
    mov bx, 80
    mul bx
    add ax, [paddle_x]
    shl ax, 1
    mov di, ax
    mov cx, [paddle_width]
    mov ah, 0x00
    mov al, ' ' 
c_pad_loop:
    mov [es:di], ax
    add di, 2
    loop c_pad_loop
    pop di
    pop cx
    pop bx
    pop ax
    pop es
    ret

draw_ball:
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    mov ax, [ball_y]
    mov di, 80
    mul di
    add ax, [ball_x]
    shl ax, 1
    mov di, ax
    mov byte [es:di], 'O'
    mov byte [es:di+1], 0x0E
    pop di
    pop ax
    pop es
    ret

clear_ball:
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    mov ax, [ball_y]
    mov di, 80
    mul di
    add ax, [ball_x]
    shl ax, 1
    mov di, ax
    mov byte [es:di], ' '
    mov byte [es:di+1], 0x00
    pop di
    pop ax
    pop es
    ret

check_brick_active:
    push si
    cmp ax, 40
    jge brick_not_active
    mov si, brick_map
    add si, ax
    mov al, [si]
    jmp brick_check_done
brick_not_active:
    xor al, al
brick_check_done:
    pop si
    ret

remove_brick:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    mov ax, cx
    push bx
    mov bl, 10
    mul bl
    pop bx
    add ax, bx
    mov si, brick_map
    add si, ax
    cmp byte [si], 0
    je remove_skip
    mov byte [si], 0
    dec byte [bricks_left]
    add word [score], 10
    mov ax, cx
    shl ax, 1
    add ax, 2
    mov dx, 80
    mul dx
    push bx
    shl bx, 3
    add ax, bx
    pop bx
    shl ax, 1
    mov di, ax
    mov ax, 0xb800
    mov es, ax
    mov cx, 8
    mov ax, 0x0F20
    push di
    rep stosw
    pop di
    mov cx, 0x1000
rm_delay:
    nop
    loop rm_delay
    mov cx, 8
    mov ax, 0x0020
    rep stosw
remove_skip:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret

move_ball:
    push ax
    push bx
    push cx
    mov ax, [ball_x]
    add ax, [ball_dx]
    mov bx, ax
    mov ax, [ball_y]
    add ax, [ball_dy]
    mov cx, ax
    cmp cx, 2
    jl no_brick_ahead
    cmp cx, 9
    jg no_brick_ahead
    mov ax, cx
    test ax, 1
    jnz no_brick_ahead
    mov ax, cx
    sub ax, 2
    shr ax, 1
    push cx
    mov cx, ax
    mov ax, bx
    shr ax, 3
    push bx
    mov bx, ax
    cmp cx, 4
    jge no_brick_ahead_restore
    cmp bx, 10
    jge no_brick_ahead_restore
    mov ax, cx
    push bx
    push dx
    mov dl, 10
    mul dl
    pop dx
    pop bx
    add ax, bx
    call check_brick_active
    cmp al, 1
    jne no_brick_ahead_restore
    call remove_brick
    neg word [ball_dy]
    call beep_sound
    pop bx
    pop cx
    mov ax, [ball_y]
    add ax, [ball_dy]
    mov [ball_y], ax
    jmp apply_x_movement
no_brick_ahead_restore:
    pop bx
    pop cx
no_brick_ahead:
    mov ax, [ball_y]
    add ax, [ball_dy]
    mov [ball_y], ax
apply_x_movement:
    mov ax, [ball_x]
    add ax, [ball_dx]
    mov [ball_x], ax
    cmp word [ball_x], 0
    jg check_right_wall
    mov word [ball_x], 1
    neg word [ball_dx]
    jmp check_vertical
check_right_wall:
    cmp word [ball_x], 79
    jl check_vertical
    mov word [ball_x], 78
    neg word [ball_dx]
check_vertical:
    cmp word [ball_y], 1
    jg check_paddle_collision
    mov word [ball_y], 2
    neg word [ball_dy]
    jmp move_ball_done
check_paddle_collision:
    cmp word [ball_dy], 1
    jne check_bottom
    mov ax, [paddle_y]
    dec ax
    cmp [ball_y], ax
    jne check_bottom
    mov ax, [ball_x]
    cmp ax, [paddle_x]
    jl check_bottom
    mov bx, [paddle_x]
    add bx, [paddle_width]
    cmp ax, bx
    jg check_bottom
    neg word [ball_dy]
    call beep_sound
    mov cx, [ball_x]
    sub cx, [paddle_x]
    cmp cx, 2
    jl bounce_strong_left
    cmp cx, 4
    jl bounce_medium_left
    cmp cx, 6
    jl bounce_straight
    cmp cx, 8
    jl bounce_medium_right
    jmp bounce_strong_right
bounce_strong_left:
    mov word [ball_dx], -2
    jmp move_ball_done
bounce_medium_left:
    mov word [ball_dx], -1
    jmp move_ball_done
bounce_straight:
    mov word [ball_dx], 0
    jmp move_ball_done
bounce_medium_right:
    mov word [ball_dx], 1
    jmp move_ball_done
bounce_strong_right:
    mov word [ball_dx], 2
    jmp move_ball_done
check_bottom:
    cmp word [ball_y], 24
    jl move_ball_done
    dec byte [lives]
    cmp byte [lives], 0
    je trigger_game_over
    call reset_ball
    jmp move_ball_done
trigger_game_over:
    mov byte [game_over], 1
move_ball_done:
    pop cx
    pop bx
    pop ax
    ret

reset_ball:
    mov word [ball_x], 40
    mov word [ball_y], 12
    mov word [ball_dx], 0
    mov word [ball_dy], 0
    call draw_ball
    mov cx, 0xFFFF
reset_delay:
    loop reset_delay
    mov cx, 0xFFFF
reset_delay2:
    loop reset_delay2
    mov word [ball_dx], 1
    mov word [ball_dy], 1
    ret

move_paddle:
    push ax
    cmp byte [key_left], 1
    jne check_right_key
    cmp word [paddle_x], 2
    jle check_right_key
    dec word [paddle_x]
    dec word [paddle_x]
check_right_key:
    cmp byte [key_right], 1
    jne move_pad_done
    mov ax, 78
    sub ax, [paddle_width]
    cmp word [paddle_x], ax
    jge move_pad_done
    inc word [paddle_x]
    inc word [paddle_x]
move_pad_done:
    pop ax
    ret

timer_sync:
    push ds
    push ax
    push bx
    mov ax, 0x0040
    mov ds, ax
    mov bx, [0x006C]
    add bx, 2
wait_tick:
    cmp bx, [0x006C]
    ja wait_tick
    pop bx
    pop ax
    pop ds
    ret

new_kbisr:
    push ax
    push ds
    push es
    push cs
    pop ds
    in al, 0x60
    cmp al, 0x4B
    je left_press
    cmp al, 0xCB
    je left_rel
    cmp al, 0x4D
    je right_press
    cmp al, 0xCD
    je right_rel
    cmp al, 0x01
    je esc_press
    jmp isr_end
left_press: mov byte [key_left], 1
            jmp isr_end
left_rel:   mov byte [key_left], 0
            jmp isr_end
right_press:mov byte [key_right], 1
            jmp isr_end
right_rel:  mov byte [key_right], 0
            jmp isr_end
esc_press:  mov byte [exit_flag], 1
isr_end:
    mov al, 0x20
    out 0x20, al
    pop es
    pop ds
    pop ax
    iret

hook_keyboard:
    cli
    xor ax, ax
    mov es, ax
    mov ax, [es:9*4]
    mov [old_isr_off], ax
    mov ax, [es:9*4+2]
    mov [old_isr_seg], ax
    mov word [es:9*4], new_kbisr
    mov [es:9*4+2], cs
    mov ax, 0xb800
    mov es, ax
    sti
    ret

unhook_keyboard:
    cli
    xor ax, ax
    mov es, ax
    mov ax, [old_isr_off]
    mov [es:9*4], ax
    mov ax, [old_isr_seg]
    mov [es:9*4+2], ax
    sti
    ret

beep_sound:
    push ax
    push bx
    push cx
    push dx
    mov al, 182
    out 0x43, al
    mov ax, 1000
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 0x03
    out 0x61, al
    mov cx, 0x1000
b1: loop b1
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    pop dx
    pop cx
    pop bx
    pop ax
    ret
beep_lose:
    push ax
    push bx
    push cx
    push dx
    mov al, 182
    out 0x43, al
    mov ax, 4000
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 0x03
    out 0x61, al
    mov cx, 0xFFFF
b2: loop b2
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    pop dx
    pop cx
    pop bx
    pop ax
    ret

game_loop:
    call timer_sync
    cmp byte [exit_flag], 1
    je exit_game_wrapper
    cmp byte [game_over], 1
    je game_over_screen
    cmp byte [bricks_left], 0
    je win_screen
    call clear_paddle
    call clear_ball
    call move_paddle
    call move_ball
    call draw_hud
    call draw_paddle
    call draw_ball
    jmp game_loop

exit_game_wrapper:
    call unhook_keyboard
    call CLRSCR
