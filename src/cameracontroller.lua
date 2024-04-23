CameraController = {}

function CameraController:load()
    self.xOffset = 300
    self.yOffset = 200
    self.lookDownYOffset = 700
    self.lookDownSpeed = 5
    self.returnToPlayerSpeed = 15
    self.scale = 2
    self.onPlayerThreshold = 5
    self.cameraState = 0
end

function CameraController:update(dt)
    local releasedCrouch = love.keyboard.isReleased(actions.crouch)
    if self.cameraState == 0 then
        -- print "Look at Player"
		cam:lookAt(
			Player.x * self.scale + self.xOffset,
			Player.y * self.scale + self.yOffset
		)
		Player.canMove = true
	end
    if love.keyboard.isDown(actions.crouch) and Player.grounded then
        -- print "Look Down"
		self.cameraState = 1
		Player.canMove = false
		local targetY = Player.y * self.scale + self.lookDownYOffset
		local currentX, currentY = cam:position()
		local newY = currentY + (targetY - currentY) * self.lookDownSpeed * dt
		cam:move(0, newY - currentY)
	end
    if releasedCrouch then
        print(releasedCrouch)
		self.cameraState = 2
	end
    if self.cameraState == 2 then
        -- print "Move to Player"
		local targetX = Player.x * self.scale + self.xOffset
		local targetY = Player.y * self.scale + self.yOffset
		local currentX, currentY = cam:position()
		local newX = currentX + (targetX - currentX) * self.returnToPlayerSpeed * dt
		local newY = currentY + (targetY - currentY) * self.returnToPlayerSpeed * dt
		cam:lookAt(newX, newY)
		if (currentY - targetY < self.onPlayerThreshold) and (currentX - targetX < self.onPlayerThreshold) then
			self.cameraState = 0
		end
    end
end