local game = require "states.game"

local menu = {}

function menu:draw()
    love.graphics.draw(menuBg, 0, 0)
    love.graphics.setFont(titleFont)
    love.graphics.printf("UFO", 0, 20, 512, "center")
    love.graphics.printf("Press 'x' to play", 0, 480, 512, "center")
end

function menu:update()
    if not joystick then
        if (love.keyboard.isDown("x")) then
            Gamestate.switch(game)
        end
    else
        if (love.keyboard.isDown("x") or joystick:isGamepadDown("a")) then
            Gamestate.switch(game)
        end
    end
end

function menu:keyreleased(key, code)
    if key == 'x' then
        Gamestate.switch(game)
    end
end

return menu