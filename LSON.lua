function Serialize(table, Spaces, LineEnd)
    if Spaces == nil then Spaces = "   "; end
    if LineEnd == nil then LineEnd = "\n"; end

    local indentCounter = 0;

    function STable(t)
        local result = "{" .. LineEnd

        indentCounter = indentCounter + 1;
        for key, value in pairs(t) do

            for i = 1, indentCounter, 1 do
                result = result .. Spaces;
            end

            result = result .. "\"" .. key .. "\"" .. ": "

            if type(value) == "number" then
                result = result .. tostring(value);
            elseif type(value) == "string" then
                result = result .. "\"" .. value .. "\"";
            elseif type(value) == "boolean" then
                result = result .. tostring(value);
            elseif type(value) == "table" then
                result = result .. STable(value)
            end

            result = result .. "," .. LineEnd
        end
        indentCounter = indentCounter - 1;

        for i = 1, indentCounter, 1 do
            result = result .. Spaces;
        end

        result = result .. "}"
        return result
    end

    return STable(table)
end

function Deserialize(lson)

    function DTable(d)
        local result = {
            data = "",
            children = {}
        };

        local childLayer = 0;
        local childCount = 0;

        for i = 1, #d, 1 do
            local char = d:sub(i, i);

            if childLayer == 0 then
                result.data = result.data .. char;
            elseif not (childLayer == 1 and char == "}") then
                result.children[childCount] = result.children[childCount] .. char
            end

            if char == "{" then
                childLayer = childLayer + 1;
                if childLayer == 1 then childCount = childCount + 1;
                    result.children[childCount] = ""
                    result.data = result.data .. tostring(childCount) .. "}";
                end

            elseif char == "}" then
                childLayer = childLayer - 1;
            end
        end

        return result;
    end

    function ConverToObject(dTable)
        local result = {};

        local keys = dTable.data:gmatch("\"(.-)\":")
        local values = dTable.data:gmatch("\":(.-),\n")

        for key in keys do
            local val = values();


            local childIndex = val:match("{(.)}");

            if childIndex == nil then
                local valText = val:match("\"(.*)\"")

                if valText == nil then
                    local valNumber = tonumber(val);
                    if valNumber == nil then
                        local valBool = val:match("true") == "true";
                        result[key] = valBool;
                    else
                        result[key] = valNumber;
                    end
                else
                    result[key] = valText
                end
            else
                result[key] = ConverToObject(DTable(dTable.children[tonumber(childIndex)]));
            end
        end

        return result;
    end

    return ConverToObject(DTable(lson:match("{(.*)}")))
end
