local Weapons = {}

function Weapons.load()
    Weapons.list = {
        pistol = {
            normal = love.graphics.newImage("sprites/pistol1.png"),
            shooting = love.graphics.newImage("sprites/pistol4.png"),
            width = 0,
            height = 0,
            shootDuration = 0.1,
            isShooting = false,
            shootTimer = 0,
            ammo = 12, --municion inicial                               --DEBEN CAMBIARSE 
            magazineSize = 12, --tamaño del cargador                    --AL MISMO TIEMPO
            reloadTime = 1.2, -- Tiempo de recarga en segundos
            isReloading = false,
            reloadTimer = 0
        },
        shotgun = {
            normal = love.graphics.newImage("sprites/shotgun1.png"),
            shooting = love.graphics.newImage("sprites/shotgun4.png"),
            width = 0,
            height = 0,
            shootDuration = 0.1,
            isShooting = false,
            shootTimer = 0,
            ammo = 6,
            magazineSize = 6,
            reloadTime = 2.0,
            isReloading = false,
            reloadTimer = 0
        }
    }-- para añadir más armas, copiar la lógica de las armas anteriores y pegarla aqui, cambiando el nombre y los sprites
     --IMPORTANTE: Tambien modificar main.lua para incluir el cambio de arma

    -- Inicializar dimensiones de las armas
    for _, weapon in pairs(Weapons.list) do
        weapon.width = weapon.normal:getWidth()
        weapon.height = weapon.normal:getHeight()
    end
end

function Weapons.update(dt, weapon)
    if weapon.isReloading then
        weapon.reloadTimer = weapon.reloadTimer - dt
        if weapon.reloadTimer <= 0 then
            weapon.isReloading = false
            weapon.ammo = weapon.magazineSize -- Recargar el cargador
        end
    elseif weapon.isShooting then
        weapon.shootTimer = weapon.shootTimer - dt
        if weapon.shootTimer <= 0 then
            weapon.isShooting = false
        end
    end
end

function Weapons.draw(weapon, x, y)
    local currentSprite = weapon.isShooting and weapon.shooting or weapon.normal
    love.graphics.draw(currentSprite, x, y)
end

function Weapons.shoot(weapon)
    if weapon.isReloading then
        return -- No puede disparar si está recargando
    end
    
    if weapon.ammo > 0 then
        playShotSound()
        playshellSound()
        weapon.isShooting = true
        weapon.shootTimer = weapon.shootDuration
        weapon.ammo = weapon.ammo - 1
        
        if weapon.ammo == 0 then
            Weapons.reload(weapon)
        end
    else
        Weapons.reload(weapon)
    end
end

function Weapons.reload(weapon)
    if not weapon.isReloading then
        weapon.isReloading = true
        weapon.reloadTimer = weapon.reloadTime
        -- Aquí podrías reproducir un sonido de recarga
    end
end

return Weapons
