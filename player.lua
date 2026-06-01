local audio = require "audio"
player = {
    body=nil,
    speed = 170,
    jumpForce = 250,
    size = 30,
    spawnX = 0,
    spawnY = 0,
    onFire = false,
    isMoving = false,
    direction = 1,
    grounded = false,
    hasKey = false,
    health = 3
}
local function OnFrame(event)
    if not player.grounded then
        local vx, vy = player.body:getLinearVelocity()
        player.body:setSequence("midair")
        if vy<-50 then
            if vx>50 then
                player.body:setFrame(4)
            elseif vx<-50 then
                player.body:setFrame(8)
            else
                player.body:setFrame(3)
            end
        elseif vy>50 then
            if vx>50 then
                player.body:setFrame(5)
            elseif vx<-50 then
                player.body:setFrame(7)
            else 
                player.body:setFrame(6)
            end
        else 
            if player.direction >= 0 then
                player.body:setFrame(1)
            else
                player.body:setFrame(2)
            end
        end
    else 
        if player.body.sequence == "midair" then
            if player.direction >= 0 then
                player.body:setSequence("walkright")
                if player.isMoving then
                    player.body:play()
                end
            else
                player.body:setSequence("walkleft")
                if player.isMoving then
                    player.body:play()
                end
            end
            player.body:setFrame(1)
        end
    end
end
function player:spawn(physics)
    local sheetOptions =
    {
        width = 240,
        height = 240,
        numFrames = 10
    }
    local sequencesData = 
    {
        {
            name = "walkright",
            start = 1,
            count = 2,
            time = 300,
            loopCount = 0, 
            loopDirection = "forward"
        },
        {
            name = "walkleft",
            start = 3,
            count = 2,
            time = 300,
            loopCount = 0, 
            loopDirection = "forward"
        },
        {
            name = "midair",
            frames = {1,3,5,6,7,8,9,10},
            time = 10000,
            loopCount = 0, 
            loopDirection = "forward"
        }
    }
    local imageSheet = graphics.newImageSheet( "assets/sprites/slime.png", sheetOptions )
    self.body = display.newSprite(imageSheet, sequencesData)
    self.body.x = self.spawnX
    self.body.y = self.spawnY
    self.body:scale(self.size/240, self.size/240)
    local halfSize = self.size / 2
    local physicsShape = {-halfSize, -halfSize+2, halfSize, -halfSize+2, halfSize, halfSize-5, -halfSize, halfSize-5}
    physics.addBody(self.body, "dynamic", {bounce = 0, shape = physicsShape})
    self.body.gravityScale=1.5
    self.health = 3
    self.body.isFixedRotation = true
    self.hasKey = false
    self.jumpsfx = audio.loadSound("assets/sounds/jump.wav")
    Runtime:addEventListener("enterFrame", OnFrame)
end
function player:delete()
    self.body:removeSelf()
    audio.dispose(self.jumpsfx)
    Runtime:removeEventListener("enterFrame", OnFrame)
end
function player:respawn()
    self.body.x = self.spawnX
    self.body.y = self.spawnY
    self.body:setLinearVelocity(0,0)
    self.health = self.health - 1
    self.hasKey = false
    self.isMoving = false
    self.onFire = false
end
function player:moveLeft(event)
    if(event.phase == "began") then
        if self.grounded then
            self.body:setSequence("walkleft")
            self.body:setFrame(2)
            self.body:play()
        end
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(-self.speed, vy)
        self.isMoving = true
        self.direction = -1
    end
    if(event.phase == "ended" or event.phase == "cancelled") then
        if self.grounded then
            self.body:pause()
            self.body:setFrame(1)
        end
        self.isMoving = false
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(0, vy)
    end
end
function player:moveRight(event)
    if(event.phase == "began") then
        if self.grounded then
            self.body:setSequence("walkright")
            self.body:setFrame(2)
            self.body:play()
        end
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(self.speed, vy)
        self.isMoving = true
        self.direction = 1
    end
    if(event.phase == "ended" or event.phase == "cancelled") then
        if self.grounded then
            self.body:pause()
            self.body:setFrame(1)
        end
        self.isMoving = false
        local vx, vy = self.body:getLinearVelocity()
        self.body:setLinearVelocity(0, vy)
    end
end
function player:jump(event)
    if(event.phase == "began") then
        if(self.grounded) then
            audio.play(self.jumpsfx)
            local vx, vy = self.body:getLinearVelocity()
            self.body:setLinearVelocity( vx, -self.jumpForce)
        end
    end
end

return player