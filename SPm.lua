os.loadAPI("./LSON.lua")

local PublicPort = 6124
local modem = peripheral.find("modem") or printError("No modem attached", 0)

local function CreatePacket(header, data)
    return LSON.Serialize({
        header = header,
        data = data
    })
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
    return LSON.Deserialize(message);
end

local function Encrypt(str, key)
    local result = ""

    for i = 1, #str, 1 do
        result = result .. "," .. tostring(bit.bxor(str:byte(i), key))
    end

    return result;
end

local function Decrypt(data, key)
    local result = "";

    for c in data:gmatch(",(.-),") do
        result = result .. bit.bxor(tonumber(c), key):char()
    end

    return result;
end

local function Send(port, packet)
    modem.transmit(port, port, packet);
end

Send(PublicPort, Encrypt(CreatePacket({ data = "Pingas", count = 100, no = true, value = nil,
    header = { name = "creeper", copy = { name = "creeper" } } }), 42));
