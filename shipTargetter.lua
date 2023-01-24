local radar = peripheral.find("radar");

local range = 50;
local target = nil;

function FindTargetIndex(ships, weight)
    for i, value in ipairs(ships) do
        if value.weight == weight then
            return i;
        end
    end

    return -1;
end

while true do
    local ships = radar.scan(range);

    if target == nil then
        target = ships[2];
    else
        local index = FindTargetIndex(ships, target.weight)

        if not index == -1 then
            local movementVector = {
                x = ships[index].position.x - target.position.x,
                y = ships[index].position.y - target.position.y,
                z = ships[index].position.z - target.position.z,
            };
            local dist = math.sqrt((movementVector.x * movementVector.x) + (movementVector.y * movementVector.y) +
                (movementVector.z * movementVector.z));
            local speed = dist / 0.5;

            print("Dist: " .. dist);
            print("Speed: " .. speed);
        end
    end

    sleep(0.5)
end