local shotSound = love.audio.newSource("audio/gunshot.mp3", "static")
local shellSound = love.audio.newSource("audio/shell.mp3", "static") -- Nuevo sonido
local reloadSound = love.audio.newSource("audio/reloadpistol.mp3", "static")
local enemyShotSound = love.audio.newSource("audio/enemyshot.mp3", "static")

local shotSoundPool = {} -- Piscina de sonidos para el disparo
local shellSoundPool = {} -- Piscina de sonidos para el casquillo
local reloadSoundPool = {} -- Pool de sonidos para la recarga
local enemyShotSoundPool = {} -- pool para los sonidos del enemigo
local poolSize = 5 -- Cantidad máxima de sonidos en paralelo
local currentShotIndex = 1 -- Índice actual de la piscina de disparos
local currentShellIndex = 1 -- Índice actual de la piscina de casquillos
local currentReloadIndex = 1 --Índice actual de la piscina de recarga
local currentEnemyShotIndex = 1 --Indice actual para los disparos del enemigo

-- Inicializar la piscina de sonidos de disparo
for i = 1, poolSize do
    table.insert(shotSoundPool, shotSound:clone())
end

for i = 1, poolSize do
    table.insert(shellSoundPool, shellSound:clone())
end

for i = 1, poolSize do
    table.insert(reloadSoundPool, reloadSound:clone())
end

for i = 1, poolSize do
    table.insert(enemyShotSoundPool, enemyShotSound:clone())
end

-- Función para reproducir el sonido de disparo
-- Variable global para rastrear el tiempo del último disparo con sonido
lastShotSoundTime = 0  

-- Función para reproducir el sonido de disparo
function playShotSound()
    local currentTime = love.timer.getTime()

    -- Si no ha pasado 0.19 segundos desde el último disparo con sonido, no reproducir 
    if currentTime - lastShotSoundTime < 0.285 then
        return
    end

    local sound = shotSoundPool[currentShotIndex]
    if sound:isPlaying() then
        sound:stop() -- Reinicia si está en uso
    end
    sound:play()

    currentShotIndex = currentShotIndex + 1
    if currentShotIndex > poolSize then
        currentShotIndex = 1 -- Regresar al inicio de la piscina
    end

    -- Guardar el tiempo del último disparo con sonido
    lastShotSoundTime = currentTime
end


-- Función para reproducir el sonido de casquillo
function playshellSound()
    local sound = shellSoundPool[currentShellIndex]
    if sound:isPlaying() then
        sound:stop() -- Reinicia si está en uso
    end
    sound:setVolume(0.3)
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

function playEnemyShotSound()
    local sound = enemyShotSoundPool[currentEnemyShotIndex]
    if sound:isPlaying() then
        sound:stop() -- Reinicia si está en uso
    end
    sound:play()
    
    currentEnemyShotIndex = currentEnemyShotIndex + 1
    if currentEnemyShotIndex > poolSize then
        currentEnemyShotIndex = 1 -- Regresar al inicio de la piscina
    end
end