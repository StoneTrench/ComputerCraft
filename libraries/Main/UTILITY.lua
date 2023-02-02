local function UTILITY_FUNC()
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
        PullEventTimeout = function(event, sec)
            local result = nil

            local function Event()
                result = os.pullEvent(event)
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
                for i = 1, #table do
                    if table[i] == val then
                        return true
                    end
                end
                return false
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
        }
    }
end

UTILITY = UTILITY_FUNC();
