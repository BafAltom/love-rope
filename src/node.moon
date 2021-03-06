require("lib/lgm/lgm")

-- somewhat inspired by http://nehe.gamedev.net/tutorial/rope_physics/17006/

export ^

class Node extends LGM.Entity

    new: (x, y) =>
        super(x, y)
        @oldX = 0
        @oldY = 0
        @speed = LGM.Vector(0, 0)
        @force = LGM.Vector(0, 0)
        @attractedByMouse = false
        @stuck = false
        @mass = 2
        @links = {}  -- list of adjacent nodes
        @bloodPS = @newBloodPS()

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
        system\setLinearAcceleration( gravityField.x, 2 * gravityField.y )
        system\setRotation( math.rad(0), math.rad(0) )
        system\setSpin( math.rad(0.5), math.rad(1), 1 )
        system\setRadialAcceleration( 0 )
        system\setTangentialAcceleration( 0 )
        system\pause()
        return system

    __tostring: =>
        return super()

    updateForces: (dt, linksToRemove) =>
        springForce = LGM.Vector(0, 0)
        for i, otherNode in ipairs(@links) do
            distOther = LGM.distance(@x, @y, otherNode.x, otherNode.y)
            if (distOther > segmentBreakDistance)
                print("must remove "..@id.." , "..otherNode.id)
                table.insert(linksToRemove, {@id, otherNode.id})
            else
                normSpring = ropeSpringStrength * (distOther - ropeSegSize)
                linkSpringF = LGM.Vector(otherNode.x - @x, otherNode.y - @y)
                linkSpringF\setNorm(normSpring)
                springForce = springForce\add(linkSpringF)

        frictionForce = @speed\scalarProduct(-frictionFactor)
        gravityForce = gravityField\scalarProduct(@mass)

        @force = springForce\add(frictionForce\add(gravityForce))

    updatePosition: (dt) =>
        @oldX, @oldY = @getX(), @getY()
        if (not @stuck) then
            if (@attractedByMouse) then
                mx, my = love.mouse.getPosition()
                distMouse = LGM.distance(mx, my, @x,  @y)
                if (distMouse < speedUserNode * dt)
                    @x, @y = mx, my
                    @speed = LGM.Vector(0, 0)
                else
                    @speed = LGM.Vector(mx - @x, my - @y)
                    @speed\setNorm(speedUserNode)
            else
                -- we apply speed += acceleration * dt
                -- with acceleration = force / mass
                @speed = @speed\add(@force\scalarProduct(dt / @mass))

            if @getX() < 0 then
                @speed.x = math.abs(@speed.x)
            elseif @getX() > wScr() then
                @speed.x = -1 * math.abs(@speed.x)
            if @getY() < 0 then
                @speed.y = math.abs(@speed.y)
            elseif @getY() > hScr() then
                @speed.y = -1 * math.abs(@speed.y)

            if @speed\norm() > maxSpeedNode then
                @speed\setNorm(maxSpeedNode)

            @x += @speed.x * dt
            @y += @speed.y * dt

    updateOther: (dt) =>
        @bloodPS\setPosition(@getX(), @getY())
        @bloodPS\update(dt)

        closestObstacle = @getClosestOf(obstacles\as_list())

        if (closestObstacle) then
            oldPos = LGM.Entity(@oldX, @oldY)
            newPos = LGM.Entity(@x, @y)
            movementSeg = LGM.Segment(oldPos\toVector(), newPos\toVector())
            isIntersecting, seg = closestObstacle\intersectSegment(movementSeg)
            if isIntersecting then
                @x = @oldX
                @y = @oldY
                -- TODO: use either a global variable or a class attribute
                @speed = @speed\scalarProduct(-1/2)

    draw: =>
        love.graphics.draw(@bloodPS)
        love.graphics.setColor(255,255,255)
        for i, otherNode in ipairs(@links)
            distance = LGM.distance(@x, @y, otherNode.x, otherNode.y)
            stretchFactor = distance / segmentBreakDistance
            stretchFactor = math.max(0, stretchFactor)
            stretchFactor = math.min(1, stretchFactor)
            love.graphics.setColor(255, 255 * (1 - stretchFactor), 255 * (1 - stretchFactor))
            love.graphics.setLineWidth(3)
            love.graphics.line(@x, @y, otherNode.x, otherNode.y)
        if @stuck
            love.graphics.setColor(255,255,255)
            love.graphics.circle("fill", @getX(), @getY(), @mass)
            love.graphics.setColor(255,0,0) -- ghost
            love.graphics.circle("line", @oldX, @oldY, @mass)
        if(DEBUG) then
            love.graphics.print(@id, @x, @y)

