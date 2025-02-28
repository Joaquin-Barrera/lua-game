local shop = {}

shop.money = 0  -- Dinero inicial
shop.moneyScale = 1  -- Escala del texto
shop.scaleTimer = 0  -- Temporizador para reducir la escala

shop.active = false -- Indica si la tienda está activa
shop.items = {
    {name = "Mejorar arma", cost = 100},
    {name = "Recuperar vida", cost = 50}
}
shop.selectedItem = 1

function shop.addMoney(amount)
    shop.money = shop.money + amount
    shop.moneyScale = 1.2  -- Aumenta el tamaño del texto temporalmente
    shop.scaleTimer = 0.5   -- Duración del efecto de escala (en segundos)
end

function shop.getMoney()
    return shop.money
end

function shop.update(dt)
    if shop.active then
        -- Pausar el juego cuando la tienda está activa
        return
    end

    -- Reducir gradualmente la escala del dinero
    if shop.moneyScale > 1 then
        shop.scaleTimer = shop.scaleTimer - dt
        if shop.scaleTimer <= 0 then
            shop.moneyScale = shop.moneyScale - dt * 2  -- Reducir gradualmente la escala
            if shop.moneyScale < 1 then
                shop.moneyScale = 1
            end
        end
    end
end

function shop.draw()
    if shop.active then
        love.mouse.setVisible(true) -- Mostrar el mouse
        -- Dibujar un fondo semitransparente para la tienda
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 100, 50, 400, 300)
        
        -- Dibujar el título de la tienda
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Tienda", 250, 70)
        
        -- Dibujar los ítems de la tienda
        for i, item in ipairs(shop.items) do
            local text = item.name .. " - " .. item.cost .. "$"
            if i == shop.selectedItem then
                text = "> " .. text .. " <"
            end
            love.graphics.print(text, 150, 120 + (i - 1) * 30)
        end
        
        -- Dibujar instrucciones
        love.graphics.print("Presiona 'Enter' para comprar", 150, 250)
        love.graphics.print("Presiona 'Escape' para salir", 150, 270)
    end
end

function shop.keypressed(key)
    if shop.active then
        if key == "up" then
            shop.selectedItem = math.max(1, shop.selectedItem - 1)
        elseif key == "down" then
            shop.selectedItem = math.min(#shop.items, shop.selectedItem + 1)
        elseif key == "return" then
            local item = shop.items[shop.selectedItem]
            if shop.money >= item.cost then
                shop.money = shop.money - item.cost
                print("Compraste: " .. item.name) -- Aquí podrías agregar efectos reales
            else
                print("No tienes suficiente dinero")
            end
        elseif key == "escape" then
            shop.active = false
        end
    end
end

return shop