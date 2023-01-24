-- Basically a script that can take a project and compile it into one lua file
local function printUsage()
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usages:")
    print(programName .. " <project.proj>")
end

local args = { ... }

if #args < 1 then
    printUsage();
    return
end

--#region utility

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local function ends_with(str, ending)
    return ending == "" or str:sub(- #ending) == ending
end

local function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

--#endregion

--#region LSON
function LSON_Serialize(table, Spaces)
    if Spaces == nil then Spaces = "   "; end
    local LineEnd = "\n";

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

function LSON_Deserialize(lson)

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

        local keyPattern = "[^:][^%S+]\"(.-)\":";

        local keys = dTable.data:gmatch(keyPattern)
        local values = dTable.data:gsub(keyPattern, ""):gmatch("(.-),")

        for key in keys do
            local val = values();

            if not (val == nil) then

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
        end

        return result;
    end

    return ConverToObject(DTable(lson:match("{(.*)}")))
end

--#endregion

function GetProjectData(path)
    local projectFilePath = shell.resolve(path)
    if not fs.exists(projectFilePath) then
        error("Project file " .. projectFilePath .. " not found!")
    end

    local fileStream = fs.open(projectFilePath, "r");
    local table = LSON_Deserialize(fileStream.readAll());
    fileStream.close();

    if table.entrypoint == nil then
        error("Project has no entrypoint!");
    end
    if table.name == nil then
        error("Project has no name!");
    end
    if table.version == nil then
        table.version = "1.0";
        warn("Version missing, setting to default 1.0 .")
    end
    if table.description == nil then
        table.description = "";
    end

    return table;
end

function ParseLuaScript(path)
    local filePath = shell.resolve(path)
    if not fs.exists(filePath) then
        printError(filePath .. " doesn't exist!")
        return
    end

    local fileName, n = filePath:gsub("(.-)/", ""):gsub("%.lua", "")

    local fileStream = fs.open(filePath, "r")
    local scriptString = fileStream.readAll();
    fileStream.close();

    local strings = scriptString:gmatch("[^\\]\"(.-)[^\\]\"")
    local functions = scriptString:gmatch("function (.-)%(")
    local variables = scriptString:gmatch("local (.-)[^=^<^>]=[^=^<^>]") or scriptString:gmatch("(.-)[^=^<^>]=[^=^<^>]")

    for value in functions do
        scriptString, n = scriptString:gsub(value, fileName .. "_" .. value)
    end

    print(scriptString)
end

ParseLuaScript(GetProjectData(args[1]).entrypoint)
