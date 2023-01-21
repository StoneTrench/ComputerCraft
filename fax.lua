local FaxPort = 6124

local printer = peripheral.find("printer") or printError("No printer attached", 0)
local modem = peripheral.find("modem") or printError("No modem attached", 0)

if not modem.isOpen(FaxPort) then
    modem.open(FaxPort)
end

local event, side, channel, replyChannel, message, distance
repeat
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
until channel == 43

printer.newPage()
printer.write(message)
printer.endPage()