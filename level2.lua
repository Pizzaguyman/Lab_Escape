local composer = require "composer"
local scene = composer.newScene()
local player = require "player"
local respawnFlag = false
local btnLeft, btnRight, btnJump, btnMenu, sceneGroup, key, exitDoor, spawnpoint, heart, heartCount
local btnAlpha = 0.4
local env = {}
local gr = {}
local spike = {}
local spikeDisplay = {}
local minispike = {}
local moveLeft = function(e)player:moveLeft(e)end
local moveRight = function(e)player:moveRight(e)end
local jump = function(e)player:jump(e)end
audio = require "audio"
local soundTable

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
    if player.hasKey then
        key.alpha = 0
        exitDoor.fill = {type = "image", filename = "assets/images/sewer.png"}
    else 
        key.alpha = 1
        exitDoor.fill = {type = "image", filename = "assets/images/sewer_with_lock.png"}
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
        if(event.other.ID == "key" and not player.hasKey) then
            audio.play(soundTable.key)
            player.hasKey = true
        end
        if(event.other.ID == "exit") then
            if player.hasKey then
                btnLeft:removeEventListener("touch", moveLeft)
                btnRight:removeEventListener("touch", moveRight)
                btnJump:removeEventListener("touch", jump)
                player.body:removeEventListener("collision",onCollision)
                audio.pause(1)
                audio.play(soundTable.victory, {onComplete = function() 
                    audio.resume(1)
                    composer:gotoScene("level3") 
                end})
            end
        end
    end
end
function spawnEnv()
    --пол
    env[1] = display.newRect(display.contentCenterX, 330, 620, 60)
    --потолок
    env[2] = display.newRect(display.contentCenterX, 0, 620, 60)
    --стены
    env[3] = display.newRect(display.contentCenterX-360, display.contentCenterY, 100, 400)
    env[4] = display.newRect(display.contentCenterX+360, display.contentCenterY, 100, 400)
    --препятствия и платформы
    env[5] = display.newRect(display.contentCenterX-300, 220, 20, 20)
    env[6] = display.newRect(display.contentCenterX-230, 160, 20, 20)
    env[7] = display.newRect(display.contentCenterX+50, 160, 540, 40)
    env[8] = display.newRect(display.contentCenterX+25, 120, 90, 40)
    env[9] = display.newRect(display.contentCenterX+250, 120, 120, 40)

    env[10] = display.newRect(display.contentCenterX-200, 275, 40, 50)
    env[11] = display.newRect(display.contentCenterX-80, 275, 40, 50)
    env[12] = display.newRect(display.contentCenterX, 220, 40, 90)
    env[13] = display.newRect(display.contentCenterX+90, 260, 140, 10)
    env[14] = display.newRect(display.contentCenterX+170, 215, 200, 10)
    
    env[15] = display.newRect(display.contentCenterX+220, 260, 20, 80)
    
    for i=1,#env,1 do
        env[i].fill = {type="image", filename="assets/materials/tile_wall.png"}
        env[i].fill.scaleX = 216 / env[i].width / 2
        env[i].fill.scaleY = 156 / env[i].height / 2
        env[i].fill.x = 0
        env[i].fill.y = 0
        sceneGroup:insert(env[i])
    end
    local groundIds = {1, 5, 6, 7, 8, 9, 10, 11, 13, 14}
    for i=1,#groundIds,1 do
        gr[i] = display.newRect(env[groundIds[i]].x, env[groundIds[i]].y - 
        env[groundIds[i]].height/2, env[groundIds[i]].width-2, 10)
        gr[i].alpha = 0
        gr[i]:setFillColor(0,0,1)
        sceneGroup:insert(gr[i])
    end
    spike[1] = display.newRect(display.contentCenterX-120, 290, 40, 20)
    spike[2] = display.newRect(display.contentCenterX-120, 130, 40, 20)
    spike[3] = display.newRect(display.contentCenterX-80, 130, 40, 20)
    spike[4] = display.newRect(display.contentCenterX-40, 130, 40, 20)
    spike[5] = display.newRect(display.contentCenterX+90, 130, 40, 20)
    spike[6] = display.newRect(display.contentCenterX+130, 130, 40, 20)
    spike[7] = display.newRect(display.contentCenterX+170, 130, 40, 20)
    spike[8] = display.newRect(display.contentCenterX+290, 290, 40, 20)
    for i=1,#spike,1 do
        spike[i]:setFillColor(1,0,0)
        spike[i].alpha = 0
        minispike[i] = display.newRect(spike[i].x, spike[i].y-spike[i].height*3/4, 
        spike[i].width/2, spike[i].height/2)
        minispike[i]:setFillColor(1,0,0)
        minispike[i].alpha = 0
        spikeDisplay[i] = display.newRect(spike[i].x, spike[i].y-spike[i].height/2, 
        spike[i].width, spike[i].height*2)
        spikeDisplay[i].fill = {type = "image", filename = "assets/images/spike.png"}
        sceneGroup:insert(spike[i])
        sceneGroup:insert(minispike[i])
        sceneGroup:insert(spikeDisplay[i])
    end

    local keySheetOptions =
    {
        width = 32,
        height = 32,
        numFrames = 24
    }
    local sequenceKey = {
        start = 1,
        count = 24,
        time = 2000,
        loopCount = 0, 
        loopDirection = "forward"
    }
    key = display.newSprite(graphics.newImageSheet( "assets/sprites/key_32x32_24f.png", 
    keySheetOptions ), sequenceKey)
    key.x = display.contentCenterX+280
    key.y = 80
    key:play()
    sceneGroup:insert(key)

    exitDoor = display.newCircle(display.contentCenterX+250, 280, 20)
    exitDoor.fill = {type = "image", filename = "assets/images/sewer_with_lock.png"}
    sceneGroup:insert(exitDoor)
    
    spawnpoint = display.newCircle(spawnpoint.x, spawnpoint.y, 22)
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
        physics.addBody(minispike[i], "static", {isSensor = true})
        minispike[i].ID = "spike"
    end
    
    physics.addBody(key, "static", {isSensor = true})
    key.ID = "key"

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
        victory = audio.loadSound("assets/sounds/victory.wav"),
        key = audio.loadSound("assets/sounds/golden key.wav")
    }
    spawnpoint = { x = -20, y = 260}
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
        btnLeft:removeEventListener("touch", moveLeft)
        btnRight:removeEventListener("touch", moveRight)
        btnJump:removeEventListener("touch", jump)
        btnMenu:removeEventListener("tap", quit)
        player.body:removeEventListener("collision",onCollision)
    end
    if "did" == event.phase then
        composer.removeScene("level2")
    end
end
function scene:destroy( event )
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene