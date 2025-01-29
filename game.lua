local Game = {}

Game.round = 1
Game.background = love.graphics.newImage("sprites/desert.jpg")

function Game.update(dt)
    if #Enemy.enemies == 0 then
        Game.round = Game.round + 1
        for i = 1, Game.round do
            Enemy.spawn()
        end
    end
end

function Game.draw()
    love.graphics.draw(Game.background, 0, 0)
    love.graphics.print("Ronda: " .. Game.round, 10, 10)
end

return Game