local Queue = {}

function Queue.new()
    return {first = 0, last = -1, length = 0, items = {}}
end

function Queue.pushFront(queue, value)
    local first = queue.first - 1
    queue.first = first
    queue.items[first] = value
    queue.length = queue.length + 1
end

function Queue.pushBack(queue, value)
    local last = queue.last + 1
    queue.last = last
    queue.items[last] = value
    queue.length = queue.length + 1
end

function Queue.popFront(queue)
    local first = queue.first
    if first > queue.last then error("Queue is empty") end
    local value = queue.items[first]
    queue.items[first] = nil
    queue.first = first + 1
    queue.length = queue.length - 1

    return value
end

function Queue.popBack(queue)
    local last = queue.last
    if queue.first > last then error("Queue is empty") end
    local value = queue.items[last]
    queue.items[last] = nil
    queue.last = last - 1
    queue.length = queue.length - 1

    return value
end

function Queue.peekFront(queue)
    if queue.first > queue.last then
        error("Queue is empty")
    end
    return queue.items[queue.first]
end

function Queue.peekBack(queue)
    if queue.first > queue.last then
        error("Queue is empty")
    end
    return queue.items[queue.last]
end

function Queue.isEmpty(queue)
    return queue.length == 0
end

function Queue.length(queue)
    return queue.length
end

function Queue.clear(queue)
    queue.first = 0
    queue.last = -1
    queue.length = 0
    queue.items = {}
end

return Queue