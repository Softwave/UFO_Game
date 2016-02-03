-- Require things
local sti = require "sti"
local utf8 = require("utf8")

require "Ufo"
require "Enemy"
require "helpers"
Timer = require "hump.timer"

-- Variables
local game = {}
statsScore = 0
statsLives = 3
statsLevel = 1
canMoveToNextLevel = true

enemyCount = 0

-- highscore
gameIsOver = false
hasHighScore = false
numOfScores = 0

-- Setup player
player = Ufo:new(512, 256)

-- Map
map = sti.new("maps/map01.lua")

-- Todo
-- Refactor highscore drawing
-- Make enemies respawn? Or some way to keep the game going after u kill them all.

function game:enter()
    -- Create enemies
    self:spawnEnemies()

    -- Clean up the scene every five seconds
    Timer.every(2, function() self:cleanUp() end )
end

function game:update(dt)
    -- Update timers
    Timer.update(dt)

    -- Update map
    map:update(dt)

    -- Update the player
    player:update(dt)
    pUfo:update(dt) 

    --Bullets
    -- Player bullets
    for i,v in ipairs(bullets) do
        -- Move bullets
        v.x = v.x + (v.dx * dt) 
        v.y = v.y + (v.dy * dt)

        -- Add to the player bullets time
        v.bt = v.bt + dt
    end
    -- Enemy Bullets
    for i,v in ipairs(enemyBullets) do
        v.x = v.x + (v.dx * dt) 
        v.y = v.y + (v.dy * dt)

        -- Add to the enemy bullets time
        v.bt = v.bt + dt

        -- Did the player get shot?
        checkPlayerShot = CheckCollision(player.xPos, player.yPos, 32, 32, v.x, v.y, 8, 8)
        if checkPlayerShot then
            if player.alive then
                player:die()
                table.remove(enemyBullets, i)
            end
        end
    end

    -- Update the enemies
    for i,v in ipairs(enemies) do
        v:update(dt)

        -- Count the enemies 
        enemyCount = i - 1

        -- Is an enemy close to the player?
        eDist = math.dist(v.xPos, v.yPos, player.xPos, player.yPos)
        v.playerDist = eDist
        v.playerX = player.xPos
        v.playerY = player.yPos

        -- Did an enemy hit the player?
        checkPlayer = CheckCollision(player.xPos, player.yPos, 32, 32, v.xPos-16, v.yPos, 32, 32)
        if checkPlayer then -- Player is hitting an enemy
            if (player.alive and v.alive) then -- only if both are alive
                -- Todo, fix it so the enemies gibs don't disappear so quickly
                player:die()
                v:die()
            end
        end
        -- Did an enemy hit a player bullet?
        for b,j in ipairs(bullets) do
            checkBullet = CheckCollision(v.xPos, v.yPos, 32, 32, j.x, j.y, 8, 8)
            if v.alive then
                if checkBullet then
                    v:die() -- kill the enemy
                    statsScore = statsScore + 1 -- Add to the score
                    -- table.remove(enemies, i) -- delete the enemy
                    table.remove(bullets, b) -- remove the bullet
                end
            end
        end
    end

    -- Update lives 
    statsLives = player.lives

    -- Update levels
    if canMoveToNextLevel then
        if enemyCount < 2 then
            game:nextLevel()
        end
    end

    
end

function game:draw()
    -- Draw the background image
    --love.graphics.draw(bg, 0, 0)

    -- Follow and center the player
    local tx = math.floor(player.xPos - love.graphics.getWidth() / 2)
    local ty = math.floor(player.yPos - love.graphics.getHeight() / 2)
    if tx < 0 then
        tx = 0
    end
    if tx > 3584 then
        tx = 3584
    end
    --print(tx)
    love.graphics.translate(-tx, 0)

    -- Draw the map
    map:draw()

    -- The player gib emitter
    love.graphics.draw(pUfo, player.xPos+16, player.yPos+16) 

    -- Draw the Bullets
    -- Player bullets
    love.graphics.setColor(255, 255, 255)
    for i,v in ipairs(bullets) do
        love.graphics.rectangle("fill", v.x, v.y, 16, 3)
    end
    -- Enemy bullets
    love.graphics.setColor(190, 38, 51)
    for i,v in ipairs(enemyBullets) do
        love.graphics.rectangle("fill", v.x, v.y, 8, 8)
    end

    love.graphics.setColor(255, 255, 255)
    -- Draw the player
    player:draw()

    -- Draw the enemies
    for i,v in ipairs(enemies) do
        v:draw()
    end


    -- Draw the score and hud
    self:drawScore()

    --fps = love.timer.getFPS( )
    --print(fps)


end

function game:addEnemy(x, y, s, l)
    table.insert(enemies, Enemy:new(x, y, s, l))
    --pEnemy = love.graphics.newParticleSystem(enemyGibs, 32)
    --pEnemy:setParticleLifetime(1, 2)
    --pEnemy:setSpread(2*math.pi)
    --pEnemy:setTangentialAcceleration(200)
    --pEnemy:setSpeed(200)
    --table.insert(pEnemies, pEnemy)
end

function game:drawScore()
    love.graphics.setFont(hudFont)
    -- Make sure the score doesn't go too far left
    scorePosX = player.xPos - love.graphics.getWidth() / 2
    if scorePosX < 0 then
        scorePosX = 0
    end
    if scorePosX > 3584 then
        scorePosX = 3584
    end
    if statsLives > 0 then
        love.graphics.printf("Score: " .. statsScore .. "\nLives: " .. statsLives .. "\nLevel: " .. statsLevel, scorePosX, 20, 512, "left")
    end

    if statsLives <= 0 then
        gameIsOver = true
    end

    if gameIsOver then

        love.graphics.printf("GAME OVER", scorePosX, 20, 512, "center")

        -- Highscores
        love.graphics.printf("HIGHSCORES", scorePosX, 100, 512, "center")
        for i,v in ipairs(highscores) do
            -- Print 10 scores
            if i <= 10 then
                love.graphics.printf(v.name.."    "..v.score, scorePosX, 100+i*20, 512, "center")
            end

            -- if the player is higher than any
            if statsScore > v.score then
                hasHighScore = true
            end

            numOfScores = i

        end

        if numOfScores < 10 then
            hasHighScore = true
        end

        if hasHighScore then
            love.graphics.printf("New highscore: " .. statsScore, scorePosX, 60, love.graphics.getWidth(), "center")
            love.graphics.printf("Name: " .. playerName, scorePosX, 80, love.graphics.getWidth(), "center")
        end

    end

end

function game:spawnEnemies()
    for i, object in pairs(map.objects) do
        randMove = love.math.random(0,1)==1
        randSpeed = love.math.random(0.5, 4.0)

        if (statsLevel % 2 == 0) then
            randSpeed = randSpeed + (statsLevel / 4)
        else
            randSpeed = randSpeed + (statsLevel / 2)
        end
        --randSpeed = love.math.random(0.5 + (statsLevel/4), 4.0 + (statsLevel/4))
        -- randSpeed = randSpeed + (statsLevel / 2)
        self:addEnemy(object.x, object.y, randSpeed, randMove)
    end
    canMoveToNextLevel = true
end

function game:cleanUp()
    --print("cleaning")
    
    -- Delete dead enemies
    for i,v in ipairs(enemies) do
        if not v.alive then
            if v.canBeDeleted then
                table.remove(enemies, i)
            end
        end
    end

    -- Delete old bullets
    for i,v in ipairs(bullets) do
        bDist = math.abs(v.x - player.xPos)
        if (bDist > 512) then
            table.remove(bullets, i)
            --print("removed" .. i)
        end
    end

    -- Delete old enemy bullets
    for i,v in ipairs(enemyBullets) do
        if v.bt > 2.0 then
            table.remove(enemyBullets, i)
        end
    end

end

function game:nextLevel()
    canMoveToNextLevel = false
    enemies = {}
    player:reset()
    self:spawnEnemies()
    statsLevel = statsLevel + 1
end


function love.textinput(t)
    if gameIsOver then
        playerName = playerName .. t
    end
end

function love.keypressed(k)
    if k == 'return' then
        if gameIsOver then

            if hasHighScore then
                table.insert( highscores, {name = playerName, score = statsScore} )
            end


            love.event.quit()
        end
    end

    if k == "backspace" then
        if (gameIsOver and hasHighScore) then
            local byteoffset = utf8.offset(playerName, -1)

            if byteoffset then
                playerName = string.sub(playerName, 1, byteoffset - 1)
            end
        end
    end

    -- Debug
    if k == "r" then
        -- game:nextLevel()
        game:nextLevel()
    end
    if k == "p" then
        print(enemyCount)
    end

end

return game