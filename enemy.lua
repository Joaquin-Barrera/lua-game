local push = require "libraries/push"
anim8 = require "libraries/anim8"
local Player = require("player")
local Sounds = require("sounds")
local Shop = require ("shop")

Enemy = {}
Enemy.projectiles = {} -- Lista de proyectiles enemigos
Enemy.anchura_enemigo = 1024 / 8  -- 128 píxeles por frame
Enemy.altura_enemigo = 128        -- 128 píxeles de alto
Enemy.enemies = {}
Enemy.spritesheet = nil
Enemy.shootingSpritesheet = nil
Enemy.shooting2Spritesheet = nil
Enemy.deathSpritesheet = nil
Enemy.grid = nil
Enemy.shootingGrid = nil
Enemy.shooting2Grid = nil
Enemy.deathGrid = nil
deadTime = 2

-- Estados del enemigo
Enemy.STATE_MOVING = "moving"
Enemy.STATE_SHOOTING = "shooting"

-- Cargar los spritesheets y definir las animaciones
function Enemy.load()
    Enemy.spritesheet = love.graphics.newImage("sprites/Run.png")
    Enemy.shootingSpritesheet = love.graphics.newImage("sprites/shot_2.png")
    Enemy.shooting2Spritesheet = love.graphics.newImage("sprites/shot_2.png")
    Enemy.deathSpritesheet = love.graphics.newImage("sprites/Dead.png")

    -- Desactivar el suavizado
    Enemy.spritesheet:setFilter("nearest", "nearest")
    Enemy.shootingSpritesheet:setFilter("nearest", "nearest")
    Enemy.shooting2Spritesheet:setFilter("nearest", "nearest")
    Enemy.deathSpritesheet:setFilter("nearest", "nearest")

    Enemy.grid = anim8.newGrid(
        Enemy.anchura_enemigo, 
        Enemy.altura_enemigo, 
        Enemy.spritesheet:getWidth(), 
        Enemy.spritesheet:getHeight()
    )

    local shootingFrameWidth = 128 
    local shootingFrameHeight = 128
    Enemy.shootingGrid = anim8.newGrid(
        shootingFrameWidth,
        shootingFrameHeight,
        Enemy.shootingSpritesheet:getWidth(),
        Enemy.shootingSpritesheet:getHeight()
    )

    local shooting2FrameWidth = 128
    local shooting2FrameHeight = 128
    Enemy.shooting2Grid = anim8.newGrid(
        shooting2FrameWidth,
        shooting2FrameHeight,
        Enemy.shooting2Spritesheet:getWidth(),
        Enemy.shooting2Spritesheet:getHeight()
    )

    Enemy.deathGrid = anim8.newGrid(
        128,
        128,
        Enemy.deathSpritesheet:getWidth(),
        Enemy.deathSpritesheet:getHeight()
    )

    -- Animaciones
    Enemy.deathAnimationTemplate = anim8.newAnimation(Enemy.deathGrid('1-4', 1), 0.1, 'pauseAtEnd')
    Enemy.shootingAnimationTemplate = {
        shooting = anim8.newAnimation(Enemy.shootingGrid('1-1', 1), 0.1)
    }
    Enemy.shooting2AnimationTemplate = anim8.newAnimation(Enemy.shooting2Grid('1-5', 1), 0.01, 'pauseAtEnd') -- Frame 1 al 4
end


function Enemy.spawn()
    local baseHeight = 360  -- La altura base del juego
    local screenHeight = push:getHeight()  -- Altura escalada actual

    table.insert(Enemy.enemies, {
        x = love.math.random(-80, -250),
        y = love.math.random(150, 220), -- Escalar en proporción a la altura
        speed = love.math.random(50, 200),
        stopX = love.math.random(1, 300),
        stopped = false,
        dead = false,
        state = Enemy.STATE_MOVING,
        animation = anim8.newAnimation(Enemy.grid('1-8', 1), 0.1),  -- Inicialización de la animación de movimiento
        shootingAnimation = Enemy.shootingAnimationTemplate.shooting:clone(),  -- Inicializar la animación de disparo
        shooting2Animation = nil,
        deathAnimation = nil,
        shootCooldown = love.math.random(2, 4),
        shootTimer = 0,
        health = 100, --vida del enemigo, cambiar junto con maxhealth
        maxHealth = 100,
        deathStartTime = nil,  -- Variable para el tiempo de inicio de la animación de muerte
        blinkTimer = 2,       -- Duración del parpadeo en segundos
        isBlinking = false     -- Estado de parpadeo
    })
end

function Enemy.drawHealthBar(enemy)
    local x = (enemy.x +30 ) --que tan de lado se dibuja (x)
    local y = enemy.y + 130 --que tan alto se dibuja
    local width = 50 --que tan gorda de ancho es la vida
    local height = 2 --que tan gorda (en altura) es la vida

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x, y, width, height)

    local healthWidth = (enemy.health / enemy.maxHealth) * width
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", x, y, healthWidth, height)

    love.graphics.setColor(1, 1, 1)
end

function Enemy.update(dt)
    if not gamePaused then
        for i = #Enemy.enemies, 1, -1 do
            local enemy = Enemy.enemies[i]

            if enemy.dead then
                if enemy.deathAnimation then
                    enemy.deathAnimation:update(dt)

                    -- Si ha comenzado la animación de muerte, contamos el tiempo para el parpadeo
                    if enemy.deathStartTime == nil then
                        enemy.deathStartTime = love.timer.getTime()
                        enemy.isBlinking = true  -- Activar el parpadeo
                    end

                    -- Si el enemigo está en estado de parpadeo
                    if enemy.isBlinking then
                        enemy.blinkTimer = enemy.blinkTimer - dt
                        if enemy.blinkTimer <= 0 then
                            enemy.isBlinking = false
                            table.remove(Enemy.enemies, i)  -- Eliminar al enemigo después del parpadeo
                        end
                    end
                end
            else
                if enemy.state == Enemy.STATE_MOVING then
                    if not enemy.stopped then
                        enemy.x = enemy.x + enemy.speed * dt
                        if enemy.x >= enemy.stopX then
                            enemy.stopped = true
                            enemy.state = Enemy.STATE_SHOOTING
                            enemy.animation = enemy.shootingAnimation  -- Cambiar a la animación de disparo
                        end
                    end
                    if enemy.animation then
                        enemy.animation:update(dt)
                    end
                elseif enemy.state == Enemy.STATE_SHOOTING then
                    enemy.shootTimer = enemy.shootTimer + dt
                    if enemy.shootTimer >= enemy.shootCooldown then
                        enemy.shootTimer = 0
                        Enemy.shoot(enemy)
                    end
                    if enemy.animation then
                        enemy.animation:update(dt)
                    end

                    if enemy.shooting2Animation then
                        enemy.shooting2Animation:update(dt)
                        if enemy.shooting2Animation.finished then
                            enemy.shooting2Animation = nil
                        end
                    end
                end
            end
        end
    end        
end

function Enemy.shoot(enemy)
    playEnemyShotSound()
    Player.health = Player.health - love.math.random(20,50) --modifica la cantidad de daño que le hace al jugador

    -- Clonar la animación de disparo 2
    enemy.shooting2Animation = Enemy.shooting2AnimationTemplate:clone()
end


function Enemy.draw()
    push:apply("start")
    local scaleX, scaleY = push:getDimensions()
    local baseWidth, baseHeight = 640, 360
    local scaleFactor = math.min(scaleX / baseWidth, scaleY / baseHeight) -- Escalar proporcionalmente

    for _, enemy in ipairs(Enemy.enemies) do
        if not enemy.dead then
            -- Dibujar la sombra antes del enemigo
            local shadowX = enemy.x + (Enemy.anchura_enemigo / 2) - 25  -- Mover la sombra más a la izquierda
            local shadowY = enemy.y + Enemy.altura_enemigo   -- Ajustar la sombra más cerca de los pies
            local shadowWidth = Enemy.anchura_enemigo * 0.5  -- Hacer la sombra más estrecha
            local shadowHeight = 6  -- Reducir la altura de la sombra

            love.graphics.setColor(0, 0, 0, 0.5)  -- Color negro con transparencia
            love.graphics.ellipse("fill", shadowX, shadowY, shadowWidth / 2, shadowHeight)  
            love.graphics.setColor(1, 1, 1)  -- Restaurar color

            -- Dibujar el enemigo
            local drawY = enemy.y * (scaleY / baseHeight) -- Ajustar la altura

            if enemy.state == Enemy.STATE_SHOOTING then
                if enemy.shooting2Animation then
                    enemy.shooting2Animation:draw(Enemy.shooting2Spritesheet, enemy.x, drawY , 0, scaleFactor, scaleFactor)
                elseif enemy.shootingAnimation then
                    enemy.shootingAnimation:draw(Enemy.shootingSpritesheet, enemy.x, drawY, 0, scaleFactor, scaleFactor)
                end
            else
                if enemy.animation then
                    enemy.animation:draw(Enemy.spritesheet, enemy.x, drawY, 0, scaleFactor, scaleFactor)
                end
            end

            Enemy.drawHealthBar(enemy)
        elseif enemy.dead and enemy.deathAnimation then
            -- Parpadeo: alternar la visibilidad del sprite
            if enemy.isBlinking then
                if math.floor(enemy.blinkTimer * 20) % 2 == 0 then
                    local scale = scaleFactor
                    local offsetX = Enemy.anchura_enemigo * (1 - scale )
                    local offsetY = Enemy.altura_enemigo * (1 - scale)

                    enemy.deathAnimation:draw(
                        Enemy.deathSpritesheet,
                        enemy.x + offsetX, enemy.y + offsetY,
                        0,
                        scale, scale
                    )
                end
            else
                -- Dibujar el sprite normalmente si no está parpadeando
                local scale = scaleFactor
                local offsetX = Enemy.anchura_enemigo * ((1 - scale) + 0.3)
                local offsetY = Enemy.altura_enemigo * (1 - scale - 0.1)

                enemy.deathAnimation:draw(
                    Enemy.deathSpritesheet,
                    enemy.x + offsetX, enemy.y + offsetY,
                    0,
                    scale, scale
                )
            end
        end
    end
    push:apply("end")
end




function Enemy.checkClick(x, y, weapon)
    if weapon.isReloading then
        return false
    end

    -- Obtener el tiempo actual
    local currentTime = love.timer.getTime()

    -- Si no ha pasado 1 segundo desde el último disparo, no hacer daño
    if weapon.lastShotTime and (currentTime - weapon.lastShotTime < 0.285) then
        return false
    end

    -- Convertir coordenadas del mouse a la escala original
    local worldX, worldY = push:toGame(x, y)
    if not worldX or not worldY then
        return false
    end

    for i = #Enemy.enemies, 1, -1 do
        local enemy = Enemy.enemies[i]

        if not enemy.dead then
            local enemyLeft = enemy.x + 47
            local enemyRight = (enemy.x - 55) + Enemy.anchura_enemigo
            local enemyTop = enemy.y + 65
            local enemyBottom = enemy.y + Enemy.altura_enemigo

            -- Definir la hitbox de la cabeza (por ejemplo, el 20% superior del enemigo)
            local headTop = enemyTop
            local headBottom = enemyTop + (Enemy.altura_enemigo * 0.095)

            if worldX >= enemyLeft and worldX <= enemyRight then 
                if worldY >= headTop and worldY <= headBottom then
                    -- Headshot: inflige daño en la cabeza
                    local damage = love.math.random(weapon.weaponDamage.headshot[1], weapon.weaponDamage.headshot[2])
                    enemy.health = enemy.health - damage
                elseif worldY >= enemyTop and worldY <= enemyBottom then
                    -- Disparo normal: inflige daño normal
                    local damage = love.math.random(weapon.weaponDamage.normal[1], weapon.weaponDamage.normal[2])
                    enemy.health = enemy.health - damage
                end

                if enemy.health <= 0 then
                    enemy.dead = true
                    enemy.deathAnimation = Enemy.deathAnimationTemplate:clone()
                    local reward = enemy.reward or 1
                    Shop.addMoney(reward)
                end                

                -- Guardar el tiempo del último disparo que hizo daño
                weapon.lastShotTime = currentTime

                return true
            end
        end
    end

    return false
end


function Enemy.clear()
    Enemy.enemies = {}
    Enemy.projectiles = {}
end

return Enemy
