keyStates = {}

actions = {
    jump="space",
    move_left="a",
    move_right="d",
    crouch="s"
}

function getDirection()
    -- Y dir not implemented
    local dir = {x = 0, y = 0}
    if love.keyboard.isDown(actions.move_left) then
        dir.x = -1
    end
    if love.keyboard.isDown(actions.move_right) then
        dir.x = 1
    end
    if love.keyboard.isDown(actions.crouch) then
        dir.y = -1
    end
    return dir
end

love.keyboard.isPressed = function(key)
    local current = love.keyboard.isDown(key)
    if keyStates[key] then
        local previous = keyStates[key].previous
        keyStates[key].current = current
        return current and not previous
    else
        keyStates[key] = {current = current, previous = false}
        return current
    end
end

love.keyboard.isReleased = function(key)
    local current = love.keyboard.isDown(key)
    if keyStates[key] then
        local previous = keyStates[key].previous
        keyStates[key].current = current
        return not current and previous
    else -- If key not in keystates
        keyStates[key] = {current = current, previous = false}
        return current
    end
end

love.keyboard.resetKeyStates = function()
    for key, _ in pairs(keyStates) do
        keyStates[key].previous = keyStates[key].current
    end
end
