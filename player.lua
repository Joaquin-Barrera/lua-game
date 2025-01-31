local Player = {}
local Weapons = require("weapons") -- Importar el módulo de armas

function Player.load()
    cursorSprite = love.graphics.newImage("sprites/mira.png")
    cursorSprite:setFilter("nearest", "nearest")

    Weapons.load() -- Cargar las armas
    Player.currentWeapon = Weapons.list.pistol -- Arma inicial
    Player.arma_X = 0
    Player.arma_Y = 0
end

function Player.update(dt)
    if not gamePaused then -- Solo actualizar si el juego no está pausado
        Player.arma_X, Player.arma_Y = love.mouse.getPosition()
        Player.arma_X = Player.arma_X - Player.currentWeapon.width / 1.8
        Player.arma_Y = Player.arma_Y - Player.currentWeapon.height / 2
        Weapons.update(dt, Player.currentWeapon)
    end
end

function Player.draw()
    -- Dibujar el arma solo si el juego no está pausado
    if not gamePaused then
        Weapons.draw(Player.currentWeapon, Player.arma_X, Player.arma_Y)
    end

    -- Dibujar el cursor solo si el juego no está pausado
    if not gamePaused then
        local mouseX, mouseY = love.mouse.getPosition()
        local scaleFactor = 0.5
        local cursorWidth = cursorSprite:getWidth() * scaleFactor
        local cursorHeight = cursorSprite:getHeight() * scaleFactor

        love.graphics.draw(cursorSprite, mouseX, mouseY, 0, scaleFactor, scaleFactor, cursorWidth / (scaleFactor * 2), cursorHeight / (scaleFactor * 2))
    end
end


function Player.shoot()
    Weapons.shoot(Player.currentWeapon) -- Disparar el arma actual
end

function Player.switchWeapon(weaponName)
    Player.currentWeapon = Weapons.list[weaponName] -- Cambiar de arma
    
end

return Player