local Player = {}
local Weapons = require("weapons") -- Importar el módulo de armas
local push = require("libraries/push") -- Ahora en minúsculas para consistencia

-- Posición real del tanque (ajústala según su ubicación en la pantalla)
Player.x = 0  -- Cambia este valor según la ubicación del tanque
Player.y = 0  -- Ajusta la altura según el terreno
Player.width = 50  -- Ancho del tanque
Player.height = 50  -- Alto del tanque

local baseWidth, baseHeight = 640, 360 -- Resolución base
local scaleX = love.graphics.getWidth() / baseWidth
local scaleY = love.graphics.getHeight() / baseHeight

local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight() 


function Player.reload()
    Weapons.reload(Player.currentWeapon) -- Recargar el arma actual
end

function Player.getPosition()
    return Player.x, Player.y
end

function Player.getSize()
    return Player.width, Player.height
end


function Player.load()
    cursorSprite = love.graphics.newImage("sprites/mira.png")
    cursorSprite:setFilter("nearest", "nearest")

    Weapons.load() -- Cargar las armas
    Player.currentWeapon = Weapons.list.pistol -- Arma inicial
    Player.arma_X = 0
    Player.arma_Y = 0

    -- Fuente para el texto de balas y recarga
    Player.font = love.graphics.newFont(18) -- Tamaño de la fuente

    -- Vida del jugador
    Player.health = 1000
    Player.maxHealth = 1000
end

function Player.update(dt, isPaused)
    -- Solo actualizar si el juego no está pausado
    if not isPaused then
        Player.arma_X, Player.arma_Y = love.mouse.getPosition()
        Player.arma_X = Player.arma_X - Player.currentWeapon.width / 1.8
        Player.arma_Y = Player.arma_Y - Player.currentWeapon.height / 2
        Weapons.update(dt, Player.currentWeapon)
    end
end

function Player.drawHealthBar(x, y)
    local width = 150  -- Ancho de la barra de vida
    local height = 10  -- Alto de la barra de vida

    -- Dibujar la vida faltante (fondo rojo)
    love.graphics.setColor(1, 0, 0)  -- Rojo
    love.graphics.rectangle("fill", x, y, width, height)

    -- Dibujar la vida actual (verde)
    local healthWidth = (Player.health / Player.maxHealth) * width
    love.graphics.setColor(0, 1, 0)  -- Verde
    love.graphics.rectangle("fill", x, y, healthWidth, height)

    -- Restaurar el color predeterminado
    love.graphics.setColor(1, 1, 1)
end


function Player.draw(isPaused)
    -- Dibujar la barra de vida en la posición del jugador
    push:apply("start")
    Player.drawHealthBar(425,240) -- Ajusta la posición relativa
    push:apply("end")
    -- Dibujar el arma
    Weapons.draw(Player.currentWeapon, Player.arma_X, Player.arma_Y)

    -- Dibujar la mira si el juego no está pausado
    if not isPaused then
        local mouseX, mouseY = love.mouse.getPosition()
        local scaleFactor = 0.5
        local cursorWidth = cursorSprite:getWidth() * scaleFactor
        local cursorHeight = cursorSprite:getHeight() * scaleFactor

        love.graphics.draw(cursorSprite, mouseX, mouseY, 0, scaleFactor, scaleFactor, cursorWidth / (scaleFactor * 2), cursorHeight / (scaleFactor * 2))

    end

    -- Dibujar el contador de balas
    love.graphics.setFont(Player.font)
    love.graphics.setColor(1, 1, 1)

    if Player.currentWeapon.isReloading then
        love.graphics.print("Recargando...", 10, 10)
    else
        local bulletsText = Player.currentWeapon.ammo .. "/" .. Player.currentWeapon.magazineSize
        love.graphics.print("Balas: " .. bulletsText, 10, 10)
    end
end


function Player.shoot(isPaused)
    -- Solo disparar si el juego no está pausado
    if not isPaused then
        Weapons.shoot(Player.currentWeapon) -- Disparar el arma actual
    end
end

function Player.switchWeapon(weaponName)
    if Weapons.list[weaponName] then
        Player.currentWeapon = Weapons.list[weaponName] -- Cambiar de arma
        print("Cambiado a: " .. weaponName)
    else
        print("Arma no válida: " .. weaponName)
    end
end

-- Función para obtener el arma actual
function Player.getCurrentWeapon()
    return Player.currentWeapon
end

return Player