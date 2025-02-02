local Player = require("player")
local Enemy = require("enemy")
local Game = require("game")
local Sounds = require("sounds")
local Menu = require("menu") -- Importar el menú

local currentState = "menu" -- Estado inicial: menú
local gamePaused = false    -- Estado de pausa

function love.load()
    love.window.setTitle("Trigger Rush // Trigger Frenzy")    
    love.window.setMode(800, 600)
    love.mouse.setVisible(false)

    -- Inicializar módulos
    Player.load()
    Enemy.load()
    Menu.load() -- Cargar el menú
end

function resetGame()
    Player.load()  -- Reinicia la vida y posición del jugador
    Enemy.clear() -- Elimina todos los enemigos
    Enemy.load()   -- Carga los enemigos de nuevo
    Game.round = 0 --por algun motivo tengo que ponerlo en 0 porque si lo pongo en 1 empieza desde la ronda 2, cosa de mandinga
    currentState = "play" -- Regresar al gameplay desde el inicio
end

function love.update(dt)
    if currentState == "menu" then
        Menu.update(dt)
    elseif currentState == "play" then
        if not gamePaused then
            Player.update(dt, gamePaused)
            Enemy.update(dt)
            Game.update(dt)

            -- Verificar si el jugador ha perdido
            if Player.health <= 0 then
                currentState = "gameover"
            end
        end
    end
end

function love.draw()
    if currentState == "menu" then
        Menu.draw()
    elseif currentState == "play" then
        Game.draw()
        Enemy.draw()
        Player.draw(gamePaused)

        -- Mostrar pantalla de pausa
        if gamePaused then
            love.mouse.setVisible(true)
            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("PAUSA", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
            love.graphics.printf("Presiona P para reanudar", 0, love.graphics.getHeight() / 2 + 20, love.graphics.getWidth(), "center")
        else
            love.mouse.setVisible(false)
        end

    elseif currentState == "gameover" then
        -- Pantalla de Game Over
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight()) -- Fondo negro
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Presiona R para reiniciar", 0, love.graphics.getHeight() / 2 + 20, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if currentState == "play" and not gamePaused then
        if key == "1" then
            Player.switchWeapon("pistol")
        elseif key == "2" then
            Player.switchWeapon("shotgun")
        elseif key == "3" then
            Player.switchWeapon("punch")
        elseif key == "r" or key == "R" then -- Detectar la tecla R
            Player.reload() -- Recargar el arma actual
        end
    end

    if currentState == "menu" then
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
        if key == "p" or key == "P" then
            gamePaused = not gamePaused
        end
    elseif currentState == "gameover" then
        if key == "r" or key == "R" then
            resetGame() -- Reiniciar el juego correctamente
        end
    end
end

function love.mousepressed(x, y, button)
    if currentState == "play" and button == 1 then
        if not gamePaused then
            -- Obtener el arma actual del jugador
            local weapon = Player.getCurrentWeapon()

            -- Intentar disparar
            Player.shoot()
            
            -- Intentar eliminar enemigos
            if Enemy.checkClick(x, y, weapon) then
            end
        end
    end
end