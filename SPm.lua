os.loadAPI("./LSON.lua")

local PublicPort = 6124
local modem = peripheral.find("modem") or printError("No modem attached", 0)

local function CreatePacket(header)
    print(LSON.Serialize(LSON.Deserialize(LSON.Serialize(header))));
end

local function StartListening(port)
    if not modem.isOpen(port) then
        modem.open(port)
    end

    local event, side, channel, replyChannel, message, distance
    repeat
        event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    until channel == port

    modem.close(port)
    return message;
end

CreatePacket({ data = "Pingas", count = 100, no = true, value = nil, header = { name = "creeper", copy = { name = "creeper" }} });
