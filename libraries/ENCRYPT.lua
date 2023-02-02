local function ENCRYPT_FUNC()
    local function ConvertStringToBytes(data)
        local result = {};

        for i = 0, #data, 1 do
            table.insert(result, i, data:byte(i))
        end

        return result;
    end

    local function ConvertBytesToString(data)
        local result = "";

        for key, value in pairs(data) do
            result = result .. (tostring(value):char())
        end

        return result;
    end

    local function MapStrUsingFunc(str, func)
        local result = ""

        for i = 1, #str, 1 do
            result = result .. tostring(func(str:byte(i), i, str)):char()
        end

        return result;
    end

    local function GenerateValueTable(key1, key2, key3, key4)
        local result = {};

        math.randomseed(key1, key2);

        for i = 1, 16 * 16, 1 do
            table.insert(result, i, (math.random(math.mininteger, math.maxinteger) + (math.pow(key4, key3 * i) % key1)));
        end

        return result;
    end

    local valueTable = {}

    local function GetValueFromTable(index)
        return valueTable[index % (#valueTable + 1)]
    end

    return {
        LoadValueTable = function(key)
            valueTable = GenerateValueTable(key)
        end,

        MapStrUsingFunc = MapStrUsingFunc,
        Encrypt = function(str, key1, key2, key3, key4)

            return MapStrUsingFunc(str, function(n, i)
                return bit.bxor(n, ((i * GetValueFromTable((i + key3) % key4) + key1) % key2));
            end)
        end,
        Decrypt = function(data, key1, key2, key3, key4)
            local result = "";

            local lkey = key;
            for i = 1, #data, 1 do
                local A1 = bit.bnot(lkey + key) * key

                lkey = ((710425941047 * lkey + A1 + 813633012810) % 711719770602) % 255
                result = result .. tostring(bit.bxor(data:byte(i), lkey)):char()
            end

            return result;
        end,
        ConvertStringToBytes = ConvertStringToBytes,
        ConvertBytesToString = ConvertBytesToString
    }
end

ENCRYPT = ENCRYPT_FUNC();
