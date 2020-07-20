org 100h

jmp start

shoot db "n",'$'

player1_ships db "***************",13,10
           db "***#*****#####*",13,10
           db "***************",13,10
           db "***************",13,10
           db "*****##********",13,10
           db "***************",13,10
           db "************#**",13,10
           db "************#**",13,10
           db "************#**",13,10
           db "**####*********",13,10
           db "***************",13,10,'$'

player2_ships db "******#####****",13,10
           db "#**************",13,10
           db "***************",13,10
           db "***********#***",13,10
           db "***********#***",13,10
           db "***********#***",13,10
           db "*##********#***",13,10
           db "***************",13,10
           db "********###****",13,10
           db "***************",13,10
           db "***************",13,10,'$'

board db " Player 1 Sea  || Player 2 Sea  ",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10
      db "***************||***************",13,10,
      db " Points   P1:00|| Points   P2:00",13,10,'$'

turn db 0

position db 0
global_position dw 0

points_player1_dx db 48, '$'
points_player1_dy db 48, '$'
points_player2_dx db 48, '$'
points_player2_dy db 48, '$'

points_player1 db 0
points_player2 db 0

start:

    mov dx, OFFSET board
    mov ah, 9
    int 21h
    mov dl, 0                       ; Cursor X position
    mov dh, 1                       ; Cursor Y position

main:   cmp points_player1, 15
        je fin
        cmp points_player2, 15
        je fin

        call set_cursor
        mov ah, 00h
        int 16h

        cmp al, 120                 ; Compare if the pressed key is 'x'
        je Down

        cmp al, 119                 ; Compare if the pressed key is 'w'
        je Up

        cmp al, 97                  ; Compare if the pressed key is 'a'
        je Left

        cmp al, 100                 ; Compare if the pressed key is 'd'
        je Right

        cmp al, 115                 ; Compare if the pressed key is 's', uncover if true
        je uncover

        jmp main                    ; If the pressed key is none of the above, ask for pressing a key again

                                    ; ------------------- Keyboard functions --------------------------

uncover:                            ; Uncover tile
        call evaluate_ship_hit
        mov dx, offset shoot
        mov ah, 9
        int 21h
        call draw_points
        call change_turn
        call set_cursor
        jmp main

Right:  cmp dl, 14                  ; Reposition cursor in X axis to the right
        je main
        cmp dl, 31
        je main
        add dl, 1
        inc position
        call set_cursor
        call calculate_global_position
        jmp main
        ret

Left:   cmp dl, 0                   ; Reposition cursor in X axis to the left
        je main
        cmp dl, 17
        je main
        sub dl, 1
        dec position
        call set_cursor
        call calculate_global_position
        jmp main

        ret

Up:     cmp dh, 1                   ; Reposition cursor in Y axis to up
        je main
        sub dh, 1
        sub position,17
        call set_cursor
        call calculate_global_position
        jmp main
        ret

Down:                               ; Reposition cursor in Y axis to down
        cmp dh, 11
        je main
        add dh, 1
        add position,17
        call set_cursor
        call calculate_global_position
        jmp main
        ret

        ; ------------------- Functions --------------------------

set_cursor proc
        mov ah, 02h
        mov bh, 00
        int 10h
        ret
set_cursor endp

change_turn proc                     ; Change turn
    mov position, 0
    cmp turn, 0
    je j2
    cmp turn, 1
    je j1

    j1:
    mov turn, 0
    mov dl, 0
    mov dh, 1
    call calculate_global_position
    ret
    j2:
    mov turn, 1
    mov dl, 17
    mov dh, 1
    call calculate_global_position
    ret
change_turn endp

evaluate_ship_hit proc

    cmp board[si],"s",'$'           ; Evaluate if this position was already selected
    je main
    cmp board[si],"n",'$'
    je main

    mov ax,0                        ; Move position respect the small board
    mov al,position
    mov si,ax
    cmp turn,0
    je comparision1
    cmp turn,1
    je comparision2

    comparision2:
    cmp player1_ships[si],"#",'$'   ; Compare if player 2 hits a target
    je fire
    cmp player1_ships[si],"*",'$'
    je agua

    comparision1:
    cmp player2_ships[si],"#",'$'   ; Compare if player 1 hits a target
    je fire
    cmp player2_ships[si],"*",'$'
    je agua

    fire:
    mov shoot, "s",'$'
    mov si, global_position
    mov board[si], "s",'$'          ; Re-render board adding the 's'
    cmp turn,0
    je add1
    cmp turn,1
    je add2

    add1:                          ; Add points
    inc points_player1
    cmp points_player1,10
    je  draw1
    inc points_player1_y
    ret
    draw1:
    mov points_player1_y,48,'$'
    inc points_player1_dx
    ret

    add2:
    inc points_player2
    cmp points_player2,10
    je draw2
    inc points_player2_dy
    ret
    draw2:
    sub points_player2_dy,48,'$'
    inc points_player2_dx
    ret

    agua:
    mov shoot, "n",'$'
    mov si, global_position
    mov board[si], "n",'$'          ; Re-render board adding the 'n'
    ret
evaluate_ship_hit endp

proc draw_points                      ; Drag points in their positions
    mov dh,12
    mov dl,13
    call set_cursor
    mov dx,offset points_player1_dx,
    mov ah,9
    int 21h

    mov dh,12
    mov dl,14
    call set_cursor
    mov dx,offset points_player1_y,
    mov ah,9
    int 21h

    mov dh,12
    mov dl,30
    call set_cursor
    mov dx,offset points_player2_dx,
    mov ah,9
    int 21h

    mov dh,12
    mov dl,31
    call set_cursor
    mov dx,offset points_player2_dy,
    mov ah,9
    int 21h
    ret
draw_points endp

proc calculate_global_position
    mov ax,0
    mov al,dh                       ; Number of columns x 19
    mov cl,19
    mul cl
    add al,dl                       ; Add posx
    mov si, ax
    mov global_position, si               ; Calculate position respect the big board
    ret
calcPosgrande endp

fin:
ret
