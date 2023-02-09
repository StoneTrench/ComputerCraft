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
