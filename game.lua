local Game = {}
push = require("libraries/push")

Game.round = 1
DefendThis = love.graphics.newImage("sprites/tank.png")
tankX = 400
tankY = 230  --esto define la posicion en x e y del tanque (lo que hay que defender digamos)

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

function Game.update(dt)
    if #Enemy.enemies == 0 then
        Game.round = Game.round + 1
        for i = 1, Game.round do
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
    love.graphics.draw(Game.background, 0, 0)
    love.graphics.draw(DefendThis, tankX, tankY, 0, 0.14, 0.14) 
    push:apply("end") -- Termina la escala de push aquí

    -- Dibujar el texto sin afectación de push pero escalado correctamente
    love.graphics.setFont(Game.font)
    love.graphics.setColor(1, 1, 1) -- Color blanco
    
    local scaleFactor = love.graphics.getHeight() / Game.baseHeight
    love.graphics.print("Ronda: " .. Game.round, 10 * scaleFactor, 30 * scaleFactor)
end

return Game
