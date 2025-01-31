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

local pausedMouseX, pausedMouseY = 0, 0 -- Variables para guardar la posición del mouse durante la pausa

function love.keypressed(key)
    if currentState == "play" and not gamePaused then -- Solo permitir cambiar de arma si no está pausado
        if key == "1" then
            Player.switchWeapon("pistol")
        elseif key == "2" then
            Player.switchWeapon("shotgun")
        elseif key == "3" then
            Player.switchWeapon("punch")
        end
    end

    if currentState == "menu" then
            -- Manejar las teclas en el menú
            local nextState = Menu.keypressed(key)
            if nextState == "play" then
                currentState = "play"
                Enemy.spawn()
            elseif nextState == "options" then
                print("Opciones seleccionadas (no implementado)")
            elseif nextState == "quit" then
                love.event.quit()
            end
        elseif currentState == "play" then
            -- Manejar la tecla de pausa
            if key == "p" or key == "P" then
                gamePaused = not gamePaused
        end
    end
end

function love.mousepressed(x, y, button)
    if currentState == "play" and button == 1 then -- Click izquierdo en el gameplay
        if not gamePaused then -- Solo disparar si el juego no está pausado
            Player.shoot()
            Enemy.checkClick(x, y) -- Verificar si se hizo clic sobre un enemigo
        end
    end
end


local pausedMouseX, pausedMouseY = 0, 0 -- Variables para guardar la posición del mouse durante la pausa
