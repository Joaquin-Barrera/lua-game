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
    if pause.isPaused then
        love.graphics.setColor(0, 0, 0, 0.5) -- Fondo semitransparente
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1) -- Color del texto
        love.graphics.printf("PAUSA", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
        love.graphics.printf("Presiona P para reanudar", 0, love.graphics.getHeight() / 2 + 20, love.graphics.getWidth(), "center")
    end
end

return pause