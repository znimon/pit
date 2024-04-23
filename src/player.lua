require("utils")
require("input")

Player = {}

function Player:load()
    self.canMove = true
    self.x = 100
    self.y = 0
    self.width = 20
    self.height = 40
    self.vx = 0
    self.vy = 0
    self.speed = 0
    self.maxSpeed = 200
    self.acceleration = 4000
    self.friction = 2000
    self.gravity = 1500
    self.grounded = false

    -- Jumping
    self.jumpAmount = -600
    -- Coyote time allows the player to jump a duration after they are no longer touching the groud
    self.coyoteTime = 0.2
    self.coyoteTimer = 0
     -- Jump buffering allows the player to tigger a jump before they've touched the ground during the prev jump
    self.jumpBufferTime = 0.2
    self.jumpBufferTimer = 0

    -- Physics
    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Player:update(dt, ignorePlayerInput)
    local dir = getDirection()
    self:move(dt, dir)
    self:manageJumpBufferTime(dt)
    self:manageCoyoteTime(dt)
    self:jump()
    self:applyGravity(dt)
    self:syncPhysics()

    if self.vy > 10 then
        print(self.vy)
    end
end

function Player:manageCoyoteTime(dt)
    if self.grounded then
        self.coyoteTimer = self.coyoteTime
    else
        self.coyoteTimer = self.coyoteTimer - dt
    end
end

function Player:manageJumpBufferTime(dt) -- Reset jump buffer timer
    self.jumpBufferTimer = self.jumpBufferTimer - dt
    if love.keyboard.isPressed(actions.jump) then
        self.jumpBufferTimer = self.jumpBufferTime
    end
end

function Player:applyGravity(dt)
    if not self.grounded then -- Only apply gravity when the player is not grounded
        self.vy = self.vy + self.gravity * dt
    end
end

function Player:move(dt, dir)
    if dir.x == 0 then
        self:applyFriction(dt)
    else
        if self.canMove then
            self.vx = self.vx + self.acceleration * dir.x * dt
            self.vx = clamp(self.vx, -self.maxSpeed, self.maxSpeed)
        end
    end
end

function Player:applyFriction(dt) -- Decelerate the player when they are no longer moving
    local frictionAmount = self.friction * dt
    if self.vx > 0 then
        self.vx = math.max(self.vx - frictionAmount, 0)
    elseif self.vx < 0 then
        self.vx = math.min(self.vx + frictionAmount, 0)
    end
end

function Player:syncPhysics()
   self.x, self.y = self.physics.body:getPosition()
   self.physics.body:setLinearVelocity(self.vx, self.vy)
end

function Player:beginContact(a, b, collision)
    if self:isGrounded(a, b, collision) then
        self:land(collision) -- Need to pass collision so we can determin when the objects stop touching one another
    end
end

function Player:isGrounded(a, b, collision)
    -- Determine if a collision is between the player and an object undernearth the player
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then -- If player is A object
        if ny > 0 then return true end
    elseif b == self.physics.fixture then -- If player is B object
        if ny < 0 then return true end
    else return false end
end

function Player:land(collision)
    self.currentGroundCollision = collision
    self.vy = 0
    self.grounded = true
end

function Player:jump()
    if self.canMove then
        if (self.coyoteTimer > 0 and self.jumpBufferTimer > 0) then
            self.vy = self.jumpAmount
            self.grounded = false
            self.coyoteTimer = 0 -- Prevents player from multi-jumping by spamming the jump button
            self.jumpBufferTimer = 0
        end
        -- Jump less high when the jump button is pressed quickly
        if love.keyboard.isReleased(actions.jump) then 
            self.vy = self.vy * 0.5
        end
    end
end

-- If we don't use endContact then the player wil float when they walk off of an edge because gravity is only applied
-- when the player is not touching the ground
function Player:endContact(a, b, collision) -- This is called then two fixtures stop touching each other
    if self.currentGroundCollision == collision then -- If the ground collision we calculated is the current collision
        -- print("No longer grounded")
        self.grounded = false
    end
end

function Player:draw()
    -- Calculate velocity magnitude (speed)
    local speed = math.sqrt(self.vx^2 + self.vy^2)
    -- Define colors
    local slowColor = {0, 255, 0}   -- Green
    local medColor = {255, 255, 0} -- Yellow
    local fastColor = {255, 0, 0}    -- Red
    if speed < 500 then
        currentColor = slowColor
    elseif speed >= 700 and speed <= 1100 then
        currentColor = medColor
    elseif speed > 1100 then
        currentColor = fastColor
        playerReachedFastColor = true
    end

    if playerReachedFastColor then
        currentColor = fastColor
    end

    love.graphics.setColor(currentColor)
    love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    love.graphics.setColor(255, 255, 255, 255)
end



-- function Player:isRightWall(nx, a, b, collision)
--     if b == self.physics.fixture then
--         if nx < 0 then return true end
--     end
-- end

-- function Player:isLeftWall(a, b, collision)
--     if b == self.physics.fixture then
--         if nx > 0 then
--             return true
--         end
--     end
-- end

-- function Player:isWalled(collision)
--     if self:isLeftWall(a, b, collision) or self:isRightWall(a, b, collision) then
--         return true
--     end
-- end

-- function Player:horizontalInput()
--     if love.keyboard.isDown("d", "right") or love.keyboard.isDown("a", "right") then
--         return true
--     end
-- end

-- function Player:wallSlide(collision)
--     if self:isWalled(collision) and not self.grounded and self:horizontalInput() then
--         self.wallSliding = true
--         self.vy = self.utils.clamp(self.vy, -wallSlideSpeed, 999999)
--     else
--         self.wallSliding = false
--     end
-- end

-- function Player:touchWall(collision)
--     print("Touch wall")
--     self.wallSlideTime = self.wallSlideDuration -- Start countdown when player touches the wall
--     self.vy = 0
--     self.touchingWall = true
--     -- self.currentWallCollision = collision
-- end

    -- (self.touchingWall)
    -- if self.touchingWall and love.keyboard.isDown("d", "right") and self.canWallSlide then
    -- if self.touchingWall and love.keyboard.isDown("d", "right") then
    --     self.wallSliding = true
    --     self.vy = self.wallSlideSpeed
    -- else
    --     self.wallSliding = false
    -- end

    -- self:wallSlide(collision)
    -- Wall Slide
    -- self:decreaseWallSlideTime(dt)
    -- print(self.vy)
    -- print(self.wallSlideTime)
    -- if self.wallSlideTime < 0 or self.grounded then
    --     self.wallSliding = false
    --     self.touchingWall = false
    -- end
    -- self:isRightWall()

    -- function Player:decreaseWallSlideTime(dt)
    --     if self.wallSliding then
    --         self.wallSlideTime = self.wallSlideTime - dt
    --     end
    -- end
