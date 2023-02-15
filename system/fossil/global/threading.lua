local function THREADING_FUNC()
    -- https://pastebin.com/KYtYxqHh

    local runningThreads = {}
    local waitingThreads = {}

    local function tick(thread, ...)
        if thread.dead then return end

        coroutine.resume(thread.coroutine, ...)
        thread.dead = (coroutine.status(thread.coroutine) == "dead")
    end

    local function tickAll()
        if #waitingThreads > 0 then
            local waitingThreadsClone = waitingThreads
            waitingThreads = {}
            for _, thread in ipairs(waitingThreadsClone) do
                tick(thread)
                table.insert(runningThreads, thread)
            end
        end
        local yield = { coroutine.yield() }
        local dead = {}
        for k, thread in ipairs(runningThreads) do
            tick(thread, table.unpack(yield))
            if thread.dead then
                table.insert(dead, k - #dead)
            end
        end
        for _, threadIndex in ipairs(dead) do
            table.remove(runningThreads, threadIndex)
        end
    end

    return {
        Start = function()
            while #runningThreads > 0 or #waitingThreads > 0 do
                tickAll()
            end
        end,
        createThread = function(action, callback, name)
            local t = {}

            t = {
                coroutine = coroutine.create(
                    function()
                        local result = { pcall(action) }

                        if result[1] then
                            callback({ table.unpack(result, 2) }, "success");
                        else
                            callback({ table.unpack(result, 2) }, "error");
                        end
                    end
                ),
                dead = false,
                name = name or "generic_thread"
            }

            table.insert(waitingThreads, t)
        end
    }
end

_G.threading = THREADING_FUNC();
