local pause = {}

pause.isPaused = false

function pause.toggle()
    pause.isPaused = not pause.isPaused
end

function pause.update(dt)
    if pause.isPaused then
        return -- No actualizar el juego si está pausado
    end
    -- Aquí podrías llamar a otras actualizaciones del juego si es necesario
end

function pause.draw()
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

    -- Definir los textos
    local pauseText = "Pausa"
    local resumeText = "Presiona Enter para continuar"

    -- Obtener dimensiones del texto
    local font = love.graphics.getFont()
    local textWidthPause = font:getWidth(pauseText)
    local textHeightPause = font:getHeight()
    local textWidthResume = font:getWidth(resumeText)
    local textHeightResume = font:getHeight()

    -- Calcular posiciones centradas
    local pauseX = (screenWidth - textWidthPause) / 2
    local pauseY = (screenHeight / 2) - textHeightPause - 20

    local resumeX = (screenWidth - textWidthResume) / 2
    local resumeY = (screenHeight / 2) + 20

    -- Dibujar los textos correctamente centrados
    love.graphics.printf(pauseText, pauseX, pauseY, textWidthPause, "left")
    love.graphics.printf(resumeText, resumeX, resumeY, textWidthResume, "left")
end


return pause
