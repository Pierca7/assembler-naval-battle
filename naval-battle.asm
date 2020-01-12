org 100h

org 100h
jmp inicio            
            
disparo db "n",'$'

botes_Jug1 db "***************",13,10
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

botes_Jug2 db "******#####****",13,10
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
         
            

turno db 0

posicion db 0
posGrande dw 0
puntos1x db 48,'$'
puntos1y db 48,'$'
puntos2x db 48,'$'            
puntos2y db 48,'$'

puntos1 db 0
puntos2 db 0
            

inicio:
    
    mov dx,OFFSET board 
    mov ah,9 
    int 21h  
    mov dl, 0          ; Cursor X position
    mov dh, 1          ; Cursor Y position
 
main:   cmp puntos1,15
        je fin
        cmp puntos2,15
        je fin        
         
        call SetCursor  
        mov ah, 00h
        int 16h
                        
        cmp al, 120     ; Compare if the pressed key is 'x' 
        je Down
                
        cmp al, 119     ; Compare if the pressed key is 'w'    
        je Up
                
        cmp al, 97      ; Compare if the pressed key is 'a'    
        je Left
                
        cmp al, 100     ; Compare if the pressed key is 'd'   
        je Right
                
        cmp al, 115     ; Compare if the pressed key is 's', uncover if true  
        je uncover
                
        jmp main        ; If the pressed key is none of the above, ask for pressing a key again

            
;------------------- Keyboard functions --------------------------

uncover:                       ; Uncover tile
        call acerto
        mov dx, offset disparo
        mov ah, 9
        int 21h
        call dibPuntos
        call pasarTurno
        call SetCursor      
        jmp main  

Right:  cmp dl, 14             ; Reposition cursor in X axis to the right
        je main
        cmp dl, 31
        je main
        add dl, 1           
        inc posicion
        call SetCursor      
        call calcPosGrande
        jmp main
        ret

Left:   cmp dl, 0              ; Reposition cursor in X axis to the left
        je main
        cmp dl, 17
        je main
        sub dl, 1           
        dec posicion
        call SetCursor      
        call calcPosGrande
        jmp main

        ret

Up:     cmp dh, 1              ; Reposition cursor in Y axis to up
        je main
        sub dh, 1           
        sub posicion,17
        call SetCursor      
        call calcPosGrande
        jmp main
        ret

Down:                         ; Reposition cursor in Y axis to down
        cmp dh, 11
        je main
        add dh, 1           
        add posicion,17
        call SetCursor      
        call calcPosGrande
        jmp main
        ret

;------------------- Functions --------------------------


SetCursor proc              
        mov ah, 02h
        mov bh, 00
        int 10h       
        ret
SetCursor endp

pasarTurno proc    ; Change turn
    mov posicion,0
    cmp turno,0
    je j2
    cmp turno,1
    je j1
    
    j1: 
    mov turno, 0
    mov dl, 0
    mov dh, 1
    call calcPosGrande
    ret
    j2: 
    mov turno, 1
    mov dl, 17
    mov dh, 1
    call calcPosGrande
    ret
    
pasarTurno endp

acerto proc
    
    cmp board[si],"s",'$'        ; Evaluate if this position was already selected 
    je main   
    cmp board[si],"n",'$'
    je main
    
    mov ax,0                     ; Move position respect the small board
    mov al,posicion
    mov si,ax 
    cmp turno,0
    je comparacion1
    cmp turno,1
    je comparacion2
                          

    comparacion2:
    cmp botes_Jug1[si],"#",'$'   ; Compare if player 2 hits a target
    je fuego
    cmp botes_Jug1[si],"*",'$'
    je agua 
      
    
    comparacion1:
    cmp botes_Jug2[si],"#",'$'   ; Compare if player 1 hits a target
    je fuego
    cmp botes_Jug2[si],"*",'$'
    je agua       
    
    
    fuego:
    mov disparo, "s",'$'
    mov si, posGrande      
    mov board[si], "s",'$'  ; Re-render board adding the 's'
    cmp turno,0
    je suma1
    cmp turno,1
    je suma2
    
    suma1:                  ; Add points
    inc puntos1
    cmp puntos1,10
    je  dib1
    inc puntos1y
    ret
    dib1:
    mov puntos1y,48,'$'
    inc puntos1x
    ret
    
    suma2:
    inc puntos2
    cmp puntos2,10
    je dib2
    inc puntos2y
    ret
    dib2:
    sub puntos2y,48,'$' 
    inc puntos2x
    ret
    
    agua:
    mov disparo, "n",'$'
    mov si, posGrande
    mov board[si], "n",'$' ; Re-render board adding the 'n'
    ret 
        
acerto endp   
    
proc dibPuntos ; Drag points in their positions
    mov dh,12
    mov dl,13
    call SetCursor
    mov dx,offset puntos1x, 
    mov ah,9 
    int 21h
    
    mov dh,12
    mov dl,14
    call SetCursor
    mov dx,offset puntos1y, 
    mov ah,9 
    int 21h 
    
    mov dh,12
    mov dl,30
    call SetCursor
    mov dx,offset puntos2x, 
    mov ah,9 
    int 21h   
    
    mov dh,12
    mov dl,31
    call SetCursor
    mov dx,offset puntos2y, 
    mov ah,9 
    int 21h
    ret       
    
dibPuntos endp

proc calcPosGrande
    mov ax,0
    mov al,dh     ; Number of columns x 19
    mov cl,19
    mul cl
    add al,dl     ; Add posx
    mov si, ax
    mov posGrande, si ; Calculate position respect the big board  
    ret
calcPosgrande endp     

fin:
ret




