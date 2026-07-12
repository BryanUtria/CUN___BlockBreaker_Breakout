# Block Breaker

Un juego estilo Breakout clásico moderno, desarrollado en Lua utilizando el framework LÖVE (Love2D). El proyecto cuenta con una arquitectura robusta basada en Programación Orientada a Objetos (utilizando metatablas), una Máquina de Estados, y un alto nivel de pulido visual (*Game Feel*).

## Desarrolladores

- Laura Barbosa Bedoya
- Andrés Felipe Uribe Rodríguez
- Brayan Steven Castelblanco Utria

---

## Características del Juego

- **Arquitectura Limpia**: Uso de Máquina de Estados (`Titulo`, `Saque`, `Jugar`, `JuegoTerminado`) para separar la lógica del juego.
- **Gráficos y Shaders Avanzados**:
  - Fondo animado tipo "Vaporwave Retro 3D" en tiempo real utilizando *GLSL Shaders*.
  - Entidades en pseudo-3D con bordes biselados, brillos e iluminación.
- **Power-Ups (Mejoras)**: Sistema de caída de cápsulas 3D con íconos vectoriales dinámicos y textos flotantes animados. Incluye:
  - `+1 Vida`
  - `+ Raqueta`
  - `+ Bolas` (Multibola)
- **Interfaz (HUD) Dinámica**: 
  - Panel superior translúcido con borde neón.
  - Íconos vectoriales dibujados por código (sin depender de fuentes unicode).
  - Barra de progreso que se llena en tiempo real al destruir bloques, con degradado de color dinámico.
- **Efectos Visuales (Game Feel)**:
  - Sistema de Partículas para las explosiones de los ladrillos (heredando el color del ladrillo destruido).
  - Efecto *Screen Shake* (temblor de pantalla) de intensidad variable según la puntuación.
  - Tweening (Animaciones suaves) al cambiar el tamaño de la raqueta.
- **Audio Completo**: Música de fondo en *streaming* para bajo consumo de RAM y efectos de sonido para rebotes, destrucciones, mejoras y pérdidas de vida.

---

## Requisitos Previos

Para poder ejecutar este juego en tu computadora, necesitas tener instalado lo siguiente:

1. **Framework LÖVE (Love2D)**:
   - Ve a la página oficial: [love2d.org](https://love2d.org/)
   - Descarga e instala la versión correspondiente a tu sistema (Windows, macOS o Linux).
   - *(Opcional pero recomendado en Windows)*: Agrega LÖVE a tus variables de entorno (PATH) para ejecutarlo desde la consola.

2. **Visual Studio Code (VS Code)** (Opcional):
   - Puedes descargarlo desde [code.visualstudio.com](https://code.visualstudio.com/).
   - Dentro de VS Code, ve a la sección de Extensiones e instala **"Love2D Support"** para facilitar la ejecución del proyecto presionando `Alt + L`.

---

## ¿Cómo ejecutar el juego?

### Desde la terminal o consola

1. Abre la terminal.
2. Verifica que la terminal esté en la misma carpeta donde se encuentra el archivo `main.lua`.
3. Ejecuta el siguiente comando:
   ```bash
   love .
   ```

*(Nota: Asegúrate de tener la música de fondo `musica.ogg` o `musica.mp3` en la carpeta `assets/sounds/` para la experiencia completa).*

---

## Estructura del Proyecto

- `main.lua`: Punto de entrada del juego, inicializa la máquina de estados, el sistema de audio, shaders y fuentes.
- `src/states/`: Contiene los estados del juego (`EstadoTitulo`, `EstadoSaque`, `EstadoJugar`, `EstadoJuegoTerminado`).
- `src/entities/`: Entidades del juego como `Raqueta`, `Pelota`, `Ladrillo` y `Mejora`. Heredan de `ElementoJuego`.
- `src/levels/Nivel.lua`: Generador de niveles, carga los mapas de los ladrillos.
- `src/utils/`: Sistemas de apoyo como `MaquinaEstados`, `Animacion` (Tweening) y `Particulas`.
- `assets/`: Carpeta para recursos de fuentes (`fonts/`) y sonidos (`sounds/`).
