-- Enemy Class

-- Require 
Timer = require "hump.timer"
require "helpers"
require "Powerup"

-- Constructor
Enemy = {}
function Enemy:new(x, y, s, l)
    pEnemy = love.graphics.newParticleSystem(enemyGibs, 32)
    pEnemy:setParticleLifetime(2, 2)
    pEnemy:setSpread(2*math.pi)
    pEnemy:setSizes(3, 2, 1)
    --pEnemy:setTangentialAcceleration(200)
    pEnemy:setLinearAcceleration(10, 300, 20, 300)
    pEnemy:setSpeed(200)

    -- Setup object
    local enemyData = { xPos = x, yPos = y, speed = s, facingLeft = l, alive = true, canShoot = true, eGibs = pEnemy, playerDist = 0, playerX = 0, playerY = 0, canBeDeleted = false, canDropPowerup = false }
    self.__index = self

    return setmetatable(enemyData, self)
end

-- Draw method
function Enemy:draw()
    flip = 1
    if self.facingLeft then
        flip = 1
    else
        flip = -1
    end

    -- Only draw if alive
    if self.alive then
        love.graphics.draw(enemy, self.xPos, self.yPos, 0, flip, 1)
    end

    love.graphics.draw(self.eGibs, self.xPos+16, self.yPos+16)
end

-- Update method
function Enemy:update(dt)
    -- Update dead enemy gibs
    self.eGibs:update(dt)

    -- Move the enemy
    spd = self.speed
    if not self.facingLeft then
        spd = self.speed * - 1
    end
    self.xPos = self.xPos - spd 

    -- Wrap around screen
    if self.xPos < -32 then
        self.xPos = 4096
    end
    if self.xPos > 4096 then
        self.xPos = 0
    end

    -- If in range of the player
    if self.playerDist < 150 then
        self:shoot()
    end

end

-- Death method
function Enemy:die()
    if self.alive then
        self.canShoot = false
        self.eGibs:emit(32)
        self.alive = false
        love.audio.play(sndBoom)

        -- Powerup
        if self.canDropPowerup then
            randNum = love.math.random(10)
            --print(randNum)
            if randNum == 7 then
                local startX = self.xPos + 16
                local startY = self.yPos + 16
                table.insert(powerups, Powerup:new(startX, startY))
            end
        end

        Timer.after(2, function() self:canDelete() end)
    end
end

--
function Enemy:canDelete()
    self.canBeDeleted = true
end

-- Shoot at the player
function Enemy:shoot()
    if self.canShoot then
        self.canShoot = false
        love.audio.play(sndShoot)

        -- Fire the bullet
        local startX = self.xPos + 16
        local startY = self.yPos + 16
        local angle = math.atan2((self.playerY - startY), (self.playerX - startX))
        local bulletDx = enemyBulletSpeed * math.cos(angle)
        local bulletDy = enemyBulletSpeed * math.sin(angle)
        local bulletTime = 0
        table.insert(enemyBullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy, bt = bulletTime})

        Timer.after(2, function() if self.alive then self.canShoot = true end end)
    end
end