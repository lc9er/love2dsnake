function love.load()
    lume = require "lume"

    -- Grid size
    gridXCount = 30
    gridYCount = 23
    cellSize = 15

    reset()
end

function getHighScore()
    if love.filesystem.getInfo("snake_high_score.txt") then
        file = love.filesystem.read("snake_high_score.txt")
        hscore = lume.deserialize(file)
    else
        hscore = 0
    end 

    return hscore
end

function reset()
    snakeSegments = {
        { x = 4, y = 3 },
        { x = 3, y = 3 },
        { x = 2, y = 3 },
    }

    -- directionQueue ensures 1 move per loop
    directionQueue = { 'right' }
    moveFood()
    timer = 0 
    snakeAlive = true
    score = 0
    highscore = getHighScore()
end

function setHighScore(newHighScore)
    serialized = lume.serialize(newHighScore)
    love.filesystem.write("snake_high_score.txt", serialized)
end

function checkCollision(x, y)
    -- hit left wall 
    return x * cellSize > cellSize
    -- hit right wall
    and x < gridXCount
    -- top wall
    and y * cellSize > cellSize * 2
    -- bottom wall
    and y < gridYCount
end

function moveFood()
    local possibleFoodPositions = {}

    for foodX = 2, gridXCount - 1 do
        for foodY = 3, gridYCount - 1 do
            local possible = true

            for segmentIndex, segment in ipairs(snakeSegments) do
                if foodX == segment.x and foodY == segment.y then
                    possible = false
                end
            end

            if possible then
                table.insert(possibleFoodPositions, {x = foodX, y = foodY})
            end
        end
    end

    foodPosition = possibleFoodPositions[
    love.math.random(#possibleFoodPositions)
    ]
end

function love.update(dt)
    timer = timer + dt

    if snakeAlive then
        if timer >= 0.15 then
            timer = 0

            if #directionQueue > 1 then
                table.remove(directionQueue, 1)
            end

            -- Current position
            local nextXPosition = snakeSegments[1].x
            local nextYPosition = snakeSegments[1].y

            -- find next position
            if directionQueue[1] == 'right' then
                nextXPosition = nextXPosition + 1
            elseif directionQueue[1] == 'left' then
                nextXPosition = nextXPosition - 1
            elseif directionQueue[1] == 'down' then
                nextYPosition = nextYPosition + 1
            elseif directionQueue[1] == 'up' then
                nextYPosition = nextYPosition - 1
            end

            local canMove = true

            -- check for eating self
            for segmentIndex, segment in ipairs(snakeSegments) do
                if segmentIndex ~= #snakeSegments
                    and nextXPosition == segment.x
                    and nextYPosition == segment.y then
                    canMove = false
                end
            end

            -- check for wall collision
            if canMove 
                and checkCollision(nextXPosition, nextYPosition) then
                canMove = true
            else
                canMove = false
            end

            -- no collisions, advance position
            if canMove then
                table.insert(snakeSegments, 1, {
                        x = nextXPosition, y = nextYPosition
                    })


                if snakeSegments[1].x == foodPosition.x
                    and snakeSegments[1].y == foodPosition.y then
                    moveFood()
                    score = score + 1
                else
                    table.remove(snakeSegments)
                end
            else
                snakeAlive = false
            end
        end
    elseif timer >= 2 then
        if score > highscore then
            setHighScore(score)
        end
        reset()
    end
end

function love.keypressed(key)
    if key == 'right' 
        and directionQueue[#directionQueue] ~= 'right'
        and directionQueue[#directionQueue] ~= 'left' then
        table.insert(directionQueue, 'right')
    elseif key == 'left' 
        and directionQueue[#directionQueue] ~= 'left'
        and directionQueue[#directionQueue] ~= 'right' then
        table.insert(directionQueue, 'left')
    elseif key == 'down' 
        and directionQueue[#directionQueue] ~= 'down'
        and directionQueue[#directionQueue] ~= 'up'then
        table.insert(directionQueue, 'down')
    elseif key == 'up' 
        and directionQueue[#directionQueue] ~= 'up'
        and directionQueue[#directionQueue] ~= 'down' then
        table.insert(directionQueue, 'up')
    end
end

function drawCell(x,y)
    love.graphics.rectangle(
        'fill',
        (x - 1) * cellSize,
        (y - 1) * cellSize,
        cellSize - 1,
        cellSize - 1
        )
end

function love.draw()

    -- love.graphics.setColor(.28, .28, .28)
    -- Scoreboard
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        gridXCount * cellSize,
        2 * cellSize
        )

    -- Top wall 
    love.graphics.setColor(.7, .8, 1)
    for i=0, gridXCount do
        drawCell(i, 2)
    end

    -- Bottom wall 
    love.graphics.setColor(.7, .8, 1)
    for i=0, gridXCount do
        drawCell(i, gridYCount)
    end

    -- Left wall 
    love.graphics.setColor(.7, .8, 1)
    for i=2, gridYCount do
        drawCell(1, i)
    end

    -- Right wall 
    love.graphics.setColor(.7, .8, 1)
    for i=2, gridYCount do
        drawCell(gridXCount, i)
    end


    -- Field of play
    love.graphics.setColor(.28, .28, .28)
    love.graphics.rectangle(
        'fill',
        cellSize,
        2 * cellSize,
        (gridXCount - 2) * cellSize,
        (gridYCount - 3) * cellSize
        )


    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            love.graphics.setColor(.6, 1, .32)
        else
            love.graphics.setColor(.5, .5, .5)
        end
        drawCell(segment.x, segment.y)

    end

    love.graphics.setColor(1, .3, .3)
    drawCell(foodPosition.x, foodPosition.y)

    -- Score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        'Score: ' .. score .. '          HighScore: ' .. highscore ,
        15, 1
        )
end
