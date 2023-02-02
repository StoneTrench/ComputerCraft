-- local function GCD(a, b)
--     local min = math.min(a, b);
--     local max = math.max(a, b);

--     if min == 0 then
--         return max;
--     end

--     local remainder = max % min;
--     return GCD(min, remainder)
-- end

-- require("libraries.UTILITY")

-- local l = "";
-- for x = 1, 1000, 1 do

--     local count = 0;

--     for n = 1, x, 1 do
--         if (GCD(x, n) == 1) then
--             count = count + 1
--         end
--     end

--     l = l .. count .. "\n"
-- end

-- UTILITY.fs.writeFile("data.txt", l)

require("libraries.ENCRYPT")

print(ENCRYPT.Decrypt(ENCRYPT.Encrypt("AssWhole", 15, 23, 64, 12), 15));