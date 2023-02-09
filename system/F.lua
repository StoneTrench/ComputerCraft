F = {
    getName = function()
        return "FossilOS", "1.0.0"
    end,
    getLicense = function()
        return "MIT License\tCopyright (c) 2023 StoneTrench"
    end,
    PATHS = {
        this = "./system/F",
        global = "./system/fossil/global/",
        commands = "./system/fossil/commands/",

        programs = "./system/fossil/programs/",
        packages = "./system/packages/",
        downloads = "./system/downloads/",
    }
}

_G.F = F;
