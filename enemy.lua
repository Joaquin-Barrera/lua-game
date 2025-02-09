local push = require "libraries/push"
anim8 = require "libraries/anim8"
local Player = require("player")
local Sounds = require("sounds")

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
    Enemy.shooting2AnimationTemplate = anim8.newAnimation(Enemy.shooting2Grid('1-5', 1), 0.1, 'pauseAtEnd') -- Frame 1 al 4
end


function Enemy.spawn()
    local baseHeight = 360  -- La altura base del juego
    local screenHeight = push:getHeight()  -- Altura escalada actual

    table.insert(Enemy.enemies, {
        x = love.math.random(-50, -250),
        y = screenHeight * (220 / baseHeight), -- Escalar en proporción a la altura
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
        health = 3,
        maxHealth = 3,
        deathStartTime = nil  -- Variable para el tiempo de inicio de la animación de muerte
    })
end


function Enemy.drawHealthBar(enemy)
    local x = enemy.x
    local y = enemy.y + 100
    local width = Enemy.anchura_enemigo
    local height = 5

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
                    
                    -- Si ha comenzado la animación de muerte, contamos el tiempo para eliminar al enemigo
                    if enemy.deathStartTime == nil then
                        enemy.deathStartTime = love.timer.getTime()
                    end

                    -- Verificamos si el tiempo de desaparición ha pasado
                    if love.timer.getTime() - enemy.deathStartTime >= deadTime then
                        table.remove(Enemy.enemies, i)  -- Eliminar al enemigo
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
    Player.health = Player.health - 10

    -- Clonar la animación de disparo 2
    enemy.shooting2Animation = Enemy.shooting2AnimationTemplate:clone()
end


function Enemy.draw()
    push:apply("start")
    local scaleX, scaleY = push:getDimensions()
    local baseWidth, baseHeight = 640, 360
    local scaleFactor = math.min(scaleX / baseWidth, scaleY / baseHeight) -- Escalar proporcionalmente

    for _, enemy in ipairs(Enemy.enemies) do
        if enemy.dead and enemy.deathAnimation then
            local scale = scaleFactor
            local offsetX = Enemy.anchura_enemigo * ((1 - scale) + 0.3)
            local offsetY = Enemy.altura_enemigo * (1 - scale - 0.1)

            enemy.deathAnimation:draw(
                Enemy.deathSpritesheet,
                enemy.x + offsetX, enemy.y + offsetY,
                0,
                scale, scale
            )
        else
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
        end
    end
    push:apply("end")
end


function Enemy.checkClick(x, y, weapon)
    if weapon.isReloading then
        return false
    end

    -- Convertir coordenadas del mouse a la escala original
    local worldX, worldY = push:toGame(x, y)
    if not worldX or not worldY then
        return false
    end

    for i = #Enemy.enemies, 1, -1 do
        local enemy = Enemy.enemies[i]
        if not enemy.dead and worldX >= enemy.x and worldX <= enemy.x + Enemy.anchura_enemigo and worldY >= enemy.y and worldY <= enemy.y + Enemy.altura_enemigo then
            enemy.health = enemy.health - 1

            if enemy.health <= 0 then
                enemy.dead = true
                enemy.deathAnimation = Enemy.deathAnimationTemplate:clone()
            end

            return true
        end
    end
    return false
end


function Enemy.clear()
    Enemy.enemies = {}
    Enemy.projectiles = {}
end

return Enemy
