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

local background -- Definir la variable globalmente

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Trigger Rush // Trigger Frenzy")

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = fullscreen,
        vsync = true,
        resizable = true
    })

    love.mouse.setVisible(true)

    -- Cargar la nueva imagen de fondo
    background = love.graphics.newImage("sprites/ciudad.png") -- Asegúrate de que el archivo esté en la ruta correcta

    -- Inicializar módulos
    Game.load()
    Player.load()
    Enemy.load()
    Menu.load()
end

function love.draw()
    push:apply("start")

    -- Calcular la escala para llenar toda la pantalla sin distorsión
    local scaleX = VIRTUAL_WIDTH / background:getWidth()
    local scaleY = VIRTUAL_HEIGHT / background:getHeight()
    local scale = math.max(scaleX, scaleY) -- Ajustar al mayor de los dos valores para evitar espacios vacíos

    -- Centrar la imagen si es más grande que la pantalla virtual
    local offsetX = (VIRTUAL_WIDTH - background:getWidth() * scale) / 2
    local offsetY = (VIRTUAL_HEIGHT - background:getHeight() * scale) / 2

    -- Dibujar la imagen escalada y centrada
    love.graphics.draw(background, offsetX, offsetY, 0, scale, scale)

    -- Dibujar los demás elementos del juego
    if currentState == "menu" then
        Menu.draw()
    elseif currentState == "play" then
        Game.draw()
        Enemy.draw()
        Player.draw(gamePaused)

     -- Dibujar el dinero del jugador
        love.graphics.setColor(1, 1, 0) -- Amarillo
        local moneyFont = love.graphics.newFont(30) -- Crear una nueva fuente con tamaño 48
        love.graphics.setFont(moneyFont) -- Establecer la nueva fuente como activa
        local moneyText = "$$$ : " .. shop.getMoney()
        local x = love.graphics.getWidth() - 150 -- Esquina inferior derecha
        local y = love.graphics.getHeight() - 100 -- Esquina inferior derecha
        love.graphics.print(moneyText, x, y, shop.moneyRotation, shop.moneyScale, shop.moneyScale
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
            love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("PAUSA", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
            love.graphics.printf("Presiona P para reanudar", 0, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH, "center")
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

    push:apply("end")
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