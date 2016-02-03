-- Require things
Gamestate = require "hump.gamestate"
local game = require "states.game"
local menu = require "states.menu"
local sti = require "sti"
require "Tserial"

-- Global things
titleFont = love.graphics.newFont("data/C64.ttf", 24)
hudFont = love.graphics.newFont("data/C64.ttf", 16)

saveFile = love.filesystem.newFile("highscores.sav")
data = ''
highscores = {}
playerName = ""
saveFile:open("r")

function love.load()
    -- Backgrounds
    bg = love.graphics.newImage("images/bg.png")

    -- Sprites
    ufo = love.graphics.newImage("images/ufo.png")
    enemy = love.graphics.newImage("images/enemy.png")
    ufoGibs = love.graphics.newImage("images/ufoGibs.png")
    enemyGibs = love.graphics.newImage("images/enemyGibs.png")

    -- Sounds
    sndBoom = love.audio.newSource("sounds/sndBoom.wav", "static")
    sndShoot = love.audio.newSource("sounds/sndShoot.ogg", "static")
    sndReset = love.audio.newSource("sounds/sndReset.wav", "static")

    -- Bullets
    bullets = {}
    bulletSpeed = 800
    enemyBullets = {}
    enemyBulletSpeed = 120
    --table.insert(bullets, {x = 256, y = 256, dx = 100, dy = 100})

    -- Enemies
    enemies = {}

    -- Maps
    --map = sti:new("maps/map01.lua")
    --map:init()

    -- Particle Systems
    pUfo = love.graphics.newParticleSystem(ufoGibs, 32)
    pUfo:setParticleLifetime(4, 4) -- Particles live at least 2s and at most 5s.
    pUfo:setSpread(2*math.pi) -- Explode in all directions
    pUfo:setTangentialAcceleration(200)
    pUfo:setSpeed(200)
    --pUfo:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
    
    pEnemies = {}
    -- pEnemy = love.graphics.newParticleSystem(enemyGibs, 32)
    -- pEnemy:setParticleLifetime(1, 2)
    -- pEnemy:setSpread(2*math.pi)
    -- pEnemy:setTangentialAcceleration(200)
    -- pEnemy:setSpeed(200)

    -- Highscores
    data = saveFile:read()
    saveFile:close()
    if data then
        highscores = Tserial.unpack(data)
    end
    --table.insert( highscores, {name = "name",score = 100 + love.math.random(1,100)} )
    function sort(a,b)
       return a.score > b.score -- sorts it by high score
    end
    table.sort(highscores,sort)

    -- Test sprites and objects
    test = love.graphics.newImage("images/test.png")

    -- States
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

function love.quit() -- will save on quit. Do not return true ever unless you know what you are doing!!!!! lol
   saveFile:open('w') -- open for writing
   saveFile:write(Tserial.pack(highscores))
   saveFile:close()
end
