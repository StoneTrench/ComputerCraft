local function S_COMPILER_FUNC()
    require("libraries.UTILITY")

    local function HandleCompilerError(message)
        error("\nCompiler error: " .. message)
    end

    local function CheckForEscapeCharacter(string, index)
        return (string:sub(index - 1, index - 1) ~= "\\") or
            ((string:sub(index - 1, index - 1) == "\\") and (string:sub(index - 2, index - 2) == "\\"))
    end

    local function FindIndexesEncompasedByPattern(string, pattern, useEscapeCharacter)
        if useEscapeCharacter == nil then useEscapeCharacter = true end

        local charIndexes = {};

        for index in util.string.findIndex(string, pattern) do
            if useEscapeCharacter then
                if CheckForEscapeCharacter(string, index) then
                    table.insert(charIndexes, #charIndexes + 1, index);
                end
            else
                table.insert(charIndexes, #charIndexes + 1, index);
            end
        end

        return charIndexes;
    end

    local function SeparateInsideAndOutside(string, pattern, useEscapeCharacter)
        local stringIndexes = FindIndexesEncompasedByPattern(string, pattern, useEscapeCharacter)
        table.insert(stringIndexes, 1, 1)
        table.insert(stringIndexes, #string)

        local inside = {};
        for i = 2, #stringIndexes - 1, 2 do
            table.insert(inside, string:sub(stringIndexes[i], stringIndexes[i + 1]))
        end
        local outside = {};
        for i = 0, #stringIndexes - 2, 2 do
            table.insert(outside, string:sub(stringIndexes[i + 1], stringIndexes[i + 2]));
        end

        return inside, outside
    end

    local function FindPartnerClosingChar(string, initCharIndex, openChar, closeChar)
        local indexes = util.IteratorToArray(util.string.findIndex(string, openChar, 1, true));

        for value in util.string.findIndex(string, closeChar, 1, true) do
            table.insert(indexes, #indexes, value);
        end

        table.sort(indexes, function(a, b) return a < b end)

        local counter = 0;
        local initCount = -1;

        for i = 1, #indexes, 1 do
            if string:sub(indexes[i], indexes[i]) == openChar then
                counter = counter + 1;
            else
                if initCount == counter then
                    return indexes[i]
                end

                counter = counter - 1;
            end

            if initCharIndex == indexes[i] then
                initCount = counter;
            end
        end


        return nil;
    end

    local function parseObjects(code_noString, parentObject)
        local result = {};
        local EndPattern = "[;}]";

        local open = util.IteratorToArray(util.string.findIndex(code_noString, "{", 1, true));
        local index = open[1];

        if index == nil then
            return util.string.trim(code_noString)
        end

        -- Handles (class, namespace, function) parsing
        while (true) do
            local closing = FindPartnerClosingChar(code_noString, index, "{", "}")

            local objectHeaderStart = code_noString:reverse():find(EndPattern, #code_noString - index)
            if objectHeaderStart == nil then
                objectHeaderStart = 1;
            else
                objectHeaderStart = #code_noString - objectHeaderStart + 2;
            end
            local header = util.string.trim(code_noString:sub(objectHeaderStart, index - 1));

            local type = "unknown";
            if header:match(" ") then
                if util.string.startsWith(header, "namespace") then
                    type = "namespace"
                elseif util.string.startsWith(header, "class") then
                    type = "class"
                elseif util.string.startsWith(header, "func") and util.string.endsWith(header, ")") then
                    type = "function"
                end

                header = header:match("%s+(.*)")
            elseif parentObject.type == "class" and header:match(parentObject.header) and
                util.string.endsWith(header, ")") then
                type = "constructor"
            end

            local data = code_noString:sub(index + 1, closing - 1);

            table.insert(result, {
                type = type,
                header = header,
                data = data,
                children = parseObjects(data, { type = type, header = header })
            })

            index = code_noString:find("{", closing, true)

            if index == nil then
                break;
            end
        end

        local code_noString_noObject = code_noString;

        for index, value in ipairs(result) do
            code_noString_noObject = code_noString_noObject:gsub(value.data, "")
        end

        print(code_noString_noObject)

        -- Handles (variable, declaration) parsing
        local variables = FindIndexesEncompasedByPattern(code_noString_noObject, "var(.*)[;,%)]", false)
        print(textutils.serialiseJSON(variables))
        print(util.table.reduce(util.table.map(variables, function(e)
            return code_noString_noObject:sub(e, e + 3)
        end), function(a, b)
            return a .. b
        end))

        return result;
    end

    return {
        Compile = function(localPath, outputPath)
            local source_code = util.fs.readFile(shell.resolve(localPath))

            local table_string_inside, table_string_outside = SeparateInsideAndOutside(source_code, "\"", true);

            local code_noString = table.concat(table_string_outside, "");

            local Objects = parseObjects(code_noString)

            util.fs.writeFile(outputPath, textutils.serializeJSON(Objects))
        end
    }
end

S_COMPILER = S_COMPILER_FUNC();

-- S_COMPILER.Compile("other/git.lua")
-- S_COMPILER.Compile("libraries/SCOMPILER.lua")
S_COMPILER.Compile("libraries/test/code.cs", "./TestObjects.json")

--UTILITY.fs.writeFile("tree.json", textutils.serialiseJSON(UTILITY.fs.tree("./")))
