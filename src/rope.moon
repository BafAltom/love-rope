require("lib/lgm/lgm")
require("node")

-- somewhat inspired by http://nehe.gamedev.net/tutorial/rope_physics/17006/

export ^

class Rope

    new: =>
        ropeSegInitialSize = ropeSegSize + gravityField.y/ropeSpringStrength
        @nodes = LGM.EntitySet()
        curId = nil
        for i = 1, numbSegment
            oldId = curId
            newNode = Node(300, 100 + (i - 1) * ropeSegInitialSize)
            @nodes\add(newNode)
            curId = newNode.id
            if (oldId) then
                @make_link(curId, oldId)

    closestNode: (x, y, maxDistance) =>
        targetEnt = LGM.Entity(x, y)
        return targetEnt\getClosestOf(@nodes\as_list(), maxDistance)

    update: (dt) =>
        linksToRemove = {} -- contains pairs of node ids
        for node in @nodes\iter() do
            node\updateForces(dt, linksToRemove)

        for link in *linksToRemove do
            startN = @nodes\find(link[1])
            endN = @nodes\find(link[2])
            @unlink(startN.id, endN.id)
            linkDirection = LGM.Vector(endN\getX() - startN\getX(), endN\getY() - startN\getY())
            linkAngle = linkDirection\angle()
            startN.bloodPS\setDirection(linkAngle)
            endN.bloodPS\setDirection(linkAngle + math.pi)
            startN.bloodPS\start()
            endN.bloodPS\start()

        -- displacement are done once all forces have been computed
        for node in @nodes\iter()
            node\updatePosition(dt)
            node\updateOther(dt)

    draw: =>
        for node in @nodes\iter()
            node\draw()

    mousepressed: (mx, my, b) =>
        userNode = @closestNode(mx, my, mousePrecision)
        if b == 'l'
            if (userNode) then
                userNode.stuck = false
                userNode.attractedByMouse = true

    mousereleased: (mx, my, b) =>
        userNode = @closestNode(mx, my, mousePrecision)
        if b == "l"
            for node in @nodes\iter()
                node.attractedByMouse = false
        elseif b == "r" then
            if (userNode) then
                userNode.stuck = not userNode.stuck
                userNode.speed = LGM.Vector(0, 0)


    make_link: (id1, id2) =>
        pA = @nodes\find(id1)
        pB = @nodes\find(id2)
        table.insert(pA.links, pB)
        table.insert(pB.links, pA)

    unlink: (id1, id2) =>
        A = @nodes\find(id1)
        B = @nodes\find(id2)
        posA = 0
        posB = 0

        -- find pos1 and pos2
        for i, node in ipairs(A.links) do
            if (node == B) then
                posA = i
                break
        for i, node in ipairs(B.links) do
            if (node == A) then
                posB = i
                break

        if (posA == 0 and posB == 0)
            print("unlink : link (#{id1}, #{id2}) did not exist")

        table.remove(A.links, posA)
        table.remove(B.links, posB)
