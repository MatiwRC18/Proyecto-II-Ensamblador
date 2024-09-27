.MODEL SMALL
.STACK 100H

.DATA
    ; Coordenadas para los rectángulos (botones)
    X1 DW 0
    Y1 DW 0
    X2 DW 0
    Y2 DW 0

    ; Textos para los botones
    textoGuardar DB 'Guardar', 0
    textoCargar DB 'Cargar', 0
    textoLimpiar DB 'Limpiar', 0


.CODE

; ----------------------------------------------------------------
; INICIALIZAR EL MODO GRAFICO 640x480 16 COLORES (12H)
; ----------------------------------------------------------------
INIT_SCREEN PROC
    MOV AX, 0012H       ; Cambiar al modo gráfico 12h (640x480, 16 colores)
    INT 10H             ; Interrupción de BIOS para cambiar el modo gráfico
    RET
INIT_SCREEN ENDP

; ----------------------------------------------------------------
; FUNCION PARA PINTAR UN PIXEL EN MODO GRAFICO
; ----------------------------------------------------------------
PINTA_PIXEL PROC
    MOV AH, 0CH         ; Función BIOS para pintar un píxel
    INT 10H             ; Interrupción de video para pintar el píxel
    RET
PINTA_PIXEL ENDP

; ----------------------------------------------------------------
; FUNCION PARA LIMPIAR LA PANTALLA Y PINTARLA DE BLANCO
; ----------------------------------------------------------------
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

; ----------------------------------------------------------------
; FUNCION PARA DIBUJAR UN RECTANGULO
; ----------------------------------------------------------------
DRAW_RECTANGLE PROC
    ; Dibujar la línea superior (de X1 a X2 en Y1)
    MOV AL, 00H        ; Color rojo
    MOV DX, [Y1]        ; Y1 (Fila inicial)
    MOV CX, [X1]        ; X1 (Columna inicial)
TOP_LINE:
    CALL PINTA_PIXEL    ; Pintar píxel
    INC CX              ; Avanza en X (columna)
    CMP CX, [X2]        ; ¿Llegamos a X2?
    JLE TOP_LINE        ; Si no, continuar

    ; Dibujar la línea inferior (de X1 a X2 en Y2)
    MOV AL, 00H         ; Color rojo
    MOV DX, [Y2]        ; Y2 (Fila final)
    MOV CX, [X1]        ; X1
BOTTOM_LINE:
    CALL PINTA_PIXEL
    INC CX
    CMP CX, [X2]
    JLE BOTTOM_LINE

    ; Dibujar la línea izquierda (de Y1 a Y2 en X1)
    MOV AL, 00H         ; Color rojo
    MOV CX, [X1]        ; X1
    MOV DX, [Y1]        ; Y1
LEFT_LINE:
    CALL PINTA_PIXEL
    INC DX              ; Avanza en Y (fila)
    CMP DX, [Y2]
    JLE LEFT_LINE

    ; Dibujar la línea derecha (de Y1 a Y2 en X2)
    MOV AL, 00H         ; Color rojo
    MOV CX, [X2]        ; X2
    MOV DX, [Y1]        ; Y1
RIGHT_LINE:
    CALL PINTA_PIXEL
    INC DX
    CMP DX, [Y2]
    JLE RIGHT_LINE

    RET
DRAW_RECTANGLE ENDP

; ----------------------------------------------------------------
; FUNCION PARA RELLENAR UN RECTANGULO
; ----------------------------------------------------------------
FILL_RECTANGLE PROC
    MOV DX, [Y1]        ; Fila inicial (Y1)
    INC DX
FILL_ROWS:
    MOV CX, [X1]        ; Columna inicial (X1)
    INC CX
FILL_PIXELS:
    
    CALL PINTA_PIXEL    ; Pintar cada píxel
    INC CX              ; Avanzar en la columna
    CMP CX, [X2]        ; ¿Llegamos al borde derecho (X2)?
    JL FILL_PIXELS     ; Si no, continuar

    INC DX              ; Pasar a la siguiente fila (avanzar en Y)
    CMP DX, [Y2]        ; ¿Llegamos al borde inferior (Y2)?
    JL FILL_ROWS       ; Si no, continuar rellenando
    RET
FILL_RECTANGLE ENDP



; ----------------------------------------------------------------
; PROGRAMA PRINCIPAL
; ----------------------------------------------------------------
MAIN PROC
    ; Inicializar la pantalla en modo gráfico
    CALL INIT_SCREEN

    ; Pintar la pantalla
    CALL CLEAR_SCREEN

    ; Dibujar cuadro de texto "dibujo sin Nombre"
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el primer botón
    MOV WORD PTR [Y1], 25   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 350  ; Columna final (X2)
    MOV WORD PTR [Y2], 50   ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    ; Dibujar botón "Limpiar"
    MOV WORD PTR [X1], 360  ; Columna inicial (X1) para el segundo botón
    MOV WORD PTR [Y1], 25   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 50   ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 07H
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
    CALL DRAW_RECTANGLE
    MOV AL, 07H
    CALL FILL_RECTANGLE

    ; Dibujar boton "cargar bosquejo"
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 435  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 160  ; Columna final (X2)
    MOV WORD PTR [Y2], 470  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 07H
    CALL FILL_RECTANGLE

    ; Dibujar cuadro de texto "Campo de texto"
    MOV WORD PTR [X1], 185  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 420  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    ; Dibujar boton "Insertar imagen"
    MOV WORD PTR [X1], 255  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 435  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 390  ; Columna final (X2)
    MOV WORD PTR [Y2], 470  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 07H
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

    ; Esperar a que se presione una tecla
    MOV AH, 00H
    INT 16H

    

    RET
MAIN ENDP

END MAIN
