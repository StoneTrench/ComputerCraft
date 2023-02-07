require("libraries.LIBS")

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

local function debugLog(...)
    if args[1] == "debug" then
        print(...)
    end
end

local peripherals = {
    modem = peripheral.find("modem"),
    helm = peripheral.find("ship_helm"),
    reader = peripheral.find("ship_reader"),
}

local defaultChannels = M_PROTOCOL.getDefaultChannels();
local parentChannel = nil;

local function PingParent(data)
    return M_PROTOCOL.Ping(peripherals.modem, parentChannel, data, 0.5)
end

local function SearchForParent()
    local result = M_PROTOCOL.Ping(peripherals.modem, defaultChannels.search, {
        os.getComputerID(),
        peripherals.reader.getShipID(),
        os.time()
    }, 1)

    if result then
        parentChannel = result[1];
        debugLog("Found parent", result[1])
    end
end

while true do
    debugLog(parentChannel)

    if parentChannel == nil then
        SearchForParent()
    else
        PingParent(peripherals.reader.getWorldspacePosition())
    end

    sleep(0.5);
end
