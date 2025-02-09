local Menu = {}

Menu.options = {"Jugar", "Opciones", "Salir"}
Menu.selected = 1


function Menu.load()
    Menu.font = love.graphics.newFont(58)
    Menu.font:setFilter("nearest", "nearest")
end

function Menu.update(dt)
    -- Aquí puedes agregar lógica de actualización si es necesario
end

function Menu.draw()
    love.graphics.setFont(Menu.font)

    -- Obtener la resolución virtual (no la de la ventana física)
    local screenWidth, screenHeight =love.graphics.getWidth(), love.graphics.getHeight()

    -- Obtener la altura de la fuente
    local fontHeight = Menu.font:getHeight()

    -- Definir el espaciado entre opciones (por ejemplo, 1.5 veces la altura de la fuente)
    local spacing = fontHeight * 1.5

    -- Calcular la altura total del menú
    local totalHeight = #Menu.options * spacing

    -- Posición inicial para centrar el menú verticalmente
    local startY = (screenHeight - totalHeight) / 2

    for i, option in ipairs(Menu.options) do
        local textWidth = Menu.font:getWidth(option)
        local x = (screenWidth - textWidth) / 2 -- Centra horizontalmente
        local y = startY + (i - 1) * spacing -- Posición vertical de cada opción

        if i == Menu.selected then
            love.graphics.setColor(1, 0, 0) -- Color rojo para la opción seleccionada
        else
            love.graphics.setColor(1, 1, 1) -- Color blanco para las demás opciones
        end

        love.graphics.print(option, x, y)
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
            return "play"
        elseif Menu.selected == 2 then
            return "options"
        elseif Menu.selected == 3 then
            love.event.quit()
        end
    end
end

return Menu
