local shop = {}

shop.money = 0  -- Dinero inicial
shop.moneyScale = 1  -- Escala del texto
shop.scaleTimer = 0  -- Temporizador para reducir la escala
shop.moneyRotation = 0  -- Ángulo de rotación del texto
shop.rotationDirection = 10  -- Dirección de la rotación (1 para adelante, -1 para atrás)
shop.rotationSpeed = 1  -- Velocidad de la rotación (en radianes por segundo)
shop.rotationRange = 0.1  -- Rango máximo de rotación (en radianes)
shop.danceTimer = 0  -- Temporizador para el baile (0 significa que no está bailando)

function shop.addMoney(amount)
    shop.money = shop.money + amount
    shop.moneyScale = 1.2  -- Aumenta el tamaño del texto temporalmente
    shop.scaleTimer = 0.5   -- Duración del efecto de escala (en segundos)
    shop.danceTimer = 1.5   -- Activar el baile por 1 segundo
end

function shop.getMoney()
    return shop.money
end

function shop.update(dt)
    -- Actualizar la escala del texto
    if shop.moneyScale > 1 then
        shop.scaleTimer = shop.scaleTimer - dt
        if shop.scaleTimer <= 0 then
            shop.moneyScale = shop.moneyScale - dt * 2  -- Reducir gradualmente la escala
            if shop.moneyScale < 1 then
                shop.moneyScale = 1  -- Asegurar que no se haga más pequeño de lo normal
            end
        end
    end

    -- Actualizar el baile solo si el temporizador es mayor que 0
    if shop.danceTimer > 0 then
        shop.danceTimer = shop.danceTimer - dt

        -- Actualizar la rotación del texto
        shop.moneyRotation = shop.moneyRotation + shop.rotationDirection * shop.rotationSpeed * dt

        -- Cambiar la dirección de la rotación si se alcanza el rango máximo
        if shop.moneyRotation > shop.rotationRange then
            shop.moneyRotation = shop.rotationRange
            shop.rotationDirection = -1
        elseif shop.moneyRotation < -shop.rotationRange then
            shop.moneyRotation = -shop.rotationRange
            shop.rotationDirection = 1
        end
    else
        -- Desactivar el baile cuando el temporizador llegue a 0
        shop.moneyRotation = 0
    end
end

return shop