local function console_FUNC()
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
            return "0.1.0"
        end,
        wind = term,
        _tCommandHistory = history,
        getColorSymbol = function(str)
            if str ~= nil then
                return "⸿" .. str .. "⸿"
            end
            return "⸿"
        end,
        read = function(tablcompleteFunc)
            table.insert(console._tCommandHistory, read(nil, console._tCommandHistory, tablcompleteFunc, ""))

            local fileStream = fs.open(commandHistoryPath, "w");
            fileStream.write(textutils.serialize(console._tCommandHistory))
            fileStream.close();

            return console._tCommandHistory[#console._tCommandHistory]
        end,
        log = function(...)
            local fullTextString = {}
            for i = 1, #arg, 1 do
                if arg[i] ~= nil then
                    table.insert(fullTextString, console.ToString(arg[i]));
                end
            end

            fullTextString = table.concat(fullTextString, " ")

            local w, h = console.wind.getSize();

            local color = ""
            local gettingEscapeSymbol = false;
            local disableWrite = false;
            local disableChar = false;
            for i = 1, #fullTextString, 1 do
                local char = fullTextString:sub(i, i);
                local x, y = console.wind.getCursorPos();

                if char == console.getColorSymbol() then
                    gettingEscapeSymbol = not gettingEscapeSymbol;
                    disableWrite = gettingEscapeSymbol;

                    if gettingEscapeSymbol == false then
                        local col = colors[color];
                        if col ~= nil then
                            console.wind.setTextColor(col)
                            disableChar = true
                        end
                        color = "";
                    end
                elseif gettingEscapeSymbol then
                    color = color .. fullTextString:sub(i, i)
                end

                if char == "\n" then
                    console.wind.setCursorPos(1, y + 1);
                elseif x > w then
                    console.wind.setCursorPos(1, y + 1);
                elseif (not disableWrite) and (not disableChar) then
                    console.wind.write(char)
                end
                disableChar = false
            end
        end,
        warn = function(...)
            console.log(console.getColorSymbol("yellow"))
            console.log(...)
        end,
        clear = function ()
            console.wind.setCursorPos(1, 1)
            console.wind.clear();
        end,
        ToString = function(value)
            if type(value) == "string" then
                return value;
            elseif type(value) == "number" then
                return tostring(value);
            elseif type(value) == "boolean" then
                if value then
                    return "true"
                else
                    return "false"
                end
            elseif type(value) == "table" then
                return util.string.trim(textutils.serialise(value):gsub("\n", ""));
            elseif type(value) == "function" then
                local info = debug.getinfo(value);
                local functionParams = {};

                for i = 1, info.nparams, 1 do
                    table.insert(functionParams, i, table.concat({ debug.getlocal(value, i) }, ": "));
                end

                return (info.name or "func") .. "(" .. table.concat(functionParams, ", ") .. ")";
            elseif type(value) == "nil" or value == nil then
                return "nil";
            end

            return debug.getinfo(value)
        end,
        clearCommandHistory = function()
            local fileStream = fs.open(commandHistoryPath, "w");
            fileStream.write("{\n}")
            fileStream.close();
        end
    }
end

_G.console = console_FUNC();
