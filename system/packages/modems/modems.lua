local function MODEMS_FUNC()
    return {
        getAllPeripheralsOnWireless = function()
            return util.table.reduce(util.table.map({
                    peripheral.find("modem", function(e)
                        return not e.isWireless();
                    end)
                }, function(modem)
                    return util.table.map(modem.getNamesRemote(), function(b)
                            return {
                                modem = modem,
                                name = b,
                                methods = modem.getMethodsRemote(b)
                            }
                        end)
                end), function(a, b)
                    return util.table.combine(a, b)
                end)
        end,
        inventory = {

        }
    }
end

MODEMS = MODEMS_FUNC();

console.log(MODEMS.getAllPeripheralsOnWireless())
