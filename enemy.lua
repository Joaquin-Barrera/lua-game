anim8 = require "libraries/anim8"

Enemy = {}

Enemy.anchura_enemigo = 75  -- Ancho de cada frame del enemigo
Enemy.altura_enemigo = 100   -- Alto de cada frame del enemigo
Enemy.enemies = {}
Enemy.spritesheet = nil     -- Imagen del spritesheet del enemigo
Enemy.deathSpritesheet = nil -- Imagen del spritesheet de la animación de muerte
Enemy.grid = nil            -- Grid del spritesheet del enemigo
Enemy.deathGrid = nil       -- Grid del spritesheet de la muerte

-- Cargar los spritesheets y definir las animaciones
function Enemy.load()
    Enemy.spritesheet = love.graphics.newImage("sprites/enemigo.png")
    Enemy.deathSpritesheet = love.graphics.newImage("sprites/muerte.png") -- Cargar imagen de muerte

    -- Crear el grid para el enemigo
    Enemy.grid = anim8.newGrid(
        Enemy.anchura_enemigo,
        Enemy.altura_enemigo,
        Enemy.spritesheet:getWidth(),
        Enemy.spritesheet:getHeight()
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
end

function Enemy.spawn()
    table.insert(Enemy.enemies, {
        x = love.math.random(-50,-250),
        y = 310,
        speed = love.math.random(50, 200),
        stopX = love.math.random(200, 600),
        stopped = false,
        dead = false,  -- Nuevo estado
        animation = anim8.newAnimation(Enemy.grid('2-5', 4), 0.1), -- Animación normal
        deathAnimation = nil  -- Animación de muerte específica
    })
end

function Enemy.update(dt)
    for i = #Enemy.enemies, 1, -1 do
        local enemy = Enemy.enemies[i]

        if enemy.dead then
            -- Si está muerto, actualizar la animación de muerte
            if enemy.deathAnimation then
                enemy.deathAnimation:update(dt)
                if enemy.deathAnimation.finished then
                    table.remove(Enemy.enemies, i) -- Eliminar enemigo tras animación
                end
            end
        else
            -- Movimiento normal si aún no ha muerto
            if not enemy.stopped then
                enemy.x = enemy.x + enemy.speed * dt
                if enemy.x >= enemy.stopX then
                    enemy.stopped = true
                end
            end
            enemy.animation:update(dt)
        end
    end
end

function Enemy.draw()
    for _, enemy in ipairs(Enemy.enemies) do
        if enemy.dead and enemy.deathAnimation then
            -- Escalar y centrar la animación de muerte
            local scale = 1  -- Ajusta este valor según necesites
            local offsetX = (Enemy.anchura_enemigo * (1 - scale)) / 0.1
            local offsetY = (Enemy.altura_enemigo * (1 - scale)) / 0.1

            enemy.deathAnimation:draw(
                Enemy.deathSpritesheet,
                enemy.x + offsetX, enemy.y + offsetY,
                0,
                scale, scale
            )
        else
            enemy.animation:draw(Enemy.spritesheet, enemy.x, enemy.y)
        end
    end
end



function Enemy.checkClick(x, y)
    for i = #Enemy.enemies, 1, -1 do
        local enemy = Enemy.enemies[i]
        if not enemy.dead and x >= enemy.x and x <= enemy.x + Enemy.anchura_enemigo and y >= enemy.y and y <= enemy.y + Enemy.altura_enemigo then
            -- Cambiar a animación de muerte
            enemy.dead = true
            enemy.deathAnimation = Enemy.deathAnimationTemplate:clone() -- Clonar animación para que sea independiente
            return true
        end
    end
    return false
end

return Enemy
