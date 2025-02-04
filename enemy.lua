anim8 = require "libraries/anim8"
local Player = require("player")
local Sounds = require("sounds")

Enemy = {}
Enemy.projectiles = {} -- Lista de proyectiles enemigos

Enemy.anchura_enemigo = 75  -- Ancho de cada frame del enemigo (enemigo.png)
Enemy.altura_enemigo = 100   -- Alto de cada frame del enemigo (enemigo.png)
Enemy.enemies = {}
Enemy.spritesheet = nil     -- Imagen del spritesheet del enemigo
Enemy.shootingSpritesheet = nil -- Imagen del spritesheet de disparo
Enemy.shooting2Spritesheet = nil -- Imagen del destello de luz al disparar
Enemy.deathSpritesheet = nil -- Imagen del spritesheet de la animación de muerte
Enemy.grid = nil            -- Grid del spritesheet del enemigo
Enemy.shootingGrid = nil    -- Grid del spritesheet de disparo
Enemy.shooting2Grid = nil   -- Grid del destello de luz al disparar
Enemy.deathGrid = nil       -- Grid del spritesheet de la muerte

-- Estados del enemigo
Enemy.STATE_MOVING = "moving"
Enemy.STATE_SHOOTING = "shooting"

-- Cargar los spritesheets y definir las animaciones
function Enemy.load()
    Enemy.spritesheet = love.graphics.newImage("sprites/enemigo.png") -- Spritesheet normal
    Enemy.shootingSpritesheet = love.graphics.newImage("sprites/shooting.png") -- Spritesheet de disparo
    Enemy.shooting2Spritesheet = love.graphics.newImage("sprites/shooting2.png") -- Destello de luz al disparar
    Enemy.deathSpritesheet = love.graphics.newImage("sprites/muerte.png") -- Spritesheet de muerte

    -- Crear el grid para el enemigo (animación normal)
    Enemy.grid = anim8.newGrid(
        Enemy.anchura_enemigo,  -- Ancho de cada frame (enemigo.png)
        Enemy.altura_enemigo,   -- Alto de cada frame (enemigo.png)
        Enemy.spritesheet:getWidth(),
        Enemy.spritesheet:getHeight()
    )

    -- Crear el grid para la animación de disparo (shooting.png)
    local shootingFrameWidth = 32  -- Ancho de cada frame en shooting.png
    local shootingFrameHeight = 32 -- Alto de cada frame en shooting.png
    Enemy.shootingGrid = anim8.newGrid(
        shootingFrameWidth,
        shootingFrameHeight,
        Enemy.shootingSpritesheet:getWidth(),
        Enemy.shootingSpritesheet:getHeight()
    )

    -- Crear el grid para el destello de luz al disparar (shooting2.png)
    local shooting2FrameWidth = 32  -- Ancho de cada frame en shooting2.png
    local shooting2FrameHeight = 32 -- Alto de cada frame en shooting2.png
    Enemy.shooting2Grid = anim8.newGrid(
        shooting2FrameWidth,
        shooting2FrameHeight,
        Enemy.shooting2Spritesheet:getWidth(),
        Enemy.shooting2Spritesheet:getHeight()
    )

    -- Crear el grid para la animación de muerte (ajustar tamaño según muerte.png)
    Enemy.deathGrid = anim8.newGrid(
        32, -- Ancho de cada frame de la animación de muerte
        32, -- Alto de cada frame de la animación de muerte
        Enemy.deathSpritesheet:getWidth(),
        Enemy.deathSpritesheet:getHeight()
    )

    -- Animación de muerte (asumiendo que muerte.png tiene 4 frames en una fila)
    Enemy.deathAnimationTemplate = anim8.newAnimation(Enemy.deathGrid('1-1', 1), 1, function(anim) anim.finished = true end)

    -- Animación de disparo (usando shooting.png)
    Enemy.shootingAnimationTemplate = anim8.newAnimation(Enemy.shootingGrid('1-1', 1), 0.1)

    -- Animación del destello de luz al disparar (usando shooting2.png)
    Enemy.shooting2AnimationTemplate = anim8.newAnimation(Enemy.shooting2Grid('1-1', 1), 0.1, function(anim) anim.finished = true end)
end

function Enemy.spawn()
    table.insert(Enemy.enemies, {
        x = love.math.random(-50, -250),
        y = 310,
        speed = love.math.random(50, 200),
        stopX = love.math.random(1, 300),
        stopped = false,
        dead = false,
        state = Enemy.STATE_MOVING,  -- Estado inicial
        animation = anim8.newAnimation(Enemy.grid('2-5', 4), 0.15), -- Animación normal (usando enemigo.png)
        shootingAnimation = Enemy.shootingAnimationTemplate:clone(), -- Animación de disparo (usando shooting.png)
        shooting2Animation = nil, -- Animación del destello de luz al disparar
        deathAnimation = nil,  -- Animación de muerte específica
        shootCooldown = love.math.random(2, 4),     -- Tiempo entre disparos
        shootTimer = 0,        -- Temporizador para disparar
        health = 3,            -- Vida del enemigo (aguanta 2 disparos, muere al tercero)
        maxHealth = 3          -- Vida máxima del enemigo
    })
end

function Enemy.drawHealthBar(enemy)
    local x = enemy.x  -- Posición X de la barra de vida (encima del enemigo)
    local y = enemy.y + 100  -- Posición Y de la barra de vida
    local width = Enemy.anchura_enemigo  -- Ancho de la barra de vida
    local height = 5  -- Alto de la barra de vida

    -- Dibujar la vida faltante (fondo rojo)
    love.graphics.setColor(1, 0, 0)  -- Rojo
    love.graphics.rectangle("fill", x, y, width, height)

    -- Dibujar la vida actual (verde)
    local healthWidth = (enemy.health / enemy.maxHealth) * width
    love.graphics.setColor(0, 1, 0)  -- Verde
    love.graphics.rectangle("fill", x, y, healthWidth, height)

    -- Restaurar el color predeterminado
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

                    -- Actualizar la animación del destello de luz si está activa
                    if enemy.shooting2Animation then
                        enemy.shooting2Animation:update(dt)
                        if enemy.shooting2Animation.finished then
                            enemy.shooting2Animation = nil -- Eliminar la animación cuando termine
                        end
                    end
                end
            end
        end
    end        
end

function Enemy.shoot(enemy)
    playEnemyShotSound() --sonido de disparoo
    -- Aplicar daño directamente al jugador
    Player.health = Player.health - 10  -- Ajusta el daño según sea necesario

    -- Iniciar la animación del destello de luz
    enemy.shooting2Animation = Enemy.shooting2AnimationTemplate:clone()
end

function Enemy.draw()
    for _, enemy in ipairs(Enemy.enemies) do
        if enemy.dead and enemy.deathAnimation then
            local scale = 1  
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
                -- Dibujar el destello de luz si está activo
                if enemy.shooting2Animation then
                    enemy.shooting2Animation:draw(Enemy.shooting2Spritesheet, enemy.x, (enemy.y+ 55))
                else
                    -- Dibujar la animación de disparo normal
                    enemy.animation:draw(Enemy.shootingSpritesheet, enemy.x, (enemy.y + 55))
                end
            else
                -- Dibujar la animación normal
                enemy.animation:draw(Enemy.spritesheet, enemy.x, enemy.y)
            end

            Enemy.drawHealthBar(enemy)
        end
    end
end

function Enemy.checkClick(x, y, weapon)
    -- Verificar si el arma está recargando
    if weapon.isReloading then
        return false
    end

    for i = #Enemy.enemies, 1, -1 do
        local enemy = Enemy.enemies[i]
        if not enemy.dead and x >= enemy.x and x <= enemy.x + Enemy.anchura_enemigo and y >= enemy.y and y <= enemy.y + Enemy.altura_enemigo then
            -- Reducir la vida del enemigo
            enemy.health = enemy.health - 1

            -- Verificar si el enemigo murió
            if enemy.health <= 0 then
                enemy.dead = true
                enemy.deathAnimation = Enemy.deathAnimationTemplate:clone() -- Clonar animación para que sea independiente
            end

            return true
        end
    end
    return false
end

function Enemy.clear()
    -- Eliminar todos los enemigos
    Enemy.enemies = {}

    -- Eliminar todos los proyectiles
    Enemy.projectiles = {}
end

return Enemy