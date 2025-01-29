local Menu = {}

Menu.options = {"Jugar", "Opciones", "Salir"}
Menu.selected = 1

function Menu.load()
    -- Fuente para el menú
    Menu.font = love.graphics.newFont(24)
end

function Menu.update(dt)
    -- Aquí puedes agregar lógica de actualización si es necesario
end

function Menu.draw()
    -- Configurar la fuente
    love.graphics.setFont(Menu.font)

    -- Dibujar las opciones del menú
    for i, option in ipairs(Menu.options) do
        local y = 200 + i * 50
        if i == Menu.selected then
            love.graphics.setColor(1, 0, 0) -- Color rojo para la opción seleccionada
        else
            love.graphics.setColor(1, 1, 1) -- Color blanco para las otras opciones
        end
        love.graphics.print(option, 400, y)
    end
end

function Menu.keypressed(key)
    if key == "up" then
        Menu.selected = Menu.selected - 1
        if Menu.selected < 1 then
            Menu.selected = #Menu.options
        end
    elseif key == "down" then
        Menu.selected = Menu.selected + 1
        if Menu.selected > #Menu.options then
            Menu.selected = 1
        end
    elseif key == "return" then
        if Menu.selected == 1 then
            -- Cambiar al estado de juego
            return "play"
        elseif Menu.selected == 2 then
            -- Cambiar al estado de opciones (por ahora no hace nada)
            return "options"
        elseif Menu.selected == 3 then
            -- Salir del juego
            love.event.quit()
        end
    end
end

return Menu