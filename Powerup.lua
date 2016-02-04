-- Powerup class

Timer = require "hump.timer"
require "helpers"

Powerup = {}
function Powerup:new(x, y)
    local powerupData = { xPos = x, yPos = y, alive = true }
    self.__index = self

    return setmetatable(powerupData, self)
end

function Powerup:draw()
    if self.alive then
        love.graphics.draw(powerupSprite, self.xPos, self.yPos)
    end
end

function Powerup:update(dt)

end

function Powerup:die()
    if self.alive then
        self.alive = false
        love.audio.play(sndPowerup)
    end
end