
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

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
  
board db " Mar jugador 1 || Mar jugador 2 ",13,10
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
      db "Puntaje Jug1:00||Puntaje Jug2:00",13,10,'$'
         
            

turno db 0

posicion db 0
posGrande dw 0
puntos1x db 48,'$'
puntos1y db 48,'$'
puntos2x db 48,'$'            
puntos2y db 48,'$'

puntos1 db 0
puntos2 db 0
            
;La variable posicion guarda la posicion del tablero chico en la que se esta.
;cuando apreto arriba, resta 17(una fila), abajo suma 17, derecha suma 1 e izquierda resta 1.
;Esto se hace en las funciones de las teclas correspondientes 


inicio:
    
    mov dx,OFFSET board 
    mov ah,9 
    int 21h  
    mov dl, 0          ; Posicion del cursor columna
    mov dh, 1          ; Posicion del cursor fila
 
main:   cmp puntos1,15
        je fin
        cmp puntos2,15
        je fin        
         
        call SetCursor  
        mov ah, 00h
        int 16h
                        
        cmp al, 120     ;Compara que tecla se presiono, si es 'x'    
        je Down
                
        cmp al, 119     ;Compara que tecla se presiono, si es 'w'    
        je Up
                
        cmp al, 97     ;Compara que tecla se presiono, si es 'a'    
        je Left
                
        cmp al, 100     ;Compara que tecla se presiono, si es 'd'    
        je Right
                
        cmp al, 115     ;Compara que tecla se presiono, si es 's'uncover    
        je uncover
                
        jmp main        ;Sino, no hace nada y vuelve a pedir una tecla

            
;------------------- Funciones del teclado --------------------------

uncover:
        call acerto
        mov dx, offset disparo
        mov ah, 9
        int 21h
        call dibPuntos
        call pasarTurno
        call SetCursor      
        jmp main  

Right:  cmp dl, 14
        je main
        cmp dl, 31
        je main
        add dl, 1           ;para reposicionar el cursor columna
        inc posicion
        call SetCursor      ;llamo al procedimiento para setear cursor
        call calcPosGrande
        jmp main
        ret

Left:   cmp dl, 0
        je main
        cmp dl, 17
        je main
        sub dl, 1           ;para reposicionar el cursor columna
        dec posicion
        call SetCursor      ;llamo al procedimiento para setear cursor    
        call calcPosGrande
        jmp main

        ret

Up:     cmp dh, 1
        je main
        sub dh, 1           ;para reposicionar el cursor fila
        sub posicion,17
        call SetCursor      ;llamo al procedimiento para setear cursor
        call calcPosGrande
        jmp main
        ret

Down:   
        cmp dh, 11
        je main
        add dh, 1           ;para reposicionar el cursor fila 
        add posicion,17
        call SetCursor      ;llamo al procedimiento para setear cursor
        call calcPosGrande
        jmp main
        ret

;------------------- Definiciones de procedimientos --------------------------


SetCursor proc              
        mov ah, 02h
        mov bh, 00
        int 10h       
        ret
SetCursor endp

pasarTurno proc  ;Cambio de turno
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
    
    cmp board[si],"s",'$' ; Me fijo si ya se disparo a esa posicion
    je main   
    cmp board[si],"n",'$'
    je main
    
    mov ax,0         ;Muevo la posicion respecto del tablero chico a si
    mov al,posicion
    mov si,ax 
    cmp turno,0
    je comparacion1
    cmp turno,1
    je comparacion2
                          

    comparacion2:
    cmp botes_Jug1[si],"#",'$'   ;Evaluo si acerto
    je fuego
    cmp botes_Jug1[si],"*",'$'
    je agua 
      
    
    comparacion1:
    cmp botes_Jug2[si],"#",'$'
    je fuego
    cmp botes_Jug2[si],"*",'$'
    je agua       
    
    
    fuego:
    mov disparo, "s",'$'
    mov si, posGrande      
    mov board[si], "s",'$' ;Modifico board para agregar la s en el lugar
    cmp turno,0
    je suma1
    cmp turno,1
    je suma2
    
    suma1:                  ;Suma de puntos
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
    mov board[si], "n",'$' ;Modifico board para agregar la n en el lugar
    ret 
        
acerto endp   
    
proc dibPuntos ;Dibujo los puntos en su posicion correspondiente
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
    mov al,dh     ;Columnas x 19
    mov cl,19
    mul cl
    add al,dl     ;+ la posx
    mov si, ax
    mov posGrande, si ;Calculo de la posicion respecto al tablero grande    
    ret
calcPosgrande endp     

fin:
ret




