require("LIBS")

local args = { ... }

if args[1] == "update" then
    local drone_lib_data = GIT.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/drones/DRONE_LIB.lua");
    local libs_data = GIT.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/libraries/Main/LIBS.lua");

    local script = "require(\"LIBS\");";
    script = script.."UTILITY.fs.writeFile(\"./DRONE_LIB.lua\", \"" .. drone_lib_data .. "\")";
    script = script.."UTILITY.fs.writeFile(\"./LIBS.lua\", \"" .. libs_data .. "\")";

    local func, err = load(script, "drone_lib_data", "t", _ENV)

    if func == nil then
        error("Function failed: " .. err)
    end

    local success, msg = pcall(func, select(3))
    if not success then
        printError(msg)
    end

    return;
end
