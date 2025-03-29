# 🎨 Etch A Sketch - Proyecto en Ensamblador x86 (DOS)

Este proyecto es una versión interactiva tipo *Etch A Sketch*, desarrollado en lenguaje ensamblador x86 (modo real DOS), con soporte para:

- Uso del mouse (movimiento y clics).
- Selección de colores y grosores.
- Dibujo de figuras predefinidas.
- Guardado y carga de bosquejos desde archivos `.TXT`.

---

## 📂 Archivos necesarios

Los siguientes archivos `.txt` son esenciales para el funcionamiento del proyecto, ya que contienen los bosquejos de figuras que se pueden dibujar:

`CIR`, `FLE`, `DIA`, `TRI`, `EST`, `COR`, `CORAZON`, `TRIAN`, `FLECHA`, `CIRCU`, `DIAMAN`, `ESTRE`

⚠️ **No se deben borrar ni mover de la carpeta principal del proyecto.**

---

## 💾 Guardado de bosquejos

- Los bosquejos creados por el usuario se almacenan **automáticamente en la misma carpeta** del ejecutable.
- Se guardan como archivos `.TXT` con el nombre ingresado por el usuario.

---

## 🖱️ Cómo usar los íconos

1. Seleccionar primero un **color**.
2. Luego, elegir un **ícono o figura** desde la interfaz.
3. Finalmente, hacer clic en cualquier lugar del área de dibujo para colocarlo.

---

## ✏️ Mostrar un archivo de dibujo

Para visualizar un bosquejo guardado:

1. Ingresar el **nombre del archivo `.txt`** en el cuadro de texto que dice `"Texto aqui:"`.
2. Presionar la tecla correspondiente para mostrarlo.

---

## 🧠 Requisitos técnicos

- Sistema: DOS (modo real).
- Lenguaje: Ensamblador x86.
- Compilador: TASM o similar.
- Ejecutable: `DIBUJO.EXE` (si no se incluye, debe compilarse desde `DIBUJO.ASM`).

---

## 👨‍💻 Autores

Proyecto realizado por: **Isaac Alvarado Mata** y **Matiwi Rivera Cascante**

---

## 🚀 Cómo compilar 

```bash
tasm DIBUJO.ASM
tlink DIBUJO.OBJ DIBUJO.EXE
