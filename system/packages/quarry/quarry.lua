local function QUARRY_FUNC()
    if not turtle then
        error("Quarry can only be used on a turtle!")
    end

    require(F.PATHS.DIR.packages .. "asr.asr")

    local parentProgram = "stones-quarry";

    local transform = ASR.loadAll(parentProgram);
    transform = transform or ASR.createObject(parentProgram, { x = 0, y = 0, z = 0, direction = "north", }, "transform")

    local function GetLength(x, y, z)
        return math.sqrt((x * x) + (y * y) + (z * z))
    end
    local function GetEnumFromVector(x, y, z)
        local max = math.max(math.abs(x), math.abs(y), math.abs(z))

        --[[
        +x east
        -x west
        +z south
        -z north
    ]]
        if max == math.abs(x) then
            if x > 0 then
                return "east", 1, 0, 0
            else
                return "west", -1, 0, 0
            end
        end

        if max == math.abs(y) then
            if y > 0 then
                return "up", 0, 1, 0
            else
                return "down", 0, -1, 0
            end
        end

        if max == math.abs(z) then
            if z > 0 then
                return "south", 0, 0, 1
            else
                return "north", 0, 0, -1
            end
        end

        return nil, 0, 0, 0;
    end

    local YawIndexToEnum = {
        [0] = "north",
        [1] = "east",
        [2] = "south",
        [3] = "west",
        [4] = "up",
        [5] = "down",
    }
    local EnumToYawIndex = {
        ["north"] = 0,
        ["east"] = 1,
        ["south"] = 2,
        ["west"] = 3,
        ["up"] = 4,
        ["down"] = 5
    }

    return {
        --[[
            -Relative x, y and z to the position the quarry was first activated
        ]]
        moveTo = function(x, y, z, canBreak)
            print(transform.x() .. " " .. transform.y() .. " " .. transform.z() .. " " .. transform.direction())

            local diffX, diffY, diffZ = x - transform.x(), y - transform.y(), z - transform.z();

            while diffX ~= 0 or diffY ~= 0 or diffZ ~= 0 do
                if QUARRY.handleFuel() then
                    error("No fuel!")
                end

                local dirs = { GetEnumFromVector(diffX, diffY, diffZ) }
                QUARRY.move(dirs[1], dirs[2], dirs[3], dirs[4], canBreak)

                diffX, diffY, diffZ = x - transform.x(), y - transform.y(), z - transform.z();
                
                console.log(diffX, diffY, diffZ, prevDist, currDist)
            end
        end,
        move = function(direction, x, y, z, canBreak)
            if direction == nil then return false end

            if direction == "up" then
                if turtle.detectUp() and canBreak then
                    if not turtle.digUp() then
                        return false;
                    end
                end

                if not turtle.up() then
                    return false;
                end
            elseif direction == "down" then
                if turtle.detectDown() and canBreak then
                    if not turtle.digDown() then
                        return false;
                    end
                end

                if not turtle.down() then
                    return false;
                end
            else
                QUARRY.faceTowards(direction)

                if turtle.detect() and canBreak then
                    if not turtle.dig() then
                        return false;
                    end
                end

                if not turtle.forward() then
                    return false;
                end
            end

            transform.x(transform.x() + x)
            transform.y(transform.y() + y)
            transform.z(transform.z() + z)
            return true;
        end,
        faceTowards = function(direction)
            local current = transform.direction();
            transform.direction(direction);

            local dist = math.abs(EnumToYawIndex[current] - EnumToYawIndex[direction]);

            for i = 1, dist, 1 do
                turtle.turnRight()
            end
        end,
        handleFuel = function()
            if turtle.getFuelLimit() == math.huge then
                return false;
            end

            if turtle.getFuelLevel() == 0 then
                local fuelIndex = QUARRY.findItemIndex(function(e)
                    if e == nil then return false end

                    return util.string.endsWith(e.name, "coal")
                end)

                if fuelIndex == -1 then
                    return true;
                end
                turtle.refuel(1)
            end

            return false;
        end,
        findItemIndex = function(predicate)
            for i = 1, 16, 1 do
                if predicate(turtle.getItemDetail(i), i) then
                    return i;
                end
            end

            return -1;
        end,
        reset = function ()
            ASR.whipeAll(parentProgram)
        end
    }
end

QUARRY = QUARRY_FUNC();
