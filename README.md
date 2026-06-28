# Block Breaker

Un juego estilo Breakout clásico, desarrollado en Lua utilizando el framework LÖVE (Love2D). El proyecto cuenta con una arquitectura basada en Programación Orientada a Objetos utilizando metatablas.

## Desarrolladores

- Laura Barbosa Bedoya
- Andrés Felipe Uribe Rodríguez
- Brayan Steven Castelblanco Utria

---

## Requisitos Previos

Para poder ejecutar este juego en tu computadora, necesitas tener instalado lo siguiente:

1. **Framework LÖVE (Love2D)**:
   - Ve a la página oficial: [love2d.org](https://love2d.org/)
   - Descarga e instala la versión correspondiente a tu sistema (Windows, macOS o Linux).
   - *(Opcional pero recomendado en Windows)*: Agrega LÖVE a tus variables de entorno (PATH) para ejecutarlo desde la consola.

2. **Visual Studio Code (VS Code)**:
   - Puedes descargarlo desde [code.visualstudio.com](https://code.visualstudio.com/).
   - Dentro de VS Code, ve a la sección de Extensiones e instala **"Love2D Support"** para facilitar la ejecución del proyecto.

---

## ¿Cómo ejecutar el juego?

### Desde la terminal o consola

1. Abre la terminal.
2. Verifica que la terminal esté en la misma carpeta donde se encuentra el archivo `main.lua`.
3. Ejecuta el siguiente comando:
   ```bash
   love .
   ```
---

## Estructura del Proyecto

- `main.lua`: Punto de entrada del juego, contiene el menú principal y el ciclo de vida de LÖVE (`love.load`, `love.update`, `love.draw`).
- `conf.lua`: Configuraciones básicas de la ventana (tamaño, título).
- `ElementoJuego.lua`: Clase abstracta de la cual heredan los objetos físicos del juego.
- `CampoJuego.lua`: Controlador central que gestiona la partida.
- `Raqueta.lua`, `Pelota.lua`, `Ladrillo.lua`: Entidades del juego interactuables.
- `GestorPuntuacion.lua` y `Nivel.lua`: Sistemas de progreso.
