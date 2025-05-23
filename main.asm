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
    txtCampo DB 'Texto aqui:$'
    txtDibujo DB 'Dibujo sin nombre$'
    txtColores DB 'Colores$'
    txtSketch DB 'Etch A Sketch$'
    txtGrosor DB 'Grosor$'
    txtAsterisco DB '*$'
    txtError DB 'Bosquejo no existe$'
    txtGuardado DB 'Bosquejo guardado$'
    txtCargado DB 'Bosquejo cargado$'
    txtPicError DB 'Imagen no existe$'
    txtPic DB 'Imagen cargada$'
    txtInvalido DB 'Debe ingresar texto$'

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

    TRIANGULO DB 'TRIAN.txt', 0
    CIRCULO DB 'CIRCU.txt', 0
    DIAMANTE DB 'DIAMAN.txt', 0
    FLECHA DB 'FLECHA.txt', 0
    CORAZON DB 'CORAZON.txt', 0
    ESTRELLA DB 'ESTRE.txt', 0
    FONDO DB 'FONDO.txt', 0
    SKETCH DB 'SKETCH.txt', 0
    RELLENO DB 'RELLENO.txt', 0
    PORTADA DB 'PORTADA.txt', 0

    TRI DB 'TRI.txt', 0
    CIR DB 'CIR.txt', 0
    DIA DB 'DIA.txt', 0
    FLE DB 'FLE.txt', 0
    COR DB 'COR.txt', 0
    EST DB 'EST.txt', 0

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
    CALL DRAW_FONDO

    RET
CLEAR_SCREEN ENDP

DRAW_RECTANGLE PROC
    ; Dibujar la línea superior (de X1 a X2 en Y1)
           
    MOV DX, [Y1]        ; Y1 (Fila inicial)
    MOV CX, [X1]        ; X1 (Columna inicial)
TOP_LINE:
    CALL PRINT_PIXEL    ; Pintar píxel
    INC CX              ; Avanza en X (columna)
    CMP CX, [X2]        ; ¿Llegamos a X2?
    JLE TOP_LINE        ; Si no, continuar

    ; Dibujar la línea inferior (de X1 a X2 en Y2)
             
    MOV DX, [Y2]        ; Y2 (Fila final)
    MOV CX, [X1]        ; X1
BOTTOM_LINE:
    CALL PRINT_PIXEL
    INC CX
    CMP CX, [X2]
    JLE BOTTOM_LINE

    ; Dibujar la línea izquierda (de Y1 a Y2 en X1)
    MOV CX, [X1]        ; X1
    MOV DX, [Y1]        ; Y1
LEFT_LINE:
    CALL PRINT_PIXEL
    INC DX              ; Avanza en Y (fila)
    CMP DX, [Y2]
    JLE LEFT_LINE

    ; Dibujar la línea derecha (de Y1 a Y2 en X2)
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
    MOV AL, 15       ; Color rojo
    MOV DX, [Y1]        ; Y1 (Fila inicial)
    MOV CX, [X1]        ; X1 (Columna inicial)
TOP_LINE_INTERACTIVE:
    CALL PRINT_PIXEL    ; Pintar píxel
    INC CX              ; Avanza en X (columna)
    CMP CX, [X2]        ; ¿Llegamos a X2?
    JLE TOP_LINE_INTERACTIVE       ; Si no, continuar

    ; Dibujar la línea inferior (de X1 a X2 en Y2)
    MOV AL, 15         ; Color rojo
    MOV DX, [Y2]        ; Y2 (Fila final)
    MOV CX, [X1]        ; X1
BOTTOM_LINE_INTERACTIVE:
    CALL PRINT_PIXEL
    INC CX
    CMP CX, [X2]
    JLE BOTTOM_LINE_INTERACTIVE

    ; Dibujar la línea izquierda (de Y1 a Y2 en X1)
    MOV AL, 15         ; Color rojo
    MOV CX, [X1]        ; X1
    MOV DX, [Y1]        ; Y1
LEFT_LINE_INTERACTIVE:
    CALL PRINT_PIXEL
    INC DX              ; Avanza en Y (fila)
    CMP DX, [Y2]
    JLE LEFT_LINE_INTERACTIVE

    ; Dibujar la línea derecha (de Y1 a Y2 en X2)
    MOV AL, 15         ; Color rojo
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
    MOV SI, OFFSET txtGrosor
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

TEXT_ERROR_PIC PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtPicError
    TEXT_POSITION 25,36
PRINT_TXT_ERROR_PIC:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_ERROR_PIC
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 04H        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_ERROR_PIC

END_PRINT_TXT_ERROR_PIC:
    RET
TEXT_ERROR_PIC ENDP

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

TEXT_PIC PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtPic
    TEXT_POSITION 25,36
PRINT_TXT_PIC:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_PIC
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 02H        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_PIC

END_PRINT_TXT_PIC:
    RET
TEXT_PIC ENDP

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

TEXT_INVALIDO PROC
    ; Escribe en pantalla texto del botón de guardar
    CLD
    MOV SI, OFFSET txtInvalido
    TEXT_POSITION 25,36
PRINT_TXT_INVALIDO:
    LODSB              ; Cargar el siguiente byte del mensaje en AL
    CMP AL, '$'
    JE END_PRINT_TXT_INVALIDO
    MOV AH, 0EH
    MOV BH, 00H
    MOV BL, 04H        ; Atributo del carácter (0Fh es blanco sobre negro)
    INT 10H
    JMP PRINT_TXT_INVALIDO

END_PRINT_TXT_INVALIDO:
    RET
TEXT_INVALIDO ENDP

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
    MOV AL, 12
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar botón "Limpiar"
    MOV WORD PTR [X1], 360  ; Columna inicial (X1) para el segundo botón
    MOV WORD PTR [Y1], 25   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 50   ; Fila final (Y2)
    MOV AL, 12
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; DIBUJAR SKETCH
    MOV WORD PTR [X1], 24   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 64   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 375  ; Fila final (Y2)
    CALL DRAW_RECTANGLE
    CALL DRAW_SKETCH
    
    ; Dibujar area de dibujo
    MOV WORD PTR [X1], 35   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 75   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 450  ; Columna final (X2)
    MOV WORD PTR [Y2], 305  ; Fila final (Y2)
    MOV AL, 0
    CALL DRAW_RECTANGLE
    MOV AL, 0FH
    CALL FILL_RECTANGLE
    CALL DRAW_PORTADA

    ; DIBUJAR RECTANGULO DE FIGURAS
    MOV WORD PTR [X1], 110   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 315  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 375  ; Columna final (X2)
    MOV WORD PTR [Y2], 365  ; Fila final (Y2)
    MOV AL, 4
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE
    
    ; DIBUJAR CUADRADO DE TRIANGULO 
    MOV WORD PTR [X1], 125   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 325  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 155  ; Columna final (X2)
    MOV WORD PTR [Y2], 355  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE


    ; DIBUJAR CUADRADO DE CIRCULO 
    MOV WORD PTR [X1], 165   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 325  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 195  ; Columna final (X2)
    MOV WORD PTR [Y2], 355  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE

    ; DIBUJAR CUADRADO DE DIAMANTE 
    MOV WORD PTR [X1], 205   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 325  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 235  ; Columna final (X2)
    MOV WORD PTR [Y2], 355  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE

    ; DIBUJAR CUADRADO DE FLECHA 
    MOV WORD PTR [X1], 250   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 325  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 280  ; Columna final (X2)
    MOV WORD PTR [Y2], 355  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE

    ; DIBUJAR CUADRADO DE CORAZON 
    MOV WORD PTR [X1], 290   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 325  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 320  ; Columna final (X2)
    MOV WORD PTR [Y2], 355  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE

    ; DIBUJAR CUADRADO DE ESTRELLA 
    MOV WORD PTR [X1], 330   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 325  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 360  ; Columna final (X2)
    MOV WORD PTR [Y2], 355  ; Fila final (Y2)
    CALL DRAW_RECTANGLE_INTERACTIVE

    CALL DRAW_TRIANGULO
    CALL DRAW_CIRCULO
    CALL DRAW_DIAMANTE
    CALL DRAW_FLECHA
    CALL DRAW_CORAZON
    CALL DRAW_ESTRELLA

    ; Dibujar boton "guardar bosquejo"
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 164  ; Columna final (X2)
    MOV WORD PTR [Y2], 425  ; Fila final (Y2)
    MOV AL, 12
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar boton "cargar bosquejo"
    MOV WORD PTR [X1], 25   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 435  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 157  ; Columna final (X2)
    MOV WORD PTR [Y2], 470  ; Fila final (Y2)
    MOV AL, 12
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar cuadro de texto "Campo de texto"
    MOV WORD PTR [X1], 185  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 420  ; Fila final (Y2)
    MOV AL, 12
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar boton "Insertar imagen"
    MOV WORD PTR [X1], 255  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 435  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 390  ; Columna final (X2)
    MOV WORD PTR [Y2], 470  ; Fila final (Y2)
    MOV AL, 12
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE

    ; Dibujar boton "RELLENO"
    MOV WORD PTR [X1], 429  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 434  ; Fila inicial (Y1)
    MOV WORD PTR [X2], 460  ; Columna final (X2)
    MOV WORD PTR [Y2], 465  ; Fila final (Y2)
    MOV AL, 12
    CALL DRAW_RECTANGLE
    MOV AL, 00H
    CALL FILL_RECTANGLE
    CALL DRAW_RELLENO

    ; Dibujar area  "Colores"
    MOV WORD PTR [X1], 480  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 25   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 615  ; Columna final (X2)
    MOV WORD PTR [Y2], 375  ; Fila final (Y2)
    MOV AL, 12
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

    ; Dibujar area  "GRUESOR"
    MOV WORD PTR [X1], 480  ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 390   ; Fila inicial (Y1)
    MOV WORD PTR [X2], 615  ; Columna final (X2)
    MOV WORD PTR [Y2], 470  ; Fila final (Y2)
    MOV AL, 12
    CALL DRAW_RECTANGLE
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

    CALL TEXT_GUARDAR
    CALL TEXT_CARGAR
    CALL TEXT_LIMPIAR
    CALL TEXT_IMAGEN
    CALL TEXT_CAMPO
    CALL TEXT_DIBUJO
    CALL TEXT_COLORES
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
    MOV SI, FILENAME_INDEX
    CMP SI, 0              ; Si el índice es 0, no se escribió nada
    JE NO_FILENAME
    JMP SAVE_SKETCH_PROCESS

NO_FILENAME:
    CALL TEXT_INVALIDO
    MOV AX, 35            ; Esperar 2 segundos
    CALL DELAY_SECONDS
    RET

SAVE_SKETCH_PROCESS:
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
    CMP CX, DRAW_X_END       ; Verificar si llegamos al final de la fila
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
    CMP DX, DRAW_Y_END       ; Verificar si llegamos al final del área de dibujo
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
    MOV SI, FILENAME_INDEX
    CMP SI, 0              ; Si el índice es 0, no se escribió nada
    JE NO_FILENAME_LOAD
    JMP LOAD_SKETCH_PROCESS

NO_FILENAME_LOAD:
    CALL TEXT_INVALIDO
    MOV AX, 35            ; Esperar 2 segundos
    CALL DELAY_SECONDS
    RET

LOAD_SKETCH_PROCESS:
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

LOAD_IMAGE PROC
    MOV SI, FILENAME_INDEX
    CMP SI, 0              ; Si el índice es 0, no se escribió nada
    JE NO_FILENAME_IMAGE
    JMP LOAD_IMAGE_PROCESS

NO_FILENAME_IMAGE:
    CALL TEXT_INVALIDO
    MOV AX, 35            ; Esperar 2 segundos
    CALL DELAY_SECONDS
    RET

LOAD_IMAGE_PROCESS:
    ; Preparar el nombre del archivo con ".txt"
    MOV SI, FILENAME_INDEX
    ADD SI, OFFSET FILENAME_BUFFER
    MOV BYTE PTR [SI], '.'
    MOV BYTE PTR [SI+1], 't'
    MOV BYTE PTR [SI+2], 'x'
    MOV BYTE PTR [SI+3], 't'
    ADD FILENAME_INDEX, 4

    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, FILENAME_BUFFER  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_LOAD_PIC   ; Saltar si hay error

    MOV BX, AX               ; Guardar el handler del archivo en BX

WAIT_FOR_CLICK:
    ; Preservar el handler antes de llamar al mouse
    PUSH BX                  
    CALL MOUSE_GET_POSITION  ; Obtener posición del mouse
    CMP [BUTTONS], 1         ; Verificar si el botón izquierdo está presionado
    JNE RESTORE_HANDLER      ; Si no, restaurar el handler y seguir esperando

    ; Definir las coordenadas del área de dibujo (36,76) a (449,304)
    SET_LINE_POINTS 36, 76, 449, 304
    CALL IS_CLICK_INSIDE_RECTANGLE  ; Verificar si el clic está dentro del área
    JNE RESTORE_HANDLER             ; Si no está dentro, restaurar handler y seguir esperando

    ; Guardar las coordenadas del clic en CX y DX para iniciar el dibujo
    
    MOV CX, [X_POS]  ; Usar X_POS como columna inicial
    MOV DX, [Y_POS]  ; Usar Y_POS como fila inicial

    CALL MOUSE_HIDE

    ; Restaurar el handler del archivo
RESTORE_HANDLER:
    POP BX                  ; Restaurar BX con el handler del archivo
    JNE WAIT_FOR_CLICK      ; Si no se ha hecho clic válido, repetir

COLUMN_LOOP_LOAD_PIC:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, 'F'             ; Saltar a la siguiente columna si es 'F'
    JE NEXT_COLUMN_PIC

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_PIC

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_PIC

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_LOAD_PIC
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_LOAD_PIC

DRAW_COLOR_PIC:
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_PIC:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, DRAW_X_END
    JL COLUMN_LOOP_LOAD_PIC

NEXT_ROW_PIC:
    MOV CX, [X_POS]         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, DRAW_Y_END
    JL COLUMN_LOOP_LOAD_PIC

DONE_LOADING_PIC:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h

    CALL MOUSE_SHOW

    CALL TEXT_PIC           ; Mostrar mensaje de éxito
    MOV AX, 35              ; Esperar 2 segundos
    CALL DELAY_SECONDS
    RET

FILE_ERROR_LOAD_PIC:
    ; Manejo de errores
    CALL TEXT_ERROR_PIC
    MOV AX, 35              ; Esperar 2 segundos
    CALL DELAY_SECONDS
    RET
LOAD_IMAGE ENDP

MOUSE_HIDE PROC
    MOV AX, 02h    ; Ocultar cursor
    INT 33h
    RET
MOUSE_HIDE ENDP

DRAW_TRIANGULO PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, TRIANGULO  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_TRIANGULO   ; Saltar si hay error
    JMP TRAINGULO_PROCESS

FILE_ERROR_TRIANGULO:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
TRAINGULO_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 127  
    MOV DX, 326 

COLUMN_LOOP_TRIANGULO:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_TRIANGULO

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_TRIANGULO

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_TRIANGULO
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_TRIANGULO

DRAW_COLOR_TRIANGULO:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_TRIANGULO:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 156
    JL COLUMN_LOOP_TRIANGULO

NEXT_ROW_TRIANGULO:
    MOV CX, 127         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 355
    JL COLUMN_LOOP_TRIANGULO

DONE_LOADING_TRIANGULO:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_TRIANGULO ENDP

DRAW_CIRCULO PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, CIRCULO  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_CIRCULO   ; Saltar si hay error
    JMP CIRCULO_PROCESS

FILE_ERROR_CIRCULO:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
CIRCULO_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 167  
    MOV DX, 326 

COLUMN_LOOP_CIRCULO:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_CIRCULO

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_CIRCULO

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_CIRCULO
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_CIRCULO

DRAW_COLOR_CIRCULO:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_CIRCULO:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 196
    JL COLUMN_LOOP_CIRCULO

NEXT_ROW_CIRCULO:
    MOV CX, 167         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 355
    JL COLUMN_LOOP_CIRCULO

DONE_LOADING_CIRCULO:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_CIRCULO ENDP

DRAW_DIAMANTE PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, DIAMANTE  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_DIAMANTE   ; Saltar si hay error
    JMP DIAMANTE_PROCESS

FILE_ERROR_DIAMANTE:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
DIAMANTE_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 207  
    MOV DX, 326 

COLUMN_LOOP_DIAMANTE:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_DIAMANTE

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_DIAMANTE

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_DIAMANTE
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_DIAMANTE

DRAW_COLOR_DIAMANTE:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_DIAMANTE:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 236
    JL COLUMN_LOOP_DIAMANTE

NEXT_ROW_DIAMANTE:
    MOV CX, 207         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 355
    JL COLUMN_LOOP_DIAMANTE

DONE_LOADING_DIAMANTE:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_DIAMANTE ENDP

DRAW_FLECHA PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, FLECHA  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_FLECHA   ; Saltar si hay error
    JMP FLECHA_PROCESS

FILE_ERROR_FLECHA:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
FLECHA_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 252  
    MOV DX, 326 

COLUMN_LOOP_FLECHA:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_FLECHA

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_FLECHA

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_FLECHA
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_FLECHA

DRAW_COLOR_FLECHA:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_FLECHA:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 281
    JL COLUMN_LOOP_FLECHA

NEXT_ROW_FLECHA:
    MOV CX, 252         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 355
    JL COLUMN_LOOP_FLECHA

DONE_LOADING_FLECHA:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_FLECHA ENDP

DRAW_CORAZON PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, CORAZON  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_CORAZON   ; Saltar si hay error
    JMP CORAZON_PROCESS

FILE_ERROR_CORAZON:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
CORAZON_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 292  
    MOV DX, 326 

COLUMN_LOOP_CORAZON:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_CORAZON

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_CORAZON

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_CORAZON
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_CORAZON

DRAW_COLOR_CORAZON:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_CORAZON:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 321
    JL COLUMN_LOOP_CORAZON

NEXT_ROW_CORAZON:
    MOV CX, 292         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 355
    JL COLUMN_LOOP_CORAZON

DONE_LOADING_CORAZON:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_CORAZON ENDP

DRAW_ESTRELLA PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, ESTRELLA  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_ESTRELLA   ; Saltar si hay error
    JMP ESTRELLA_PROCESS

FILE_ERROR_ESTRELLA:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
ESTRELLA_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 332  
    MOV DX, 326 

COLUMN_LOOP_ESTRELLA:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_ESTRELLA

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_ESTRELLA

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_ESTRELLA
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_ESTRELLA

DRAW_COLOR_ESTRELLA:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_ESTRELLA:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 361
    JL COLUMN_LOOP_ESTRELLA

NEXT_ROW_ESTRELLA:
    MOV CX, 332         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 355
    JL COLUMN_LOOP_ESTRELLA

DONE_LOADING_ESTRELLA:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_ESTRELLA ENDP

DRAW_TRI PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, TRI  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_TRI   ; Saltar si hay error
    MOV BX, AX               ; Guardar el handler del archivo en BX
    JMP WAIT_FOR_CLICK_TRI

FILE_ERROR_TRI:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
WAIT_FOR_CLICK_TRI:
    ; Preservar el handler antes de llamar al mouse
    PUSH BX                  
    CALL MOUSE_GET_POSITION  ; Obtener posición del mouse
    CMP [BUTTONS], 1         ; Verificar si el botón izquierdo está presionado
    JNE RESTORE_HANDLER_TRI      ; Si no, restaurar el handler y seguir esperando

    ; Definir las coordenadas del área de dibujo (36,76) a (449,304)
    SET_LINE_POINTS 36, 76, 449, 304
    CALL IS_CLICK_INSIDE_RECTANGLE  ; Verificar si el clic está dentro del área
    JNE RESTORE_HANDLER_TRI             ; Si no está dentro, restaurar handler y seguir esperando

    ; Guardar las coordenadas del clic en CX y DX para iniciar el dibujo
    
    MOV CX, [X_POS]  ; Usar X_POS como columna inicial
    MOV DX, [Y_POS]  ; Usar Y_POS como fila inicial

    CALL MOUSE_HIDE

    ; Restaurar el handler del archivo
RESTORE_HANDLER_TRI:
    POP BX                  ; Restaurar BX con el handler del archivo
    JNE WAIT_FOR_CLICK_TRI      ; Si no se ha hecho clic válido, repetir

COLUMN_LOOP_TRI:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL,'F'
    JE NEXT_COLUMN_TRI

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_TRI

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_TRI

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_TRI
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_TRI

DRAW_COLOR_TRI:
    
    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    MOV AL, [SELECTED_COLOR]
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_TRI:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, DRAW_X_END
    JL COLUMN_LOOP_TRI

NEXT_ROW_TRI:
    MOV CX, [X_POS]         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, DRAW_Y_END
    JL COLUMN_LOOP_TRI

DONE_LOADING_TRI:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h

    CALL MOUSE_SHOW
    RET

DRAW_TRI ENDP

DRAW_CIR PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, CIR  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_CIR   ; Saltar si hay error
    MOV BX, AX               ; Guardar el handler del archivo en BX
    JMP WAIT_FOR_CLICK_CIR

FILE_ERROR_CIR:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
WAIT_FOR_CLICK_CIR:
    ; Preservar el handler antes de llamar al mouse
    PUSH BX                  
    CALL MOUSE_GET_POSITION  ; Obtener posición del mouse
    CMP [BUTTONS], 1         ; Verificar si el botón izquierdo está presionado
    JNE RESTORE_HANDLER_CIR      ; Si no, restaurar el handler y seguir esperando

    ; Definir las coordenadas del área de dibujo (36,76) a (449,304)
    SET_LINE_POINTS 36, 76, 449, 304
    CALL IS_CLICK_INSIDE_RECTANGLE  ; Verificar si el clic está dentro del área
    JNE RESTORE_HANDLER_CIR             ; Si no está dentro, restaurar handler y seguir esperando

    ; Guardar las coordenadas del clic en CX y DX para iniciar el dibujo
    
    MOV CX, [X_POS]  ; Usar X_POS como columna inicial
    MOV DX, [Y_POS]  ; Usar Y_POS como fila inicial

    CALL MOUSE_HIDE

    ; Restaurar el handler del archivo
RESTORE_HANDLER_CIR:
    POP BX                  ; Restaurar BX con el handler del archivo
    JNE WAIT_FOR_CLICK_CIR      ; Si no se ha hecho clic válido, repetir

COLUMN_LOOP_CIR:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL,'F'
    JE NEXT_COLUMN_CIR

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_CIR

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_CIR

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_CIR
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_CIR

DRAW_COLOR_CIR:
    
    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    MOV AL, [SELECTED_COLOR]
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_CIR:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, DRAW_X_END
    JL COLUMN_LOOP_CIR

NEXT_ROW_CIR:
    MOV CX, [X_POS]         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, DRAW_Y_END
    JL COLUMN_LOOP_CIR

DONE_LOADING_CIR:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h

    CALL MOUSE_SHOW
    RET

DRAW_CIR ENDP

DRAW_DIA PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, DIA  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_DIA   ; Saltar si hay error
    MOV BX, AX               ; Guardar el handler del archivo en BX
    JMP WAIT_FOR_CLICK_DIA

FILE_ERROR_DIA:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
WAIT_FOR_CLICK_DIA:
    ; Preservar el handler antes de llamar al mouse
    PUSH BX                  
    CALL MOUSE_GET_POSITION  ; Obtener posición del mouse
    CMP [BUTTONS], 1         ; Verificar si el botón izquierdo está presionado
    JNE RESTORE_HANDLER_DIA      ; Si no, restaurar el handler y seguir esperando

    ; Definir las coordenadas del área de dibujo (36,76) a (449,304)
    SET_LINE_POINTS 36, 76, 449, 304
    CALL IS_CLICK_INSIDE_RECTANGLE  ; Verificar si el clic está dentro del área
    JNE RESTORE_HANDLER_DIA             ; Si no está dentro, restaurar handler y seguir esperando

    ; Guardar las coordenadas del clic en CX y DX para iniciar el dibujo
    
    MOV CX, [X_POS]  ; Usar X_POS como columna inicial
    MOV DX, [Y_POS]  ; Usar Y_POS como fila inicial

    CALL MOUSE_HIDE

    ; Restaurar el handler del archivo
RESTORE_HANDLER_DIA:
    POP BX                  ; Restaurar BX con el handler del archivo
    JNE WAIT_FOR_CLICK_DIA      ; Si no se ha hecho clic válido, repetir

COLUMN_LOOP_DIA:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL,'F'
    JE NEXT_COLUMN_DIA

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_DIA

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_DIA

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_DIA
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_DIA

DRAW_COLOR_DIA:
    
    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    MOV AL, [SELECTED_COLOR]
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_DIA:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, DRAW_X_END
    JL COLUMN_LOOP_DIA

NEXT_ROW_DIA:
    MOV CX, [X_POS]         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, DRAW_Y_END
    JL COLUMN_LOOP_DIA

DONE_LOADING_DIA:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    CALL MOUSE_SHOW
    RET

DRAW_DIA ENDP

DRAW_FLE PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, FLE  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_FLE   ; Saltar si hay error
    MOV BX, AX               ; Guardar el handler del archivo en BX
    JMP WAIT_FOR_CLICK_FLE

FILE_ERROR_FLE:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
WAIT_FOR_CLICK_FLE:
    ; Preservar el handler antes de llamar al mouse
    PUSH BX                  
    CALL MOUSE_GET_POSITION  ; Obtener posición del mouse
    CMP [BUTTONS], 1         ; Verificar si el botón izquierdo está presionado
    JNE RESTORE_HANDLER_FLE      ; Si no, restaurar el handler y seguir esperando

    ; Definir las coordenadas del área de dibujo (36,76) a (449,304)
    SET_LINE_POINTS 36, 76, 449, 304
    CALL IS_CLICK_INSIDE_RECTANGLE  ; Verificar si el clic está dentro del área
    JNE RESTORE_HANDLER_FLE             ; Si no está dentro, restaurar handler y seguir esperando

    ; Guardar las coordenadas del clic en CX y DX para iniciar el dibujo
    
    MOV CX, [X_POS]  ; Usar X_POS como columna inicial
    MOV DX, [Y_POS]  ; Usar Y_POS como fila inicial

    CALL MOUSE_HIDE

    ; Restaurar el handler del archivo
RESTORE_HANDLER_FLE:
    POP BX                  ; Restaurar BX con el handler del archivo
    JNE WAIT_FOR_CLICK_FLE      ; Si no se ha hecho clic válido, repetir

COLUMN_LOOP_FLE:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL,'F'
    JE NEXT_COLUMN_FLE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_FLE

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_FLE

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_FLE
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_FLE

DRAW_COLOR_FLE:
    
    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    MOV AL, [SELECTED_COLOR]
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_FLE:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, DRAW_X_END
    JL COLUMN_LOOP_FLE

NEXT_ROW_FLE:
    MOV CX, [X_POS]         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, DRAW_Y_END
    JL COLUMN_LOOP_FLE

DONE_LOADING_FLE:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    CALL MOUSE_SHOW
    RET

DRAW_FLE ENDP

DRAW_COR PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, COR  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_COR   ; Saltar si hay error
    MOV BX, AX               ; Guardar el handler del archivo en BX
    JMP WAIT_FOR_CLICK_COR

FILE_ERROR_COR:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
WAIT_FOR_CLICK_COR:
    ; Preservar el handler antes de llamar al mouse
    PUSH BX                  
    CALL MOUSE_GET_POSITION  ; Obtener posición del mouse
    CMP [BUTTONS], 1         ; Verificar si el botón izquierdo está presionado
    JNE RESTORE_HANDLER_COR      ; Si no, restaurar el handler y seguir esperando

    ; Definir las coordenadas del área de dibujo (36,76) a (449,304)
    SET_LINE_POINTS 36, 76, 449, 304
    CALL IS_CLICK_INSIDE_RECTANGLE  ; Verificar si el clic está dentro del área
    JNE RESTORE_HANDLER_COR             ; Si no está dentro, restaurar handler y seguir esperando

    ; Guardar las coordenadas del clic en CX y DX para iniciar el dibujo
    
    MOV CX, [X_POS]  ; Usar X_POS como columna inicial
    MOV DX, [Y_POS]  ; Usar Y_POS como fila inicial

    CALL MOUSE_HIDE

    ; Restaurar el handler del archivo
RESTORE_HANDLER_COR:
   
    POP BX                  ; Restaurar BX con el handler del archivo
    JNE WAIT_FOR_CLICK_COR      ; Si no se ha hecho clic válido, repetir

COLUMN_LOOP_COR:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL,'F'
    JE NEXT_COLUMN_COR

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_COR

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_COR

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_COR
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_COR

DRAW_COLOR_COR:
    
    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    MOV AL, [SELECTED_COLOR]
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_COR:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, DRAW_X_END
    JL COLUMN_LOOP_COR

NEXT_ROW_COR:
    MOV CX, [X_POS]         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, DRAW_Y_END
    JL COLUMN_LOOP_COR

DONE_LOADING_COR:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    CALL MOUSE_SHOW
    RET

DRAW_COR ENDP

DRAW_EST PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, EST  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_EST   ; Saltar si hay error
    MOV BX, AX               ; Guardar el handler del archivo en BX
    JMP WAIT_FOR_CLICK_EST

FILE_ERROR_EST:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
WAIT_FOR_CLICK_EST:
    
    ; Preservar el handler antes de llamar al mouse
    PUSH BX                  
    CALL MOUSE_GET_POSITION  ; Obtener posición del mouse
    CMP [BUTTONS], 1         ; Verificar si el botón izquierdo está presionado
    JNE RESTORE_HANDLER_EST      ; Si no, restaurar el handler y seguir esperando

    ; Definir las coordenadas del área de dibujo (36,76) a (449,304)
    SET_LINE_POINTS 36, 76, 449, 304
    CALL IS_CLICK_INSIDE_RECTANGLE  ; Verificar si el clic está dentro del área
    JNE RESTORE_HANDLER_EST             ; Si no está dentro, restaurar handler y seguir esperando

    ; Guardar las coordenadas del clic en CX y DX para iniciar el dibujo    
    
    MOV CX, [X_POS]  ; Usar X_POS como columna inicial
    MOV DX, [Y_POS]  ; Usar Y_POS como fila inicial

    CALL MOUSE_HIDE
    ; Restaurar el handler del archivo
RESTORE_HANDLER_EST:
    
    POP BX                  ; Restaurar BX con el handler del archivo
    JNE WAIT_FOR_CLICK_EST      ; Si no se ha hecho clic válido, repetir

COLUMN_LOOP_EST:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL,'F'
    JE NEXT_COLUMN_EST

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_EST

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_EST

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_EST
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_EST

DRAW_COLOR_EST:
    
    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    MOV AL, [SELECTED_COLOR]
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_EST:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, DRAW_X_END
    JL COLUMN_LOOP_EST

NEXT_ROW_EST:
    MOV CX, [X_POS]         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, DRAW_Y_END
    JL COLUMN_LOOP_EST

DONE_LOADING_EST:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    CALL MOUSE_SHOW
    RET

DRAW_EST ENDP

DRAW_FONDO PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, FONDO  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_FONDO   ; Saltar si hay error
    JMP FONDO_PROCESS

FILE_ERROR_FONDO:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
FONDO_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 0  
    MOV DX, 0 

COLUMN_LOOP_FONDO:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_FONDO

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_FONDO

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_FONDO
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_FONDO

DRAW_COLOR_FONDO:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_FONDO:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 642
    JL COLUMN_LOOP_FONDO

NEXT_ROW_FONDO:
    MOV CX, 0         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 481
    JL COLUMN_LOOP_FONDO

DONE_LOADING_FONDO:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_FONDO ENDP


DRAW_SKETCH PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, SKETCH  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_SKETCH   ; Saltar si hay error
    JMP SKETCH_PROCESS

FILE_ERROR_SKETCH:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
SKETCH_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 25  
    MOV DX, 65 

COLUMN_LOOP_SKETCH:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_SKETCH

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_SKETCH

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_SKETCH
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_SKETCH

DRAW_COLOR_SKETCH:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_SKETCH:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 462
    JL COLUMN_LOOP_SKETCH

NEXT_ROW_SKETCH:
    MOV CX, 25         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 376
    JL COLUMN_LOOP_SKETCH

DONE_LOADING_SKETCH:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_SKETCH ENDP


DRAW_RELLENO PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, RELLENO  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_RELLENO   ; Saltar si hay error
    JMP RELLENO_PROCESS

FILE_ERROR_RELLENO:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET
RELLENO_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 430  
    MOV DX, 435 

COLUMN_LOOP_RELLENO:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_RELLENO

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_RELLENO

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_RELLENO
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_RELLENO

DRAW_COLOR_RELLENO:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_RELLENO:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 462
    JL COLUMN_LOOP_RELLENO

NEXT_ROW_RELLENO:
    MOV CX, 430         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 466
    JL COLUMN_LOOP_RELLENO

DONE_LOADING_RELLENO:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_RELLENO ENDP

DRAW_PORTADA PROC
    
    ; Abrir el archivo
    MOV AH, 3Dh              ; Función para abrir archivo
    MOV AL, 0                ; Modo de lectura
    LEA DX, PORTADA  ; Dirección del nombre del archivo
    INT 21h
    JC FILE_ERROR_PORTADA   ; Saltar si hay error
    JMP PORTADA_PROCESS

FILE_ERROR_PORTADA:
    MOV CX, 200
    MOV DX, 200
    MOV AL, 4
    CALL PRINT_PIXEL    
    RET

PORTADA_PROCESS:

    MOV BX, AX               ; Guardar el handler del archivo en BX
    
    MOV CX, 36 
    MOV DX, 76 

COLUMN_LOOP_PORTADA:
    
    ; Leer un byte del archivo (color)
    CALL READ_BYTE

    CMP AL, '%'             ; Verificar si es el fin del archivo
    JE DONE_LOADING_PORTADA

    CMP AL, '@'             ; Verificar si es el fin de la fila
    JE NEXT_ROW_PORTADA

    CMP AL, 0Dh             ; Retorno de carro
    JE COLUMN_LOOP_PORTADA
    CMP AL, 0Ah             ; Nueva línea
    JE COLUMN_LOOP_PORTADA

DRAW_COLOR_PORTADA:
    
    ; Convertir el carácter a su valor hexadecimal
    CALL ASCII_TO_COLOR

    ; Dibujar el píxel con el color correspondiente
    MOV AH, 0Ch             ; Función para dibujar píxel
    MOV BH, 0               ; Página 0
    MOV CX, CX
    MOV DX, DX
    INT 10h                 ; Dibujar el píxel

NEXT_COLUMN_PORTADA:
    INC CX                  ; Avanzar a la siguiente columna
    CMP CX, 452
    JL COLUMN_LOOP_PORTADA

NEXT_ROW_PORTADA:
    MOV CX, 36         ; Reiniciar columna
    INC DX                  ; Avanzar a la siguiente fila
    CMP DX, 306
    JL COLUMN_LOOP_PORTADA

DONE_LOADING_PORTADA:
    ; Cerrar el archivo
    MOV AH, 3Eh             ; Cerrar archivo
    MOV BX, BX              ; Handle del archivo
    INT 21h
    RET

DRAW_PORTADA ENDP

FILL_DRAWING_AREA PROC
    MOV WORD PTR [X1], 35   ; Columna inicial (X1) para el tercer botón
    MOV WORD PTR [Y1], 75 ; Fila inicial (Y1)
    MOV WORD PTR [X2], 450  ; Columna final (X2)
    MOV WORD PTR [Y2], 305  ; Fila final (Y2)
    MOV AL, [SELECTED_COLOR]
    CALL FILL_RECTANGLE
    MOV WORD PTR [DRAW_X], 242
    MOV WORD PTR [DRAW_Y], 190
    RET
FILL_DRAWING_AREA ENDP

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
    JNE CHECK_RECT_18
    JMP LOAD_DRAWING

    CHECK_RECT_18:
    SET_LINE_POINTS 255, 435, 390, 470
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_19
    JMP LOAD_PIC

    CHECK_RECT_19:
    SET_LINE_POINTS 125, 325, 155, 355
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_20
    JMP PRINT_TRIANGULO

    CHECK_RECT_20:
    SET_LINE_POINTS 165, 325, 195, 355
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_21
    JMP PRINT_CIRCULO

    CHECK_RECT_21:
    SET_LINE_POINTS 205, 325, 235, 355
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_22
    JMP PRINT_DIAMANTE

    CHECK_RECT_22:
    SET_LINE_POINTS 250, 325, 280, 355
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_23
    JMP PRINT_FLECHA

    CHECK_RECT_23:
    SET_LINE_POINTS 290, 325, 320, 355
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_24
    JMP PRINT_CORAZON

    CHECK_RECT_24:
    SET_LINE_POINTS 330, 325, 360, 355
    CALL IS_CLICK_INSIDE_RECTANGLE
    JNE CHECK_RECT_25
    JMP PRINT_ESTRELLA

    CHECK_RECT_25:
    SET_LINE_POINTS 429, 434, 460, 465
    CALL IS_CLICK_INSIDE_RECTANGLE
    JE FILL_AREA
     
    CALL DRAWING_LOOP

DRAW_PROCESS:
    MOV AL, [RECTANGLE_COLORS + DI]   ; Cargar el color de la tabla en AL
    MOV [SELECTED_COLOR], AL
    CALL DRAWING_LOOP
    JMP MAIN_LOOP           ; Continuar verificando clics

FILL_AREA:
    CALL FILL_DRAWING_AREA
    JMP MAIN_LOOP

PRINT_ESTRELLA:
    CALL DRAW_EST
    JMP MAIN_LOOP

PRINT_TRIANGULO:
    CALL DRAW_TRI
    JMP MAIN_LOOP

PRINT_CIRCULO:
    CALL DRAW_CIR
    JMP MAIN_LOOP

PRINT_DIAMANTE:
    CALL DRAW_DIA
    JMP MAIN_LOOP

PRINT_FLECHA:
    CALL DRAW_FLE
    JMP MAIN_LOOP

PRINT_CORAZON:
    CALL DRAW_COR
    JMP MAIN_LOOP

LOAD_PIC:
    CALL LOAD_IMAGE
    CALL RESET_FILENAME_BUFFER
    CALL RESET_CAMPO_TXT
    JMP MAIN_LOOP

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

