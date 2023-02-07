local function DRONE_FUNC()
    require("libraries.UTILITY")

    local mainPeripherals = {}

    return {
        Initialize = function()
            mainPeripherals.helm = peripheral.find("helm");
            mainPeripherals.wireless_modem = UTILITY.table.find({peripheral.find("modem")}, function (e)
                return e.isWireless()
            end);
        end,
        hasHelm = function ()
            return mainPeripherals.helm ~= nil;
        end,
        hasWireless = function ()
            return mainPeripherals.wireless_modem ~= nil;
        end
    }
end

DRONE = DRONE_FUNC();
