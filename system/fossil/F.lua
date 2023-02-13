F = {
    getName = function()
        return "FossilOS", "1.0.0"
    end,
    getLicenseCopyright = function()
        local fileStream = fs.open(F.PATHS.FILE.license, "r");
        local a, _, b, c = fileStream.readLine(), fileStream.readLine(), fileStream.readLine(), fileStream.readAll();
        fileStream.close();
        return a, b, c;
    end,
    PATHS = {
        FILE = {
            settings = "./system/fossil/.settings",
            license = "./system/fossil/LICENSE",
            this = "./system/fossil/F",
        },
        DIR = {
            programData = "./system/programData/",
            packages = "./system/packages/",
            commands = "./system/commands/",
            autorun = "./system/autorun/",

            commands_fossil = "./system/fossil/commands/",
            programs = "./system/fossil/programs/",
            global = "./system/fossil/global/",
            docs = "./system/fossil/docs/",
        }
    },
    settings = {
        set = function(name, value)
            local s = nil

            local success, result = pcall(util.fs.readFile, F.PATHS.FILE.settings)

            if not success then
                s = {};
            else
                s = textutils.unserialise(result);
            end

            s[name] = value;
            util.fs.writeFile(F.PATHS.FILE.settings, textutils.serialise(s))
        end,
        get = function(name, default)
            local success, result = pcall(util.fs.readFile, F.PATHS.FILE.settings);

            if not success then
                F.settings.set(name, default);
                return default;
            else
                s = textutils.unserialise(result);
            end

            return s[name];
        end
    },
    programData = {
        getOrCreate = function(programName, groupName, dataName, default)
            if not util.string.endsWith(groupName, ".json") then
                groupName = groupName .. ".json";
            end
            local path = fs.combine(F.PATHS.DIR.programData, programName, groupName)

            if fs.exists(path) then
                return textutils.unserializeJSON(util.fs.readFile(path))[dataName] or default;
            else
                util.fs.writeFile(path, textutils.serializeJSON(
                    {
                        [dataName] = default
                    }
                ))
                return default;
            end
        end,
        set = function(programName, groupName, dataName, value)
            if not util.string.endsWith(groupName, ".json") then
                groupName = groupName .. ".json";
            end
            local path = fs.combine(F.PATHS.DIR.programData, programName, groupName)

            local data = {};
            if fs.exists(path) then
                data = textutils.unserializeJSON(util.fs.readFile(path));
            end

            data[dataName] = value;
            util.fs.writeFile(path, textutils.serializeJSON(data))
        end,
        getGroups = function(programName)
            if not util.string.endsWith(groupName, ".json") then
                groupName = groupName .. ".json";
            end
            local path = fs.combine(F.PATHS.DIR.programData, programName)

            return util.table.map(fs.list(path), function(e)
                    return e:sub(".json", "")
                end);
        end,
        getFullObject = function(programName, groupName)
            if not util.string.endsWith(groupName, ".json") then
                groupName = groupName .. ".json";
            end
            local path = fs.combine(F.PATHS.DIR.programData, programName, groupName)

            if fs.exists(path) then
                return textutils.unserializeJSON(util.fs.readFile(path));
            else
                return nil;
            end
        end
    }
}

_G.F = F;
