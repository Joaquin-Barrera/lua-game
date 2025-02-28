local Game = {}
push = require("libraries/push")
shop = require("shop")
Game.waveCount = 0
Game.wavesPerRound = 3 -- Puedes cambiar esto a 3, 4 o el valor que prefieras (CANTIDAD DE OLEADAS POR RONDA)

Game.round = 1
DefendThis = love.graphics.newImage("sprites/tank.png")
tankX = 2000
tankY = 1050  -- Posición del tanque en relación con el fondo (no con la pantalla virtual)

-- Resolución nativa del juego
Game.baseWidth = 640
Game.baseHeight = 360

-- Calcular factor de escala basado en la altura de la pantalla
local function updateFont()
    local scaleFactor = love.graphics.getHeight() / Game.baseHeight
    Game.font = love.graphics.newFont(math.floor(15 * scaleFactor))
    Game.font:setFilter("nearest", "nearest")
end

-- Inicializar la fuente con el tamaño escalado
updateFont()

-- Cargar el fondo del juego
function Game.load()
    Game.background = love.graphics.newImage("sprites/ciudad.png") -- Fondo de 2980x1771
end

function Game.update(dt)
    if #Enemy.enemies == 0 then
        Game.waveCount = Game.waveCount + 1 -- Aumenta el contador de oleadas
        
        if Game.waveCount >= Game.wavesPerRound then
            Game.round = Game.round + 1
            Game.waveCount = 0 -- Reinicia el contador de oleadas

            -- Activar la tienda al completar una ronda
            shop.active = true
        end

        -- Determinar cuántos enemigos se spawnearán en esta oleada
        local minEnemies = 1 + Game.round  -- Valor mínimo de enemigos, puedes ajustarlo
        local maxEnemies = 3 + Game.round  -- Valor máximo de enemigos, puedes ajustarlo
        local numEnemies = love.math.random(minEnemies, maxEnemies)

        for i = 1, numEnemies do
            Enemy.spawn()
        end
    end
end

function Game.resize(w, h)
    push:resize(w, h)  -- Ajustar push a la nueva resolución
    updateFont()        -- Actualizar el tamaño de la fuente
end

function Game.draw()
    -- IMPORTANTE: NO AFECTAR LOS TEXTOS CON PUSH PORQUE SE VEN BORROSOS SI LO HAGO
    push:apply("start")

    -- Calcular la escala y el desplazamiento del fondo
    local scaleX = Game.baseWidth / Game.background:getWidth()
    local scaleY = Game.baseHeight / Game.background:getHeight()
    local scale = math.max(scaleX, scaleY) -- Escalar el fondo para que ocupe toda la pantalla
    local offsetX = (Game.baseWidth - Game.background:getWidth() * scale) / 2
    local offsetY = (Game.baseHeight - Game.background:getHeight() * scale) / 2

    -- Dibujar el fondo escalado y centrado
    love.graphics.draw(Game.background, offsetX, offsetY, 0, scale, scale)

    -- Dibujar el tanque en la posición correcta (ajustada por el desplazamiento del fondo)
    love.graphics.draw(DefendThis, offsetX + tankX * scale, offsetY + tankY * scale, 0, 0.14, 0.14)

    push:apply("end") -- Termina la escala de push aquí

    -- Dibujar el texto sin afectación de push pero escalado correctamente
    love.graphics.setFont(Game.font)
    love.graphics.setColor(1, 1, 1) -- Color blanco
    
    local scaleFactor = love.graphics.getHeight() / Game.baseHeight
    love.graphics.print("Ronda: " .. Game.round, 10 * scaleFactor, 30 * scaleFactor)
end

return Game