_G.compression = {
    lzw = {
        compress = function(str)
            local dict = {}
            local output = {}
            local phrase = ""
            for i = 1, #str do
                local c = str:sub(i, i)
                local new_phrase = phrase .. c
                if dict[new_phrase] then
                    phrase = new_phrase
                else
                    output[#output + 1] = dict[phrase]
                    dict[new_phrase] = #dict + 1
                    phrase = c
                end
            end
            output[#output + 1] = dict[phrase]
            return output
        end,
        decompress = function(_data)
            local _dataObj = textutils.unserialiseJSON(_data)
            local compressed_data = _dataObj.o;
            local codes = _dataObj.c;

            local inverse_codes = {}
            for k, v in pairs(codes) do
                inverse_codes[v] = k
            end
            local data = ''
            local code = 0
            local bits = 0
            for i = 1, compressed_data:len() do
                code = code * 256 + string.byte(compressed_data:sub(i, i))
                bits = bits + 8
                while bits >= 8 do
                    local char = inverse_codes[math.floor(code % (2 ^ bits / 256)) + 1]
                    if char ~= nil then
                        data = data .. char
                        code = math.floor(code / 256)
                        bits = bits - #tostring(codes[char])
                    else
                        break;
                    end
                end
            end
            print(data)

            return data
        end
    },
    rle = {
        compress = function(data)
            local output = ""
            local current = data:sub(1, 1)
            local count = 1
            for i = 2, data:len() do
                if data:sub(i, i) == current then
                    count = count + 1
                else
                    output = output .. current .. count
                    current = data:sub(i, i)
                    count = 1
                end
            end
            output = output .. current .. count
            return output
        end,
        decompress = function(data)
            local output = ""
            local i = 1
            while i <= data:len() do
                local char = data:sub(i, i)
                i = i + 1
                local count = ""
                while data:sub(i, i) >= '0' and data:sub(i, i) <= '9' do
                    count = count .. data:sub(i, i)
                    i = i + 1
                end
                count = tonumber(count)
                for j = 1, count do
                    output = output .. char
                end
            end
            return output
        end
    }
}
