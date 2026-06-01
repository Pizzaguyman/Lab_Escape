local composer = require "composer"
local scene = composer.newScene()
local background
physics = require "physics"
audio = require "audio"
local soundTable
mainMusicChannel = audio.play(audio.loadStream("assets/music/mainbg.mp3"), { loops = -1 })
audio.setVolume(mainMusicChannel, 0.5)
local function goToLevel1()
    composer.gotoScene("level1")
end

local function goToLevel2()
    composer.gotoScene("level2")
end

local function goToLevel3()
    composer.gotoScene("level3")
end

function scene:create( event )
    local sceneGroup = self.view
    display.setDefault("background", 0.7,0.7,1)
    background = display.newRect(display.contentCenterX, display.contentCenterY, 720, 500)
    background.fill = {type = "image", filename = "assets/images/bg_main.jpg"}
    background.y = background.y+30
    background.alpha = 0.9
    sceneGroup:insert(background)
    levelBtn1 = display.newRoundedRect(display.contentCenterX, 140, 300, 40, 15)
    levelBtn2 = display.newRoundedRect(display.contentCenterX, 210, 300, 40, 15)
    levelBtn3 = display.newRoundedRect(display.contentCenterX, 280, 300, 40, 15)
    levelBtn1:setFillColor(0.8)
    levelBtn2:setFillColor(0.8)
    levelBtn3:setFillColor(0.8)
    levelBtn1:setStrokeColor(0.5, 0.5, 0.6)
    levelBtn1.strokeWidth = 3
    levelBtn2:setStrokeColor(0.5, 0.5, 0.6)
    levelBtn2.strokeWidth = 3
    levelBtn3:setStrokeColor(0.5, 0.5, 0.6)
    levelBtn3.strokeWidth = 3
    text1 = display.newText("Уровень 1", display.contentCenterX, 140, native.systemFont, 25)
    text1:setFillColor(0)
    text2 = display.newText("Уровень 2", display.contentCenterX, 210, native.systemFont, 25)
    text2:setFillColor(0)
    text3 = display.newText("Уровень 3", display.contentCenterX, 280, native.systemFont, 25)
    text3:setFillColor(0)
    name_text = display.newText("Lab Escape", display.contentCenterX, 60, native.newFont("Comic Sans MS", 45))
    sceneGroup:insert(levelBtn1)
    sceneGroup:insert(levelBtn2)
    sceneGroup:insert(levelBtn3)
    sceneGroup:insert(text1)
    sceneGroup:insert(text2)
    sceneGroup:insert(text3)
    sceneGroup:insert(name_text)
end
function scene:show( event )
    if (event.phase == "did") then
        physics.start()
        composer.removeScene("level1")
        composer.removeScene("level2")
        composer.removeScene("level3")
        levelBtn1:addEventListener("tap", goToLevel1)
        levelBtn2:addEventListener("tap", goToLevel2)
        levelBtn3:addEventListener("tap", goToLevel3)
    end
end
function scene:hide( event )
    if "will" == event.phase then
        physics.stop()
    end
    if "did" == event.phase then
        levelBtn1:removeEventListener("tap", goToLevel1)
        levelBtn2:removeEventListener("tap", goToLevel2)
        levelBtn3:removeEventListener("tap", goToLevel3) 
    end
end
function scene:destroy( event )
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene