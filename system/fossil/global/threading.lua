local function THREADING_FUNC()
    local waitingThreads = {}
    local maxThreadTimeout = 256;
    local defaultThreadTimeout = 8;
    local currentlyThreading = false;

    local shouldEnd = false;

    local events = {
        "fossil.threading.thread.create"
    }

    return {
        Start = function()
            parallel.waitForAll(
                function()
                    while not shouldEnd do
                        if (#waitingThreads > 0) and (not currentlyThreading) then
                            currentlyThreading = true

                            local threads = { table.unpack(waitingThreads) }
                            waitingThreads = {};
                            parallel.waitForAll(table.unpack(threads))

                            currentlyThreading = false;
                        end

                        sleep(0)
                    end
                end
            )
        end,
        End = function()
            shouldEnd = true;
        end,
        isThreading = function()
            return currentlyThreading;
        end,
        timeoutFunction = function(func, timeout, ...)
            local a = { ... }

            return parallel.waitForAny(
                    function() sleep(timeout) end,
                    function() func(table.unpack(a)) end
                ) == 2;
        end,
        --[[-Creates a thread and adds it to the thread queue.

            ---@param action () -> any
            ---@param callback (result: any, status: "success"|"error"|"timeout") -> void
            ---@param timeout seconds
        ]] --
        createThread = function(action, callback, timeout)
            if timeout == nil then timeout = defaultThreadTimeout end
            if timeout > maxThreadTimeout then timeout = maxThreadTimeout end

            local t = function()
                if not threading.timeoutFunction(
                        function()
                            local actionResult = { pcall(action) };

                            if callback ~= nil then
                                if actionResult[1] then
                                    callback({ table.unpack(actionResult, 2) }, "success")
                                else
                                    callback({ table.unpack(actionResult, 2) }, "error")
                                end
                            end
                        end, timeout) then
                    if callback ~= nil then
                        callback({}, "timeout")
                    end
                end
            end
            table.insert(waitingThreads, t)

            os.queueEvent(events[1])

            return t;
        end
    }
end

_G.threading = THREADING_FUNC();
