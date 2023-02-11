local function CONSOLE_FUNC()
    local CONSOLES = {};

    return {
        version = function()
            return "1.0.0"
        end,
        getConsoleById = function(id)
            return util.table.find(CONSOLES, function (e)
                return e.id == id;
            end)
        end,
        getConsoleByWind = function(wind)
            return util.table.find(CONSOLES, function (e)
                return e.wind == wind;
            end)
        end,
        createConsole = function(_wind, _id)
            local cons = {}

            cons = {
                id = _id,
                wind = _wind,
                read = function(history, tablcompleteFunc)
                    local result = read(nil, history, tablcompleteFunc, "")
                    return result
                end,
                write = function(...)
                    local fullTextString = {}
                    for i = 1, #arg, 1 do
                        if arg[i] ~= nil then
                            table.insert(fullTextString, CONSOLE.ToString(arg[i]));
                        end
                    end

                    fullTextString = table.concat(fullTextString, " ")

                    local w, h = cons.wind.getSize();

                    local color = ""
                    local gettingEscapeSymbol = false;
                    local disableWrite = false;
                    local disableChar = false;
                    local i = 1;
                    local count = #fullTextString;
                    while i <= count do
                        local char = fullTextString:sub(i, i);

                        if char == CONSOLE.getColorSymbol() then
                            gettingEscapeSymbol = not gettingEscapeSymbol;
                            disableWrite = gettingEscapeSymbol;

                            if gettingEscapeSymbol == false then
                                local col = colors[color];
                                if col ~= nil then
                                    cons.wind.setTextColor(col)
                                    disableChar = true
                                end
                                color = "";
                            end
                        elseif gettingEscapeSymbol then
                            color = color .. fullTextString:sub(i, i)
                        end

                        if char == "\n" then
                            local x, y = cons.wind.getCursorPos();
                            cons.wind.setCursorPos(1, y + 1);
                            disableChar = true;
                        end
                        if char == "\t" then
                            local tabSize = F.settings.get("console.tabSize", 3) + 1;
                            local x, y = cons.wind.getCursorPos();
                            cons.wind.setCursorPos(math.ceil(x / tabSize) * tabSize + 1, y)
                            disableChar = true;
                        end
                        local x, y = cons.wind.getCursorPos();
                        if x > w then
                            cons.wind.setCursorPos(1, y + 1);
                        end
                        local x, y = cons.wind.getCursorPos();
                        if y > h then
                            term.scroll(1)
                            term.setCursorPos(x, y - 1)
                        end

                        if (not disableWrite) and (not disableChar) then
                            cons.wind.write(char)
                        end
                        disableChar = false

                        i = i + 1
                    end
                end,
                log = function(...)
                    local a = { ... }
                    table.insert(a, "\n")
                    cons.write(table.unpack(a))
                end,
                warn = function(...)
                    cons.write(CONSOLE.getColorSymbol("yellow"))
                    cons.log(...)
                    cons.write(CONSOLE.getColorSymbol("white"))
                end,
                clear = function()
                    cons.wind.setCursorPos(1, 1)
                    cons.wind.clear();
                end,
            }

            table.insert(CONSOLES, cons);

            return cons;
        end,
        getColorSymbol = function(str)
            if str ~= nil then
                return "§" .. str .. "§"
            end
            return "§"
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
    }
end

_G.CONSOLE = CONSOLE_FUNC();
