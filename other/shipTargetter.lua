local radar = peripheral.find("radar");

local range = 50;
local target = nil;

function FindTargetIndex(ships, mass)
    for i, value in ipairs(ships) do
        if math.floor(value.mass / 10) == math.floor(mass / 10) then
            return i;
        end
    end

    return -1;
end

while true do
    local ships = { radar.scan(range) };

    print(ships[2])

    if target == nil then
        target = ships[2];
    else
        local index = FindTargetIndex(ships, target.mass)

        if not (index == -1) then
            local movementVector = {
                x = ships[index].position[1] - target.position[1],
                y = ships[index].position[2] - target.position[2],
                z = ships[index].position[3] - target.position[3],
            };
            local dist = math.sqrt((movementVector.x * movementVector.x) + (movementVector.y * movementVector.y) +
                (movementVector.z * movementVector.z));
            local speed = dist / 0.5;

            print("Dist: " .. dist);
            print("Speed: " .. speed);

            target = ships[index];

        end
    end

    sleep(0.5)
end
