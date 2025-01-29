local Player = {}

function Player.load()
    cursorSprite = love.graphics.newImage("sprites/mira.png")
    cursorSprite:setFilter("nearest", "nearest") -- Evita que la imagen se vea borrosa al escalar

    Player.armaNormal = love.graphics.newImage("sprites/pistol1.png")
    Player.armaDisparando = love.graphics.newImage("sprites/pistol4.png")
    Player.currentArma = Player.armaNormal
    Player.anchura_arma = Player.armaNormal:getWidth()
    Player.altura_arma = Player.armaNormal:getHeight()
    Player.arma_X = 0
    Player.arma_Y = 0
    Player.isShooting = false
    Player.shootDuration = 0.1
    Player.shootTimer = 0
end


function Player.update(dt)
    Player.arma_X, Player.arma_Y = love.mouse.getPosition()
    Player.arma_X = Player.arma_X - Player.anchura_arma / 1.8
    Player.arma_Y = Player.arma_Y - Player.altura_arma / 2

    if Player.isShooting then
        Player.shootTimer = Player.shootTimer - dt 
        if Player.shootTimer <= 0 then
            Player.isShooting = false
            Player.currentArma = Player.armaNormal
            playShotSound()
        end
    end
end

function Player.draw()
    love.graphics.draw(Player.currentArma, Player.arma_X, Player.arma_Y)
    
    local mouseX, mouseY = love.mouse.getPosition()
    local scaleFactor = 0.5 -- Ajusta el tamaño de la mira según necesites
    local cursorWidth = cursorSprite:getWidth() * scaleFactor
    local cursorHeight = cursorSprite:getHeight() * scaleFactor

    -- Dibujar la mira escalada correctamente
    love.graphics.draw(cursorSprite, mouseX, mouseY, 0, scaleFactor, scaleFactor, cursorWidth / (scaleFactor * 2), cursorHeight / (scaleFactor * 2))
end


function Player.shoot()
    Player.currentArma = Player.armaDisparando
    Player.isShooting = true
    Player.shootTimer = Player.shootDuration
end

return Player