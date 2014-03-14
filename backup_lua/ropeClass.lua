require("lib/lgm/lgm")

-- somewhat inspired by http://nehe.gamedev.net/tutorial/rope_physics/17006/

ropeClass = {}
nodeClass = {}

function ropeClass.make_link(rope, n1, n2)
    A = rope.nodes[n1]
    B = rope.nodes[n2]
    table.insert(A.links, LGM.Segment(A, B))
    table.insert(B.links, LGM.Segment(B, A))
    table.insert(A.linksDistance[B], ropeSegSize)
    table.insert(B.linksDistance[A], ropeSegSize)
end

function ropeClass.unlink(rope, n1, n2)
    local A = rope.nodes[n1]
    local B = rope.nodes[n2]
    local posA = 0
    local posB = 0

    -- find pos1 and pos2
    for i, s in ipairs(A.links) do
        if (s.pB == B) then
            posA = i
            break
        end
    end
    for i, s in ipairs(B.links) do
        if (s.pB == A) then
            posB = i
            break
        end
    end

    if (posA == 0 and posB == 0) then print("unlink : link "..n1..", "..n2.." did not exist") end

    table.remove(A.links, posA)
    table.remove(B.links, posB)
    A.linksDistance[B] = nil
    B.linksDistance[A] = nil
end

function nodeClass.newBloodPS()
    system = love.graphics.newParticleSystem( img_blood, 75 )
    system:setPosition( 0, 0 )
    system:setOffset( 0, 0 )
    system:setBufferSize( 400 )
    system:setEmissionRate( 200 )
    system:setEmitterLifetime( 2 )
    system:setParticleLifetime( 5 )
    system:setColors( 255, 0, 0, 255, 150, 0, 0, 255 )
    system:setSizes( 0.25, 0 )
    system:setSpeed( 100, 150 )
    system:setDirection( math.rad(0) )
    system:setSpread( math.rad(45) )
    system:setLinearAcceleration( gravityFieldX, 2 * gravityFieldY )
    system:setRotation( math.rad(0), math.rad(0) )
    system:setSpin( math.rad(0.5), math.rad(1), 1 )
    system:setRadialAcceleration( 0 )
    system:setTangentialAcceleration( 0 )
    system:pause()
    return system
end

function nodeClass.newNode()
    node = {
        id = 'undefined',
        X = 0,
        Y = 0,
        oldX = 0,
        oldY = 0,
        getX = function(node) return node.X end,
        getY = function(node) return node.Y end,
        speedV = LGM.Vector(0, 0)
        forceV = LGM.Vector(0, 0)
        attractedByMouse = false,
        stuck = false,
        mass = 2,
        links = {},
        linksDistance = {},
        bloodPS = nodeClass.newBloodPS()
    }
    setmetatable(node, {__index = nodeClass})
    return node
end

function nodeClass.updateForces(node, dt, linksToRemove)
    node.totalF = LGM.Vector(0, 0)

    springF = LGM.Vector(0, 0)
    for i, seg in ipairs(node.links) do
        otherNode = seg.pB
        distOther = LGM.distance(node.X, node.Y, otherNode.X, otherNode.Y)
        node.linksDistance[otherNode] = distOther
        if (distOther > segmentBreakDistance) then
            print("must remove "..node.id.." , "..otherNode.id)
            table.insert(linksToRemove, {node.id, otherNode.id})
        else
            normSpring = ropeSpringStrength * (distOther - ropeSegSize)
            linkSpringV = LGM.Vector(otherNode.X - node.X, otherNode.Y - node.Y)
            linkSpringV:setNorm(normSpring)
            springF = springF:add(linkSpringV)
        end
    end

    frictionF = LGM.Vector(- (friction * node.speed.x), - (friction * node.speed.y))

    gravityF = LGM.Vector(gravityFieldX * node.mass, gravityFieldY * node.mass)

    node.forceV = node.forceV:add(springF:add(frictionF:add(gravityF)))
end

function nodeClass.updatePosition(node, dt)
    node.oldX, node.oldY = node.X, node.Y
    if (not node.stuck) then
        if (node.attractedByMouse) then
            mx, my = love.mouse.getPosition()
            distMouse = LGM.distance(mx, my, node.X, node.Y)
            if (distMouse < speedUserNode * dt) then
                node.X, node.Y = mx, my
                node.speedV = LGM.Vector(0, 0)
            else
                node.speedV = LGM.Vector(mx - node.X, my - node.Y)
                node.speedV:setNorm(speedUserNode)
            end
        else
            node.speedV.x = node.speedV.x + dt * node.forceV.x / node.mass
            node.speedV.y = node.speedV.y + dt * node.forceV.y / node.mass
        end

        if node:getX() < 0 then
            node.speedV.x = math.abs(node.speedV.x)
        elseif node:getX() > wScr then
            node.speedV.x = -1 * math.abs(node.speedV.x)
        end
        if node:getY() < 0 then
            node.speedV.y = math.abs(node.speedV.y)
        elseif node:getY() > hScr then
            node.speedV.y = -1*math.abs(node.speedV.y)
        end

        if (node.speedV:norm() > maxSpeedNode) then
            node.speedV:setNorm(maxSpeedNode)
        end

        node.X = node.X + node.speedV.x*dt
        node.Y = node.Y + node.speedV.y*dt
    end
end

function nodeClass.updateOther(node, dt)
    node.bloodPS:setPosition(node:getX(), node:getY())
    node.bloodPS:update(dt)

    closestObstacle = findClosestOf(obstacles, node)

    if (closestObstacle) then
        oldPos = LGM.Entity(node.oldX, node.oldY)
        newPos = LGM.Entity(node.X, node.Y)
        if (closestObstacle:intersectSegment(LGM.Segment(oldPos, newPos))) then
            print(node.id.." intersects "..closestObstacle.id)
        end
    end
end

function nodeClass.draw(node)
    love.graphics.draw(node.bloodPS)
    fillage = "fill"
    if (node.stuck) then
        fillage = "line"
    end
    love.graphics.setColor(255,255,255)
    love.graphics.circle(fillage, node.X, node.Y, node.mass)
    love.graphics.setColor(255,0,0) -- ghost
    love.graphics.circle("line", node.oldX, node.oldY, node.mass)
    love.graphics.setColor(255,255,255)
    for i, seg in ipairs(node.links) do
        otherNode = seg.pB
        stretchFactor = seg:norm()/segmentBreakDistance
        stretchFactor = math.max(0, stretchFactor)
        stretchFactor = math.min(1, stretchFactor)
        love.graphics.setColor(255, 255 * (1 - stretchFactor), 255 * (1 - stretchFactor))
        love.graphics.line(node.X, node.Y, otherNode.X, otherNode.Y)
    end
    if(DEBUG) then
        love.graphics.print(node.id, node.X, node.Y)
    end
end

function ropeClass.newRope()
    rope = {}
    setmetatable(rope, {__index = ropeClass})
    local ropeSegInitialSize = ropeSegSize + gravityFieldY/ropeSpringStrength
    rope.nodes = {}
    for i = 1, numbSegment do
        rope.nodes[i] = nodeClass.newNode()
        rope.nodes[i].id = i
        rope.nodes[i].X = 300
        rope.nodes[i].Y = 100 + (i - 1) * (ropeSegInitialSize)
        rope.nodes[i].oldX = rope.nodes[i].X
        rope.nodes[i].oldY = rope.nodes[i].Y
        if (i > 1) then
            rope:make_link(i, i-1)
        end
    end
    return rope
end

function ropeClass.closestNode(rope, x, y, maxDistance)
    mouseObject = {getX = function() return x end, getY = function() return y end}
    return findClosestOf(rope.nodes, mouseObject, maxDistance)
end

function ropeClass.update(rope, dt)
    linksToRemove = {}
    for i = 1, #rope.nodes do
        rope.nodes[i]:updateForces(dt, linksToRemove)
    end

    for j = 1, #linksToRemove do
        startN = rope.nodes[linksToRemove[j][1]]
        endN = rope.nodes[linksToRemove[j][2]]
        rope:unlink(startN.id, endN.id)
        angle = bafaltomAngle2Entities(startN, endN)
        startN.bloodPS:setDirection(angle)
        endN.bloodPS:setDirection(angle + math.pi)
        startN.bloodPS:start()
        endN.bloodPS:start()
    end


    -- displacement are done once all forces have been computed
    for i=1,#rope.nodes do
        rope.nodes[i]:updatePosition(dt)
        rope.nodes[i]:updateOther(dt)
    end
end

function ropeClass.draw(rope)
    for i = 1, #rope.nodes do
        currN = rope.nodes[i]
        currN:draw()
    end
end

function ropeClass.mousepressed(rope, mx, my, b)
    userNode = rope:closestNode(mx, my, mousePrecision)
    if b == 'l' then
        if (userNode) then
            userNode.stuck = false
            userNode.attractedByMouse = true
        end
    end
end

function ropeClass.mousereleased(rope, mx, my, b)
    userNode = rope:closestNode(mx, my, mousePrecision)
    if b == "l" then
        for i = 1, #rope.nodes do
            rope.nodes[i].attractedByMouse = false
        end
    elseif b == "r" then
        if (userNode) then
            userNode.stuck = not userNode.stuck
            userNode.speedX, userNode.speedY = 0, 0
        end
    end
end
