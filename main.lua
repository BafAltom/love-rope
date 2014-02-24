function love.load()
    require "ropeClass"
    require "variables"
    require "resources"
    require "obstacle"

    rope = ropeClass.newRope()
    obstacles.init()
end

function love.update(dt)
    FPS = 1/dt
    --love.timer.sleep(0.1)
    rope:update(dt)

    for i, o in ipairs(obstacles) do
        o:updateForces(dt)
        o:updatePosition(dt)
    end
end

function love.draw()
    love.graphics.setColor(255,255,255)
    love.graphics.print("FPS: "..round(FPS), 10, 10)
    rope:draw()

    for i, o in ipairs(obstacles) do
        o:draw()
    end
end

function love.mousepressed(x, y, b)
    rope:mousepressed(x, y, b)
end

function love.mousereleased(x, y, b)
    rope:mousereleased(x, y, b)
end

function love.keyreleased(k)
    if k == "escape" then
        love.event.quit()
    end
end

function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end
