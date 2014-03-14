require("lib/lgm/lgm")

obstacleClass = {}

function obstacleClass.newObstacle()
    obstacle = {
        X = 0,
        Y = 0,
        getX = function(o) return o.X end,
        getY = function(o) return o.Y end,
        speedX = 0,
        speedY = 0,
        forceX = 0,
        forceY = 0,
        attractedByMouse = false,
        stuck = true,
        mass = 2,
        segments = {}  -- List of LGM.Segment
    }
    setmetatable(obstacle, {__index = obstacleClass})
    return obstacle
end

function obstacleClass.points(obstacle)
    pList = {}
    if #obstacle.segments > 0 then
        firstPoint = obstacle.segments[0].pA
        table.insert(pList, firstPoint)
        curPoint = firstPoint
        for _, s in ipairs(obstacle.segments) do
            assert(s.pA == curPoint)
            table.insert(pList, s.pB)
            curPoint = s.pB
        end
    end
end

function obstacleClass.update(obstacle, dt)
    obstacle:updateForces(dt)
    obstacle:updatePosition(dt)
    obstacle:updateOther(dt)
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
            distMouse = LGM.distance(mx, my, obstacle.X, obstacle.Y)
            if (distMouse < speedUserobstacle * dt) then
                obstacle.X, obstacle.Y = mx, my
                obstacle.speed = LGM.Vector(0, 0)
            else
                obstacle.speed = LGM.Vector(mx - obstacle.X, my - obstacle.Y)
                obstacle.speed:setNorm(speedUserobstacle)
            end
        else
            obstacle.speed.x = obstacle.speed.x + dt*obstacle.forceX/obstacle.mass
            obstacle.speed.y = obstacle.speed.y + dt*obstacle.forceY/obstacle.mass
        end

        if obstacle:getX() < 0 then
            obstacle.speed.x = math.abs(obstacle.speed.x)
        elseif obstacle:getX() > wScr then
            obstacle.speed.x = -1*math.abs(obstacle.speed.x)
        end
        if obstacle:getY() < 0 then
            obstacle.speed.y = math.abs(obstacle.speed.y)
        elseif obstacle:getY() > hScr then
            obstacle.speed.y = -1*math.abs(obstacle.speed.y)
        end

        if (LGM.distance(0,0,obstacle.speed.x, obstacle.speed.y) > maxSpeedobstacle) then
            obstacle.speed:setNorm(maxSpeedobstacle)
        end

        obstacle.X = obstacle.X + obstacle.speed.x*dt
        obstacle.Y = obstacle.Y + obstacle.speed.y*dt
    end
end

function obstacleClass.updateOther(obstacle, dt)

end

function obstacleClass.intersectSegment(obstacle, segment)
    -- segment is outside if one point is inside and the other outside
    -- inside: same direction (left/right) of all segments
    A = segment.pA
    B = segment.pB
    firstSegment = obstacle.segments[1]
    segmentA_dir = firstSegment:isLeft(A)
    segmentA_same = true
    segmentB_dir = firstSegment:isLeft(B)
    segmentB_same = true
    for _, s in ipairs(obstacle.segments) do
        if (segmentA_same and s:isLeft(A) ~= segmentA_dir) then
            segmentA_same = false
        end
        if (segmentB_same and s:isLeft(B) ~= segmentB_dir) then
            segmentB_same = false
        end
    end
    return ((segmentA_same and not segmentB_same) or (segmentB_same and not segmentA_same))
end

function obstacleClass.draw(obstacle)
    love.graphics.setColor(255,255,255)
    love.graphics.polygon("fill", obstacle:points())
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
    table.insert(o.segments, LGM.Segment(LGM.Entity(50, 50), LGM.Entity(150, 50)))
    table.insert(o.segments, LGM.Segment(LGM.Entity(150, 50), LGM.Entity(150, 150)))
    table.insert(o.segments, LGM.Segment(LGM.Entity(150, 150), LGM.Entity(50, 150)))
    table.insert(o.segments, LGM.Segment(LGM.Entity(150, 150), LGM.Entity(50, 50)))

    table.insert(obstacles, o)
end
