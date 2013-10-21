require("bafaltom2D")

obstacleClass = {}

function obstacleClass.newObstacle()
    obstacle = {
        X = 0,
        Y = 0,
        getX = function(obstacle) return obstacle.X end,
        getY = function(obstacle) return obstacle.Y end,
        speedX = 0,
        speedY = 0,
        forceX = 0,
        forceY = 0,
        attractedByMouse = false,
        stuck = true,
        mass = 2,
        points = {}  -- x1 y1 x2 y2 ...
    }
    setmetatable(obstacle, {__index = obstacleClass})
    return obstacle
end

function obstacleClass.updateForces(obstacle, dt)
    obstacle.forceX = 0
    obstacle.forceY = 0

    frictionX = -friction * obstacle.speedX
    frictionY = -friction * obstacle.speedY

    gravityX = gravityFieldX * obstacle.mass
    gravityY = gravityFieldY * obstacle.mass

    obstacle.forceX = springX + frictionX + gravityX
    obstacle.forceY = springY + frictionY + gravityY
end

function obstacleClass.updatePosition(obstacle, dt)
    if (not obstacle.stuck) then
        if (obstacle.attractedByMouse) then
            mx, my = love.mouse.getPosition()
            distMouse = distance2Points(mx, my, obstacle.X, obstacle.Y)
            if (distMouse < speedUserobstacle * dt) then
                obstacle.X, obstacle.Y = mx, my
                obstacle.speedX, obstacle.speedY = 0, 0
            else
                obstacle.speedX, obstacle.speedY = bafaltomVector(obstacle.X, obstacle.Y, mx, my, speedUserobstacle)
            end
        else
            obstacle.speedX = obstacle.speedX + dt*obstacle.forceX/obstacle.mass
            obstacle.speedY = obstacle.speedY + dt*obstacle.forceY/obstacle.mass
        end

        if obstacle:getX() < 0 then
            obstacle.speedX = math.abs(obstacle.speedX)
        elseif obstacle:getX() > wScr then
            obstacle.speedX = -1*math.abs(obstacle.speedX)
        end
        if obstacle:getY() < 0 then
            obstacle.speedY = math.abs(obstacle.speedY)
        elseif obstacle:getY() > hScr then
            obstacle.speedY = -1*math.abs(obstacle.speedY)
        end

        if (distance2Points(0,0,obstacle.speedX, obstacle.speedY) > maxSpeedobstacle) then
            obstacle.speedX, obstacle.speedY = bafaltomVector(0,0,obstacle.speedX, obstacle.speedY, maxSpeedobstacle)
        end

        obstacle.X = obstacle.X + obstacle.speedX*dt
        obstacle.Y = obstacle.Y + obstacle.speedY*dt
    end
end

function obstacleClass.updateOther(obstacle, dt)

end

function obstacleClass.draw(obstacle)
    love.graphics.setColor(255,255,255)
    love.graphics.polygon("fill", obstacle.points)
end

function obstacleClass.mousepressed(obstacle, mx, my, b)
    if b == 'l' then
        obstacle.attractedByMouse = true
    end
end

function obstacleClass.mousereleased(obstacle, mx, my, b)
    if b == "l" then
        for i = 1, #rope.obstacles do
            rope.obstacles[i].attractedByMouse = false
        end
    end
end

obstacles = {}

function obstacles.init()
    o = obstacleClass.newObstacle()
    o.X = 100
    o.Y = 100
    table.insert(o.points, 50)
    table.insert(o.points, 50)

    table.insert(o.points, 150)
    table.insert(o.points, 50)

    table.insert(o.points, 150)
    table.insert(o.points, 150)

    table.insert(o.points, 50)
    table.insert(o.points, 150)

    table.insert(obstacles, o)
end
