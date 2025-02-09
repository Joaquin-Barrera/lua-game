local Player = require("player")
local Enemy = require("enemy")
local Game = require("game")
local Sounds = require("sounds")
local Menu = require("menu")
push = require("libraries/push") -- Ahora en minúsculas para consistencia

WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
WINDOW_WIDTH, WINDOW_HEIGHT = WINDOW_WIDTH * 0.8, WINDOW_HEIGHT * 0.8

VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 640 , 360

local currentState = "menu"
local gamePaused = false
local fullscreen = false -- Ahora empieza en ventana
local screenWidth, screenHeight = VIRTUAL_WIDTH, VIRTUAL_HEIGHT

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Trigger Rush // Trigger Frenzy")

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = fullscreen,
        vsync = true,
        resizable = true
    })

    love.mouse.setVisible(false)

    -- Inicializar módulos
    Player.load()
    Enemy.load()
    Menu.load()
end

function resetGame()
    Player.load()
    Enemy.clear()
    Enemy.load()
    Game.round = 0
    currentState = "play"
end

function love.update(dt)
    if currentState == "menu" then
        Menu.update(dt)
    elseif currentState == "play" then
        if not gamePaused then
            Player.update(dt, gamePaused, screenWidth, screenHeight)
            Enemy.update(dt)
            Game.update(dt)

            if Player.health <= 0 then
                currentState = "gameover"
            end
        end
    end
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.draw()
    Game.background = love.graphics.newImage("sprites/ciudadprueba2.png")
   
    -- Dibujar la interfaz y los objetos del juego
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
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER", 0, VIRTUAL_HEIGHT / 2 - 40, VIRTUAL_WIDTH, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Presiona R para reiniciar", 0, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH, "center")
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
        elseif key == "r" then
            Player.reload()
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
        if key == "p" then
            gamePaused = not gamePaused
        end
    elseif currentState == "gameover" then
        if key == "r" then
            resetGame()
        end
    end

    -- Alternar entre pantalla completa y ventana
    if key == "f" then
        fullscreen = not fullscreen
        push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
            fullscreen = fullscreen,
            resizable = true,
            vsync = true
        })
    end
end

function love.mousepressed(x, y, button)
    if currentState == "play" and button == 1 then
        if not gamePaused then
            local weapon = Player.getCurrentWeapon()
            Player.shoot()
            Enemy.checkClick(x, y, weapon)
        end
    end
end
