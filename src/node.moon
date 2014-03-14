require("lib/lgm/lgm")

-- somewhat inspired by http://nehe.gamedev.net/tutorial/rope_physics/17006/

export ^

class Node extends LGM.Entity

    newBloodPS: =>
        system = love.graphics.newParticleSystem(img_blood, 75)
        system\setPosition( 0, 0 )
        system\setOffset( 0, 0 )
        system\setBufferSize( 400 )
        system\setEmissionRate( 200 )
        system\setEmitterLifetime( 2 )
        system\setParticleLifetime( 5 )
        system\setColors( 255, 0, 0, 255, 150, 0, 0, 255 )
        system\setSizes( 0.25, 0 )
        system\setSpeed( 100, 150 )
        system\setDirection( math.rad(0) )
        system\setSpread( math.rad(45) )
        system\setLinearAcceleration( gravityFieldX, 2 * gravityFieldY )
        system\setRotation( math.rad(0), math.rad(0) )
        system\setSpin( math.rad(0.5), math.rad(1), 1 )
        system\setRadialAcceleration( 0 )
        system\setTangentialAcceleration( 0 )
        system\pause()
        return system

    new: (x, y) =>
        super(x, y)
        @oldX = 0
        @oldY = 0
        @speed = LGM.Vector(0, 0)
        @force = LGM.Vector(0, 0)
        @attractedByMouse = false
        @stuck = false
        @mass = 2
        @links = {}
        @bloodPS = @newBloodPS()

    updateForces: (dt, linksToRemove) =>
        springForce = LGM.Vector(0, 0)
        for i, seg in ipairs(@links) do
            otherNode = seg.pB
            distOther = LGM.distance(@X, @Y, otherNode.X, otherNode.Y)
            if (distOther > segmentBreakDistance)
                print("must remove "..@id.." , "..otherNode.id)
                table.insert(linksToRemove, {@, otherNode})
            else
                normSpring = ropeSpringStrength * (distOther - ropeSegSize)
                linkSpringF = LGM.Vector(otherNode.X - @X, otherNode.Y - @Y)
                linkSpringF\setNorm(normSpring)
                springForce = springForce\add(linkSpringF)

        friction = @speed\scalarProduct(-friction)
        gravity = gravityField\scalarProduct(@mass)

        @force = springForce\add(friction\add(gravity))

    updatePosition: (dt) =>
        @oldX, @oldY = @getX(), @getY()
        if (not @stuck) then
            if (@attractedByMouse) then
                mx, my = love.mouse.getPosition()
                distMouse = LGM.distance(mx, my, @X,  @Y)
                if (distMouse < speedUserNode * dt)
                    @X, @Y = mx, my
                    @speed = LGM.Vector(0, 0)
                else
                    @speed = LGM.Vector(mx - @X, my - @Y)
                    @speed\setNorm(speedUserNode)
            else
                -- speed += acceleration * dt
                -- acceleration = force / mass
                @speed = @speed\add(@force\scalarProduct(dt / @mass))

            if @getX() < 0 then
                @speed.x = math.abs(@speed.x)
            elseif @getX() > wScr() then
                @speed.x = -1 * math.abs(@speed.x)
            if @getY() < 0 then
                @speed.y = math.abs(@speed.y)
            elseif @getY() > hScr() then
                @speed.y = -1 * math.abs(@speed.y)

            if @speed\norm() > maxSpeedobstacle then
                @speed:setNorm(maxSpeedobstacle)

            @X += @speed.x * dt
            @Y += @speed.y * dt

    updateOther: (dt) =>
        @bloodPS\setPosition(@getX(), @getY())
        @bloodPS\update(dt)

        closestObstacle = @getClosestOf(obstacles\as_list)

        if (closestObstacle) then
            oldPos = LGM.Entity(@oldX, @oldY)
            newPos = LGM.Entity(@X, @Y)
            movementSeg = LGM.Segment(oldPos, newPos)
            if (closestObstacle\intersectSegment(movementSeg)) then
                print(node.id.." intersects "..closestObstacle.id)

    draw: =>
        love.graphics.draw(@bloodPS)
        fillage = if @stuck then "fill" else "line"
        love.graphics.setColor(255,255,255)
        love.graphics.circle(fillage, node.X, node.Y, node.mass)
        love.graphics.setColor(255,0,0) -- ghost
        love.graphics.circle("line", node.oldX, node.oldY, node.mass)
        love.graphics.setColor(255,255,255)
        for i, seg in ipairs(@links)
            otherNode = seg.pB
            stretchFactor = seg\norm() / segmentBreakDistance
            stretchFactor = math.max(0, stretchFactor)
            stretchFactor = math.min(1, stretchFactor)
            love.graphics.setColor(255, 255 * (1 - stretchFactor), 255 * (1 - stretchFactor))
            love.graphics.line(@X, @Y, otherNode.X, otherNode.Y)
        if(DEBUG) then
            love.graphics.print(@id, @X, @Y)

