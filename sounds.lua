local shotSound = love.audio.newSource("audio/gunshot.mp3", "static")
local soundPool = {} -- La piscina de sonidos
local poolSize = 5 -- Cantidad máxima de sonidos en paralelo
local currentIndex = 1 -- Índice actual de la piscina

-- Inicializar la piscina de sonidos
for i = 1, poolSize do
    table.insert(soundPool, shotSound:clone())
end

-- Función para reproducir el sonido
function playShotSound()
    local sound = soundPool[currentIndex]
    if sound:isPlaying() then
        sound:stop() -- Reinicia si está en uso
    end
    sound:play()
    
    currentIndex = currentIndex + 1
    if currentIndex > poolSize then
        currentIndex = 1 -- Regresar al inicio de la piscina
    end
end