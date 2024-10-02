.MODEL SMALL
.STACK 100H

.DATA
    ; Coordenadas para los rectángulos (botones)
    X1 DW 0
    Y1 DW 0
    X2 DW 0
    Y2 DW 0

   ; Cadenas de texto (terminadas en '$')
    txtGuardar DB 'Guardar bosquejo$'
    txtCargar DB 'Cargar bosquejo$'
    txtLimpiar DB 'Limpiar$'
    txtImagen DB 'Insertar imagen$'
    txtCampo DB 'Campo de texto$'
    txtDibujo DB 'Dibujo sin nombre$'


.CODE

INIT_SCREEN PROC
    MOV AX, 0012H       ; Cambiar al modo gráfico 12h (640x480, 16 colores)
    INT 10H             ; Interrupción de BIOS para cambiar el modo gráfico
    RET
INIT_SCREEN ENDP

PRINT_PIXEL PROC
    MOV AH, 0CH         ; Función BIOS para pintar un píxel
    INT 10H             ; Interrupción de video para pintar el píxel
    RET
PRINT_PIXEL ENDP

CLEAR_SCREEN PROC
    MOV AX, 0F00H       ; Establecer color blanco (0F en modo gráfico)
    MOV CX, 0           ; Iniciar desde la esquina superior izquierda
    MOV DX, 0

PAINT_SCREEN:
    MOV AH, 0CH         ; Función BIOS para pintar un píxel
    MOV AL, 08H         ; Establecer color blanco
    INT 10H             ; Interrupción de video BIOS para pintar el píxel
    INC CX              ; Avanzar en X (columna)
    CMP CX, 640         ; ¿Llegamos al borde derecho?
    JNE PAINT_SCREEN

    MOV CX, 0           ; Reiniciar la columna
    INC DX              ; Avanzar en Y (fila)
    CMP DX, 480         ; ¿Llegamos al final de la pantalla?
    JNE PAINT_SCREEN

    RET
CLEAR_SCREEN ENDP

DRAW_RECTANGLE PROC
    ; Dibujar la línea superior (de X1 a X2 en Y1)
    MOV AL, 00H       ; Color rojo
    MOV DX, [Y1]        ; Y1 (Fila inicial)
    MOV CX, [X1]        ; X1 (Columna inicial)
TOP_LINE:
    CALL PRINT_PIXEL    ; Pintar píxel
    INC CX              ; Avanza en X (columna)
    CMP CX, [X2]        ; ¿Llegamos a X2?
    JLE TOP_LINE        ; Si no, continuar

    ; Dibujar la línea inferior (de X1 a X2 en Y2)
    MOV AL, 00H         ; Color rojo
    MOV DX, [Y2]        ; Y2 (Fila final)
    MOV CX, [X1]        ; X1
BOTTOM_LINE:
    CALL PRINT_PIXEL
    INC CX
    CMP CX, [X2]
    JLE BOTTOM_LINE

    ; Dibujar la línea izquierda (de Y1 a Y2 en X1)
    MOV AL, 00H         ; Color rojo
    MOV CX, [X1]        ; X1
    MOV DX, [Y1]        ; Y1
LEFT_LINE:
    CALL PRINT_PIXEL
    INC DX              ; Avanza en Y (fila)
    CMP DX, [Y2]
    JLE LEFT_LINE

    ; Dibujar la línea derecha (de Y1 a Y2 en X2)
    MOV AL, 00H         ; Color rojo
    MOV CX, [X2]        ; X2
    MOV DX, [Y1]        ; Y1
RIGHT_LINE:
    CALL PRINT_PIXEL
    INC DX
    CMP DX, [Y2]
    JLE RIGHT_LINE

    RET
DRAW_RECTANGLE ENDP

DRAW_RECTANGLE_INTERACTIVE PROC
    ; Dibujar la línea superior (de X1 a X2 en Y1)
    MOV AL, 0FH       ; Color rojo
    MOV DX, [Y1]        ; Y1 (Fila inicial)
    MOV CX, [X1]        ; X1 (Columna inicial)
TOP_LINE_INTERACTIVE:
    CALL PRINT_PIXEL    ; Pintar píxel
    INC CX              ; Avanza en X (columna)
    CMP CX, [X2]        ; ¿Llegamos a X2?
    JLE TOP_LINE_INTERACTIVE       ; Si no, continuar

    ; Dibujar la línea inferior (de X1 a X2 en Y2)
    MOV AL, 0FH         ; Color rojo
    MOV DX, [Y2]        ; Y2 (Fila final)
    MOV CX, [X1]        ; X1
BOTTOM_LINE_INTERACTIVE:
    CALL PRINT_PIXEL
    INC CX
    CMP CX, [X2]
    JLE BOTTOM_LINE_INTERACTIVE

    ; Dibujar la línea izquierda (de Y1 a Y2 en X1)
    MOV AL, 0FH         ; Color rojo
    MOV CX, [X1]        ; X1
    MOV DX, [Y1]        ; Y1
LEFT_LINE_INTERACTIVE:
    CALL PRINT_PIXEL
    INC DX              ; Avanza en Y (fila)
    CMP DX, [Y2]
    JLE LEFT_LINE_INTERACTIVE

    ; Dibujar la línea derecha (de Y1 a Y2 en X2)
    MOV AL, 0FH         ; Color rojo
    MOV CX, [X2]        ; X2
    MOV DX, [Y1]        ; Y1
RIGHT_LINE_INTERACTIVE:
    CALL PRINT_PIXEL
    INC DX
    CMP DX, [Y2]
    JLE RIGHT_LINE_INTERACTIVE

    RET
DRAW_RECTANGLE_INTERACTIVE ENDP

FILL_RECTANGLE PROC
    MOV DX, [Y1]        ; Fila inicial (Y1)
    INC DX
FILL_ROWS:
    MOV CX, [X1]        ; Columna inicial (X1)
    INC CX
FILL_PIXELS:
    
    CALL PRINT_PIXEL    ; Pintar cada píxel
    INC CX              ; Avanzar en la columna
    CMP CX, [X2]        ; ¿Llegamos al borde derecho (X2)?
    JL FILL_PIXELS     ; Si no, continuar

    INC DX              ; Pasar a la siguiente fila (avanzar en Y)
    CMP DX, [Y2]        ; ¿Llegamos al borde inferior (Y2)?
    JL FILL_ROWS       ; Si no, continuar rellenando
    RET
FILL_RECTANGLE ENDP

DRAW_ARROW_UP PROC
    MOV BH, 00H    ; Página 0
    MOV AL, 0FH    ; Color VERDE
    ; Dibujar la línea HORIZONTAL DEL TRIANGULO 
    MOV CX, 537
    MOV DX, 410
DRAW_HORIZONTAL_LINE_UP:
    MOV AH, 0CH
    INT 10H
    INC CX
    CMP CX, 557
    JNE DRAW_HORIZONTAL_LINE_UP

    ; Dibujar SLASH DEL TRIANGULO (\)
    MOV CX, 557
    MOV DX, 410
DRAW_SLASH_LEFT_UP:
    MOV AH, 0CH
    INT 10H
    DEC CX
    DEC DX
    CMP CX, 546
    JNE DRAW_SLASH_LEFT_UP

    ; Dibujar SLASH DEL TRIANGULO (/)
    MOV CX, 537
    MOV DX, 410
DRAW_SLASH_RIGHT_UP:
    MOV AH, 0CH
    INT 10H
    INC CX
    DEC DX
    CMP CX, 547
    JNE DRAW_SLASH_RIGHT_UP

    RET
DRAW_ARROW_UP ENDP

DRAW_ARROW_DOWN PROC
    MOV BH, 00H    ; Página 0
    MOV AL, 0FH    ; Color VERDE
    ; Dibujar la línea HORIZONTAL DEL TRIANGULO 
    MOV CX, 537
    MOV DX, 435
DRAW_HORIZONTAL_LINE_DOWN:
    MOV AH, 0CH
    INT 10H
    INC CX
    CMP CX, 557
    JNE DRAW_HORIZONTAL_LINE_DOWN

    ; Dibujar SLASH DEL TRIANGULO (\)
    MOV CX, 547
    MOV DX, 445
DRAW_SLASH_LEFT_DOWN:
    MOV AH, 0CH
    INT 10H
    DEC CX
    DEC DX
    CMP CX, 537
    JNE DRAW_SLASH_LEFT_DOWN

    ; Dibujar SLASH DEL TRIANGULO (/)
    MOV CX, 547
    MOV DX, 445
DRAW_SLASH_RIGHT_DOWN:
    MOV AH, 0CH
    INT 10H
    INC CX
    DEC DX
    CMP CX, 557
    JNE DRAW_SLASH_RIGHT_DOWN

    RET
DRAW_ARROW_DOWN ENDP

DRAW_ARROW_RIGHT PROC
    MOV BH, 00H    ; Página 0
    MOV AL, 0FH    ; Color VERDE
    ; Dibujar la línea VERTICAL DEL TRIANGULO 
    MOV CX, 577
    MOV DX, 450
DRAW_VERTICAL_LINE_RIGHT:
    MOV AH, 0CH
    INT 10H
    DEC DX
    CMP DX, 430
    JNE DRAW_VERTICAL_LINE_RIGHT

    ; Dibujar SLASH DEL TRIANGULO (\)
    MOV CX, 587
    MOV DX, 440
DRAW_SLASH_LEFT_RIGHT:
    MOV AH, 0CH
    INT 10H
    DEC CX
    DEC DX
    CMP CX, 577
    JNE DRAW_SLASH_LEFT_RIGHT

    ; Dibujar SLASH DEL TRIANGULO (/)
    MOV CX, 577
    MOV DX, 450
DRAW_SLASH_RIGHT_RIGHT:
    MOV AH, 0CH
    INT 10H
    INC CX
    DEC DX
    CMP CX, 587
    JNE DRAW_SLASH_RIGHT_RIGHT

    RET
DRAW_ARROW_RIGHT ENDP

DRAW_ARROW_LEFT PROC
    MOV BH, 00H    ; Página 0
    MOV AL, 0FH    ; Color VERDE
    ; Dibujar la línea VERTICAL DEL TRIANGULO 
    MOV CX, 517
    MOV DX, 450
DRAW_VERTICAL_LINE_LEFT:
    MOV AH, 0CH
    INT 10H
    DEC DX
    CMP DX, 430
    JNE DRAW_VERTICAL_LINE_LEFT

    ; Dibujar SLASH DEL TRIANGULO (\)
    MOV CX, 517
    MOV DX, 450
DRAW_SLASH_LEFT_LEFT:
    MOV AH, 0CH
    INT 10H
    DEC CX
    DEC DX
    CMP CX, 507
    JNE DRAW_SLASH_LEFT_LEFT

    ; Dibujar SLASH DEL TRIANGULO (/)
    MOV CX, 507
    MOV DX, 440
DRAW_SLASH_RIGHT_LEFT:
    MOV AH, 0CH
    INT 10H
    INC CX
    DEC DX
    CMP CX, 517
    JNE DRAW_SLASH_RIGHT_LEFT

    RET
DRAW_ARROW_LEFT ENDP

TEXT_POSITION MACRO fila, columna
    MOV AH, 02H          ; Función 02h - Mover el cursor
    MOV BH, 00H          ; Página de visualización 0 (modo estándar)
    MOV DH, fila         ; Fila (posición vertical)
    MOV DL, columna      ; Columna (posición horizontal)
    INT 10H              ; Interrupción BIOS para mover el cursor
ENDM

TEXT_GUARDAR PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtGuardar
    TEXT_POSITION 25,4
PRINT_TXT_GUARDAR:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_GUARDAR
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 0FH        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_GUARDAR

END_PRINT_TXT_GUARDAR:
    RET
TEXT_GUARDAR ENDP

TEXT_CARGAR PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtCargar
    TEXT_POSITION 28,4
PRINT_TXT_CARGAR:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_CARGAR
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 0FH        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_CARGAR

END_PRINT_TXT_CARGAR:
    RET
TEXT_CARGAR ENDP

TEXT_LIMPIAR PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtLimpiar
    TEXT_POSITION 2,48
PRINT_TXT_LIMPIAR:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_LIMPIAR
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 0FH        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_LIMPIAR

END_PRINT_TXT_LIMPIAR:
    RET
TEXT_LIMPIAR ENDP

TEXT_IMAGEN PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtImagen
    TEXT_POSITION 28,33
PRINT_TXT_IMAGEN:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_IMAGEN
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 0FH        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_IMAGEN

END_PRINT_TXT_IMAGEN:
    RET
TEXT_IMAGEN ENDP

TEXT_CAMPO PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtCampo
    TEXT_POSITION 25,33
PRINT_TXT_CAMPO:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_CAMPO
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 0FH        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_CAMPO

END_PRINT_TXT_CAMPO:
    RET
TEXT_CAMPO ENDP

TEXT_DIBUJO PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtDibujo
    TEXT_POSITION 2,17
PRINT_TXT_DIBUJO:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_DIBUJO
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 0FH        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_DIBUJO

END_PRINT_TXT_DIBUJO:
    RET
TEXT_DIBUJO ENDP

; ----------------------------------------------------------------
; PROGRAMA PRINCIPAL
; ----------------------------------------------------------------
MAIN PROC
    MOV AX,@DATA
	MOV DS,AX

    ; Inicializar la pantalla en modo gráfico
    CALL INIT_SCREEN

    ; Pintar la pantalla
    CALL CLEAR_SCREEN

    ; Dibujar cuadro de texto "dibujo sin Nombre"
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el primer botón
    MOV WORD PTR [Y1], 25   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 350  ; Columna final (X2)
    MOV WORD PTR [Y2], 50   ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar botón "Limpiar"
    MOV WORD PTR [X1], 360  ; Columna inicial (X1) para el segundo botón
    MOV WORD PTR [Y1], 25   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 50   ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar area de dibujo
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 65   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 375  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    ; Dibujar boton "guardar bosquejo"
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 160  ; Columna final (X2)
    MOV WORD PTR [Y2], 425  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar boton "cargar bosquejo"
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 435  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 160  ; Columna final (X2)
    MOV WORD PTR [Y2], 470  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar cuadro de texto "Campo de texto"
    MOV WORD PTR [X1], 185  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 420  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar boton "Insertar imagen"
    MOV WORD PTR [X1], 255  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 435  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 390  ; Columna final (X2)
    MOV WORD PTR [Y2], 470  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar area  "Colores"
    MOV WORD PTR [X1], 480  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 25   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 615  ; Columna final (X2)
    MOV WORD PTR [Y2], 375  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 07H
    CALL FILL_RECTANGLE

    ; Dibujar cuadro color  "azul"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 80   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 110   ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 01H
    CALL FILL_RECTANGLE

    ; Dibujar color  "verde"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 140  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 170  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 02H
    CALL FILL_RECTANGLE

    ; Dibujar color  "rojo"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 200  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 230  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 04H
    CALL FILL_RECTANGLE

    ; Dibujar color  "amarillo"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 260   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 290  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0EH
    CALL FILL_RECTANGLE

    ; Dibujar color  "blanco"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 320   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 350  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    ; Dibujar color  "morado"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 80   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 110  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 05H
    CALL FILL_RECTANGLE

    ; Dibujar color  "marron"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 140   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 170  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 06H
    CALL FILL_RECTANGLE

    ; Dibujar color  "azul claro"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 200   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 230  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 09H
    CALL FILL_RECTANGLE
    

    ; Dibujar color  "verde claro"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 260   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 290  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0AH
    CALL FILL_RECTANGLE

    ; Dibujar color  "negro"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 320   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 350  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar cuadrado  "flecha arriba"
    MOV WORD PTR [X1], 532  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 562  ; Columna final (X2)
    MOV WORD PTR [Y2], 420  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0CH
    CALL FILL_RECTANGLE
    ; CALL DRAW_TRIANGLE_UP
   
    
    ; Dibujar cuadrado  "flecha abajo"
    MOV WORD PTR [X1], 532  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 425   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 562  ; Columna final (X2)
    MOV WORD PTR [Y2], 455  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0CH
    CALL FILL_RECTANGLE

    ; Dibujar cuadrado  "flecha izquierda"
    MOV WORD PTR [X1], 497  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 425   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 527 ; Columna final (X2)
    MOV WORD PTR [Y2], 455  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0CH
    CALL FILL_RECTANGLE

    ; Dibujar cuadrado  "flecha derecha"
    MOV WORD PTR [X1], 567  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 425   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 597  ; Columna final (X2)
    MOV WORD PTR [Y2], 455  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0CH
    CALL FILL_RECTANGLE

    CALL DRAW_ARROW_UP
    CALL DRAW_ARROW_DOWN
    CALL DRAW_ARROW_RIGHT
    CALL DRAW_ARROW_LEFT

    CALL TEXT_GUARDAR
    CALL TEXT_CARGAR
    CALL TEXT_LIMPIAR
    CALL TEXT_IMAGEN
    CALL TEXT_CAMPO
    CALL TEXT_DIBUJO
    
    ; Esperar a que se presione una tecla
    MOV AH, 00H
    INT 16H
    RET
MAIN ENDP

END MAIN
