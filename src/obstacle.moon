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
            firstPoint = @segments[0].pA
            table.insert(pList, firstPoint)
            curPoint = firstPoint
            for _, s in ipairs(@segments) do
                assert(s.pA == curPoint)
                table.insert(pList, s.pB)
                curPoint = s.pB

    update: (dt) =>
        @updateForces(dt)
        @updatePosition(dt)
        @updateOther(dt)

    updateForces: (dt) =>
        @force = LGM.Vector(0, 0)
        friction = @speed\scalarProduct(-friction)
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

    intersectSegment: (segment) =>
        -- segment is outside if one point is inside and the other outside
        -- inside: same direction (left/right) of all segments
        A = segment.pA
        B = segment.pB
        firstSegment = @segments[1]
        segmentA_dir = firstSegment\isLeft(A)
        segmentA_same = true
        segmentB_dir = firstSegment\isLeft(B)
        segmentB_same = true
        for _, s in ipairs(@segments)
            if (segmentA_same and s\isLeft(A) ~= segmentA_dir)
                segmentA_same = false
            if (segmentB_same and s\isLeft(B) ~= segmentB_dir)
                segmentB_same = false
        return ((segmentA_same and not segmentB_same) or (segmentB_same and not segmentA_same))

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
