local function DRONE_FUNC()
    require("libraries.UTILITY")

    local mainPeripherals = {
        helm = nil,
        wireless_modem = nil,
        reader = nil
    }

    return {
        Initialize = function()
            mainPeripherals.helm = peripheral.find("helm");
            mainPeripherals.wireless_modem = UTILITY.table.find({ peripheral.find("modem") },
                    function(e) return e.isWireless() end);
            mainPeripherals.reader = peripheral.find("reader")

            if DRONE.hasHelm() then
                mainPeripherals.helm.assemble();
            end
        end,
        hasHelm = function()
            return mainPeripherals.helm ~= nil;
        end,
        hasWireless = function()
            return mainPeripherals.wireless_modem ~= nil;
        end,
        hasReader = function()
            return mainPeripherals.reader ~= nil;
        end,
        gotoLine = function(x, y, z)
            if DRONE.hasReader() then
                mainPeripherals.reader.transformPosition(x, y, z);--mainPeripherals.helm.
            end
        end,
    }
end

DRONE = DRONE_FUNC();
