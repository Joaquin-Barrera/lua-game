anim8 = require "libraries/anim8"

Enemy = {}

Enemy.anchura_enemigo = 75  -- Ancho de cada frame del spritesheet
Enemy.altura_enemigo = 100   -- Alto de cada frame del spritesheet
Enemy.enemies = {}
Enemy.spritesheet = nil     -- Aquí guardaremos la imagen del spritesheet
Enemy.grid = nil            -- Aquí definiremos la cuadrícula del spritesheet
Enemy.animation = nil       -- Aquí definiremos la animación

-- Cargar el spritesheet y definir la animación
function Enemy.load()
    Enemy.spritesheet = love.graphics.newImage("sprites/enemigo.png")

    -- Crear el grid
    Enemy.grid = anim8.newGrid(
        Enemy.anchura_enemigo,  -- Ancho de cada frame
        Enemy.altura_enemigo,    -- Alto de cada frame
        Enemy.spritesheet:getWidth(),  -- Ancho total del spritesheet
        Enemy.spritesheet:getHeight()  -- Alto total del spritesheet
    )

    -- Crear la animación
    Enemy.animation = anim8.newAnimation(Enemy.grid('2-5', 4), 0.1)

end

function Enemy.spawn()
    table.insert(Enemy.enemies, {
        x = love.math.random(-50,-250),
        y = 310,
        speed = love.math.random(50, 200),
        stopX = love.math.random(200, 600),
        stopped = false,
        animation = anim8.newAnimation(Enemy.grid('2-5', 4), 0.1)

    })
end

function Enemy.update(dt)
    for i = #Enemy.enemies, 1, -1 do
        local enemy = Enemy.enemies[i]
        if not enemy.stopped then
            enemy.x = enemy.x + enemy.speed * dt
            if enemy.x >= enemy.stopX then
                enemy.stopped = true
            end
        end
        -- Actualizar la animación del enemigo
        enemy.animation:update(dt)
    end
end

function Enemy.draw()
    for _, enemy in ipairs(Enemy.enemies) do
        -- Dibujar la animación del enemigo en su posición
        enemy.animation:draw(Enemy.spritesheet, enemy.x, enemy.y)
    end
end

function Enemy.checkClick(x, y)
    for i = #Enemy.enemies, 1, -1 do
        local enemy = Enemy.enemies[i]
        if x >= enemy.x and x <= enemy.x + Enemy.anchura_enemigo and y >= enemy.y and y <= enemy.y + Enemy.altura_enemigo then
            table.remove(Enemy.enemies, i)
            return true
        end
    end
    return false
end

return Enemy