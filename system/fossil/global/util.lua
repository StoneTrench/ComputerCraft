local function UTILITY_FUNC()
    local circleCounts = {
        { 1,    1 },
        { 2,    6 },
        { 3,    8 },
        { 4,    12 },
        { 6,    16 },
        { 7,    20 },
        { 9,    24 },
        { 11,   28 },
        { 13,   32 },
        { 14,   36 },
        { 16,   40 },
        { 18,   44 },
        { 19,   48 },
        { 21,   52 },
        { 23,   56 },
        { 25,   60 },
        { 27,   64 },
        { 28,   68 },
        { 30,   72 },
        { 32,   76 },
        { 33,   80 },
        { 35,   84 },
        { 37,   88 },
        { 38,   92 },
        { 40,   96 },
        { 41,   100 },
        { 43,   104 },
        { 45,   108 },
        { 47,   112 },
        { 49,   116 },
        { 51,   120 },
        { 53,   124 },
        { 54,   128 },
        { 56,   132 },
        { 58,   136 },
        { 59,   140 },
        { 61,   144 },
        { 63,   148 },
        { 65,   152 },
        { 66,   148 },
        { 68,   160 },
        { 69,   156 },
        { 71,   164 },
        { 72,   168 },
        { 73,   172 },
        { 75,   176 },
        { 76,   180 },
        { 79,   188 },
        { 82,   196 },
        { 86,   204 },
        { 90,   212 },
        { 95,   220 },
        { 100,  228 },
        { 106,  236 },
        { 113,  244 },
        { 120,  252 },
        { 129,  260 },
        { 139,  268 },
        { 152,  276 },
        { 166,  284 },
        { 184,  292 },
        { 207,  300 },
        { 236,  308 },
        { 275,  316 },
        { 330,  324 },
        { 412,  332 },
        { 548,  340 },
        { 822,  348 },
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
        pullEventTimeout = function(event, sec)
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
        pullEventAny = function(...)
            local events = {}
            local result = {}

            for key, value in pairs({...}) do
                events[#events + 1] = function()
                    result = { os.pullEvent(value) }
                end
            end

            return parallel.waitForAny(table.unpack(events)), result
        end,
        IteratorToArray = function(itterator)
            local result = {}
            for value in itterator do
                table.insert(result, value);
            end
            return result;
        end,
        clone = function(orig)
            local orig_type = type(orig)
            local copy
            if orig_type == 'table' then
                copy = {}
                for orig_key, orig_value in next, orig, nil do
                    copy[util.clone(orig_key)] = util.clone(orig_value)
                end
                setmetatable(copy, util.clone(getmetatable(orig)))
            else
                copy = orig
            end
            return copy
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
            foreach = function(path, func)
                if not fs.exists(path) then
                    error("Path not found! (" .. path .. ")")
                end

                local function t(p)
                    local files = fs.list(p)

                    for index, value in ipairs(files) do
                        local fp = fs.combine(p, value);

                        if func(fp) then
                            return;
                        end

                        if fs.isDir(fp) then
                            t(fp)
                        end
                    end
                end

                t(path);
            end,
            tree = function(path)
                path = shell.resolve(path)

                if not fs.exists(path) then
                    error("Path not found! (" .. path .. ")")
                end

                local result = {};

                util.fs.foreach(path, function(fp)
                    local lfp = fp:gsub(path, "")

                    local parent = util.table.getFromPath(result, fs.getDir(lfp))

                    if parent then
                        if fs.isDir(fp) then
                            parent[fs.getName(fp)] = {}
                        else
                            parent[fs.getName(fp)] = (#util.fs.readFile(fp) * 1E-3) .. " kb"
                        end
                    end
                end)

                return result;
            end,
            findFile = function(path, pattern)
                path = shell.resolve(path)

                if not fs.exists(path) then
                    error("Path not found! (" .. path .. ")")
                end

                local result = nil

                util.fs.foreach(path, function(fp)
                    if fs.getName(fp):match(pattern) then
                        result = fp;
                        return true;
                    end
                end)

                return result;
            end,
            findFiles = function(path, pattern)
                path = shell.resolve(path)

                if not fs.exists(path) then
                    error("Path not found! (" .. path .. ")")
                end

                local result = {}

                util.fs.foreach(path, function(fp)
                    if fs.getName(fp):match(pattern) then
                        table.insert(result, fp);
                    end
                end)

                return result;
            end
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
            find = function(table, predicate)
                for key, value in pairs(table) do
                    if predicate(value, key, table) then
                        return value
                    end
                end
                return nil
            end,
            indexOf = function(table, element)
                for key, value in pairs(table) do
                    if value == element then
                        return key
                    end
                end
                return nil
            end,
            getFromPath = function(table, path)
                local prev = table;

                for key in path:gmatch("([^.]+)") do
                    logger.log(key)

                    if key == "." then
                        return prev;
                    end

                    local value = prev[key];

                    if value == nil then
                        return nil;
                    end

                    prev = value;
                end

                return prev;
            end,
            combine = function(a, b)
                local result = {}
                for key, value in pairs(a) do
                    result[key] = value
                end
                for key, value in pairs(b) do
                    result[key] = value
                end
                return result;
            end,
            toArray = function(table)
                local result = {}
                for key, value in pairs(table) do
                    result[#result + 1] = value
                end
                return result;
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
                return util.string.trim(str:sub(index - size, index + size))
            end,
            startsWith = function(str, text)
                return str:sub(1, #text) == text
            end,
            endsWith = function(str, text)
                return text == "" or str:sub( -#text) == text
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
                        return util.draw.createMaterial(sText, fgrcol, bkgcol);
                    end
                }
            end,
            circle = function(wind, x, y, radius, startDeg, endDeg, material)
                if material == nil then material = util.draw.createMaterial(); end
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
                if material == nil then material = util.draw.createMaterial(); end

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
                if material == nil then material = util.draw.createMaterial(); end
                if open == nil then open = false end

                for i = 1, #array - 2, 2 do
                    util.draw.line(wind, array[i], array[i + 1], array[i + 2], array[i + 3], material)
                end

                if not open then
                    util.draw.line(wind, array[#array - 1], array[#array], array[1], array[2], material)
                end
            end,
            rect = function(wind, ax, ay, bx, by, material)
                if material == nil then material = util.draw.createMaterial(); end

                local minX = math.min(ax, bx)
                local minY = math.min(ay, by)
                local maxX = math.max(ax, bx)
                local maxY = math.max(ay, by)

                material.handleColor(wind, function()
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

_G.util = UTILITY_FUNC();
