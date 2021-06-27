function love.load()
    -- Grid size
    gridXCount = 30
    gridYCount = 23
    cellSize = 15

    reset()
end

function reset()
    snakeSegments = {
        { x = 3, y = 1 },
        { x = 2, y = 1 },
        { x = 1, y = 1 },
    }

    -- directionQueue ensures 1 move per loop
    directionQueue = { 'right' }
    moveFood()
    timer = 0 
    snakeAlive = true
end

function checkCollision(x, y)
    return x * cellSize > 0
    and x < gridXCount + 1
    and y * cellSize > 0
    and y < gridYCount + 1
end

function moveFood()
    local possibleFoodPositions = {}

    for foodX = 1, gridXCount do
        for foodY = 1, gridYCount do
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
            if checkCollision(nextXPosition, nextYPosition) then
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
                else
                    table.remove(snakeSegments)
                end
            else
                snakeAlive = false
            end
        end
    elseif timer >= 2 then
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

    love.graphics.setColor(.28, .28, .28)
    love.graphics.rectangle(
        'fill',
        0,
        0,
        gridXCount * cellSize,
        gridYCount * cellSize
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

    -- -- Temporary (debugging)
    -- for directionIndex, direction in ipairs(directionQueue) do
    --     love.graphics.setColor(1, 1, 1)
    --     love.graphics.print(
    --         'X Coord:[' ..snakeSegments[1].x.. '], Y Coord:[' .. snakeSegments[1].y .. ']',
    --         15, 15 * directionIndex
    --     )
    -- end
end
