local Menu = {}

Menu.options = {
    {text = "Jugar", action = "play"},
    {text = "Opciones", action = "options"},
    {text = "Salir", action = "quit"}
}
Menu.selected = nil

function Menu.load()
    Menu.font = love.graphics.newFont(36)
    Menu.font:setFilter("nearest", "nearest")
    Menu.background = love.graphics.newImage("sprites/menubackground.png")
end

function Menu.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local buttonWidth, buttonHeight = 300, 80
    local spacing = 20
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
    love.graphics.draw(Menu.background, 0, 0, 0, love.graphics.getWidth() / Menu.background:getWidth(), love.graphics.getHeight() / Menu.background:getHeight())
    love.graphics.setFont(Menu.font)
    
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local buttonWidth, buttonHeight = 300, 80
    local spacing = 20
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
        
        love.graphics.rectangle("fill", x, y, buttonWidth, buttonHeight, 10)
        
        love.graphics.setColor(1, 1, 1) -- Color blanco para el texto
        local textWidth = Menu.font:getWidth(option.text)
        local textHeight = Menu.font:getHeight()
        love.graphics.print(option.text, x + (buttonWidth - textWidth) / 2, y + (buttonHeight - textHeight) / 2)
    end
end

function Menu.mousepressed(x, y, button)
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