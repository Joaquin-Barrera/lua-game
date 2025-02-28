anim8 = require "libraries/anim8"
local push = require "libraries/push"

local Weapons = {}

function Weapons.load()
    Weapons.list = {
        pistol = {
            spritesheet = love.graphics.newImage("sprites/pistol.png"),
            width = 24320 / 19,  -- Ajustar al tamaño correcto del frame
            height = 720, 
            isShooting = false,
            shootTimer = 0,
            ammo = 12,
            magazineSize = 12,
            reloadTime = 1.2,
            isReloading = false,
            reloadTimer = 0,
            weaponDamage = {normal = {20, 40}, headshot = {30, 50}}
        }
    }

    -- Configurar animaciones de la pistola
    local pistol = Weapons.list.pistol
    pistol.spritesheet:setFilter("nearest", "nearest") -- Evitar desenfoque
    pistol.grid = anim8.newGrid(pistol.width, pistol.height, pistol.spritesheet:getWidth(), pistol.spritesheet:getHeight())

    pistol.animations = {
        idle = anim8.newAnimation(pistol.grid(1, 1), 0.1), -- Frame 1 = normal
        shooting = anim8.newAnimation(pistol.grid("1-19", 1), 0.01) --Animación
    }
    
    pistol.currentAnimation = pistol.animations.idle
end

function Weapons.update(dt, weapon)
    weapon.currentAnimation:update(dt) -- Mantener la animación actualizada

    if weapon.isReloading then
        weapon.reloadTimer = weapon.reloadTimer - dt
        if weapon.reloadTimer <= 0 then
            weapon.isReloading = false
            weapon.ammo = weapon.magazineSize
        end
    elseif weapon.isShooting then
        -- Dejar que la animación maneje el tiempo de disparo
        if weapon.currentAnimation.position == #weapon.animations.shooting.frames then
            weapon.isShooting = false
            weapon.currentAnimation = weapon.animations.idle -- Volver a idle solo cuando termine la animación
        end
    end
end

--BASTANTE MEJOR PERO NECESITA CAMBIOS, MEJORAR HACIENDO QUE NO SIGA LINEALMENTE EL MOUSE
function Weapons.draw(weapon, x, y)
    push:apply("start")
    
    -- Resolución virtual definida en Push
    local virtualWidth = 640  
    local virtualHeight = 360  

    -- Obtener dimensiones de la pantalla
    local screenWidth, screenHeight = push:getDimensions()
    
    -- Escalar la posición para que se ajuste a la pantalla completa
    local scaleX = screenWidth / virtualWidth
    local scaleY = screenHeight / virtualHeight
    local scaleFactor = math.min(scaleX, scaleY)  

    -- Obtener la posición del mouse
    local mouseX, mouseY = love.mouse.getPosition()

    -- Escalar la posición del mouse al espacio virtual
    mouseX = (mouseX / screenWidth) 
    mouseY = (mouseY / screenHeight)

    -- Normalizar posición del mouse en el rango -1 a 1 (centro = 0, izquierda = -1, derecha = 1)
    local normalizedMouseX = (mouseX / (virtualWidth))

    -- Definir el rango de movimiento del arma
    local xMin, xMax = -400, 50
    local yMin, yMax = 0, 100  

    -- Mapear la posición normalizada del mouse al rango de movimiento del arma
    local targetX = xMin + (xMax - xMin) * ((normalizedMouseX + 1) / 2)
    local targetY = mouseY

    -- Aplicar interpolación suavizada
    local lerpFactor = 0.3  
    x = x + (targetX - x) * lerpFactor
    y = y + (targetY - y) * lerpFactor

    -- Aplicar límites
    x = math.max(xMin, math.min(xMax, x))
    y = math.max(yMin, math.min(yMax, y))

    -- Ajustar el tamaño del arma usando scaleFactor
    local weaponScale = scaleFactor * 0.5  

    -- Dibujar el arma con la escala aplicada
    weapon.currentAnimation:draw(weapon.spritesheet, x * scaleFactor, y * scaleFactor, 0, weaponScale, weaponScale)

    push:apply("end")
end





function Weapons.shoot(weapon)
    if weapon.isReloading or weapon.isShooting then return end
    
    if weapon.ammo > 0 then
        playShotSound()
        playshellSound()
        weapon.isShooting = true
        weapon.currentAnimation = weapon.animations.shooting -- Cambiar a animación de disparo
        weapon.currentAnimation:gotoFrame(1) -- Reiniciar animación desde el primer frame
        weapon.currentAnimation:resume() -- Asegurar que se reproduzca de nuevo
        weapon.ammo = weapon.ammo - 1

        if weapon.ammo == 0 then
            Weapons.reload(weapon)
        end
    else
        Weapons.reload(weapon)
    end
end

function Weapons.reload(weapon)
    if weapon.ammo == weapon.magazineSize then return end

    if not weapon.isReloading then
        weapon.isReloading = true
        weapon.reloadTimer = weapon.reloadTime
        playReloadSound()
    end
end

return Weapons
