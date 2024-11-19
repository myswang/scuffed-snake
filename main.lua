local Queue = require("queue")

local max_width = 30
local max_height = 20
local cell_size = 30
local snake_scale = 0.8
local snake_size = cell_size * snake_scale
local middle = (snake_scale + 1) / 2


local screen_width = cell_size * max_width
local screen_height = cell_size * max_height
local start_cell_x = 1
local start_cell_y = 2
local end_cell_x = max_width - 1
local end_cell_y = max_height - 1
local mid_y = math.floor((end_cell_y + start_cell_y) / 2)
local mid_x = math.floor((end_cell_x + start_cell_x) / 2)

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
local game_running = false

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
    game_running = false
    direction = directions.right
    update_timer = tick_rate

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

    Queue.clear(snake)
    Queue.clear(inputs)

    -- create starting snake
    for i = 4, 2, -1 do
        grid[mid_y][start_cell_x+i] = 1
        Queue.pushBack(snake, {y=mid_y, x=start_cell_x+i})
    end

    -- create an apple for testing purposes
    grid[mid_y][mid_x] = 2
end

function love.load()
    love.window.setTitle("Scuffed Snake Game")
    love.window.setMode(screen_width, screen_height)
    love.graphics.setFont(love.graphics.newFont(font_size))

    restart_game()
end

function love.keypressed(key)
    if not game_running then game_running = true end

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
    -- control snake update speed
    update_timer = update_timer - dt
    if update_timer > 0 or game_over or not game_running then
        return
    end
    update_timer = tick_rate

    -- change snake direction
    while not Queue.isEmpty(inputs) do
        local temp = Queue.popFront(inputs)
        if temp ~= direction and (temp.y + direction.y ~= 0 or temp.x + direction.x ~= 0) then
            direction = temp
            break
        end
    end

    -- move the snake
    local head = Queue.peekFront(snake)
    local head_new= {y=head.y+direction.y, x=head.x+direction.x}
    -- check for collision with world boundaries or self
    if head_new.y <= start_cell_y or head_new.x <= start_cell_x
    or head_new.y >= end_cell_y+1 or head_new.x >= end_cell_x+1
    or grid[head_new.y][head_new.x] == 1 then
        game_over = true
    end

    -- grow snake if it collides with an apple
    if grid[head_new.y][head_new.x] == 2 then
        spawn_apple()
        score = score + 1
    else
        local tail = Queue.popBack(snake)
        grid[tail.y][tail.x] = 0
    end

    -- change color of snake head on death
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
    if game_over then
        text:add({{1, 0, 0}, "Game Over! Score: "..score}, 0, 0)
    elseif not game_running then
        text:add({{1, 1, 1}, "Press any key to start!"}, 0, 0)
    else
        text:add({{1, 1, 1}, "Score: "..score}, 0, 0)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(text, 0, 0)

    -- draw the snake
    for i = 1, max_height do
        for j = 1, max_width do
            if grid[i][j] == 1 then
                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle("fill", (j-middle)*cell_size, (i-middle)*cell_size, snake_size, snake_size)
            elseif grid[i][j] == 2 then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", (j-middle)*cell_size, (i-middle)*cell_size, snake_size, snake_size)
            elseif grid[i][j] == 3 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (j-middle)*cell_size, (i-middle)*cell_size, snake_size, snake_size)
            end
        end
    end

end