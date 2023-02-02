require("LIBS")

local args = { ... }

if args[1] == "update" then
    local script = "require(\"LIBS\");";
    script = script .. "local drone_lib_data = GIT.get(\"StoneTrench/ComputerCraft/master/drones/DRONE_LIB.lua\");"
    script = script .. "local libs_data = GIT.get(\"StoneTrench/ComputerCraft/master/libraries/Main/LIBS.lua\");";
    script = script .. "UTILITY.fs.writeFile(\"./DRONE_LIB.lua\", drone_lib_data);";
    script = script .. "UTILITY.fs.writeFile(\"./LIBS.lua\", libs_data);";

    local func, err = load(script, "drone_lib_data", "t", _ENV)

    if func == nil then
        error("Function failed: " .. script)
    end

    local success, msg = pcall(func, select(3))
    if not success then
        error(msg)
    end

    return;
end

while true do
    print(textutils.serialiseJSON(settings))
    print(M_PROTOCOL.Ping(peripheral.wrap("top"), M_PROTOCOL.getDefaultSearchChannel(), "Hello", 0.5) or "nil")
    sleep(0.5);
end
