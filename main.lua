local Queue = require("queue")

local max_width = 30
local max_height = 20
local cell_size = 30
local snake_size = cell_size * 0.8

local screen_width = cell_size * max_width
local screen_height = cell_size * max_height
local start_cell_x = 1
local start_cell_y = 2
local end_cell_x = max_width - 1
local end_cell_y = max_height - 1

local font_size = cell_size

local grid = {}
local snake = Queue.new()

local directions = {
    up = {y=-1, x=0},
    down = {y=1, x=0},
    left = {y=0, x=-1},
    right = {y=0, x=1}
}

local direction = directions.right
local inputs = Queue.new()

local tick_rate = 0.1
local update_timer = tick_rate

local score = 0
local game_over = false

local function spawn_apple()
    local empty_spots = {}
    -- get a list of all empty slots
    for i = 1, max_height do
        for j = 1, max_width do
            if grid[i][j] == 0 then
                table.insert(empty_spots, ({y=i, x=j}))
            end
        end
    end
    -- select one of them at random
    local new_spot = empty_spots[math.random(#empty_spots)]
    grid[new_spot.y][new_spot.x] = 2
end

local function restart_game()
    math.randomseed(os.time() + os.clock() * 1000000)
    score = 0
    game_over = false
    direction = directions.right

    -- generate game grid
    for i = 1, max_height do
        grid[i] = {}
        for j = 1, max_width do
            if i <= start_cell_y or j <= start_cell_x or i >= end_cell_y+1 or j >= end_cell_x+1 then
                grid[i][j] = 4
            else
                grid[i][j] = 0
            end
        end
    end

    -- create starting snake
    grid[5][5] = 1
    grid[5][4] = 1
    grid[5][3] = 1

    Queue.clear(snake)
    Queue.pushBack(snake, {y=5, x=5})
    Queue.pushBack(snake, {y=5, x=4})
    Queue.pushBack(snake, {y=5, x=3})

    Queue.clear(inputs)
    update_timer = tick_rate

    -- create an apple for testing purposes
    spawn_apple()
end

function love.load()
    love.window.setTitle("Scuffed Snake Game")
    love.window.setMode(screen_width, screen_height)
    love.graphics.setFont(love.graphics.newFont(font_size))

    restart_game()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "return" then
        restart_game()
    elseif key == "w" or key == "up" then
        Queue.pushBack(inputs, directions.up)
    elseif key == "s" or key == "down" then
        Queue.pushBack(inputs, directions.down)
    elseif key == "a" or key == "left" then
        Queue.pushBack(inputs, directions.left)
    elseif key == "d" or key == "right" then
        Queue.pushBack(inputs, directions.right)
    end
end

function love.update(dt)
    update_timer = update_timer - dt
    if update_timer > 0 or game_over then
        return
    end
    update_timer = tick_rate
    -- change snake direction
    if not Queue.isEmpty(inputs) then
        local temp = Queue.popFront(inputs)
        if temp.y + direction.y ~= 0 or temp.x + direction.x ~= 0 then
            direction = temp
        end
    end

    -- move the snake
    local head = Queue.peekFront(snake)
    local head_new= {y=head.y+direction.y, x=head.x+direction.x}
    -- check for collision with world boundaries or self
    if head_new.y <= start_cell_y or head_new.x <= start_cell_x
    or head_new.y >= end_cell_y+1 or head_new.x >= end_cell_x+1
    or grid[head_new.y][head_new.x] == 1 then
        grid[head_new.y][head_new.x] = 3
        game_over = true
    end

    if grid[head_new.y][head_new.x] == 2 then
        spawn_apple()
        score = score + 1
    else
        local tail = Queue.popBack(snake)
        grid[tail.y][tail.x] = 0
    end

    if game_over then
        grid[head_new.y][head_new.x] = 3
    else
        grid[head_new.y][head_new.x] = 1
    end
    Queue.pushFront(snake, head_new)

end

function love.draw()
    -- draw world boundaries
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle(
        "fill", 
        start_cell_x*cell_size, 
        start_cell_y*cell_size, 
        cell_size*(end_cell_x-start_cell_x),
        cell_size*(end_cell_y-start_cell_y)
    )

    -- draw scoreboard
    local font = love.graphics.getFont()
    local text = love.graphics.newText(font)
    text:add({{1, 1, 1}, "Score: " .. score}, 0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(text, 0, 0)

    -- draw the snake
    for i = 1, max_height do
        for j = 1, max_width do
            if grid[i][j] == 1 then
                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle("fill", (j-0.9)*cell_size, (i-0.9)*cell_size, snake_size, snake_size)
            elseif grid[i][j] == 2 then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", (j-0.9)*cell_size, (i-0.9)*cell_size, snake_size, snake_size)
            elseif grid[i][j] == 3 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (j-0.9)*cell_size, (i-0.9)*cell_size, snake_size, snake_size)
            end
        end
    end

end