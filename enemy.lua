anim8 = require "libraries/anim8"

Enemy = {}

Enemy.anchura_enemigo = 75  -- Ancho de cada frame del enemigo (enemigo.png)
Enemy.altura_enemigo = 100   -- Alto de cada frame del enemigo (enemigo.png)
Enemy.enemies = {}
Enemy.spritesheet = nil     -- Imagen del spritesheet del enemigo
Enemy.shootingSpritesheet = nil -- Imagen del spritesheet de disparo
Enemy.deathSpritesheet = nil -- Imagen del spritesheet de la animación de muerte
Enemy.grid = nil            -- Grid del spritesheet del enemigo
Enemy.shootingGrid = nil    -- Grid del spritesheet de disparo
Enemy.deathGrid = nil       -- Grid del spritesheet de la muerte

-- Estados del enemigo
Enemy.STATE_MOVING = "moving"
Enemy.STATE_SHOOTING = "shooting"

-- Cargar los spritesheets y definir las animaciones
function Enemy.load()
    Enemy.spritesheet = love.graphics.newImage("sprites/enemigo.png") -- Spritesheet normal
    Enemy.shootingSpritesheet = love.graphics.newImage("sprites/shooting.png") -- Spritesheet de disparo
    Enemy.deathSpritesheet = love.graphics.newImage("sprites/muerte.png") -- Spritesheet de muerte

    -- Crear el grid para el enemigo (animación normal)
    Enemy.grid = anim8.newGrid(
        Enemy.anchura_enemigo,  -- Ancho de cada frame (enemigo.png)
        Enemy.altura_enemigo,   -- Alto de cada frame (enemigo.png)
        Enemy.spritesheet:getWidth(),
        Enemy.spritesheet:getHeight()
    )

    -- Crear el grid para la animación de disparo (shooting.png)
    -- Ajusta estos valores según las dimensiones de shooting.png
    local shootingFrameWidth = 32  -- Ancho de cada frame en shooting.png
    local shootingFrameHeight = 32 -- Alto de cada frame en shooting.png
    Enemy.shootingGrid = anim8.newGrid(
        shootingFrameWidth,
        shootingFrameHeight,
        Enemy.shootingSpritesheet:getWidth(),
        Enemy.shootingSpritesheet:getHeight()
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
    -- Ajusta los frames según shooting.png
    Enemy.shootingAnimationTemplate = anim8.newAnimation(Enemy.shootingGrid('1-1', 1), 0.1) -- '1-3' significa 3 frames en la fila 1
end

function Enemy.spawn()
    table.insert(Enemy.enemies, {
        x = love.math.random(-50, -250),
        y = 310,
        speed = love.math.random(50, 200),
        stopX = love.math.random(200, 600),
        stopped = false,
        dead = false,
        state = Enemy.STATE_MOVING,  -- Estado inicial
        animation = anim8.newAnimation(Enemy.grid('2-5', 4), 0.1), -- Animación normal (usando enemigo.png)
        shootingAnimation = Enemy.shootingAnimationTemplate:clone(), -- Animación de disparo (usando shooting.png)
        deathAnimation = nil,  -- Animación de muerte específica
        shootCooldown = 2,     -- Tiempo entre disparos
        shootTimer = 0         -- Temporizador para disparar
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
            if enemy.state == Enemy.STATE_MOVING then
                -- Movimiento normal si aún no ha muerto
                if not enemy.stopped then
                    enemy.x = enemy.x + enemy.speed * dt
                    if enemy.x >= enemy.stopX then
                        enemy.stopped = true
                        enemy.state = Enemy.STATE_SHOOTING  -- Cambiar a estado de disparo
                        enemy.animation = enemy.shootingAnimation  -- Cambiar a animación de disparo
                    end
                end
                enemy.animation:update(dt)
            elseif enemy.state == Enemy.STATE_SHOOTING then
                -- Lógica de disparo
                enemy.shootTimer = enemy.shootTimer + dt
                if enemy.shootTimer >= enemy.shootCooldown then
                    enemy.shootTimer = 0
                    Enemy.shoot(enemy)  -- Disparar
                end
                enemy.animation:update(dt)
            end
        end
    end
end

function Enemy.draw()
    for _, enemy in ipairs(Enemy.enemies) do
        if enemy.dead and enemy.deathAnimation then
            -- Escalar y centrar la animación de muerte
            local scale = 1  
            local offsetX = Enemy.anchura_enemigo * ((1 - scale) + 0.3) -- Controla que tan horizontal se muestra la calavera
            local offsetY = Enemy.altura_enemigo * (1 - scale - 0.1) -- Controla que tan vertical se muestra la calavera

            enemy.deathAnimation:draw(
                Enemy.deathSpritesheet,
                enemy.x + offsetX, enemy.y + offsetY,
                0,
                scale, scale
            )
        else
            -- Dibujar la animación normal o de disparo según el estado
            if enemy.state == Enemy.STATE_SHOOTING then
                enemy.animation:draw(Enemy.shootingSpritesheet, enemy.x, (enemy.y+ 55)) -- Usar shooting.png
            else
                enemy.animation:draw(Enemy.spritesheet, enemy.x, enemy.y) -- Usar enemigo.png
            end
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

function Enemy.shoot(enemy)
    -- Crear un proyectil en la posición del enemigo
    local projectile = {
        x = enemy.x + Enemy.anchura_enemigo / 2,  -- Centrar el proyectil en el enemigo
        y = enemy.y + Enemy.altura_enemigo / 2,
        speed = 100,  -- Velocidad del proyectil
        active = true
    }
    -- Aquí podrías agregar el proyectil a una lista de proyectiles para manejarlos
    -- table.insert(Enemy.projectiles, projectile)
    print("Enemigo dispara en x: " .. projectile.x .. ", y: " .. projectile.y)  -- Debug
end

return Enemy