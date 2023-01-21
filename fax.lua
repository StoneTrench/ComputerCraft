local FaxPort = 6124

local printer = peripheral.find("printer") or printError("No printer attached", 0)
local modem = peripheral.find("modem") or printError("No modem attached", 0)

if not modem.isOpen(FaxPort) then
    modem.open(FaxPort)
end

local event, side, channel, replyChannel, message, distance
repeat
    event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
until channel == FaxPort

-- Paper Width is 25 columns

printer.newPage();
local columnCounter = 0;
local rowCounter = 0;
for i = 1, #message, 1 do
    local char = message:sub(i, i);
    columnCounter = columnCounter + 1;

    printer.write(char);
    printer.setCursor(columnCounter, rowCounter);

    if columnCounter == 25 or char == "\n" then
        columnCounter = 0;
        rowCounter = rowCounter + 1;
    end
end
printer.endPage();