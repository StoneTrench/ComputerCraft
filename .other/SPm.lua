os.loadAPI("./LSON.lua")

local PublicPort = 6124
local modem = peripheral.find("modem") or printError("No modem attached", 0)

local function CreatePacket(header, data)
    return LSON.Serialize({
        header = header,
        data = data
    }, "-")
end

local function Encrypt(str, key)
    local result = ""

    local lkey = key;
    for i = 1, #str, 1 do
        local A1 = bit.bnot(lkey + key) * key

        lkey = ((710425941047 * lkey + A1 + 813633012810) % 711719770602) % 255
        result = result .. tostring(bit.bxor(str:byte(i), lkey)):char()
    end

    return result;
end

local function Decrypt(data, key)
    local result = "";

    local lkey = key;
    for i = 1, #data, 1 do
        local A1 = bit.bnot(lkey + key) * key

        lkey = ((710425941047 * lkey + A1 + 813633012810) % 711719770602) % 255
        result = result .. tostring(bit.bxor(data:byte(i), lkey)):char()
    end

    return result;
end

local function ToHex(data)
    local line = ""
    for i = 1, #data, 1 do
        local val = string.format("%x", data:byte(i));
        if #val == 1 then write(" ") end
        write(val .. " ")

        if val == "a" then
            line = line .. "\\n"
        else
            line = line .. data:sub(i, i) .. " "
        end

        if i % 8 == 0 then
            write("   " .. line .. "\n")
            line = ""
        end
    end

    for i = 1, 8 - (#data % 8), 1 do
        write("   ")
    end

    write("   " .. line .. "\n")
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

local function Send(port, packet)
    if modem == nil then
        print(packet)
        return
    end

    modem.transmit(port, port, packet);
end

local table = { data = "Pingas", count = 100, no = true, value = nil,
    header = { name = "creeper", copy = { name = "creeper" } } }

for e = -1000000, 1000000, 1000 do

    local encrypted = Encrypt(CreatePacket(table), e);

    os.queueEvent("fakeEvent");
    os.pullEvent();

    for i = -100, 100, 1 do
        local test = Decrypt(encrypted, i)

        if test:match("creeper") then
            print(i .. " " .. e)
        end
    end
end
