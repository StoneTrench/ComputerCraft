local function TURT_Q_FUNC()
    local programName = "TURT_Q"

    local shouldStop = false;

    local function updateLoop()
        threading.createThread(
            function()
                while not shouldStop do
                    local queueSize = F.programData.getOrCreate(programName, "queue", "length", 0)

                    if queueSize > 0 then
                        local element = F.programData.getOrCreate(programName, "queue", "q" .. queueSize);
                        if element then
                            util.table.getFromPath(_G, element.path)(table.unpack(element.params));
                        end
                        F.programData.set(programName, "queue", "length", queueSize - 1)
                    end

                    sleep(1);
                end
            end,
            function(result, status)
                console.log(result)
            end,
            "TURT_Q_updateLoop"
        )
    end

    updateLoop();

    return {
        queueFunctionCall = function(globalFunctionPath, ...)
            local queueSize = F.programData.getOrCreate(programName, "queue", "length", 0)

            F.programData.set(programName, "queue", "length", queueSize + 1)
            F.programData.set(programName, "queue", "q" .. (queueSize + 1), {
                path = globalFunctionPath,
                params = { ... }
            })
        end,
        cancelAll = function()
            F.programData.delete(programName, "queue")
        end,
        stop = function()
            shouldStop = true;
        end
    }
end

TURT_Q = TURT_Q_FUNC()
