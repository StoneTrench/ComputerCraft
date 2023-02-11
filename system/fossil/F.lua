F = {
    getName = function()
        return "FossilOS", "1.0.0"
    end,
    getLicense = function()
        return "MIT License\tCopyright (c) 2023 StoneTrench"
    end,
    PATHS = {
        this = "./system/fossil/F",
        global = "./system/fossil/global/",
        commands = "./system/fossil/commands/",

        programs = "./system/fossil/programs/",
        packages = "./system/packages/",
        downloads = "./system/downloads/",
        settings = "./system/fossil/.settings",
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
