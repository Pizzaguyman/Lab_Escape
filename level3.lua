local composer = require "composer"
local scene = composer.newScene()
local player = require "player"
local respawnFlag = false
local background, btnLeft, btnRight, btnJump, btnMenu, sceneGroup, exitDoor, water, spawnpoint, onFireDisplay
local btnAlpha = 0.6
local env = {}
local gr = {}
local spike = {}
local spikeDisplay = {}
local minispike = {}
local boxes = {}
local fire = {}
local fireDisplay = {}
local moveLeft = function(e)player:moveLeft(e)end
local moveRight = function(e)player:moveRight(e)end
local jump = function(e)player:jump(e)end
audio = require "audio"
local soundTable
local fireChannel

local function resetBoxes()
    for i=1,#boxes,1 do
        boxes[i].isVisible = true
        boxes[i].isBodyActive = true
    end
end
function onFrame(event)
    if respawnFlag then
        if fireChannel then audio.stop(fireChannel) end
        audio.play(soundTable.death)
        player:respawn()
        resetBoxes()
        respawnFlag = false
    end
    onFireDisplay.x = player.body.x
    onFireDisplay.y = player.body.y-6
    if player.onFire then
        onFireDisplay.alpha = 1
    else
        onFireDisplay.alpha = 0
    end
    
    for i=1,#boxes,1 do
        if boxes[i].toBeDestroyed then
            audio.play(soundTable.boxdeath)
            boxes[i].isVisible = false
            boxes[i].isBodyActive = false
            boxes[i].toBeDestroyed = false
        end
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
        if(event.other.ID == "fire" and not player.onFire) then
            fireChannel = audio.play(soundTable.fire, { loops = -1 })
            player.onFire = true
        end
        if(event.other.ID == "water" and player.onFire) then
            audio.play(soundTable.fizz)
            audio.stop(fireChannel)
            player.onFire = false
        end
        if(event.other.ID == "box" and player.onFire) then
            event.other.toBeDestroyed = true
        end
        if(event.other.ID == "exit") then
            if fireChannel then audio.stop(fireChannel) end
            btnLeft:removeEventListener("touch", moveLeft)
            btnRight:removeEventListener("touch", moveRight)
            btnJump:removeEventListener("touch", jump)
            audio.pause(1)
            audio.play(soundTable.victory, {onComplete = function() 
                audio.resume(1)
                composer:gotoScene("mainmenu") 
            end})
        end
    end
end
function spawnEnv()
    --пол
    env[1] = display.newRect(display.contentCenterX, 300, 610, 40)
    --потолок
    env[2] = display.newRect(display.contentCenterX, 20, 610, 40)
    --стены
    env[3] = display.newRect(display.contentCenterX-355, display.contentCenterY, 100, 400)
    env[4] = display.newRect(display.contentCenterX+355, display.contentCenterY, 100, 400)
    --препятствия и платформы
    env[5] = display.newRect(display.contentCenterX-285, 225, 40, 20)
    env[6] = display.newRect(display.contentCenterX-130, 170, 80, 20)
    env[7] = display.newRect(display.contentCenterX+275, 150, 60, 40)
    env[8] = display.newRect(display.contentCenterX+40, 180, 100, 20)
    env[9] = display.newRect(display.contentCenterX, 150, 20, 40)
    env[10] = display.newRect(display.contentCenterX+80, 150, 20, 40)
    env[11] = display.newRect(display.contentCenterX+160, 60, 20, 40)
    
    for i=1,#env,1 do
        env[i].fill = {type="image", filename="assets/materials/tile_wall.png"}
        env[i].fill.scaleX = 216 / env[i].width / 2
        env[i].fill.scaleY = 156 / env[i].height / 2
        env[i].fill.x = 0
        env[i].fill.y = 0
        sceneGroup:insert(env[i])
    end
    local groundIds = {1, 5, 6, 7, 8, 9, 10}
    for i=1,#groundIds,1 do
        gr[i] = display.newRect(env[groundIds[i]].x, env[groundIds[i]].y - 
        env[groundIds[i]].height/2, env[groundIds[i]].width-2, 10)
        gr[i].alpha = 0
        gr[i]:setFillColor(0, 0, 1)
        sceneGroup:insert(gr[i])
    end

    spike[1] = display.newRect(display.contentCenterX+80, 270, 40, 20)
    spike[2] = display.newRect(display.contentCenterX-160, 270, 40, 20)
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
        sceneGroup:insert(spikeDisplay[i])
    end

    local fireSheetOptions =
    {
        width = 80,
        height = 110,
        numFrames = 4
    }
    local sequenceFire = {
        start = 1,
        count = 4,
        time = 500,
        loopCount = 0, 
        loopDirection = "forward"
    }
    fire[1] = display.newRect(display.contentCenterX-30, 270, 30, 20)
    fire[2] = display.newRect(display.contentCenterX-60, 270, 30, 20)
    for i=1,#fire,1 do
        fireDisplay[i] = display.newSprite(graphics.newImageSheet( "assets/sprites/Fire_filled.png", 
        fireSheetOptions ), sequenceFire)
        fireDisplay[i].x = fire[i].x
        fireDisplay[i].y = fire[i].y-10
        fireDisplay[i]:scale(30/80, 40/110)
        fireDisplay[i]:play()
        fire[i]:setFillColor(1,0.5,0)
        fire[i].alpha = 0
        sceneGroup:insert(fire[i])
        sceneGroup:insert(fireDisplay[i])
    end

    local onFireSheetOptions = 
    {
        width = 320,
        height = 320,
        numFrames = 4
    }
    local sequenceOnFire = {
        start = 1,
        count = 4,
        time = 500,
        loopCount = 0, 
        loopDirection = "forward"
    }
    onFireDisplay = display.newSprite(graphics.newImageSheet( "assets/sprites/OnFire_Spreadsheet.png", 
    onFireSheetOptions ), sequenceOnFire)
    onFireDisplay.x = spawnpoint.x
    onFireDisplay.y = spawnpoint.y
    onFireDisplay:scale(40/320,40/320)
    onFireDisplay:play()
    sceneGroup:insert(onFireDisplay)

    water = display.newRect(display.contentCenterX+40, 153, 60, 34)
    water:setFillColor(0.4,0.4,1)
    water.alpha = 0.8
    sceneGroup:insert(water)

    boxes[1] = display.newRect(display.contentCenterX-110, 110, 40, 100)
    boxes[1].fill = {type = "image", filename = "assets/images/box1.png"}
    boxes[2] = display.newRect(display.contentCenterX+160, 140, 60, 30)
    boxes[2].fill = {type = "image", filename = "assets/images/box2.png"}
    for i=1,#boxes,1 do
        boxes[i].toBeDestroyed = false
        sceneGroup:insert(boxes[i])
    end

    exitDoor = display.newCircle(display.contentCenterX+270, 100, 22)
    exitDoor.fill = {type = "image", filename = "assets/images/sewer.png"}
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

    for i=1,#fire,1 do
        physics.addBody(fire[i], "static", {isSensor = true})
        fire[i].ID = "fire"
    end

    physics.addBody(water, "static", {isSensor = true})
    water.ID = "water"
    
    for i=1,#boxes,1 do
        physics.addBody(boxes[i], "static", {bounce = 0})
        boxes[i].ID = "box"
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
        victory = audio.loadSound("assets/sounds/victory.wav"),
        fire = audio.loadSound("assets/sounds/fire.wav"),
        boxdeath = audio.loadSound("assets/sounds/fire_destroy.wav"),
        fizz = audio.loadSound("assets/sounds/fizz.wav")
    }
    spawnpoint = {x = 500, y = 240}
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
    btnMenu:setFillColor(0.2)
    sceneGroup:insert(btnLeft)
    sceneGroup:insert(btnRight)
    sceneGroup:insert(btnJump)
    sceneGroup:insert(btnMenu)
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
        if fireChannel then audio.stop(fireChannel) end
        player:delete()
        btnLeft:removeEventListener("touch", moveLeft)
        btnRight:removeEventListener("touch", moveRight)
        btnJump:removeEventListener("touch", jump)
        btnMenu:removeEventListener("tap", quit)
        player.body:removeEventListener("collision",onCollision)
        Runtime:removeEventListener("enterFrame", onFrame)
    end
    if "did" == event.phase then
        composer.removeScene("level3")
    end
end
function scene:destroy( event )
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene