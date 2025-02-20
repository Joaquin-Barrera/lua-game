local Player = require("player")
local Enemy = require("enemy")
local Game = require("game")
local Sounds = require("sounds")
local Menu = require("menu")
push = require("libraries/push")
local shop = require("shop") -- Importar la tienda

WINDOW_WIDTH, WINDOW_HEIGHT = love.window.getDesktopDimensions()
WINDOW_WIDTH, WINDOW_HEIGHT = WINDOW_WIDTH * 0.8, WINDOW_HEIGHT * 0.8

VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 640, 360

local currentState = "menu"
local gamePaused = false
local fullscreen = false
local screenWidth, screenHeight = VIRTUAL_WIDTH, VIRTUAL_HEIGHT

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Trigger Rush // Trigger Frenzy")

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = fullscreen,
        vsync = true,
        resizable = true
    })

    love.mouse.setVisible(true)

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
            -- Solo actualizar el juego si la tienda no está activa
            if not shop.active then
                Player.update(dt, gamePaused, screenWidth, screenHeight)
                Enemy.update(dt)
                Game.update(dt)
            end

            -- Actualizar la tienda
            shop.update(dt)

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

        -- Dibujar el dinero del jugador
        love.graphics.setColor(1, 1, 0) -- Amarillo
        local x = love.graphics.getWidth() - 100
        local y = love.graphics.getHeight() - 200
        love.graphics.print("$$$ : ", x, y)
        local textWidth = love.graphics.getFont():getWidth("$$$ : ")
        love.graphics.print(
            shop.getMoney(),
            x + textWidth, y,
            shop.moneyRotation,
            shop.moneyScale, shop.moneyScale
        )
        love.graphics.setColor(1, 1, 1) -- Restaurar a blanco

        -- Dibujar la tienda si está activa
        if shop.active then
            shop.draw()
        end

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
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER", 0, love.graphics.getHeight() / 2 - 40, love.graphics.getWidth(), "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Presiona R para reiniciar", 0, love.graphics.getHeight() / 2 + 20, love.graphics.getWidth(), "center")
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if currentState == "menu" then
            local nextState = Menu.mousepressed(x, y, button)
            if nextState == "play" then
                currentState = "play"
                Enemy.spawn()
            elseif nextState == "options" then
                print("Opciones seleccionadas (no implementado)")
            elseif nextState == "quit" then
                love.event.quit()
            end
        elseif currentState == "play" then
            if not gamePaused then
                local weapon = Player.getCurrentWeapon()
                Player.shoot()
                Enemy.checkClick(x, y, weapon)
            end
        end
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

    if key == "p" and currentState == "play" then
        gamePaused = not gamePaused
    elseif key == "r" and currentState == "gameover" then
        resetGame()
    elseif key == "f" then
        fullscreen = not fullscreen
        push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
            fullscreen = fullscreen,
            resizable = true,
            vsync = true
        })
    end

    -- Manejar la entrada de la tienda
    if shop.active then
        shop.keypressed(key)
    end
end