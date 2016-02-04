-- UFO Class

-- Require
Timer = require "hump.timer"
require "helpers"

-- Constructor
Ufo = {}
function Ufo:new(x, y)
 -- Setup object
    local ufoData = { xPos = x, yPos = y, lives = 3, speed = 3, alive = true, canShoot = true, facingRight = true, isInvincible = false, isVisible = true }
    self.__index = self

    return setmetatable(ufoData, self)
end

-- Set Position method
function Ufo:setPos(x, y)
    self.xPos = x
    self.yPos = y
end

-- Draw method
function Ufo:draw()
    -- Only draw player when alive
    if self.alive then
        if self.isVisible then -- Only draw when visible
            love.graphics.draw(ufo, self.xPos, self.yPos)
        end
    end

end

-- Update method
function Ufo:update(dt)
    -- Update the timer
    Timer.update(dt)

    -- Only do if player is alive
    if self.alive then
        -- Up/Down movement
        if (love.keyboard.isDown("up") or joystick:isGamepadDown("dpup")) then
            self.yPos = self.yPos - self.speed
        end
        if (love.keyboard.isDown("down") or joystick:isGamepadDown("dpdown")) then
            self.yPos = self.yPos + self.speed
        end

        -- Left/Right movement
        if (love.keyboard.isDown("left") or joystick:isGamepadDown("dpleft")) then
            self.xPos = self.xPos - self.speed
            self.facingRight = false
        end
        if (love.keyboard.isDown("right") or joystick:isGamepadDown("dpright")) then
            self.xPos = self.xPos + self.speed
            self.facingRight = true
        end

        -- Shoot
        if (love.keyboard.isDown("x") or joystick:isGamepadDown("a")) then
            self:shoot()
        end

        --anyDown = Joystick:isGamepadDown("a")
        --print(anyDown)

    end

    if self.xPos < 0 then
        self.xPos = 4096
    end
    if self.xPos > 4096 then
        self.xPos = 0
    end

    -- Keep from moving too far left
    -- if self.xPos < 256 then
    --     self.xPos = 256
    -- end

end

-- Death method
function Ufo:die()
    -- Only kill the player when u aren't invincible
    if not self.isInvincible then
        self.alive = false
        pUfo:emit(16) -- Emit gibs
        love.audio.play(sndBoom) -- play boom

        -- Take away a life
        self.lives = self.lives - 1

        -- Reset the player after a short delay
        Timer.after(2.0, function() self:reset() end)
    end
end

-- Reset the player after death
function Ufo:reset()
    if self.lives > 0 then

        showResetText = true
        if not self.alive then
            resetText = "New ship..."
        end

        self:setPos(2048, 256)
        self.alive = true
        -- Make player invincible for a short time
        self.isInvincible = true
        -- Play sound
        love.audio.play(sndReset)
        -- Make player flash while they're invincible 
        local t = 0
        Timer.during(3, function(dt)
            t = t + dt
            self.isVisible = (t % .2) < .1
            end, function()
            self.visible = true
            self.isInvincible = false
            showResetText = false
        end)

    end


end

-- Shoot method
function Ufo:shoot()
    if self.canShoot then
        self.canShoot = false
        love.audio.play(sndShoot)
        

        -- Fire the bullet
        local bulletDx = bulletSpeed * math.cos(0) -- Fire in a strait line
        local bulletDy = bulletSpeed * math.sin(0)
        if not self.facingRight then -- If we're not facing right then flip the direction
            bulletDx = bulletDx * -1
            bulletDy = bulletDy * -1
        end
        local bulletTime = 0
        local offX = -32
        if self.facingRight then
            offX = 32
        end
        table.insert(bullets, {x = self.xPos+offX, y = self.yPos+16, dx = bulletDx, dy = bulletDy, bt = bulletTime})

        Timer.after(0.7, function() self.canShoot = true end)
    end
end