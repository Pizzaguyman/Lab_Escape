local composer = require "composer"
local scene = composer.newScene()
local player = require "player"
local respawnFlag = false
local btnLeft, btnRight, btnJump, btnMenu, sceneGroup, exitDoor, spawnpoint, heart, heartCount
local btnAlpha = 0.6
local env = {}
local gr = {}
local spike = {}
local spikeDisplay = {}
local spikeWidth = 32
local spikeHeight = 20
local moveLeft = function(e)player:moveLeft(e)end
local moveRight = function(e)player:moveRight(e)end
local jump = function(e)player:jump(e)end
audio = require "audio"
local soundTable
local mainMusicChannel

function onFrame(event)
    if respawnFlag then
        if player.health > 1 then
            audio.play(soundTable.death)
            player:respawn()
            heartCount.text = ": "..player.health
        else
            audio.play(soundTable.death)
            quit()
        end
        respawnFlag = false
    end
end

function onCollision(event)
    if (event.other.ID == "ground") then
        if (event.phase == "began") then
            player.grounded = true
        end
        if (event.phase == "ended") then
            player.grounded = false
        end
    end
    if (event.phase == "began") then
        if (event.other.ID == "spike") then
            respawnFlag = true
        end
        if(event.other.ID == "exit") then
            -- Play victory sound and stop background music
            if soundTable and soundTable.victory then
                btnLeft:removeEventListener("touch", moveLeft)
                btnRight:removeEventListener("touch", moveRight)
                btnJump:removeEventListener("touch", jump)
                player.body:removeEventListener("collision",onCollision)
                audio.pause(1)
                audio.play(soundTable.victory, {onComplete = function() 
                    audio.resume(1)
                    composer:gotoScene("level2") 
                end})
            end
        end
    end
end

function spawnEnv()
    --пол
    env[1] = display.newRect(display.contentCenterX, 330, 620, 60)
    --потолок
    env[2] = display.newRect(display.contentCenterX, 0, 620, 50)
    --стены
    env[3] = display.newRect(display.contentCenterX-360, display.contentCenterY, 100, 400)
    env[4] = display.newRect(display.contentCenterX+360, display.contentCenterY, 100, 400)
    --препятствия и платформы
    env[5] = display.newRect(display.contentCenterX+120, 288, 40, 24)
    env[6] = display.newRect(display.contentCenterX-205, 240, 30, 40)
    env[7] = display.newRect(display.contentCenterX+50, 215, 540, 20)
    env[8] = display.newRect(display.contentCenterX+295, 190, 30, 40)
    env[9] = display.newRect(display.contentCenterX-50, 115, 540, 20)
    
    for i=1,#env,1 do
        env[i].fill = {type="image", filename="assets/materials/tile_wall.png"}
        env[i].fill.scaleX = 216 / env[i].width / 2
        env[i].fill.scaleY = 156 / env[i].height / 2
        env[i].fill.x = 0
        env[i].fill.y = 0
        sceneGroup:insert(env[i])
    end

    gr[1] = display.newRect(display.contentCenterX, 300, 620, 10)
    gr[2] = display.newRect(display.contentCenterX+120, 276, 38, 10)
    gr[3] = display.newRect(display.contentCenterX+50, 205, 538, 10)
    gr[4] = display.newRect(display.contentCenterX+295, 170, 28, 10)
    gr[5] = display.newRect(display.contentCenterX-50, 105, 538, 10)
    for i=1,#gr,1 do
        gr[i].alpha = 0
        gr[i]:setFillColor(0,0,1)
        sceneGroup:insert(gr[i])
    end

    spike[1] = display.newRect(display.contentCenterX+52, 290, spikeWidth, spikeHeight)
    spike[2] = display.newRect(display.contentCenterX+84, 290, spikeWidth, spikeHeight)
    spike[3] = display.newRect(display.contentCenterX+156, 290, spikeWidth, spikeHeight)
    spike[4] = display.newRect(display.contentCenterX-130, 290, spikeWidth, spikeHeight)
    spike[5] = display.newRect(display.contentCenterX+120, 195, spikeWidth, spikeHeight)
    spike[6] = display.newRect(display.contentCenterX+30, 195, spikeWidth, spikeHeight)
    spike[7] = display.newRect(display.contentCenterX-60, 195, spikeWidth, spikeHeight)
    spike[8] = display.newRect(display.contentCenterX-204, 195, spikeWidth, spikeHeight)
    spike[9] = display.newRect(display.contentCenterX, 95, spikeWidth, spikeHeight)
    
    for i=1,#spike,1 do
        spike[i]:setFillColor(1,0,0)
        spike[i].alpha = 0
        spikeDisplay[i] = display.newRect(spike[i].x, spike[i].y-spike[i].height/2, 
        spike[i].width, spike[i].height*2)
        spikeDisplay[i].fill = {type = "image", filename = "assets/images/spike.png"}
        sceneGroup:insert(spike[i])
        sceneGroup:insert(spikeDisplay[i])
    end
    
    exitDoor = display.newCircle(display.contentCenterX+285, 260, 22)
    exitDoor.fill = {type = "image", filename = "assets/images/sewer.png"}
    sceneGroup:insert(exitDoor)

    spawnpoint = display.newCircle(-20, 70, 22)
    spawnpoint.fill = {type = "image", filename = "assets/images/sewer-no-bars.png"}
    sceneGroup:insert(spawnpoint)
end

function initEnvPhysics()
    for i=1,#env,1 do
        physics.addBody(env[i], "static", {bounce = 0})
    end

    for i=1,#gr,1 do
        physics.addBody(gr[i], "static", {isSensor = true})
        gr[i].ID = "ground"
    end

    for i=1,#spike,1 do
        physics.addBody(spike[i], "static", {isSensor = true})
        spike[i].ID = "spike"
    end

    physics.addBody(exitDoor, "static", {isSensor = true})
    exitDoor.ID = "exit"
end

function quit()
    composer:gotoScene("mainmenu")
end

function scene:create( event )
    soundTable = {
        bg = audio.loadStream("assets/music/mainbg.mp3"),
        death = audio.loadSound("assets/sounds/splat.wav"),
        victory = audio.loadSound("assets/sounds/victory.wav")
    }
    spawnpoint = { x = -20, y = 70}
    display.setDefault( "textureWrapX", "repeat" )
    display.setDefault( "textureWrapY", "mirroredRepeat" )
    sceneGroup = self.view
    background = display.newRect(display.contentCenterX, display.contentCenterY, 630, 320)
    background.alpha = 0.9
    background.fill = {type = "image", filename = "assets/images/blurredbg.png"}
    sceneGroup:insert(background)
    spawnEnv()
    btnLeft = display.newCircle(-20, 260, 40)
    btnLeft.alpha = btnAlpha
    btnLeft.fill = {type = "image", filename = "assets/images/leftbtn.png"}
    btnRight = display.newCircle(500, 260, 40)
    btnRight.alpha = btnAlpha
    btnRight.fill = {type = "image", filename = "assets/images/rightbtn.png"}
    btnJump = display.newRect(display.contentCenterX,285, 400, 45)
    btnJump.alpha = btnAlpha
    btnJump.fill = {type = "image", filename = "assets/images/jumpbtn.png"}
    btnMenu = display.newCircle(-80, 30, 20)
    btnMenu.fill = {type = "image", filename = "assets/images/exit.png"}
    heart = display.newRect(display.contentCenterX + 260, 30, 40, 40)
    heart.fill = {type = "image", filename = "assets/images/heart.png"}
    heartCount = display.newText(": 3", display.contentCenterX + 300, 30, native.systemFont, 25)
    sceneGroup:insert(btnLeft)
    sceneGroup:insert(btnRight)
    sceneGroup:insert(btnJump)
    sceneGroup:insert(btnMenu)
    sceneGroup:insert(heart)
    sceneGroup:insert(heartCount)
end

function scene:show( event )
    if (event.phase == "did") then
        physics.start()
        initEnvPhysics()
        player.spawnX = spawnpoint.x
        player.spawnY = spawnpoint.y
        player:spawn(physics)
        btnLeft:addEventListener("touch", moveLeft)
        btnRight:addEventListener("touch", moveRight)
        btnJump:addEventListener("touch", jump)
        btnMenu:addEventListener("tap", quit)
        player.body:addEventListener("collision",onCollision)
        Runtime:addEventListener("enterFrame", onFrame)
        sceneGroup:insert(player.body)
    end
end

function scene:hide( event )
    if "will" == event.phase then
        player:delete()
        btnMenu:removeEventListener("tap", quit)
        player.body:removeEventListener("collision",onCollision)
        Runtime:removeEventListener("enterFrame", onFrame)
    end
    if "did" == event.phase then
        composer.removeScene("level1")
    end
end

function scene:destroy( event )
    -- Clean up audio when destroying scene
    if soundTable then
        if soundTable.bg then audio.dispose(soundTable.bg) end
        if soundTable.death then audio.dispose(soundTable.death) end
        if soundTable.jump then audio.dispose(soundTable.jump) end
        if soundTable.victory then audio.dispose(soundTable.victory) end
        soundTable = nil
    end
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene