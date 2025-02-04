local Player = {}
local Weapons = require("weapons") -- Importar el módulo de armas

-- Posición real del tanque (ajústala según su ubicación en la pantalla)
Player.x = 570  -- Cambia este valor según la ubicación del tanque
Player.y = 350  -- Ajusta la altura según el terreno
Player.width = 50  -- Ancho del tanque
Player.height = 50  -- Alto del tanque


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
    Player.health = 100
    Player.maxHealth = 100
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

function Player.drawHealthBar()
    local x = 100  -- Posición X de la barra de vida
    local y = 450  -- Posición Y de la barra de vida (debajo del texto de balas)
    local width = 200  -- Ancho de la barra de vida
    local height = 20  -- Alto de la barra de vida

    -- Dibujar la vida faltante (fondo rojo)
    love.graphics.setColor(1, 0, 0)  -- Rojo
    love.graphics.rectangle("fill", tankX, tankY, width, height)

    -- Dibujar la vida actual (verde)
    local healthWidth = (Player.health / Player.maxHealth) * width
    love.graphics.setColor(0, 1, 0)  -- Verde
    love.graphics.rectangle("fill", tankX, tankY, healthWidth, height)

    -- Restaurar el color predeterminado
    love.graphics.setColor(1, 1, 1)
end

function Player.draw(isPaused)
    Player.drawHealthBar()
    -- Dibujar el arma siempre, incluso si el juego está pausado
    Weapons.draw(Player.currentWeapon, Player.arma_X, Player.arma_Y)

    -- Dibujar la mira personalizada solo si el juego no está pausado
    if not isPaused then
        local mouseX, mouseY = love.mouse.getPosition()
        local scaleFactor = 0.5
        local cursorWidth = cursorSprite:getWidth() * scaleFactor
        local cursorHeight = cursorSprite:getHeight() * scaleFactor

        love.graphics.draw(cursorSprite, mouseX, mouseY, 0, scaleFactor, scaleFactor, cursorWidth / (scaleFactor * 2), cursorHeight / (scaleFactor * 2))
    end

    -- Dibujar la cantidad de balas o el estado de recarga
    love.graphics.setFont(Player.font) -- Establecer la fuente
    love.graphics.setColor(1, 1, 1) -- Color blanco

    if Player.currentWeapon.isReloading then
        -- Mostrar "Recargando..." mientras el arma está recargando
        love.graphics.print("Recargando...", 10, 10) -- Posición (10, 10)
    else
        -- Mostrar la cantidad de balas (ejemplo: "5/10")
        local bulletsText = Player.currentWeapon.ammo .. "/" .. Player.currentWeapon.magazineSize
        love.graphics.print("Balas: " .. bulletsText, 10, 10) -- Posición (10, 10)
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