-- Cargar módulos
local Player = require("player")
local Enemy = require("enemy")
local Game = require("game")
local Sounds = require("sounds")
local Menu = require("menu") -- Importar el menú

-- Estados del juego
local currentState = "menu" -- Estado inicial: menú
local gamePaused = false    -- Estado de pausa

function love.load()
    love.window.setTitle("Shooter prueba")
    love.window.setMode(800, 600)
    love.mouse.setVisible(false)

    -- Inicializar módulos
    Player.load()
    Enemy.load()
    Menu.load() -- Cargar el menú
end

function love.update(dt)
    if currentState == "menu" then
        -- Actualizar el menú
        Menu.update(dt)
    elseif currentState == "play" then
        if not gamePaused then
            -- Actualizar el gameplay solo si no está pausado
            Player.update(dt)
            Enemy.update(dt)
            Game.update(dt)
        end
    end
end

function love.draw()
    if currentState == "menu" then
        -- Dibujar el menú
        Menu.draw()
    elseif currentState == "play" then
        -- Dibujar el gameplay
        Game.draw()
        Enemy.draw()
        Player.draw()

        -- Dibujar la pantalla de pausa si el juego está pausado
        if gamePaused then
            love.graphics.setColor(0, 0, 0, 0.5) -- Fondo semitransparente
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1) -- Color del texto
            love.graphics.printf("PAUSA", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
            love.graphics.printf("Presiona P para reanudar", 0, love.graphics.getHeight() / 2 + 20, love.graphics.getWidth(), "center")
        end
    end
end

function love.keypressed(key)
    if currentState == "menu" then
        -- Manejar las teclas en el menú
        local nextState = Menu.keypressed(key)
        if nextState == "play" then
            currentState = "play" -- Cambiar al estado de juego
            Enemy.spawn() -- Generar un enemigo inicial
        elseif nextState == "options" then
            -- Aquí puedes agregar lógica para el menú de opciones
            print("Opciones seleccionadas (no implementado)")
        elseif nextState == "quit" then
            love.event.quit() -- Salir del juego
        end
    elseif currentState == "play" then
        -- Manejar las teclas en el gameplay (si es necesario)
        if key == "p" or key == "P" then
            gamePaused = not gamePaused -- Alternar entre pausado y no pausado
        end
    end
end

function love.mousepressed(x, y, button)
    if currentState == "play" and button == 1 then -- Click izquierdo en el gameplay
        -- Activar la animación de disparo siempre
        Player.shoot()

        -- Verificar si se hizo clic sobre un enemigo
        Enemy.checkClick(x, y)
    end
end