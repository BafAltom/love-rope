love.load = ->
    require "rope"
    require "variables"
    require "resources"
    require "obstacle"

    ropePlayer = Rope()
    obstacles = defaultObstacleList()

love.update = (dt) ->
    FPS = 1/dt
    --love.timer.sleep(0.1)
    ropePlayer\update dt

    for i, o in ipairs(obstacles) do
        o\update(dt)

love.draw = ->
    love.graphics.setColor(255,255,255)
    love.graphics.print("FPS: "..round(FPS), 10, 10)
    ropePlayer\draw()

    for i, o in ipairs(obstacles) do
        o\draw()

love.mousepressed = (x, y, b) ->
    rope\mousepressed(x, y, b)

love.mousereleased = (x, y, b) ->
    rope\mousereleased(x, y, b)

love.keyreleased = (k) ->
    if k == "escape" then
        love.event.quit()

round = (num, idp) ->
    mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
