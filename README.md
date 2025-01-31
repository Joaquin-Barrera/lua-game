# Lua Strike
**Descripción**: Este es un juego de disparos desarrollado en Lua utilizando el framework LÖVE. 

## Requisitos

- **LÖVE**: Asegúrate de tener instalada la versión 11.0 o superior de LÖVE. Puedes descargarla desde [love2d.org](https://love2d.org/).

## Instalación y Ejecución

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/Joaquin-Barrera/lua-game.git
   cd lua-game
   ```

2. **Ejecutar el juego**:
   - Si estás en **Windows** o **macOS**, arrastra la carpeta del proyecto sobre el ejecutable de LÖVE.

## Controles

- **Movimiento**: Utiliza las teclas de dirección o las teclas 'W', 'A', 'S', 'D' para mover al personaje.
- **Disparo**: Presiona la barra espaciadora para disparar.
- **Pausa**: Presiona la tecla 'P' para pausar el juego.

## Estructura del Proyecto
- **main.lua**: Punto de entrada del juego.
- **game.lua**: Lógica principal del juego.
- **menu.lua**: Gestión del menú principal.
- **pause.lua**: Gestión de la pantalla de pausa.
- **player.lua**: Control del jugador.
- **enemy.lua**: Control de los enemigos.
- **weapons.lua**: Gestión de las armas y disparos.
- **sounds.lua**: Gestión de los efectos de sonido.
- **carpetas**:
  - **audio**: Archivos de sonido del juego.
  - **sprites**: Imágenes y sprites utilizados en el juego.
  - **libraries**: Bibliotecas externas utilizadas, como 'anim8' para la gestión de animaciones.

## Créditos
- **Desarrollador**: Joaquín Barrera
- **Framework**: [LÖVE](https://love2d.org/)
- **Bibliotecas**: 'anim8' para animaciones