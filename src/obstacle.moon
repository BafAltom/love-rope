require "lib/lgm/lgm"

export *

class Obstacle extends LGM.Entity

    new: (x, y) =>
        super x, y
        @speed = LGM.Vector(0, 0)
        @force = LGM.Vector(0, 0)
        @attractedByMouse = false
        @stuck = true
        @mass = 2
        @segments = {}  -- List of LGM.Segment

    points: =>
        pList = {}
        if #@segments > 0
            firstPoint = nil
            for _, s in ipairs(@segments) do
                assert(curPoint == nil or (s.pA.x == curPoint.x and s.pA.y == curPoint.y), "#{s.pA} \t #{curPoint}")
                table.insert(pList, s.pB.x)
                table.insert(pList, s.pB.y)
                curPoint = s.pB
        return pList

    update: (dt) =>
        @updateForces(dt)
        @updatePosition(dt)
        @updateOther(dt)

    updateForces: (dt) =>
        @force = LGM.Vector(0, 0)
        friction = @speed\scalarProduct(-frictionFactor)
        gravity = gravityField\scalarProduct(@mass)
        @force = friction\add(gravity)

    updatePosition: (dt) =>
        if (not @stuck) then
            if (@attractedByMouse) then
                mx, my = love.mouse.getPosition()
                distMouse = LGM.distance(mx, my, @getX!, @getY!)
                if (distMouse < speedUserobstacle * dt) then
                    @x, @y = mx, my
                    @speed = LGM.Vector(0, 0)
                else
                    @speed = LGM.Vector(mx - @x, my - @y)
                    @speed\setNorm(speedUserobstacle)
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

            @x += @speed.x * dt
            @y += @speed.y * dt

    updateOther: (dt) =>

    intersectSegment: (outSegment) =>
        -- segment intersect obstacle iff it intersects one of its edges
        for _, seg in ipairs(@segments)
            if seg\intersect(outSegment)
                return true
        return false

    draw: =>
        love.graphics.setColor(255,255,255)
        love.graphics.polygon("fill", @points())

    mousepressed: (mx, my, b) =>
    if b == 'l'
        @attractedByMouse = true

    mousereleased: (mx, my, b) =>
    if b == "l"
        @attractedByMouse = false

defaultObstacleList = ->
    oList = EntitySet()
    -- o = Obstacle(100, 100)
    -- table.insert(o.segments, LGM.Segment(LGM.Entity(50, 50), LGM.Entity(150, 50)))
    -- table.insert(o.segments, LGM.Segment(LGM.Entity(150, 50), LGM.Entity(150, 150)))
    -- table.insert(o.segments, LGM.Segment(LGM.Entity(150, 150), LGM.Entity(50, 150)))
    -- table.insert(o.segments, LGM.Segment(LGM.Entity(150, 150), LGM.Entity(50, 50)))
    -- oList\add(o)

    return oList
