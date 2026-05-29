local composer = require "composer"
local scene = composer.newScene()
local player = require "player"
local respawnFlag = false
local btnLeft, btnRight, btnJump, btnMenu, sceneGroup, keyDisplay, key, exitDoor, fire, water, spawnpoint
local btnAlpha = 0.6
local env = {}
local gr = {}
local spike = {}
local moveLeft = function(e)player:moveLeft(e)end
local moveRight = function(e)player:moveRight(e)end
local jump = function(e)player:jump(e)end
function onFrame(event)
    if respawnFlag then
        player:respawn()
        respawnFlag = false
    end
    if player.hasKey then
        keyDisplay.alpha = 1
        key.alpha = 0
    else 
        keyDisplay.alpha = 0
        key.alpha = 1
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
    if (event.other.ID == "spike") then
        respawnFlag = true
    end
    if(event.other.ID == "key") then
        player.hasKey = true
    end
    if(event.other.ID == "exit") then
        if player.hasKey then
            advance()
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
    env[5] = display.newRect(display.contentCenterX+120, 260, 40, 40)
    env[6] = display.newRect(display.contentCenterX-30, 190, 60, 40)
    env[7] = display.newRect(display.contentCenterX-245, 150, 120, 40)
    for i=1,#env,1 do
        sceneGroup:insert(env[i])
    end
    groundIds = {1, 5, 6, 7}
    for i=1,#groundIds,1 do
        gr[i] = display.newRect(env[groundIds[i]].x, env[groundIds[i]].y - 
        env[groundIds[i]].height/2, env[groundIds[i]].width-2, 10)
        gr[i].alpha = 1
        gr[i]:setFillColor(0)
        sceneGroup:insert(gr[i])
    end
    spike[1] = display.newRect(display.contentCenterX+80, 270, 40, 20)
    spike[2] = display.newRect(display.contentCenterX+160, 270, 40, 20)
    spike[3] = display.newRect(display.contentCenterX-130, 270, 40, 20)
    for i=1,#spike,1 do
        spike[i]:setFillColor(1,0,0)
        sceneGroup:insert(spike[i])
    end



    key = display.newRect(display.contentCenterX+280, 250, 40, 20)
    key:setFillColor(1,1,0)
    sceneGroup:insert(key)

    exitDoor = display.newCircle(display.contentCenterX-285, 100, 22)
    exitDoor:setFillColor(0)
    sceneGroup:insert(exitDoor)
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
    
    physics.addBody(key, "static", {isSensor = true})
    key.ID = "key"

    physics.addBody(exitDoor, "static", {isSensor = true})
    exitDoor.ID = "exit"
end
function quit()
    composer:gotoScene("mainmenu")
end
function advance()
    composer:gotoScene("mainmenu")
end
function scene:create( event )
    spawnpoint = { x = -20, y = 220}
    sceneGroup = self.view
    display.setDefault("background", 0.5,0.8,1)
    spawnEnv()
    btnLeft = display.newCircle(-20, 260, 40)
    btnLeft.alpha = btnAlpha
    btnRight = display.newCircle(500, 260, 40)
    btnRight.alpha = btnAlpha
    btnJump = display.newRect(display.contentCenterX,285, 400, 45)
    btnJump.alpha = btnAlpha
    btnMenu = display.newCircle(-80, 30, 20)
    btnMenu:setFillColor(0.2)
    keyDisplay = display.newRect(display.contentCenterX*2+80, 40, 30, 60)
    keyDisplay:setFillColor(1,1,0)
    
    sceneGroup:insert(btnLeft)
    sceneGroup:insert(btnRight)
    sceneGroup:insert(btnJump)
    sceneGroup:insert(btnMenu)
    sceneGroup:insert(keyDisplay)
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
        physics.stop()
        btnLeft:removeEventListener("touch", moveLeft)
        btnRight:removeEventListener("touch", moveRight)
        btnJump:removeEventListener("touch", jump)
        btnMenu:removeEventListener("tap", quit)
        player.body:removeEventListener("collision",onCollision)
    end
    if "did" == event.phase then
        composer.removeScene("testlevel")
    end
end
function scene:destroy( event )
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene