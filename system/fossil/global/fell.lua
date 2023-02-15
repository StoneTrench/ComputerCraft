local function fell_FUNC()
    local commandHistoryPath = fs.combine(F.PATHS.DIR.global, "../.commandHistory");

    local fileStream = fs.open(commandHistoryPath, "r");
    local history
    if fileStream then
        history = textutils.unserialize(fileStream.readAll()) or {};
        fileStream.close();
    else
        history = {}
    end

    return {
        version = function()
            return "1.0.0";
        end,
        completionPaths = {
            "rom/programs/",
            F.PATHS.DIR.commands_fossil,
            F.PATHS.DIR.commands,
        },
        commandHistory = history,
        scrollPos = 0,
        getCompletionPaths = function()
            return util.table.combine(fell.completionPaths, { [#fell.completionPaths + 1] = shell.dir() })
        end,
        getProgramPath = function(name)
            if name ~= nil then
                for key, value in pairs(fell.getCompletionPaths()) do
                    local completion = fs.complete(name, value)

                    if #completion > 0 then
                        if completion[1] == ".lua" then
                            return fs.combine(value, name .. completion[1]);
                        end
                    end
                end
            end

            return nil;
        end,
        readCommand = function(writePrefix, commandCompletedCallback)
            if writePrefix then
                console.write(
                    CONSOLE.getColorSymbol("green") ..
                    os.getComputerLabel() .. " " ..
                    CONSOLE.getColorSymbol("purple") ..
                    fell.version() .. " " ..
                    CONSOLE.getColorSymbol("yellow") .. "~/" ..
                    shell.dir() .. "\n" ..
                    CONSOLE.getColorSymbol("white") .. "$ "
                )
            end
            local command = ""

            command = console.input.read(fell.commandHistory, fell.complete)

            if fell.commandHistory[#fell.commandHistory] ~= command then
                table.insert(fell.commandHistory, command)

                local fileStream = fs.open(commandHistoryPath, "w");
                fileStream.write(textutils.serialize(fell.commandHistory))
                fileStream.close();
            end

            return fell.run(command, commandCompletedCallback)
        end,
        run = function(command, commandCompletedCallback)
            local tokens = fell.fromShell.tokenise(command);
            local program = fell.getProgramPath(tokens[1]);
            if not program then
                console.warn(tokens[1], "command not found!\n")
                return;
            end

            program = fell.resolveGlobal(program)

            threading.createThread(
                function()
                    shell.execute(program, table.unpack(tokens, 2))
                end,
                commandCompletedCallback
            )
            return true
        end,
        complete = function(sLine)
            if #sLine > 0 then
                for key, value in pairs(fell.getCompletionPaths()) do
                    local completion = fs.complete(sLine, value)

                    if #completion > 0 then
                        return util.table.map(completion, function(e)
                            return e:gsub(".lua", "")
                        end);
                    end
                end
            end
            return nil
        end,
        clearCommandHistory = function()
            local fileStream = fs.open(commandHistoryPath, "w");
            fileStream.write("{\n}")
            fileStream.close();
        end,
        resolveGlobal = function (globalPath)
            local shellDir = shell.dir();
            
            local _, c = shellDir:gsub("/", "")

            if c == 0 then
                _, c = shellDir:gsub("\\", "")
            end
            if c == 0 and #shellDir > 0 then
                c = 1;
            end
            
            return fs.combine(string.rep("../", c, ""), globalPath);
        end,
        fromShell = {
            tokenise = function(...)
                local sLine = table.concat({ ... }, " ")
                local tWords = {}
                local bQuoted = false
                for match in string.gmatch(sLine .. "\"", "(.-)\"") do
                    if bQuoted then
                        table.insert(tWords, match)
                    else
                        for m in string.gmatch(match, "[^ \t]+") do
                            table.insert(tWords, m)
                        end
                    end
                    bQuoted = not bQuoted
                end
                return tWords
            end
        },
        startInstance = function()
            -- print header
            local name, version      = F.getName();
            local license, copyright = F.getLicenseCopyright();
            console.log(CONSOLE.getColorSymbol("yellow") .. name .. "\t" .. version)
            console.log(license .. "\t" .. copyright .. CONSOLE.getColorSymbol("white"))

            local runningCommand = false;
            local function threadCallback(result1, status1)
                threading.createThread(
                    function()
                        if not runningCommand then
                            if fell.readCommand(true, function()
                                    runningCommand = false
                                end)
                            then
                                runningCommand = true
                            end
                        end
                    end,
                    threadCallback
                )
            end

            threadCallback()
        end,
    }
end


_G.fell = fell_FUNC()
