.MODEL SMALL
.STACK 100H

.DATA
   ; Coordenadas para los rectángulos (botones)
    X1 DW 0
    Y1 DW 0
    X2 DW 0
    Y2 DW 0

    Y DW  0
    X DW  0
    Y_C DW  0
    X_C DW  0
    E DW  0

   ; Cadenas de texto (terminadas en '$')
    txtGuardar DB 'Guardar bosquejo$'
    txtCargar DB 'Cargar bosquejo$'
    txtLimpiar DB 'Limpiar$'
    txtImagen DB 'Insertar imagen$'
    txtCampo DB 'Texto aqui:$'
    txtDibujo DB 'Dibujo sin nombre$'
    txtColores DB 'Colores$'
    txtSketch DB 'Etch A Sketch$'
    txtGruesor DB 'Gruesor$'
    txtAsterisco DB '*$'
    txtError DB 'Bosquejo no existe$'
    txtGuardado DB 'Bosquejo guardado$'
    txtCargado DB 'Bosquejo cargado$'

    LINE_POINTS dw 0,0,0,0 
    ; Colores correspondientes a cada rectángulo
    RECTANGLE_COLORS DB 01H, 02H, 04H, 0EH, 0FH, 05H, 06H, 09H, 0AH, 00H
    SELECTED_COLOR DB 0 
    SELECTED_THICKNESS DW 0

    X_POS DW 0        ; Almacena la posición X del mouse
    Y_POS DW 0        ; Almacena la posición Y del mouse
    BUTTONS DW 0      ; Almacena el estado de los botones del mouse

    DRAW_X DW ?
    DRAW_Y DW ?

    DRAW_X1 DW 36     ; Limite izquierdo del área de dibujo
    DRAW_Y1 DW 76     ; Limite superior del área de dibujo
    DRAW_X2 DW 449    ; Limite derecho del área de dibujo
    DRAW_Y2 DW 304    ; Limite inferior del área de dibujo

    ; Definir el área de texto y límites
    TXT_COLUMN_START EQU 36     ; Columna inicial (aproximado desde 190px)
    TXT_ROW_START    EQU 25      ; Fila inicial (aproximado desde 395px)
    MAX_COLUMNS      EQU 57      ; Máximo número de columnas en la línea

    ; Buffers
    FILENAME_BUFFER DB 100 DUP(0)  ; Almacenar el nombre del archivo
    FILENAME_INDEX DW 0           ; Índice para el buffer del nombre
    BYTE_BUFFER DB 0  ; Buffer para almacenar el byte temporalmente
    
    CURSOR_ROW  DB TXT_ROW_START ; Inicializar la fila del cursor
    CURSOR_COL  DB TXT_COLUMN_START ; Inicializar la columna del cursor

    DRAW_X_START EQU 36    ; Coordenada X inicial del área de dibujo
    DRAW_X_END   EQU 450   ; Coordenada X final del área de dibujo
    DRAW_Y_START EQU 76    ; Coordenada Y inicial del área de dibujo
    DRAW_Y_END   EQU 304   ; Coordenada Y final del área de dibujo


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
    TEXT_POSITION 25,24
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

TEXT_SKETCH PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtSketch
    TEXT_POSITION 21,24
PRINT_TXT_SKETCH:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_SKETCH
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 04H        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_SKETCH

END_PRINT_TXT_SKETCH:
    RET
TEXT_SKETCH ENDP

TEXT_GRUESOR PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtGruesor
    TEXT_POSITION 25,65
PRINT_TXT_GRUESOR:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_GRUESOR
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 0FH        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_GRUESOR

END_PRINT_TXT_GRUESOR:
    RET
TEXT_GRUESOR ENDP

TEXT_ASTERISCO PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtAsterisco
    TEXT_POSITION 25,56
PRINT_TXT_ASTERISCO:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_ASTERISCO
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 09H        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_ASTERISCO

END_PRINT_TXT_ASTERISCO:
    RET
TEXT_ASTERISCO ENDP

TEXT_ERROR PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtError
    TEXT_POSITION 25,36
PRINT_TXT_ERROR:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_ERROR
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 04H        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_ERROR

END_PRINT_TXT_ERROR:
    RET
TEXT_ERROR ENDP

TEXT_GUARDADO PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtGuardado
    TEXT_POSITION 25,36
PRINT_TXT_GUARDADO:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_GUARDADO
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 02H        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_GUARDADO

END_PRINT_TXT_GUARDADO:
    RET
TEXT_GUARDADO ENDP

TEXT_CARGADO PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtCargado
    TEXT_POSITION 25,36
PRINT_TXT_CARGADO:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_CARGADO
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 02H        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_CARGADO

END_PRINT_TXT_CARGADO:
    RET
TEXT_CARGADO ENDP

DELAY_SECONDS PROC
    ; Guardar el número de segundos en CX para el bucle externo
    MOV CX, AX

NEXT_SECOND:
    ; Bucle interno para consumir tiempo (aproximadamente 1 segundo en DOSBox)
    MOV DX, 0FFFFh   ; Establecer el valor inicial del bucle interno

DELAY_LOOP:
    DEC DX           ; Decrementar DX
    JNZ DELAY_LOOP   ; Continuar hasta que DX llegue a 0

    ; Decrementar CX (segundos restantes)
    LOOP NEXT_SECOND ; Repetir hasta que CX llegue a 0

    RET
DELAY_SECONDS ENDP

CIRCLE PROC
    
    PUSH    DX              ; Guardar registro DX en la pila para preservarlo
    PUSH    CX              ; Guardar registro CX en la pila para preservarlo

    MOV     X, SI           ; X = SI (radio inicial)
    MOV     X_C, DX         ; X_C = DX (coordenada X del centro del círculo)
    MOV     Y_C, CX         ; Y_C = CX (coordenada Y del centro del círculo)

CIR:
    MOV     DX, X           ; Copiar X a DX para comparación
    CMP     DX, Y           ; Comparar DX con Y (Y empieza en 0)
    JNGE    FIN_CIR         ; Si X < Y, salir del bucle y terminar el círculo

    CALL    DRAWCIRCLE      ; Llamar a la función que dibuja los puntos del círculo

    INC     Y               ; Incrementar Y para la siguiente iteración (avanzar en el eje Y)

    PUSH    AX              ; Guardar el valor de AX para preservar el resultado de la multiplicación

    MOV     AX, 2           ; Preparar para calcular 2*Y
    MUL     Y               ; AX = 2*Y
    INC     AX              ; AX = 2*Y + 1
    ADD     AX, E           ; E = E + (2*Y + 1)
    MOV     E, AX           ; Actualizar E con el nuevo valor

    SUB     AX, X           ; Calcular AX - X (diferencia entre AX y X)
    MOV     DX, 2           ; Preparar para multiplicación por 2
    MUL     DX              ; AX = 2*(AX - X)
    INC     AX              ; AX = AX + 1
    CMP     AX, 0           ; Comparar el resultado con 0
    JG      E_CHECK         ; Si es positivo, ir a E_CHECK

    POP     AX              ; Restaurar el valor anterior de AX
    JMP     CIR             ; Volver al inicio del bucle para la siguiente iteración

E_CHECK:
    DEC     X               ; Decrementar X (avanzar hacia adentro en el eje X)
    MOV     AX, X           ; Copiar X a AX
    MOV     DX, 2           ; Preparar para multiplicación por 2
    MUL     DX              ; AX = 2*X
    MOV     DX, 1           ; DX = 1
    SUB     DX, AX          ; DX = 1 - (2*X)
    ADD     E, DX           ; E = E + (1 - 2*X)

    POP     AX              ; Restaurar el valor anterior de AX
    JMP     CIR             ; Volver al inicio del bucle para la siguiente iteración

FIN_CIR:
    MOV WORD PTR [Y], 0     ; Reiniciar Y a 0
    MOV WORD PTR [X], 0     ; Reiniciar X a 0
    MOV WORD PTR [E], 0     ; Reiniciar E a 0
    MOV WORD PTR [Y_C], 0   ; Reiniciar Y_C a 0
    MOV WORD PTR [X_C], 0   ; Reiniciar X_C a 0
    
    POP     CX              ; Restaurar el valor original de CX
    POP     DX              ; Restaurar el valor original de DX

    RET                     ; Retornar al final del procedimiento
CIRCLE ENDP

DRAWCIRCLE PROC
    PUSH    DX              ; Guardar DX en la pila
    PUSH    CX              ; Guardar CX en la pila

    ; Dibujar el primer punto: (X_C + X, Y_C + Y)  ESTE 
    MOV     DX, X_C
    MOV     CX, Y_C
    ADD     DX, X           ; DX = X_C + X
    ADD     CX, Y           ; CX = Y_C + Y
    CALL    PRINT_PIXEL     ; Llamar a la función para dibujar el píxel en (DX, CX)

    ; Dibujar el segundo punto: (X_C + Y, Y_C + X) ESTE 
    MOV     DX, X_C
    MOV     CX, Y_C
    ADD     DX, Y           ; DX = X_C + Y
    ADD     CX, X           ; CX = Y_C + X
    CALL    PRINT_PIXEL     ; Llamar a la función para dibujar el píxel en (DX, CX)

    ; Dibujar el tercer punto: (X_C - Y, Y_C + X) ESTE 
    MOV     DX, X_C
    SUB     DX, Y           ; DX = X_C - Y
    CALL    PRINT_PIXEL     ; Llamar a la función para dibujar el píxel en (DX, CX)

    ; Dibujar el cuarto punto: (X_C - X, Y_C + Y)  ESTE 
    MOV     DX, X_C
    MOV     CX, Y_C
    SUB     DX, X           ; DX = X_C - X
    ADD     CX, Y           ; CX = Y_C + Y
    CALL    PRINT_PIXEL     ; Llamar a la función para dibujar el píxel en (DX, CX)

    ; Dibujar el quinto punto: (X_C - X, Y_C - Y) ESTE 
    MOV     CX, Y_C
    SUB     CX, Y           ; CX = Y_C - Y
    CALL    PRINT_PIXEL     ; Llamar a la función para dibujar el píxel en (DX, CX)

    ; Dibujar el sexto punto: (X_C - Y, Y_C - X) ESTE
    MOV     DX, X_C
    MOV     CX, Y_C
    SUB     DX, Y           ; DX = X_C - Y
    SUB     CX, X           ; CX = Y_C - X
    CALL    PRINT_PIXEL     ; Llamar a la función para dibujar el píxel en (DX, CX)

    ; Dibujar el séptimo punto: (X_C + Y, Y_C - X) ESTE  
    MOV     DX, X_C
    ADD     DX, Y           ; DX = X_C + Y
    CALL    PRINT_PIXEL     ; Llamar a la función para dibujar el píxel en (DX, CX)

    ; Dibujar el octavo punto: (X_C + X, Y_C - Y) ESTE 
    MOV     DX, X_C
    MOV     CX, Y_C
    ADD     DX, X           ; DX = X_C + X
    SUB     CX, Y           ; CX = Y_C - Y
    CALL    PRINT_PIXEL     ; Llamar a la función para dibujar el píxel en (DX, CX)

    POP     CX              ; Restaurar el valor original de CX
    POP     DX              ; Restaurar el valor original de DX
    RET                     ; Retornar al final del procedimiento
DRAWCIRCLE ENDP

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

    ; DIBUJAR SKETCH
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 65   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 375  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 04H
    CALL FILL_RECTANGLE
    
    ; Dibujar area de dibujo
    MOV WORD PTR [X1], 35   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 75   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 450  ; Columna final (X2)
    MOV WORD PTR [Y2], 305  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    MOV WORD PTR [X1], 170   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 325  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 315  ; Columna final (X2)
    MOV WORD PTR [Y2], 355  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    MOV AL, 00H
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
    CALL DRAW_RECTANGLE_INTERACTIVE
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

    ; Dibujar area  "GRUESOR"
    MOV WORD PTR [X1], 480  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 615  ; Columna final (X2)
    MOV WORD PTR [Y2], 470  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar GRUESOR PEQUENO
    MOV WORD PTR [X1], 505  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 450   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 515  ; Columna final (X2)
    MOV WORD PTR [Y2], 460  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    ; Dibujar GRUESOR MEDIANO
    MOV WORD PTR [X1], 525  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 440   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 545  ; Columna final (X2)
    MOV WORD PTR [Y2], 460  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    ; Dibujar GRUESOR GRANDE
    MOV WORD PTR [X1], 555  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 430   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 585  ; Columna final (X2)
    MOV WORD PTR [Y2], 460  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE
    MOV AL, 0FH
    CALL FILL_RECTANGLE

    

    MOV     DX,340
    MOV     CX,70
    MOV     SI,28
    MOV     AL, 0FH
    CALL    CIRCLE


    MOV     DX,340
    MOV     CX,415
    MOV     SI,28
    MOV     AL, 0FH
    CALL    CIRCLE


    CALL TEXT_GUARDAR
    CALL TEXT_CARGAR
    CALL TEXT_LIMPIAR
    CALL TEXT_IMAGEN
    CALL TEXT_CAMPO
    CALL TEXT_DIBUJO
    CALL TEXT_COLORES
    CALL TEXT_SKETCH
    CALL TEXT_GRUESOR

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
    JZ CHECK_MOUSE_BRIDGE  ; Si no se presiona tecla, revisar el mouse

    ; Leer la tecla presionada
    MOV AH, 00h
    INT 16h

    CMP AL, 'a'   ; Tecla A (izquierda)
    JE DRAW_LEFT_BRIDGE
    CMP AL, 'd'   ; Tecla D (derecha)
    JE DRAW_RIGHT_BRIDGE
    CMP AL, 'w'   ; Tecla W (arriba)
    JE DRAW_UP_BRIDGE
    CMP AL, 's'   ; Tecla S (abajo)
    JE DRAW_DOWN_BRIDGE
    JMP DRAW_LOOP

DRAW_LEFT_BRIDGE:
    JMP DRAW_LEFT

DRAW_RIGHT_BRIDGE:
    JMP DRAW_RIGHT

DRAW_UP_BRIDGE:
    JMP DRAW_UP

DRAW_DOWN_BRIDGE:
    JMP DRAW_DOWN

CHECK_MOUSE_BRIDGE:
    JMP CHECK_MOUSE

DRAW_LEFT:
    CMP [SELECTED_THICKNESS], 1
    JE LEFT_ONE
    CMP [SELECTED_THICKNESS], 2 
    JE LEFT_TWO
    CMP [SELECTED_THICKNESS], 3 
    JE LEFT_THREE
LEFT_ONE:
    CMP [DRAW_X], 36   ; Límite izquierdo del área de dibujo
    JLE DRAW_LOOP_BRIDGE_1
    DEC WORD PTR [DRAW_X]  ; Decrementar DRAW_X
    CALL DRAW_PIXEL
    JMP DRAW_LOOP
LEFT_TWO:
    CMP [DRAW_X], 36   ; Límite izquierdo del área de dibujo
    JLE DRAW_LOOP_BRIDGE_1
    DEC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    CMP [DRAW_X], 36   ; Límite izquierdo del área de dibujo
    JLE DRAW_LOOP_BRIDGE_1
    CMP [DRAW_Y], 304
    JGE DRAW_LOOP_BRIDGE_1 
    INC WORD PTR [DRAW_Y]
    CALL DRAW_PIXEL
    DEC WORD PTR [DRAW_Y]
    CMP [DRAW_X], 36   ; Límite izquierdo del área de dibujo
    JLE DRAW_LOOP_BRIDGE_1
    CMP [DRAW_Y], 76
    JLE DRAW_LOOP_BRIDGE_1
    DEC WORD PTR [DRAW_Y]
    CALL DRAW_PIXEL
    INC WORD PTR [DRAW_Y]
    JMP DRAW_LOOP

DRAW_LOOP_BRIDGE_1:
    JMP DRAW_LOOP

LEFT_THREE:
    CMP [DRAW_X], 36   ; Límite izquierdo del área de dibujo
    JLE DRAW_LOOP_1
    DEC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    CMP [DRAW_X], 36   ; Límite izquierdo del área de dibujo
    JLE DRAW_LOOP_1
    CMP [DRAW_Y], 304
    JGE DRAW_LOOP_1 
    INC WORD PTR [DRAW_Y]
    CALL DRAW_PIXEL
    DEC WORD PTR [DRAW_Y]
    CMP [DRAW_X], 36   ; Límite izquierdo del área de dibujo
    JLE DRAW_LOOP_1
    CMP [DRAW_Y], 76
    JLE DRAW_LOOP_1
    DEC WORD PTR [DRAW_Y]
    CALL DRAW_PIXEL
    INC WORD PTR [DRAW_Y]
    ADD WORD PTR [DRAW_Y], 2
    CALL DRAW_PIXEL
    SUB WORD PTR [DRAW_Y], 4
    CALL DRAW_PIXEL
    ADD WORD PTR [DRAW_Y], 2
    JMP DRAW_LOOP
    
DRAW_LOOP_1:
    JMP DRAW_LOOP
    
DRAW_RIGHT:
    CMP [SELECTED_THICKNESS], 1
    JE RIGHT_ONE
    CMP [SELECTED_THICKNESS], 2 
    JE RIGHT_TWO
    CMP [SELECTED_THICKNESS], 3 
    JE RIGHT_THREE
RIGHT_ONE:
    CMP [DRAW_X], 449  ; Límite derecho del área de dibujo
    JGE DRAW_LOOP_BRIDGE_2
    INC WORD PTR [DRAW_X]  ; Incrementar DRAW_X
    CALL DRAW_PIXEL
    JMP DRAW_LOOP
RIGHT_TWO:
    CMP [DRAW_X], 449  ; Límite derecho del área de dibujo
    JGE DRAW_LOOP_BRIDGE_2
    INC WORD PTR [DRAW_X]  ; Incrementar DRAW_X
    CALL DRAW_PIXEL
    CMP [DRAW_X], 449  ; Límite derecho del área de dibujo
    JGE DRAW_LOOP_BRIDGE_2
    CMP [DRAW_Y], 304
    JGE DRAW_LOOP_BRIDGE_2
    INC WORD PTR [DRAW_Y]
    CALL DRAW_PIXEL
    DEC WORD PTR [DRAW_Y]
    CMP [DRAW_X], 449  ; Límite derecho del área de dibujo
    JGE DRAW_LOOP_BRIDGE_2
    CMP [DRAW_Y], 76
    JLE DRAW_LOOP_BRIDGE_2
    DEC WORD PTR [DRAW_Y]
    CALL DRAW_PIXEL
    INC WORD PTR [DRAW_Y]
    JMP DRAW_LOOP

DRAW_LOOP_BRIDGE_2:
    JMP DRAW_LOOP

RIGHT_THREE:
    CMP [DRAW_X], 449  ; Límite derecho del área de dibujo
    JGE DRAW_LOOP_2
    INC WORD PTR [DRAW_X]  ; Incrementar DRAW_X
    CALL DRAW_PIXEL
    CMP [DRAW_X], 449  ; Límite derecho del área de dibujo
    JGE DRAW_LOOP_2
    CMP [DRAW_Y], 304
    JGE DRAW_LOOP_2
    INC WORD PTR [DRAW_Y]
    CALL DRAW_PIXEL
    DEC WORD PTR [DRAW_Y]
    CMP [DRAW_X], 449  ; Límite derecho del área de dibujo
    JGE DRAW_LOOP_2
    CMP [DRAW_Y], 76
    JLE DRAW_LOOP_2
    DEC WORD PTR [DRAW_Y]
    CALL DRAW_PIXEL
    INC WORD PTR [DRAW_Y]
    ADD WORD PTR [DRAW_Y], 2
    CALL DRAW_PIXEL
    SUB WORD PTR [DRAW_Y], 4
    CALL DRAW_PIXEL
    ADD WORD PTR [DRAW_Y], 2
    JMP DRAW_LOOP

DRAW_LOOP_2:
    JMP DRAW_LOOP

DRAW_UP:
    CMP [SELECTED_THICKNESS], 1
    JE UP_ONE
    CMP [SELECTED_THICKNESS], 2 
    JE UP_TWO
    CMP [SELECTED_THICKNESS], 3 
    JE UP_THREE
UP_ONE:
    CMP [DRAW_Y], 76   ; Límite superior del área de dibujo
    JLE DRAW_LOOP_BRIDGE_3
    DEC WORD PTR [DRAW_Y]  ; Decrementar DRAW_Y
    CALL DRAW_PIXEL   
    JMP DRAW_LOOP
UP_TWO:
    CMP [DRAW_Y], 76   ; Límite superior del área de dibujo
    JLE DRAW_LOOP_BRIDGE_3
    DEC WORD PTR [DRAW_Y]  ; Decrementar DRAW_Y
    CALL DRAW_PIXEL
    CMP [DRAW_Y], 76   ; Límite superior del área de dibujo
    JLE DRAW_LOOP_BRIDGE_3
    CMP [DRAW_X], 449   
    JGE DRAW_LOOP_BRIDGE_3
    INC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    DEC WORD PTR [DRAW_X]
    CMP [DRAW_Y], 76   ; Límite superior del área de dibujo
    JLE DRAW_LOOP_BRIDGE_3
    CMP [DRAW_X], 36   
    JLE DRAW_LOOP_BRIDGE_3
    DEC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    INC WORD PTR [DRAW_X]
    JMP DRAW_LOOP

DRAW_LOOP_BRIDGE_3:
    JMP DRAW_LOOP

UP_THREE:
    CMP [DRAW_Y], 76   ; Límite superior del área de dibujo
    JLE DRAW_LOOP_3
    DEC WORD PTR [DRAW_Y]  ; Decrementar DRAW_Y
    CALL DRAW_PIXEL
    CMP [DRAW_Y], 76   ; Límite superior del área de dibujo
    JLE DRAW_LOOP_3
    CMP [DRAW_X], 449   
    JGE DRAW_LOOP_3
    INC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    DEC WORD PTR [DRAW_X]
    CMP [DRAW_Y], 76   ; Límite superior del área de dibujo
    JLE DRAW_LOOP_3
    CMP [DRAW_X], 36   
    JLE DRAW_LOOP_3
    DEC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    INC WORD PTR [DRAW_X]
    ADD WORD PTR [DRAW_X], 2
    CALL DRAW_PIXEL
    SUB WORD PTR [DRAW_X], 4
    CALL DRAW_PIXEL
    ADD WORD PTR [DRAW_X], 2
    JMP DRAW_LOOP

DRAW_LOOP_3:
    JMP DRAW_LOOP

DRAW_DOWN:
    CMP [SELECTED_THICKNESS], 1
    JE DOWN_ONE
    CMP [SELECTED_THICKNESS], 2 
    JE DOWN_TWO
    CMP [SELECTED_THICKNESS], 3 
    JE DOWN_THREE
DOWN_ONE:
    CMP [DRAW_Y], 304  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_BRIDGE_4
    INC WORD PTR [DRAW_Y]  ; Incrementar DRAW_Y
    CALL DRAW_PIXEL
    JMP DRAW_LOOP
DOWN_TWO:
    CMP [DRAW_Y], 304  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_BRIDGE_4
    INC WORD PTR [DRAW_Y]  ; Incrementar DRAW_Y
    CALL DRAW_PIXEL
    CMP [DRAW_Y], 304  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_BRIDGE_4
    CMP [DRAW_X], 449  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_BRIDGE_4
    INC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    DEC WORD PTR [DRAW_X]
    CMP [DRAW_Y], 304  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_BRIDGE_4
    CMP [DRAW_X], 36  
    JLE DRAW_LOOP_BRIDGE_4
    DEC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    INC WORD PTR [DRAW_X]
    JMP DRAW_LOOP

DRAW_LOOP_BRIDGE_4:
    JMP DRAW_LOOP 

DOWN_THREE:
    CMP [DRAW_Y], 304  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_4
    INC WORD PTR [DRAW_Y]  ; Incrementar DRAW_Y
    CALL DRAW_PIXEL
    CMP [DRAW_Y], 304  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_4
    CMP [DRAW_X], 449  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_4
    INC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    DEC WORD PTR [DRAW_X]
    CMP [DRAW_Y], 304  ; Límite inferior del área de dibujo
    JGE DRAW_LOOP_4
    CMP [DRAW_X], 36  
    JLE DRAW_LOOP_4
    DEC WORD PTR [DRAW_X]
    CALL DRAW_PIXEL
    INC WORD PTR [DRAW_X]
    ADD WORD PTR [DRAW_X], 2
    CALL DRAW_PIXEL
    SUB WORD PTR [DRAW_X], 4
    CALL DRAW_PIXEL
    ADD WORD PTR [DRAW_X], 2
    JMP DRAW_LOOP

DRAW_LOOP_4:
    JMP DRAW_LOOP
    
CHECK_MOUSE:
    ; Verificar si se presionó el botón izquierdo del mouse
    CALL MOUSE_GET_POSITION
    CMP [BUTTONS], 1
    JNE DRAW_LOOP_5  ; Si no se presionó el botón izquierdo, continuar dibujando

    ; Verificar si el clic está dentro del área de dibujo
    CMP [X_POS], 36
    JL EXIT_DRAWING    ; Si está fuera del área de dibujo (izquierda), verificar rectángulos
    CMP [X_POS], 449
    JG EXIT_DRAWING    ; Si está fuera del área de dibujo (derecha), verificar rectángulos
    CMP [Y_POS], 76
    JL EXIT_DRAWING    ; Si está fuera del área de dibujo (arriba), verificar rectángulos
    CMP [Y_POS], 304
    JG EXIT_DRAWING    ; Si está fuera del área de dibujo (abajo), verificar rectángulos

    MOV AX, [X_POS]   ; Cargar el valor de X_POS en AX
    MOV [DRAW_X], AX  ; Mover el valor de AX a DRAW_X

    MOV AX, [Y_POS]   ; Cargar el valor de Y_POS en AX
    MOV [DRAW_Y], AX  ; Mover el valor de AX a DRAW_Y
    JMP DRAW_LOOP  ; Volver al ciclo de dibujo

DRAW_LOOP_5:
    JMP DRAW_LOOP

EXIT_DRAWING:
    RET
DRAWING_LOOP ENDP

DRAW_PIXEL PROC
    ; Dibujar el píxel con el color seleccionado en SELECTED_COLOR
    MOV AL, [SELECTED_COLOR] 
    MOV CX, [DRAW_X]
    MOV DX, [DRAW_Y]
    CALL PRINT_PIXEL
    RET
DRAW_PIXEL ENDP

CLEAR_DRAWING_AREA PROC
    MOV WORD PTR [X1], 35   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 75 ; Fila inicial (Y1)
    MOV WORD PTR [X2], 450  ; Columna final (X2)
    MOV WORD PTR [Y2], 305  ; Fila final (Y2)
    MOV AL, 0FH
    CALL FILL_RECTANGLE
    MOV WORD PTR [DRAW_X], 242
    MOV WORD PTR [DRAW_Y], 190
    RET
CLEAR_DRAWING_AREA ENDP

SET_LINE_POINTS MACRO X1,Y1,X2,Y2
    LEA BX, LINE_POINTS
    MOV WORD PTR [BX], X1
    MOV WORD PTR [BX+2], Y1
    MOV WORD PTR [BX+4], X2
    MOV WORD PTR [BX+6], Y2
ENDM

WRITE_CHARACTER PROC
    ;IDK
WRITE_LOOP:
    MOV AH, 01h
    INT 16h
    JZ CHECK_CLICK

    ; Leer la tecla presionada
    MOV AH, 00h
    INT 16h              ; Esperar la entrada del usuario
    
    ; Verificar si es Backspace
    CMP AL, 8
    JE HANDLE_BACKSPACE  ; Llamar a la rutina de retroceso

   ; Guardar el carácter en el buffer de nombre del archivo
    MOV SI, FILENAME_INDEX
    ADD SI, OFFSET FILENAME_BUFFER
    MOV [SI], AL  ; Guardar el carácter ingresado

    ; Posicionar el cursor en la pantalla usando INT 10h, Función 02h
    MOV AH, 02h          ; Función para mover el cursor
    MOV BH, 0            ; Página 0
    MOV DH, CURSOR_ROW   ; Fila actual
    MOV DL, CURSOR_COL   ; Columna actual
    INT 10h              ; Llamar a la BIOS para mover el cursor

    ; Imprimir el carácter en la pantalla usando BIOS
    MOV AH, 0Eh          ; Función para imprimir en modo texto
    MOV BH, 0            ; Página 0
    MOV BL, 0EH            ; Color AMARILLO
    INT 10h              ; Llamada a la BIOS para imprimir el carácter

    ; Incrementar el índice y la columna del cursor
    INC FILENAME_INDEX
    INC CURSOR_COL

    ; Verificar si alcanzamos el límite de la línea
    CMP CURSOR_COL, MAX_COLUMNS
    JGE DONE_WRITING  ; Si se alcanza el límite, dejar de escribir

    JMP WRITE_LOOP

HANDLE_BACKSPACE:
    ; Verificar si hay texto que borrar
    CMP FILENAME_INDEX, 0
    JLE NO_BACKSPACE

    ; Retroceder el índice y la columna del cursor
    DEC FILENAME_INDEX
    DEC CURSOR_COL

    ; Posicionar el cursor en la pantalla usando INT 10h, Función 02h
    MOV AH, 02h          ; Función para mover el cursor
    MOV BH, 0            ; Página 0
    MOV DH, CURSOR_ROW   ; Fila actual
    MOV DL, CURSOR_COL   ; Columna actual
    INT 10h              ; Llamar a la BIOS para mover el cursor

    ; Sobrescribir el carácter con un espacio en blanco
    MOV AH, 0Eh
    MOV AL, ' '          ; Imprimir espacio en blanco
    MOV BH, 0
    MOV BL, 0            ; Color negro
    INT 10h              ; Imprimir espacio

    JMP WRITE_LOOP

NO_BACKSPACE:
    JMP WRITE_LOOP

CHECK_CLICK:
    CALL MOUSE_GET_POSITION
    CMP [BUTTONS], 1
    JE DONE_WRITING
    JMP WRITE_LOOP

DONE_WRITING:
    RET
WRITE_CHARACTER ENDP

RESET_CAMPO_TXT PROC
    ; Dibujar cuadro de texto "Campo de texto"
    MOV WORD PTR [X1], 280  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 420  ; Fila final (Y2)
    MOV AL, 00H
    CALL FILL_RECTANGLE
    RET

RESET_CAMPO_TXT ENDP 

SAVE_SKETCH PROC
    ; Preparar el nombre del archivo con ".txt"
    MOV SI, FILENAME_INDEX
    ADD SI, OFFSET FILENAME_BUFFER
    MOV BYTE PTR [SI], '.'      ; Agregar '.txt' al nombre
    MOV BYTE PTR [SI+1], 't'
    MOV BYTE PTR [SI+2], 'x'
    MOV BYTE PTR [SI+3], 't'
    ADD FILENAME_INDEX, 4

    ; Crear el archivo
    MOV AH, 3Ch              ; Crear archivo (Función 3Ch)
    MOV CX, 0                ; Atributo: Archivo normal
    LEA DX, FILENAME_BUFFER  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR            ; Saltar si hay error

    MOV BX, AX               ; Guardar el handle del archivo

    ; Inicializar coordenadas para recorrer el área de dibujo
    MOV DX, DRAW_Y_START     ; Y inicial (fila)

ROW_LOOP:
    MOV CX, DRAW_X_START     ; X inicial (columna)

COLUMN_LOOP:
    ; Leer el color del píxel en (CX, DX)
    MOV AH, 0Dh              ; Función de BIOS para leer píxel
    MOV BH, 0                ; Página 0
    INT 10h                  ; Llamada a BIOS para leer el píxel

    ; Convertir el color a ASCII
   
    ; Convertir el color a ASCII y guardarlo en BYTE_BUFFER
    CALL COLOR_TO_ASCII
    MOV BYTE_BUFFER, AL      ; Guardar el resultado en el buffer

    ; Escribir el valor en el archivo
    CALL WRITE_BYTE

    ; Avanzar a la siguiente columna (X)
    INC CX
    CMP CX, DRAW_X2       ; Verificar si llegamos al final de la fila
    JL COLUMN_LOOP

    ; Escribir '@' para indicar fin de la fila
    MOV AL, '@'
    MOV BYTE_BUFFER, AL
    CALL WRITE_BYTE

    ; Agregar salto de línea después de '@'
    MOV AL, 0Dh   ; Carácter de retorno de carro
    MOV BYTE_BUFFER, AL
    CALL WRITE_BYTE

    MOV AL, 0Ah   ; Carácter de nueva línea
    MOV BYTE_BUFFER, AL
    CALL WRITE_BYTE

    ; Avanzar a la siguiente fila (Y)
    INC DX
    CMP DX, DRAW_Y2       ; Verificar si llegamos al final del área de dibujo
    JL ROW_LOOP

    ; Escribir '%' para indicar fin del archivo
    MOV AL, '%'
    MOV BYTE_BUFFER, AL
    CALL WRITE_BYTE

    ; Cerrar el archivo
    MOV AH, 3Eh              ; Cerrar archivo (Función 3Eh)
    MOV BX, BX               ; Handle del archivo
    INT 21h

    ; Limpiar el campo de texto para permitir escribir un nuevo nombre

    
    CALL TEXT_GUARDADO
    CALL RESET_NOMBRE
    CALL DISPLAY_FILENAME
    CALL RESET_FILENAME_BUFFER
    MOV AX, 35            ; Esperar 2 segundos
    CALL DELAY_SECONDS

    RET
FILE_ERROR:
    RET
SAVE_SKETCH ENDP

WRITE_BYTE PROC
    ; Guardar coordenadas para no perderlas
    PUSH CX
    PUSH DX

    ; Escribir un byte en el archivo
    MOV AH, 40h              ; Función para escribir en archivo
    MOV BX, BX               ; Handle del archivo
    MOV CX, 1                ; Escribir 1 byte
    LEA DX, BYTE_BUFFER      ; Dirección del byte
    INT 21h

    ; Restaurar coordenadas
    POP DX
    POP CX

    RET
WRITE_BYTE ENDP

COLOR_TO_ASCII PROC
    ; AL contiene el valor del color (0-15)
    CMP AL, 10
    JL DIGIT_COLOR           ; Si es menor que 10, es un dígito

    ; Convertir valores de 10-15 en letras 'A'-'F'
    ADD AL, 55               ; 'A' = 65, entonces 10 + 55 = 65 ('A')
    RET

DIGIT_COLOR:
    ADD AL, 48               ; '0' = 48, entonces 0-9 se convierten en '0'-'9'
    RET
COLOR_TO_ASCII ENDP

RESET_FILENAME_BUFFER PROC
    ; Limpiar el FILENAME_BUFFER y reiniciar FILENAME_INDEX
    MOV CX, 100               ; Tamaño del buffer
    MOV SI, OFFSET FILENAME_BUFFER

CLEAR_BUFFER_LOOP:
    MOV BYTE PTR [SI], 0      ; Llenar con ceros
    INC SI
    LOOP CLEAR_BUFFER_LOOP

    ; Reiniciar el índice del buffer
    MOV FILENAME_INDEX, 0
    MOV CURSOR_ROW, TXT_ROW_START ; Inicializar la fila del cursor
    MOV CURSOR_COL, TXT_COLUMN_START ; Inicializar la columna del cursor

    RET
RESET_FILENAME_BUFFER ENDP

LOAD_SKETCH PROC
    ; Preparar el nombre del archivo con ".txt"
    MOV SI, FILENAME_INDEX
    ADD SI, OFFSET FILENAME_BUFFER
    MOV BYTE PTR [SI], '.'      ; Agregar '.txt'
    MOV BYTE PTR [SI+1], 't'
    MOV BYTE PTR [SI+2], 'x'
    MOV BYTE PTR [SI+3], 't'
    ADD FILENAME_INDEX, 4

    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, FILENAME_BUFFER  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_LOAD       ; Saltar si hay error

    MOV BX, AX               ; Guardar el handle del archivo

    ; Inicializar coordenadas para el área de dibujo
    MOV DX, DRAW_Y_START     ; Y inicial (fila)


    MOV CX, DRAW_X_START     ; X inicial (columna)

COLUMN_LOOP_LOAD:
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL,'F'
    JE NEXT_COLUMN

    CMP AL, '%'              ; Verificar si es el fin del archivo
    JE DONE_LOADING

    CMP AL, '@'              ; Verificar si es el fin de la fila
    JE NEXT_ROW
    
    CMP AL, 0Dh   ; Retorno de carro (CR)
    JE COLUMN_LOOP_LOAD
    CMP AL, 0Ah   ; Nueva línea (LF)
    JE COLUMN_LOOP_LOAD

DRAW_COLOR:
    ; Convertir el carácter a su valor hexadecimal correspondiente
    CALL ASCII_TO_COLOR
    
    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch              ; Función para dibujar píxel
    MOV AL, AL
    MOV BH, 0                ; Página 0
    MOV CX, CX               ; Columna
    MOV DX, DX               ; Fila
    INT 10h                  ; Dibujar el píxel


NEXT_COLUMN:
    ; Avanzar a la siguiente columna
    INC CX
    CMP CX, DRAW_X_END
    JL COLUMN_LOOP_LOAD

NEXT_ROW:
    MOV CX, DRAW_X_START
    INC DX
    JMP COLUMN_LOOP_LOAD      ; Continuar si no es el final


DONE_LOADING:
    ; Cerrar el archivo
    MOV AH, 3Eh              ; Función para cerrar archivo
    MOV BX, BX               ; Handle del archivo
    INT 21h
    CALL TEXT_CARGADO
    MOV AX, 35            ; Esperar 2 segundos
    CALL DELAY_SECONDS
    CALL RESET_NOMBRE
    CALL DISPLAY_FILENAME
    RET

FILE_ERROR_LOAD:
    ; Manejo de errores (archivo no encontrado)
    CALL TEXT_ERROR
    MOV AX, 35            ; Esperar 2 segundos
    CALL DELAY_SECONDS
    RET
LOAD_SKETCH ENDP

READ_BYTE PROC
    PUSH CX
    PUSH DX
    MOV AH, 3Fh              ; Función para leer archivo
    MOV BX, BX               ; Handle del archivo
    LEA DX, BYTE_BUFFER      ; Buffer temporal
    MOV CX, 1                ; Leer un byte
    INT 21h
    MOV AL, BYTE_BUFFER      ; Almacenar byte en AL
    POP DX
    POP CX
    RET
READ_BYTE ENDP

ASCII_TO_COLOR PROC
    PUSH CX
    PUSH DX
    ; Convertir carácter ASCII en AL a su valor de color (0-15)
    CMP AL, '0'
    JL INVALID_COLOR         ; Si AL < '0', es un carácter inválido

    CMP AL, '9'
    JLE DIGIT_COLOR_CON          ; Si AL está entre '0' y '9', convertir directamente

    CMP AL, 'A'
    JL INVALID_COLOR         ; Si AL < 'A', no es un carácter válido

    CMP AL, 'F'
    JG INVALID_COLOR         ; Si AL > 'F', es inválido

    ; Convertir letras A-F a valores 10-15
    SUB AL, 'A'              ; Ajustar para que 'A' = 0
    ADD AL, 10               ; Luego ajustar para que 'A' = 10
    JMP RETURN_COLOR         ; Saltar a devolver el valor

DIGIT_COLOR_CON:
    ; Convertir dígitos '0'-'9' a sus valores numéricos
    SUB AL, '0'
    JMP RETURN_COLOR         ; Saltar a devolver el valor

INVALID_COLOR:
    ; Manejo de caracteres inválidos (asignar un color por defecto, por ejemplo 0)
    MOV AL, 15                ; Color por defecto (negro o transparente)

RETURN_COLOR:
    POP DX
    POP CX
    RET
ASCII_TO_COLOR ENDP

DISPLAY_FILENAME PROC
    
    ; Inicializar el puntero al buffer del nombre del archivo
    LEA SI, FILENAME_BUFFER

    ; Posicionar el cursor en el área del rectángulo "Dibujo sin nombre"
    MOV CURSOR_ROW, 2      ; Fila donde comienza el texto (ajustar según diseño)
    MOV CURSOR_COL, 16     ; Columna donde empieza (ajustar según diseño)

DISPLAY_CHAR_LOOP:
    ; Cargar el siguiente carácter del buffer
    LODSB                  ; Cargar el byte de [SI] en AL
    CMP AL, 0              ; Verificar si es el final del nombre (byte nulo)
    JE DONE_DISPLAY        ; Si es nulo, terminamos

    ; Posicionar el cursor en pantalla
    MOV AH, 02h            ; Función para mover cursor
    MOV BH, 0              ; Página 0
    MOV DH, CURSOR_ROW     ; Fila actual
    MOV DL, CURSOR_COL     ; Columna actual
    INT 10h                ; Llamar a la BIOS para mover el cursor

    ; Imprimir el carácter en la pantalla con un color específico
    MOV AH, 0Eh            ; Función para imprimir en modo texto
    MOV BL, 0Eh            ; Atributo de color (amarillo)
    INT 10h                ; Llamar a la BIOS para imprimir el carácter

    ; Avanzar a la siguiente columna
    INC CURSOR_COL
    CMP CURSOR_COL, 40     ; Limitar la longitud del nombre en pantalla
    JGE DONE_DISPLAY       ; Si excede, terminamos

    JMP DISPLAY_CHAR_LOOP  ; Repetir para el siguiente carácter

DONE_DISPLAY:
    RET
DISPLAY_FILENAME ENDP


RESET_NOMBRE PROC
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el primer botón
    MOV WORD PTR [Y1], 25   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 350  ; Columna final (X2)
    MOV WORD PTR [Y2], 50   ; Fila final (Y2)
    MOV AL, 00H
    CALL FILL_RECTANGLE
    RET
RESET_NOMBRE ENDP

;---------------------------------------------------------
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

    MOV WORD PTR [DRAW_X], 242
    MOV WORD PTR [DRAW_Y], 190
    

    ; Bucle infinito para obtener la posición del mouse y el estado de los botones
MAIN_LOOP:
    CALL MOUSE_GET_POSITION

    ; Verificar si se presionó el botón izquierdo del mouse
    CMP [BUTTONS], 1
    JNE MAIN_LOOP  ; Si no se presionó el botón izquierdo, repetir bucle

    SET_LINE_POINTS 500, 80, 530, 110
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_2
    MOV DI, 0
    JMP DRAW_PROCESS
               
    CHECK_RECT_2:
    SET_LINE_POINTS 500, 140, 530, 170
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_3
    MOV DI, 1
    JMP DRAW_PROCESS

    CHECK_RECT_3:
    SET_LINE_POINTS 500, 200, 530, 230
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_4
    MOV DI, 2
    JMP DRAW_PROCESS

    CHECK_RECT_4:
    SET_LINE_POINTS 500, 260, 530, 290
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_5
    MOV DI, 3
    JMP DRAW_PROCESS

    CHECK_RECT_5:
    SET_LINE_POINTS 500, 320, 530, 350
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_6
    MOV DI, 4
    JMP DRAW_PROCESS

    CHECK_RECT_6:
    SET_LINE_POINTS 565, 80, 595, 110
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_7
    MOV DI, 5
    JMP DRAW_PROCESS

    CHECK_RECT_7:
    SET_LINE_POINTS 565, 140, 595, 170
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_8
    MOV DI, 6
    JMP DRAW_PROCESS

    CHECK_RECT_8:
    SET_LINE_POINTS 565, 200, 595, 230
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_9
    MOV DI, 7
    JMP DRAW_PROCESS

    CHECK_RECT_9:
    SET_LINE_POINTS 565, 260, 595, 290
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_10
    MOV DI, 8
    JMP DRAW_PROCESS 

    CHECK_RECT_10:
    SET_LINE_POINTS 565, 320, 595, 350
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_11
    MOV DI, 9
    JMP DRAW_PROCESS 

    CHECK_RECT_11:
    SET_LINE_POINTS 505, 450, 515, 460
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_12
    JMP THICKNESS_1

    CHECK_RECT_12:
    SET_LINE_POINTS 525, 440, 545, 460
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_13
    JMP THICKNESS_2

    CHECK_RECT_13:
    SET_LINE_POINTS 555, 430, 585, 460
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_14
    JMP THICKNESS_3 

    CHECK_RECT_14:
    SET_LINE_POINTS 360, 25, 460, 50
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_15
    JMP CLEAN_DRAWING_AREA 

    CHECK_RECT_15:
    SET_LINE_POINTS 185, 390, 460, 420
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_16
    JMP TXT_INPUT_MODE

    CHECK_RECT_16:
    SET_LINE_POINTS 25, 390, 164, 425
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_17
    JMP SAVE_DRAWING

    CHECK_RECT_17:
    SET_LINE_POINTS 25, 435, 157, 470
    CALL IS_CLICK_INSIDE_RECTANGLE
    JE LOAD_DRAWING
    
    CALL DRAWING_LOOP

DRAW_PROCESS:
    MOV AL, [RECTANGLE_COLORS + DI]   ; Cargar el color de la tabla en AL
    MOV [SELECTED_COLOR], AL
    CALL DRAWING_LOOP
    JMP MAIN_LOOP           ; Continuar verificando clics

LOAD_DRAWING:
    CALL LOAD_SKETCH
    CALL RESET_FILENAME_BUFFER
    CALL RESET_CAMPO_TXT
    JMP MAIN_LOOP

SAVE_DRAWING:
    CALL SAVE_SKETCH
    CALL RESET_CAMPO_TXT
    JMP MAIN_LOOP

TXT_INPUT_MODE:
    CALL TEXT_ASTERISCO
    CALL WRITE_CHARACTER
    JMP MAIN_LOOP

CLEAN_DRAWING_AREA:
    CALL CLEAR_DRAWING_AREA   ; Llamar a la función de limpiar el área de dibujo
    CALL RESET_NOMBRE
    CALL TEXT_DIBUJO
    JMP MAIN_LOOP             ; Volver al bucle principal

THICKNESS_1:
    MOV [SELECTED_THICKNESS], 1
    CALL DRAWING_LOOP
    JMP MAIN_LOOP           ; Continuar verificando clics

THICKNESS_2:
    MOV [SELECTED_THICKNESS], 2
    CALL DRAWING_LOOP
    JMP MAIN_LOOP           ; Continuar verificando clics

THICKNESS_3:
    MOV [SELECTED_THICKNESS], 3
    CALL DRAWING_LOOP
    JMP MAIN_LOOP           ; Continuar verificando clics

MAIN ENDP

END MAIN

