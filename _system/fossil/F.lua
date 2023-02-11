F = {
    getName = function()
        return "FossilOS", "1.0.0"
    end,
    getLicenseCopyright = function()
        local fileStream = fs.open(F.PATHS.license, "r");
        local a, _, b, c = fileStream.readLine(), fileStream.readLine(), fileStream.readLine(), fileStream.readAll();
        fileStream.close();
        return a, b, c;
    end,
    PATHS = {
        this = "./system/fossil/F",
        global = "./system/fossil/global/",
        commands = "./system/fossil/commands/",
        commands_fossil = "./system/commands/",

        programs = "./system/fossil/programs/",
        packages = "./system/packages/",
        downloads = "./system/downloads/",
        settings = "./system/fossil/.settings",
        license = "./system/fossil/LICENSE"
    },
    settings = {
        set = function(name, value)
            local s = nil

            local success, result = pcall(util.fs.readFile, F.PATHS.settings)

            if not success then
                s = {};
            else
                s = textutils.unserialise(result);
            end

            s[name] = value;
            util.fs.writeFile(F.PATHS.settings, textutils.serialise(s))
        end,
        get = function(name, default)
            local success, result = pcall(util.fs.readFile, F.PATHS.settings);

            if not success then
                F.settings.set(name, default);
                return default;
            else
                s = textutils.unserialise(result);
            end

            return s[name];
        end
    }
}

_G.F = F;
