local function DRONE_FUNC()
    require(".libraries.UTILITY")

    local mainPeripherals = {
        helm = nil,
        wireless_modem = nil,
        reader = nil,
        radar = nil
    }

    return {
        Initialize = function()
            mainPeripherals.helm = peripheral.find("helm");
            mainPeripherals.wireless_modem = UTILITY.table.find({ peripheral.find("modem") },
                    function(e) return e.isWireless() end);
            mainPeripherals.reader = peripheral.find("reader")
            mainPeripherals.radar = peripheral.find("radar")

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
        hasRadar = function()
            return mainPeripherals.radar ~= nil;
        end,
        gotoLine = function(x, y, z)
            if DRONE.hasReader() then
                mainPeripherals.reader.transformPosition(x, y, z); --mainPeripherals.helm.
                return true
            end

            return false
        end,
        radarScan = function(range)
            if DRONE.hasRadar() then
                return { mainPeripherals.radar.scan(range) }; --mainPeripherals.helm.
            end
            return nil
        end
    }
end

DRONE = DRONE_FUNC();
