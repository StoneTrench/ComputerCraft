local function CONSOLE_FUNC()
    local CONSOLES = {};

    return {
        version = function()
            return "1.0.0"
        end,
        getConsoleById = function(id)
            return util.table.find(CONSOLES, function(e)
                    return e.id == id;
                end)
        end,
        getConsoleByWind = function(wind)
            return util.table.find(CONSOLES, function(e)
                    return e.wind == wind;
                end)
        end,
        createConsole = function(_wind, _id, _margins)
            local cons = {}

            cons = {
                id = _id,
                wind = _wind,
                margins = _margins or {
                    top = 0,
                    bottom = 0,
                    left = 0,
                    right = 0
                },
                input = {
                    reading = false,
                    string = nil,
                    -- number
                    textPos = nil,
                    tabcompleteIndex = nil,
                    historyIndex = nil,
                    startCursorX = nil,
                    startCursorY = nil,
                    read = function(history, tabCompleteFunc, default, textCursor, iscursorcolor)
                        if not iscursorcolor then iscursorcolor = true end
                        if not textCursor then textCursor = CONSOLE.getColorSymbol("gray") end

                        history = util.table.reverse(history)

                        if not reading then
                            cons.input.string = default or "";
                            cons.input.tabcompleteIndex = 0;
                            cons.input.historyIndex = 0;
                            cons.input.textPos = 1;
                            cons.input.startCursorX, cons.input.startCursorY = cons.wind.getCursorPos();
                            reading = true

                            if not iscursorcolor then
                                cons.write(cons.input.string .. textCursor)
                            end
                        end

                        local w, h = cons.wind.getSize();

                        repeat
                            local index, eventData = util.pullEventAny("key", "char")
                            local keyChar = eventData[2];

                            local tabComplete = tabCompleteFunc and (tabCompleteFunc(cons.input.string) or {}) or {};

                            if index == 1 then
                                -- #region edit
                                if (keyChar == keys.enter or keyChar == keys.right) and (
                                    ((cons.input.tabcompleteIndex == 0) and (history[cons.input.historyIndex] ~= nil)) or
                                    (tabComplete[cons.input.tabcompleteIndex] ~= nil)
                                    )
                                then
                                    if (cons.input.tabcompleteIndex == 0) and (history[cons.input.historyIndex] ~= nil) then
                                        cons.input.string = history[cons.input.historyIndex];

                                        cons.input.historyIndex = 0;
                                        cons.input.textPos = #cons.input.string + 1
                                        keyChar = nil
                                    elseif tabComplete[cons.input.tabcompleteIndex] ~= nil then
                                        cons.input.string = cons.input.string .. tabComplete
                                            [cons.input.tabcompleteIndex];

                                        cons.input.tabcompleteIndex = 0;
                                        cons.input.textPos = #cons.input.string + 1
                                        keyChar = nil
                                    end
                                elseif keyChar == keys.left then
                                    cons.input.textPos = cons.input.textPos - 1
                                    if cons.input.textPos < 1 then
                                        cons.input.textPos = 1
                                    end
                                elseif keyChar == keys.right then
                                    cons.input.textPos = cons.input.textPos + 1
                                    if cons.input.textPos > #cons.input.string + 1 then
                                        cons.input.textPos = #cons.input.string + 1
                                    end
                                    --#endregion
                                    --#region history
                                elseif keyChar == keys.down then
                                    cons.input.historyIndex = cons.input.historyIndex - 1
                                    if cons.input.historyIndex < 0 then
                                        cons.input.historyIndex = 0
                                    end
                                    cons.input.tabcompleteIndex = 0
                                elseif keyChar == keys.up then
                                    cons.input.historyIndex = cons.input.historyIndex + 1
                                    if cons.input.historyIndex > #history then
                                        cons.input.historyIndex = #history
                                    end
                                    cons.input.tabcompleteIndex = 0
                                    --#endregion
                                    --#region complete
                                elseif keyChar == keys.tab then
                                    cons.input.tabcompleteIndex = cons.input.tabcompleteIndex + 1
                                    if cons.input.tabcompleteIndex > #tabComplete then
                                        cons.input.tabcompleteIndex = 0
                                    end

                                    --#endregion
                                    --#region edit
                                elseif keyChar == keys.backspace then
                                    if cons.input.textPos > 1 then
                                        cons.input.string = cons.input.string:sub(1, cons.input.textPos - 2) ..
                                            cons.input.string:sub(cons.input.textPos);

                                        cons.input.textPos = cons.input.textPos - 1
                                    end
                                elseif keyChar == keys.delete then
                                    if cons.input.textPos < #cons.input.string + 1 then
                                        cons.input.string = cons.input.string:sub(1, cons.input.textPos - 1) ..
                                            cons.input.string:sub(cons.input.textPos + 1);
                                    end
                                end
                                --#endregion
                            else
                                cons.input.string = cons.input.string:sub(1, cons.input.textPos - 1) ..
                                    keyChar .. cons.input.string:sub(cons.input.textPos);
                                cons.input.textPos = cons.input.textPos + 1
                            end

                            cons.wind.setCursorPos(cons.input.startCursorX, cons.input.startCursorY)

                            if iscursorcolor then
                                cons.write(cons.input.string:sub(1, cons.input.textPos - 1));
                                local defaultbkgcol = cons.wind.getBackgroundColor()
                                cons.wind.setBackgroundColor(colors[textCursor:sub(2, #textCursor - 1)])

                                local c = cons.input.string:sub(cons.input.textPos, cons.input.textPos);

                                cons.write(c);

                                cons.wind.setBackgroundColor(defaultbkgcol)
                                cons.write(cons.input.string:sub(cons.input.textPos + 1));
                            else
                                cons.write(
                                    cons.input.string:sub(1, cons.input.textPos - 1) ..
                                    textCursor ..
                                    cons.input.string:sub(cons.input.textPos)
                                )
                            end

                            local defaultbkgcol = cons.wind.getBackgroundColor()
                            cons.wind.setBackgroundColor(colors.gray)
                            if cons.input.tabcompleteIndex == 0 then
                                cons.write(history[cons.input.historyIndex] or "")
                            else
                                cons.write(tabComplete[cons.input.tabcompleteIndex] or "")
                            end
                            cons.wind.setBackgroundColor(defaultbkgcol)

                            local x, _ = cons.wind.getCursorPos();
                            cons.write(string.rep(" ", w - x))
                        until index == 1 and keyChar == keys.enter

                        console.log()

                        reading = false;
                        return cons.input.string;
                    end,
                },
                write = function(...)
                    local fullTextString = {}
                    for i = 1, #arg, 1 do
                        if arg[i] ~= nil then
                            table.insert(fullTextString, CONSOLE.ToString(arg[i]));
                        end
                    end

                    fullTextString = table.concat(fullTextString, " ") or ""

                    if #fullTextString == 0 then
                        return;
                    end

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
                            cons.wind.setCursorPos(cons.margins.left + 1, y + 1);
                            disableChar = true;
                        end
                        if char == "\t" then
                            local tabSize = F.settings.get("console.tabSize", 3) + 1;
                            local x, y = cons.wind.getCursorPos();
                            cons.wind.setCursorPos(math.ceil(x / tabSize) * tabSize + 1, y)
                            disableChar = true;
                        end
                        local x, y = cons.wind.getCursorPos();
                        if x > w - cons.margins.right then
                            cons.wind.setCursorPos(cons.margins.left + 1, y + 1);
                        end
                        local x, y = cons.wind.getCursorPos();
                        if y > h - cons.margins.bottom then
                            cons.wind.scroll(1)
                            cons.wind.setCursorPos(cons.margins.left + 1, y - 1 - cons.margins.bottom)
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
                error = function(...)
                    cons.write(CONSOLE.getColorSymbol("red"))
                    cons.log(...)
                    cons.write(CONSOLE.getColorSymbol("white"))
                end,
                clear = function()
                    cons.wind.clear();
                    cons.wind.setCursorPos(1, 1);
                end,
                redirectGlobalCommands = function()
                    _G.print = cons.log;
                    _G.warn = cons.warn;
                    _G.printError = cons.error;
                end
            }

            table.insert(CONSOLES, cons);

            return cons;
        end,
        getColorSymbol = function(str)
            if str ~= nil then
                return CONSOLE.getColorSymbol() .. str .. CONSOLE.getColorSymbol();
            end
            return "§";
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
