local function UTILITY_FUNC()
    local circleCounts = {
        { 1, 1 },
        { 2, 6 },
        { 3, 8 },
        { 4, 12 },
        { 6, 16 },
        { 7, 20 },
        { 9, 24 },
        { 11, 28 },
        { 13, 32 },
        { 14, 36 },
        { 16, 40 },
        { 18, 44 },
        { 19, 48 },
        { 21, 52 },
        { 23, 56 },
        { 25, 60 },
        { 27, 64 },
        { 28, 68 },
        { 30, 72 },
        { 32, 76 },
        { 33, 80 },
        { 35, 84 },
        { 37, 88 },
        { 38, 92 },
        { 40, 96 },
        { 41, 100 },
        { 43, 104 },
        { 45, 108 },
        { 47, 112 },
        { 49, 116 },
        { 51, 120 },
        { 53, 124 },
        { 54, 128 },
        { 56, 132 },
        { 58, 136 },
        { 59, 140 },
        { 61, 144 },
        { 63, 148 },
        { 65, 152 },
        { 66, 148 },
        { 68, 160 },
        { 69, 156 },
        { 71, 164 },
        { 72, 168 },
        { 73, 172 },
        { 75, 176 },
        { 76, 180 },
        { 79, 188 },
        { 82, 196 },
        { 86, 204 },
        { 90, 212 },
        { 95, 220 },
        { 100, 228 },
        { 106, 236 },
        { 113, 244 },
        { 120, 252 },
        { 129, 260 },
        { 139, 268 },
        { 152, 276 },
        { 166, 284 },
        { 184, 292 },
        { 207, 300 },
        { 236, 308 },
        { 275, 316 },
        { 330, 324 },
        { 412, 332 },
        { 548, 340 },
        { 822, 348 },
        { 1642, 356 },
    }
    local function FindClosestCircleStep(radius)
        local result = circleCounts[#circleCounts][2];

        for i = 1, #circleCounts, 1 do
            if circleCounts[i][1] > radius then
                if i == 1 then
                    result = circleCounts[i][2];
                else
                    result = circleCounts[i - 1][2];
                end

                break;
            end
        end

        return 360 / result;
    end

    return {
        version = function ()
            return "1.0.0"
        end,
        eval = function(lua_code, ...)
            local func, err = load(lua_code, "lua_code", "t", _ENV)
            if not func then
                error(err)
                return
            end
            local success, msg = pcall(func, select(3, ...))
            if not success then
                error(msg)
            end
        end,
        PullEventTimeout = function(event, sec)
            local result = nil

            local function Event()
                result = { os.pullEvent(event) }
            end

            local function Timeout()
                sleep(sec)
            end

            parallel.waitForAny(Event, Timeout)
            return result;
        end,
        IteratorToArray = function(itterator)
            local result = {}
            for value in itterator do
                table.insert(result, value);
            end
            return result;
        end,
        fs = {
            writeFile = function(path, data)
                local file = fs.open(path, "w");
                file.write(data);
                file.close();
            end,
            readFile = function(path)
                if not fs.exists(path) then
                    error("File not found! (" .. path .. ")")
                end
                if fs.isDir(path) then
                    error("Cannot read a directory! (" .. path .. ")")
                end

                local file = fs.open(path, "r");
                local data = file.readAll();
                file.close();
                return data;
            end,
            tree = function(path)
                if not fs.exists(path) then
                    error("Path not found! (" .. path .. ")")
                end

                local result = {};

                local function t(p, parent)
                    local files = fs.list(p)
                    local name = fs.getName(p)

                    parent[name] = {}

                    for index, value in ipairs(files) do
                        local fp = p .. "/" .. value;
                        if fs.isDir(fp) then
                            t(fp, parent[name])
                        else
                            parent[name][value] = (#UTILITY.fs.readFile(fp) * 1E-3) .. " kb"
                        end
                    end
                end

                t(path, result);

                return result;
            end,
        },
        table = {
            reduce = function(arrayTable, func)
                local result = arrayTable[1]
                for i = 2, #arrayTable, 1 do
                    result = func(result, arrayTable[i])
                end
                return result;
            end,
            reverse = function(arrayTable)
                local result = {}
                for i = #arrayTable, 1, -1 do
                    result[#result + 1] = arrayTable[i]
                end
                return result;
            end,
            map = function(table, func)
                local result = {}
                for key, value in pairs(table) do
                    result[key] = func(value, key, table)
                end
                return result;
            end,
            filter = function(table, func)
                local result = {}
                for key, value in pairs(table) do
                    if func(value, key, table) then
                        result[key] = table[key]
                    end
                end
                return result;
            end,
            contains = function(table, val)
                for key, value in pairs(table) do
                    if value == val then
                        return true
                    end
                end
                return false
            end,
            find = function (table, predicate)
                for key, value in pairs(table) do
                    if predicate(value, key, table) then
                        return value
                    end
                end
                return nil
            end
        },
        string = {
            findIndex = function(str, pattern, init, plain)
                if init == nil then init = 1 end
                if plain == nil then plain = false end

                local index = init;
                return function()
                    index = str:find(pattern, index + 1, plain);
                    return index;
                end
            end,
            findRevIndex = function(str, pattern, init, plain)
                if init == nil then init = 1 end
                if plain == nil then plain = false end

                local index = init;
                return function()
                    index = str:reverse():find(pattern, index + 1, plain);
                    return #str - index + 1;
                end
            end,
            trim = function(str)
                return str:gsub("%s+", " "):match("^%s*(.*)"):match("(.-)%s*$")
            end,
            peek = function(str, index, size)
                if index == nil or str == nil then
                    return nil
                end
                return UTILITY.string.trim(str:sub(index - size, index + size))
            end,
            startsWith = function(str, text)
                return str:sub(1, #text) == text
            end,
            endsWith = function(str, text)
                return text == "" or str:sub(- #text) == text
            end,
            toByteArray = function(str)
                local result = {};

                for i = 0, #str, 1 do
                    table.insert(result, i, str:byte(i))
                end

                return result;
            end,
            fromByteArray = function(array)
                local result = "";

                for key, value in pairs(array) do
                    result = result .. (tostring(value):char())
                end

                return result;
            end
        },
        draw = {
            createMaterial = function(sText, fgrcol, bkgcol)
                if sText == nil then sText = "*" end
                if fgrcol == nil then fgrcol = colors.white; end
                if bkgcol == nil then bkgcol = colors.black; end

                local index = 0;

                return {
                    fgrcol = fgrcol,
                    bkgcol = bkgcol,
                    getNext = function()
                        if index >= #sText then
                            index = 0;
                        end
                        index = index + 1;
                        return sText:sub(index, index)
                    end,
                    handleColor = function(wind, func)
                        local bkg = wind.getBackgroundColor();
                        local fgr = wind.getTextColor();

                        wind.setBackgroundColor(bkgcol)
                        wind.setTextColor(fgrcol)

                        func()

                        wind.setBackgroundColor(bkg)
                        wind.setTextColor(fgr)
                    end,
                    clone = function()
                        return UTILITY.draw.createMaterial(sText, fgrcol, bkgcol);
                    end
                }
            end,
            circle = function(wind, x, y, radius, startDeg, endDeg, material)
                if material == nil then material = UTILITY.draw.createMaterial(); end
                if endDeg == nil then endDeg = 360 end
                if startDeg == nil then startDeg = 0; end

                material.handleColor(wind, function()
                    local step = FindClosestCircleStep(radius) / math.pi;

                    for i = startDeg, endDeg, step do
                        local angle = i * math.pi / 180;
                        local xPos = math.floor(x + (radius * math.cos(angle)))
                        local yPos = math.floor(y + (radius * math.sin(angle)))

                        wind.setCursorPos(xPos, yPos)
                        wind.write(material.getNext())
                    end
                end)
            end,
            line = function(wind, ax, ay, bx, by, material)
                if material == nil then material = UTILITY.draw.createMaterial(); end

                material.handleColor(wind, function()
                    ax = math.floor(ax)
                    ay = math.floor(ay)
                    bx = math.floor(bx)
                    by = math.floor(by)

                    local dx = math.abs(bx - ax)
                    local dy = math.abs(by - ay)
                    local sx = (ax < bx) and 1 or -1
                    local sy = (ay < by) and 1 or -1
                    local err = dx - dy

                    while true do
                        wind.setCursorPos(ax, ay)
                        wind.write(material.getNext())

                        if (ax == bx and ay == by) then
                            break
                        end

                        local e2 = 2 * err
                        if (e2 > -dy) then
                            err = err - dy;
                            ax = math.floor(ax + sx);
                        end

                        if (e2 < dx) then
                            err = err + dx;
                            ay = math.floor(ay + sy);
                        end
                    end
                end)
            end,
            polygon = function(wind, array, open, material)
                if material == nil then material = UTILITY.draw.createMaterial(); end
                if open == nil then open = false end

                for i = 1, #array - 2, 2 do
                    UTILITY.draw.line(wind, array[i], array[i + 1], array[i + 2], array[i + 3], material)
                end

                if not open then
                    UTILITY.draw.line(wind, array[#array - 1], array[#array], array[1], array[2], material)
                end
            end,
            rect = function (wind, ax, ay, bx, by, material)
                if material == nil then material = UTILITY.draw.createMaterial(); end
                
                local minX = math.min(ax, bx)
                local minY = math.min(ay, by)
                local maxX = math.max(ax, bx)
                local maxY = math.max(ay, by)

                material.handleColor(wind, function ()
                    for x = minX, maxX, 1 do
                        for y = minY, maxY, 1 do
                            wind.setCursorPos(x, y)
                            wind.write(material.getNext())
                        end
                    end
                end)
            end
        }
    }
end

UTILITY = UTILITY_FUNC();
