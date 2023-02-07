local function ENCRYPT_FUNC()
    local function MapStrUsingFunc(str, func)
        local result = ""

        for i = 1, #str, 1 do
            result = result .. tostring(func(str:byte(i), i, str)):char()
        end

        return result;
    end

    return {
        MapStrUsingFunc = MapStrUsingFunc,
        XorData = function(str, key)
            local lkey = key;
            return MapStrUsingFunc(str, function(n, i)
                local A1 = bit.bnot(lkey + key) * key
                lkey = ((710425941047 * lkey + A1 + 813633012810) % 711719770602) % 255

                return bit.bxor(n, lkey);
            end)
        end
    }
end

ENCRYPT = ENCRYPT_FUNC();




local function GIT_FUNC()
    if not http then
        error("Git requires the http API")
        error("Set http.enabled to true in the config")
        return
    end

    local function get(address)
        local path = address:gsub("https://github.com/", ""):gsub("https://raw.githubusercontent.com/", ""):gsub("blob/"
            , "")

        local response, err = http.get("https://raw.githubusercontent.com/" .. path)

        if response then
            local headers = response.getResponseHeaders()
            if not headers["Content-Type"] or not headers["Content-Type"]:find("^text/plain") then
                return nil;
            end

            local data = response.readAll()
            response.close()
            return data;
        else
            return nil;
        end
    end

    return {
        get = get,
        run = function(address, ...)
            local data = get(address)

            if data == nil then
                return false;
            end

            local func, err = load(data, address, "t", _ENV)

            if not func then
                error(err)
            end

            return pcall(func, select(3, ...))
        end
    }
end

GIT = GIT_FUNC();




local function M_PROTOCOL_FUNC()

    local function Ping(modem, channel, data, timeout)
        if not modem.isOpen(channel) then
            modem.open(channel)
        end

        modem.transmit(channel, channel, data);

        -- event, side, channel, replyChannel, message, distance
        local modem_message = -1;
        repeat
            modem_message = UTILITY.PullEventTimeout("modem_message", timeout)
        until (modem_message == nil) or (modem_message[3] == channel)

        if modem_message == nil then
            return nil;
        end

        modem.close(channel)

        return modem_message[5], modem_message[6];
    end

    return {
        getDefaultChannels = function()
            return {
                global = 0,
                search = 65535,
                droneGlobal = 65534,
            };
        end,
        Ping = Ping,
    }
end

M_PROTOCOL = M_PROTOCOL_FUNC();




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




