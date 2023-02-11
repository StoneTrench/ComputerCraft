local function fell_FUNC()
    local commandHistoryPath = fs.combine(F.PATHS.global, "../.commandHistory");

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
            F.PATHS.commands,
            "rom/programs/",
        },
        commandHistory = history,
        scrollPos = 0,
        getCompletionPaths = function()
            return util.table.combine(fell.completionPaths, { [#fell.completionPaths + 1] = shell.dir() })
        end,
        getProgramPath = function(name)
            if name ~= nil then
                for key, value in pairs(fell.getCompletionPaths()) do
                    local completion = fs.complete(name, shell.resolve(value))

                    if #completion > 0 then
                        if completion[1] == ".lua" then
                            return fs.combine(shell.resolve(value), name .. completion[1]);
                        end
                    end
                end
            end

            return nil;
        end,
        readCommand = function()
            console.write(
                CONSOLE.getColorSymbol("green") ..
                os.getComputerLabel() .. " " ..
                CONSOLE.getColorSymbol("purple") ..
                fell.version() .. " " ..
                CONSOLE.getColorSymbol("yellow") .. "~/" ..
                shell.dir() .. "\n" ..
                CONSOLE.getColorSymbol("white") .. "$ "
            )
            local command = ""

            -- parallel.waitForAny(
            --     function()
            command = console.read(fell.commandHistory, fell.complete)
            --     end,
            --     function()
            --         while true do
            --             local event, key, isHeld = os.pullEvent("key")

            --             if key == keys.up then
            --                 console.wind.scroll(-1)
            --                 fell.scrollPos = fell.scrollPos - 1;
            --             elseif key == keys.down then
            --                 console.wind.scroll(1)
            --                 fell.scrollPos = fell.scrollPos + 1;
            --             end

            --             sleep(0.1)
            --         end
            --     end
            -- );

            if fell.commandHistory[#fell.commandHistory] ~= command then
                table.insert(fell.commandHistory, command)

                local fileStream = fs.open(commandHistoryPath, "w");
                fileStream.write(textutils.serialize(fell.commandHistory))
                fileStream.close();
            end

            local tokens = fell.fromShell.tokenise(command);
            local program = fell.getProgramPath(tokens[1]);
            if not program then
                console.warn(tokens[1], "command not found!\n")
                return
            end
            shell.run(program, table.unpack(tokens, 2))
        end,
        complete = function(sLine)
            if #sLine > 0 then
                for key, value in pairs(fell.getCompletionPaths()) do
                    local completion = fs.complete(sLine, shell.resolve(value))

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
    }
end


_G.fell = fell_FUNC()
