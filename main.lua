-- Cargar módulos
local Player = require("player")
local Enemy = require("enemy")
local Game = require("game")
local Sounds = require("sounds")
local Menu = require("menu") -- Importar el menú

-- Estados del juego
local currentState = "menu" -- Estado inicial: menú

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
        -- Actualizar el gameplay
        Player.update(dt)
        Enemy.update(dt)
        Game.update(dt)
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
       -- Player.keypressed(key)
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