local push = require "libraries/push"
anim8 = require "libraries/anim8"
local Player = require("player")
local Sounds = require("sounds")

Enemy = {}
Enemy.projectiles = {} -- Lista de proyectiles enemigos
Enemy.anchura_enemigo = 75
Enemy.altura_enemigo = 100
Enemy.enemies = {}
Enemy.spritesheet = nil
Enemy.shootingSpritesheet = nil
Enemy.shooting2Spritesheet = nil
Enemy.deathSpritesheet = nil
Enemy.grid = nil
Enemy.shootingGrid = nil
Enemy.shooting2Grid = nil
Enemy.deathGrid = nil

-- Estados del enemigo
Enemy.STATE_MOVING = "moving"
Enemy.STATE_SHOOTING = "shooting"

-- Cargar los spritesheets y definir las animaciones
function Enemy.load()
    Enemy.spritesheet = love.graphics.newImage("sprites/enemigo.png")
    Enemy.shootingSpritesheet = love.graphics.newImage("sprites/enemigooriginal.png")
    Enemy.shooting2Spritesheet = love.graphics.newImage("sprites/shooting2.png")
    Enemy.deathSpritesheet = love.graphics.newImage("sprites/muerte.png")

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

    local shootingFrameWidth = 32
    local shootingFrameHeight = 32
    Enemy.shootingGrid = anim8.newGrid(
        shootingFrameWidth,
        shootingFrameHeight,
        Enemy.shootingSpritesheet:getWidth(),
        Enemy.shootingSpritesheet:getHeight()
    )

    local shooting2FrameWidth = 32
    local shooting2FrameHeight = 32
    Enemy.shooting2Grid = anim8.newGrid(
        shooting2FrameWidth,
        shooting2FrameHeight,
        Enemy.shooting2Spritesheet:getWidth(),
        Enemy.shooting2Spritesheet:getHeight()
    )

    Enemy.deathGrid = anim8.newGrid(
        64,
        64,
        Enemy.deathSpritesheet:getWidth(),
        Enemy.deathSpritesheet:getHeight()
    )

    Enemy.deathAnimationTemplate = anim8.newAnimation(Enemy.deathGrid('1-1', 1), 1, function(anim) anim.finished = true end)
    Enemy.shootingAnimationTemplate = anim8.newAnimation(Enemy.shootingGrid('1-1', 1), 0.1)
    Enemy.shooting2AnimationTemplate = anim8.newAnimation(Enemy.shooting2Grid('1-1', 1), 0.1, function(anim) anim.finished = true end)
end

function Enemy.spawn()
    table.insert(Enemy.enemies, {
        x = love.math.random(-50, -250),
        y = 250,
        speed = love.math.random(50, 200),
        stopX = love.math.random(1, 300),
        stopped = false,
        dead = false,
        state = Enemy.STATE_MOVING,
        animation = anim8.newAnimation(Enemy.grid('2-5', 4), 0.15),
        shootingAnimation = Enemy.shootingAnimationTemplate:clone(),
        shooting2Animation = nil,
        deathAnimation = nil,
        shootCooldown = love.math.random(2, 4),
        shootTimer = 0,
        health = 3,
        maxHealth = 3
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
                    if enemy.deathAnimation.finished then
                        table.remove(Enemy.enemies, i)
                    end
                end
            else
                if enemy.state == Enemy.STATE_MOVING then
                    if not enemy.stopped then
                        enemy.x = enemy.x + enemy.speed * dt
                        if enemy.x >= enemy.stopX then
                            enemy.stopped = true
                            enemy.state = Enemy.STATE_SHOOTING
                            enemy.animation = enemy.shootingAnimation
                        end
                    end
                    enemy.animation:update(dt)
                elseif enemy.state == Enemy.STATE_SHOOTING then
                    enemy.shootTimer = enemy.shootTimer + dt
                    if enemy.shootTimer >= enemy.shootCooldown then
                        enemy.shootTimer = 0
                        Enemy.shoot(enemy)
                    end
                    enemy.animation:update(dt)

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

    enemy.shooting2Animation = Enemy.shooting2AnimationTemplate:clone()
end

function Enemy.draw()
    push:apply("start")  -- Iniciar la escala con push

    -- Determina el factor de escala exacto en función de la resolución
    local scaleX, scaleY = push:getDimensions()
    local scaleFactor = scaleX / 640  -- La resolución base es 640x360, así que escalamos en función de eso

    -- Asegurémonos de que la escala sea un múltiplo entero (por ejemplo, 2x, 3x, etc.)
    if scaleFactor % 1 ~= 0 then
        scaleFactor = math.floor(scaleFactor)  -- Forzamos la escala a ser un valor entero
    end

    for _, enemy in ipairs(Enemy.enemies) do
        if enemy.dead and enemy.deathAnimation then
            local scale = scaleFactor  -- Usamos la escala exacta
            local offsetX = Enemy.anchura_enemigo * ((1 - scale) + 0.3)
            local offsetY = Enemy.altura_enemigo * (1 - scale - 0.1)

            enemy.deathAnimation:draw(
                Enemy.deathSpritesheet,
                enemy.x + offsetX, enemy.y + offsetY,
                0,
                scale, scale
            )
        else
            if enemy.state == Enemy.STATE_SHOOTING then
                if enemy.shooting2Animation then
                    enemy.shooting2Animation:draw(Enemy.shooting2Spritesheet, enemy.x, (enemy.y + 55), 0, scaleFactor, scaleFactor)
                else
                    enemy.animation:draw(Enemy.shootingSpritesheet, enemy.x, (enemy.y + 55), 0, scaleFactor, scaleFactor)
                end
            else
                enemy.animation:draw(Enemy.spritesheet, enemy.x, enemy.y, 0, scaleFactor, scaleFactor)
            end

            Enemy.drawHealthBar(enemy)
        end
    end

    push:apply("end")  -- Finalizar la escala con push
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
