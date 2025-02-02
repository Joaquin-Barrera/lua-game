local shotSound = love.audio.newSource("audio/gunshot.mp3", "static")
local shellSound = love.audio.newSource("audio/shell.mp3", "static") -- Nuevo sonido
local reloadSound = love.audio.newSource("audio/reloadpistol.mp3", "static")

local shotSoundPool = {} -- Piscina de sonidos para el disparo
local shellSoundPool = {} -- Piscina de sonidos para el casquillo
local reloadSoundPool = {} -- Pool de sonidos para la recarga
local poolSize = 5 -- Cantidad máxima de sonidos en paralelo
local currentShotIndex = 1 -- Índice actual de la piscina de disparos
local currentShellIndex = 1 -- Índice actual de la piscina de casquillos
local currentReloadIndex = 1 --Índice actual de la piscina de recarga

-- Inicializar la piscina de sonidos de disparo
for i = 1, poolSize do
    table.insert(shotSoundPool, shotSound:clone())
end

-- Inicializar la piscina de sonidos de casquillo
for i = 1, poolSize do
    table.insert(shellSoundPool, shellSound:clone())
end

for i = 1, poolSize do
    table.insert(reloadSoundPool, reloadSound:clone())
end

-- Función para reproducir el sonido de disparo
function playShotSound()
    local sound = shotSoundPool[currentShotIndex]
    if sound:isPlaying() then
        sound:stop() -- Reinicia si está en uso
    end
    sound:play()
    
    currentShotIndex = currentShotIndex + 1
    if currentShotIndex > poolSize then
        currentShotIndex = 1 -- Regresar al inicio de la piscina
    end
end

-- Función para reproducir el sonido de casquillo
function playshellSound()
    local sound = shellSoundPool[currentShellIndex]
    if sound:isPlaying() then
        sound:stop() -- Reinicia si está en uso
    end
    sound:play()
    
    currentShellIndex = currentShellIndex + 1
    if currentShellIndex > poolSize then
        currentShellIndex = 1 -- Regresar al inicio de la piscina
    end
end

-- Función para reproducir el sonido de recarga
function playReloadSound()
    local sound = reloadSoundPool[currentReloadIndex]
    if sound:isPlaying() then
        sound:stop() -- Reinicia si está en uso
    end
    sound:play()
    
    currentReloadIndex = currentReloadIndex + 1
    if currentReloadIndex > poolSize then
        currentReloadIndex = 1 -- Regresar al inicio de la piscina
    end
end