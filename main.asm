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
    txtColores DB 'Colores$'

    ; Coordenadas para los rectángulos (botones)
    RECT_1 DW 500, 80, 530, 110       ; X1, Y1, X2, Y2 del rectángulo 1 (color azul)
    RECT_2 DW 500, 140, 530, 170      ; X1, Y1, X2, Y2 del rectángulo 2 (color verde)
    RECT_3 DW 500, 200, 530, 230      ; X1, Y1, X2, Y2 del rectángulo 3 (color rojo)
    RECT_4 DW 500, 260, 530, 290      ; X1, Y1, X2, Y2 del rectángulo 4 (color amarillo)
    RECT_5 DW 500, 320, 530, 350      ; X1, Y1, X2, Y2 del rectángulo 5 (color blanco)
    RECT_6 DW 565, 80, 595, 110       ; X1, Y1, X2, Y2 del rectángulo 6 (color morado)
    RECT_7 DW 565, 140, 595, 170      ; X1, Y1, X2, Y2 del rectángulo 7 (color marrón)
    RECT_8 DW 565, 200, 595, 230      ; X1, Y1, X2, Y2 del rectángulo 8 (color azul claro)
    RECT_9 DW 565, 260, 595, 290      ; X1, Y1, X2, Y2 del rectángulo 9 (color verde claro)
    RECT_10 DW 565, 320, 595, 350     ; X1, Y1, X2, Y2 del rectángulo 10 (color negro)
    RECT_11 DW 360, 25, 460, 50       ; Coordenadas del área de limpieza

    ; Colores correspondientes a cada rectángulo
    RECTANGLE_COLORS DB 01H, 02H, 04H, 0EH, 0FH, 05H, 06H, 09H, 0AH, 00H
    SELECTED_COLOR DB 0 

    X_POS DW 0        ; Almacena la posición X del mouse
    Y_POS DW 0        ; Almacena la posición Y del mouse
    BUTTONS DW 0      ; Almacena el estado de los botones del mouse

    DRAW_X DW ?
    DRAW_Y DW ?

    DRAW_X1 DW 25     ; Limite izquierdo del área de dibujo
    DRAW_Y1 DW 65     ; Limite superior del área de dibujo
    DRAW_X2 DW 460    ; Limite derecho del área de dibujo
    DRAW_Y2 DW 375    ; Limite inferior del área de dibujo


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
    TEXT_POSITION 2,16
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

TEXT_COLORES PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtColores
    TEXT_POSITION 3,65
PRINT_TXT_COLORES:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_COLORES
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 0FH        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_COLORES

END_PRINT_TXT_COLORES:
    RET
TEXT_COLORES ENDP

SET_GRAFICS PROC 

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
    MOV WORD PTR [X2], 164  ; Columna final (X2)
    MOV WORD PTR [Y2], 425  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar boton "cargar bosquejo"
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 435  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 157  ; Columna final (X2)
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
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar cuadro color  "azul"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 80   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 110   ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 01H
    CALL FILL_RECTANGLE

    ; Dibujar color  "verde"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 140  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 170  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 02H
    CALL FILL_RECTANGLE

    ; Dibujar color  "rojo"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 200  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 230  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 04H
    CALL FILL_RECTANGLE

    ; Dibujar color  "amarillo"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 260   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 290  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 0EH
    CALL FILL_RECTANGLE

    ; Dibujar color  "blanco"
    MOV WORD PTR [X1], 500  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 320   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 530  ; Columna final (X2)
    MOV WORD PTR [Y2], 350  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    ; Dibujar color  "morado"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 80   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 110  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 05H
    CALL FILL_RECTANGLE

    ; Dibujar color  "marron"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 140   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 170  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 06H
    CALL FILL_RECTANGLE

    ; Dibujar color  "azul claro"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 200   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 230  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 09H
    CALL FILL_RECTANGLE
    

    ; Dibujar color  "verde claro"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 260   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 290  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 0AH
    CALL FILL_RECTANGLE

    ; Dibujar color  "negro"
    MOV WORD PTR [X1], 565  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 320   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 595  ; Columna final (X2)
    MOV WORD PTR [Y2], 350  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
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
    CALL TEXT_COLORES

    RET

SET_GRAFICS ENDP

MOUSE_INIT PROC
    MOV AX, 0      ; Función 0 de la interrupción 33h: inicializar el mouse
    INT 33h        ; Interrupción para interactuar con el mouse
    RET
MOUSE_INIT ENDP

MOUSE_SHOW PROC
    MOV AX, 01h    ; Función 01h de INT 33h: Mostrar el cursor del mouse
    INT 33h        ; Interrupción para interactuar con el mouse
    RET
MOUSE_SHOW ENDP

MOUSE_GET_POSITION PROC
    PUSH AX        ; Preservar AX
    MOV AX, 03h    ; Función 3 de la interrupción 33h: obtener estado del mouse
    INT 33h        ; Interrupción para interactuar con el mouse

    MOV [X_POS], CX   ; Guardar la posición X en X_POS
    MOV [Y_POS], DX   ; Guardar la posición Y en Y_POS
    MOV [BUTTONS], BX ; Guardar el estado de los botones en BUTTONS

    POP AX         ; Restaurar AX
    RET
MOUSE_GET_POSITION ENDP

IS_CLICK_INSIDE_RECTANGLE PROC
    PUSH AX        ; Preservar AX

    ; Comparar X del mouse con X1 y X2 del rectángulo
    MOV AX, [BX]        ; AX = X1 del rectángulo
    CMP CX, AX          ; CX < X1?
    JL @NOT_INSIDE      ; Si CX es menor que X1, salir (no está dentro)

    MOV AX, [BX+4]      ; AX = X2 del rectángulo
    CMP CX, AX          ; CX > X2?
    JG @NOT_INSIDE      ; Si CX es mayor que X2, salir (no está dentro)

    ; Comparar Y del mouse con Y1 y Y2 del rectángulo
    MOV AX, [BX+2]      ; AX = Y1 del rectángulo
    CMP DX, AX          ; DX < Y1?
    JL @NOT_INSIDE      ; Si DX es menor que Y1, salir (no está dentro)

    MOV AX, [BX+6]      ; AX = Y2 del rectángulo
    CMP DX, AX          ; DX > Y2?
    JG @NOT_INSIDE      ; Si DX es mayor que Y2, salir (no está dentro)

    ; Si llegamos aquí, el clic está dentro del rectángulo
    CMP AX, AX          ; Comparación redundante para activar ZF (establecer ZF)
    JMP @DONE

@NOT_INSIDE:
    OR AX, AX           ; Comparación para limpiar ZF (desactivar ZF)

@DONE:
    POP AX              ; Restaurar AX
    RET
IS_CLICK_INSIDE_RECTANGLE ENDP


DRAWING_LOOP PROC
    ; Bucle para mover el cursor y dibujar con las teclas
DRAW_LOOP:
    ; Verificar si se presiona una tecla
    MOV AH, 01h
    INT 16h
    JZ CHECK_MOUSE  ; Si no se presiona tecla, revisar el mouse

    ; Leer la tecla presionada
    MOV AH, 00h
    INT 16h

    CMP AL, 'a'   ; Tecla A (izquierda)
    JE DRAW_LEFT
    CMP AL, 'd'   ; Tecla D (derecha)
    JE DRAW_RIGHT
    CMP AL, 'w'   ; Tecla W (arriba)
    JE DRAW_UP
    CMP AL, 's'   ; Tecla S (abajo)
    JE DRAW_DOWN
    JMP DRAW_LOOP

DRAW_LEFT:
    CMP [DRAW_X], 25   ; Límite izquierdo del área de dibujo
    JLE DRAW_LOOP
    DEC WORD PTR [DRAW_X]  ; Decrementar DRAW_X
    JMP DRAW_PIXEL

DRAW_RIGHT:
    CMP [DRAW_X], 460  ; Límite derecho del área de dibujo
    JGE DRAW_LOOP
    INC WORD PTR [DRAW_X]  ; Incrementar DRAW_X
    JMP DRAW_PIXEL

DRAW_UP:
    CMP [DRAW_Y], 65   ; Límite superior del área de dibujo
    JLE DRAW_LOOP
    DEC WORD PTR [DRAW_Y]  ; Decrementar DRAW_Y
    JMP DRAW_PIXEL

DRAW_DOWN:
    CMP [DRAW_Y], 375  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP
    INC WORD PTR [DRAW_Y]  ; Incrementar DRAW_Y
    JMP DRAW_PIXEL

DRAW_PIXEL:
    ; Dibujar el píxel con el color seleccionado en SELECTED_COLOR
    MOV AL, [SELECTED_COLOR] 
    MOV CX, [DRAW_X]
    MOV DX, [DRAW_Y]
    CALL PRINT_PIXEL
    JMP DRAW_LOOP

CHECK_MOUSE:
    ; Verificar si se presionó el botón izquierdo del mouse
    CALL MOUSE_GET_POSITION
    CMP [BUTTONS], 1
    JNE DRAW_LOOP  ; Si no se presionó el botón izquierdo, continuar dibujando

    ; Verificar si el clic está dentro del área de dibujo
    CMP [X_POS], 25
    JL EXIT_DRAWING    ; Si está fuera del área de dibujo (izquierda), verificar rectángulos
    CMP [X_POS], 460
    JG EXIT_DRAWING    ; Si está fuera del área de dibujo (derecha), verificar rectángulos
    CMP [Y_POS], 65
    JL EXIT_DRAWING    ; Si está fuera del área de dibujo (arriba), verificar rectángulos
    CMP [Y_POS], 375
    JG EXIT_DRAWING    ; Si está fuera del área de dibujo (abajo), verificar rectángulos

    MOV AX, [X_POS]   ; Cargar el valor de X_POS en AX
    MOV [DRAW_X], AX  ; Mover el valor de AX a DRAW_X

    MOV AX, [Y_POS]   ; Cargar el valor de Y_POS en AX
    MOV [DRAW_Y], AX  ; Mover el valor de AX a DRAW_Y
    JMP DRAW_LOOP  ; Volver al ciclo de dibujo

EXIT_DRAWING:
    RET
DRAWING_LOOP ENDP

CLEAR_DRAWING_AREA PROC
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 65   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 375  ; Fila final (Y2)
    MOV AL, 0FH
    CALL FILL_RECTANGLE
    RET
CLEAR_DRAWING_AREA ENDP

; ----------------------------------------------------------------
; PROGRAMA PRINCIPAL
; ----------------------------------------------------------------
MAIN PROC
    MOV AX,@DATA
	MOV DS,AX

    CALL SET_GRAFICS
    ; Inicializar el mouse
    CALL MOUSE_INIT

    ; Mostrar el cursor del mouse
    CALL MOUSE_SHOW

    ; Bucle infinito para obtener la posición del mouse y el estado de los botones
MAIN_LOOP:
    CALL MOUSE_GET_POSITION

    ; Verificar si se presionó el botón izquierdo del mouse
    CMP [BUTTONS], 1
    JNE MAIN_LOOP  ; Si no se presionó el botón izquierdo, repetir bucle

    ; Verificar si el clic está dentro de algún rectángulo
    MOV SI, OFFSET RECT_1  ; Iniciar con el primer rectángulo
    MOV DI, OFFSET RECTANGLE_COLORS ; Iniciar con el primer color
    MOV CX, 11              ; Número de rectángulos

CHECK_RECTANGLES:
    MOV BX, SI              ; Dirección de las coordenadas del rectángulo actual
    MOV CX, [X_POS]         ; Coordenada X del mouse
    MOV DX, [Y_POS]         ; Coordenada Y del mouse
    CALL IS_CLICK_INSIDE_RECTANGLE
    JZ RECTANGLE_FOUND     ; Si ZF está activado, se encontró un clic dentro del rectángulo

    ; Incrementar punteros para pasar al siguiente rectángulo y su color
    ADD SI, 8               ; Avanzar 8 bytes (4 palabras) a las coordenadas del siguiente rectángulo
    INC DI                  ; Avanzar al siguiente color
    LOOP CHECK_RECTANGLES   ; Repetir hasta comprobar todos los rectángulos

    JMP MAIN_LOOP           ; Si no se encontró un clic dentro de ningún rectángulo, repetir el bucle principal

RECTANGLE_FOUND:
    CMP DI, OFFSET RECTANGLE_COLORS + 10
    JE CLEAN_DRAWING_AREA
    MOV AL, [DI]              ; Cargar el color del rectángulo seleccionado en AL
    MOV [SELECTED_COLOR], AL          ; Cargar el color del rectángulo seleccionado en AL
    CALL DRAWING_LOOP
    JMP MAIN_LOOP           ; Continuar verificando clics

CLEAN_DRAWING_AREA:
    CALL CLEAR_DRAWING_AREA   ; Llamar a la función de limpiar el área de dibujo
    JMP MAIN_LOOP             ; Volver al bucle principal
MAIN ENDP

END MAIN

