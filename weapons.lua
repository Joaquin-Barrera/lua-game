anim8 = require "libraries/anim8"
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

--MEJORAR PARA PANTALLA COMPLETA, QUIZAS NECESITO USAR PUSH, VERIFICAR
function Weapons.draw(weapon, x, y)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Limitar X dentro de un rango permitido
    if x > 50 then
        x = 50
    end

    -- Limitar Y dentro de un rango permitido
    if y > 50 then
        y = 50
    end

    -- Dibujar el arma en la posición corregida
    weapon.currentAnimation:draw(weapon.spritesheet, x, y)
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
