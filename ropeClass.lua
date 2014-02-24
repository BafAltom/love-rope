require("bafaltom2D")

-- somewhat inspired by http://nehe.gamedev.net/tutorial/rope_physics/17006/

ropeClass = {}
nodeClass = {}

function ropeClass.make_link(G, n1, n2)
    table.insert(G.nodes[n1].links, n2)
    table.insert(G.nodes[n2].links, n1)
    table.insert(G.nodes[n1].linksDistance, ropeSegSize)
    table.insert(G.nodes[n2].linksDistance, ropeSegSize)
end

function ropeClass.unlink(G, n1, n2)
    local _node1 = G.nodes[n1]
    local _node2 = G.nodes[n2]
    local _pos1 = 0
    local _pos2 = 0

    -- find pos1 and pos2
    for i = 1, #_node1.links do
        if (_node1.links[i] == n2) then
            _pos1 = i
            break
        end
    end
    for i = 1, #_node2.links do
        if (_node2.links[i] == n1) then
            _pos2 = i
            break
        end
    end

    if (_pos1 == 0 and _pos2 == 0) then print("unlink : link "..n1..", "..n2.." did not exist") end

    table.remove(_node1.links, _pos1)
    table.remove(_node2.links, _pos2)
    table.remove(_node1.linksDistance, _pos1)
    table.remove(_node2.linksDistance, _pos2)
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
        speedX = 0,
        speedY = 0,
        forceX = 0,
        forceY = 0,
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
    node.forceX = 0
    node.forceY = 0

    springX, springY = 0, 0
    for j = 1, #node.links do
        linkId = node.links[j]
        linkN = rope.nodes[linkId]

        distJ = distance2Entities(node, linkN)
        node.linksDistance[j] = distJ
        if (distJ > segmentBreakDistance) then
            print("must remove "..node.id.." , "..linkN.id)
            table.insert(linksToRemove, {node.id, linkN.id})
        else
            normSpringJ = ropeSpringStrength*(distJ - ropeSegSize)
            springJ_x, springJ_y = bafaltomVector(node.X, node.Y, linkN.X, linkN.Y, normSpringJ)
            springX = springX + springJ_x
            springY = springY + springJ_y
        end
    end

    frictionX = - (friction * node.speedX)
    frictionY = - (friction * node.speedY)

    gravityX = gravityFieldX * node.mass
    gravityY = gravityFieldY * node.mass

    node.forceX = springX + frictionX + gravityX
    node.forceY = springY + frictionY + gravityY
end

function nodeClass.updatePosition(node, dt)
    node.oldX, node.oldY = node.X, node.Y
    if (not node.stuck) then
        if (node.attractedByMouse) then
            mx, my = love.mouse.getPosition()
            distMouse = distance2Points(mx, my, node.X, node.Y)
            if (distMouse < speedUserNode * dt) then
                node.X, node.Y = mx, my
                node.speedX, node.speedY = 0, 0
            else
                node.speedX, node.speedY = bafaltomVector(node.X, node.Y, mx, my, speedUserNode)
            end
        else
            node.speedX = node.speedX + dt * node.forceX / node.mass
            node.speedY = node.speedY + dt * node.forceY / node.mass
        end

        if node:getX() < 0 then
            node.speedX = math.abs(node.speedX)
        elseif node:getX() > wScr then
            node.speedX = -1*math.abs(node.speedX)
        end
        if node:getY() < 0 then
            node.speedY = math.abs(node.speedY)
        elseif node:getY() > hScr then
            node.speedY = -1*math.abs(node.speedY)
        end

        if (distance2Points(0, 0, node.speedX, node.speedY) > maxSpeedNode) then
            node.speedX, node.speedY = bafaltomVector(0, 0, node.speedX, node.speedY, maxSpeedNode)
        end

        node.X = node.X + node.speedX*dt
        node.Y = node.Y + node.speedY*dt
    end
end

function nodeClass.updateOther(node, dt)
    node.bloodPS:setPosition(node:getX(), node:getY())
    node.bloodPS:update(dt)

    closestObstacle = findClosestOf(obstacles, node)

    nbrPoints = (#closestObstacle.points)/2
    for i=1, 2--[[2*(nbrPoints)]], 2 do
        -- determine if node has passed through each face of the obstacle
        -- this is done by computing if the old position of the node was left or right of the vector
        -- then if the new position is left or right of the vector
        -- if it switched position -> must check closer

        j = i + 2
        if (j > 2*nbrPoints) then
            j = 1
        end

        obsPointX = closestObstacle.points[i]
        obsPointY = closestObstacle.points[i+1]
        obsOtherPointX = closestObstacle.points[j]
        obsOtherPointY = closestObstacle.points[j+1]

        vFaceX, vFaceY = bafaltomVector(obsPointX, obsPointY, obsOtherPointX, obsOtherPointY, 1) -- vector of the face of the obstacle
        vOldX, vOldY = bafaltomVector(obsPointX, obsPointY, node.oldX, node.oldY, 1)
        vNewX, vNewY = bafaltomVector(obsPointX, obsPointY, node.X, node.Y, 1)
        dotProductOld = dotProduct(vFaceX, vFaceY, vOldX, vOldY)
        dotProductNew = dotProduct(vFaceX, vFaceY, vNewX, vNewY)
        --print(i, dotProductOld, dotProductNew)
        if (dotProductOld * dotProductNew < 0) then
            print(node.id.."intersect"..i)
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
    for j = 1, #node.links do
        linkId = node.links[j]
        linkN = rope.nodes[linkId]
        stretchFactor = node.linksDistance[j]/segmentBreakDistance
        stretchFactor = math.max(0, stretchFactor)
        stretchFactor = math.min(1, stretchFactor)
        love.graphics.setColor(255, 255 * (1 - stretchFactor), 255 * (1 - stretchFactor))
        love.graphics.line(node.X, node.Y, linkN.X, linkN.Y)
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


    -- displacement are done once all force have been computed
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
