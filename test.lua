local diskDrives = peripheral.find("modem").getNamesRemote();
local monitor = peripheral.find("monitor");

local y = 1;

for key, value in pairs(diskDrives) do
    monitor.setCursorPos(0, y);
    monitor.write(value);
    y = y + 1;
end
