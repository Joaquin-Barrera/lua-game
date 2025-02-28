local Menu = {}

Menu.options = {
    {text = "Jugar", action = "play"},
    {text = "Opciones", action = "options"},
    {text = "Salir", action = "quit"}
}
Menu.selected = nil

function Menu.load()
    Menu.font = love.graphics.newFont(48) -- Tamaño de fuente ajustado para la resolución de la ventana
    Menu.font:setFilter("nearest", "nearest") -- Filtro "nearest" para texto nítido
    Menu.background = love.graphics.newImage("sprites/menubackground.png")
end

function Menu.update(dt)
    -- Obtener la posición del mouse en coordenadas virtuales
    local mouseX, mouseY = push:toGame(love.mouse.getPosition())
    local screenWidth, screenHeight = VIRTUAL_WIDTH, VIRTUAL_HEIGHT -- Usar la resolución virtual
    local buttonWidth, buttonHeight = 200, 50 -- Tamaño de los botones
    local spacing = 10 -- Espaciado entre botones
    local totalHeight = #Menu.options * (buttonHeight + spacing) - spacing
    local startY = (screenHeight - totalHeight) / 2

    Menu.selected = nil
    for i, option in ipairs(Menu.options) do
        local x = (screenWidth - buttonWidth) / 2
        local y = startY + (i - 1) * (buttonHeight + spacing)
        
        if mouseX >= x and mouseX <= x + buttonWidth and mouseY >= y and mouseY <= y + buttonHeight then
            Menu.selected = i
        end
    end
end

function Menu.draw()
    -- Dibujar el fondo y los botones dentro del contexto de push
    push:apply("start")

    -- Dibujar el fondo del menú escalado a la resolución virtual
    local scaleX = VIRTUAL_WIDTH / Menu.background:getWidth()
    local scaleY = VIRTUAL_HEIGHT / Menu.background:getHeight()
    love.graphics.draw(Menu.background, 0, 0, 0, scaleX, scaleY)

    local screenWidth, screenHeight = VIRTUAL_WIDTH, VIRTUAL_HEIGHT -- Usar la resolución virtual
    local buttonWidth, buttonHeight = 200, 50 -- Tamaño de los botones
    local spacing = 10 -- Espaciado entre botones
    local totalHeight = #Menu.options * (buttonHeight + spacing) - spacing
    local startY = (screenHeight - totalHeight) / 2
    
    for i, option in ipairs(Menu.options) do
        local x = (screenWidth - buttonWidth) / 2
        local y = startY + (i - 1) * (buttonHeight + spacing)
        
        if Menu.selected == i then
            love.graphics.setColor(1, 0, 0) -- Color rojo para el botón seleccionado
        else
            love.graphics.setColor(0.5, 0.5, 0.5) -- Color gris para los demás botones
        end
        
        love.graphics.rectangle("fill", x, y, buttonWidth, buttonHeight, 5) -- Botones con esquinas redondeadas
    end

    push:apply("end")

    -- Dibujar el texto fuera del contexto de push (en la resolución de la ventana)
    love.graphics.setFont(Menu.font)
    for i, option in ipairs(Menu.options) do
        local x = (screenWidth - buttonWidth) / 2
        local y = startY + (i - 1) * (buttonHeight + spacing)
        
        -- Convertir coordenadas virtuales a coordenadas de la ventana
        local realX, realY = push:toReal(x, y)
        local realButtonWidth, realButtonHeight = push:toReal(buttonWidth, buttonHeight)

        love.graphics.setColor(1, 1, 1) -- Color blanco para el texto
        local textWidth = Menu.font:getWidth(option.text)
        local textHeight = Menu.font:getHeight()
        love.graphics.print(option.text, realX + (realButtonWidth - textWidth) / 2, realY + (realButtonHeight - textHeight) / 2)
    end
end

function Menu.mousepressed(x, y, button)
    -- Convertir las coordenadas del mouse a coordenadas virtuales
    local virtualX, virtualY = push:toGame(x, y)
    if button == 1 and Menu.selected then
        local action = Menu.options[Menu.selected].action
        if action == "play" then
            return "play"
        elseif action == "options" then
            return "options"
        elseif action == "quit" then
            love.event.quit()
        end
    end
    return nil
end

return Menu