local game = require "states.game"

local menu = {}

function menu:draw()
    love.graphics.setFont(titleFont)
    love.graphics.printf("UFO", 0, 20, 512, "center")
    love.graphics.printf("Press 'x' to play", 0, 480, 512, "center")
end

function menu:keyreleased(key, code)
    if key == 'x' then
        Gamestate.switch(game)
    end
end

return menu