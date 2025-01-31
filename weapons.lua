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
            shootTimer = 0
        },
        shotgun = {
            normal = love.graphics.newImage("sprites/shotgun1.png"),
            shooting = love.graphics.newImage("sprites/shotgun4.png"),
            width = 0,
            height = 0,
            shootDuration = 0.1,
            isShooting = false,
            shootTimer = 0
        },
        punch = {
            normal = love.graphics.newImage("sprites/punch1.png"),
            shooting = love.graphics.newImage("sprites/punch3.png"),
            width = 0,
            height = 0,
            shootDuration = 0.1,
            isShooting = false,
            shootTimer = 0
        },
        -- Añade más armas aquí
    }

    -- Inicializar dimensiones de las armas
    for _, weapon in pairs(Weapons.list) do
        weapon.width = weapon.normal:getWidth()
        weapon.height = weapon.normal:getHeight()
    end
end

function Weapons.update(dt, weapon)
    if weapon.isShooting then
        weapon.shootTimer = weapon.shootTimer - dt
        if weapon.shootTimer <= 0 then
            weapon.isShooting = false
            -- Aquí podrías añadir lógica adicional, como reproducir un sonido
        end
    end
end

function Weapons.draw(weapon, x, y)
    local currentSprite = weapon.isShooting and weapon.shooting or weapon.normal
    love.graphics.draw(currentSprite, x, y)
end

function Weapons.shoot(weapon) --lo que pasa cuando el arma dispara
    playShotSound()
    weapon.isShooting = true
    weapon.shootTimer = weapon.shootDuration
end

return Weapons