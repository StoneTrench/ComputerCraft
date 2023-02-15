local function QUARRY_FUNC()
    if not turtle then
        error("Quarry can only be used on a turtle!")
    end

    require(F.PATHS.DIR.packages .. "asr.asr")

    local parentProgram = "stones-quarry";

    local transform = ASR.loadAll(parentProgram);
    transform = transform or ASR.createObject(parentProgram, { x = 0, y = 0, z = 0, direction = "north", }, "transform")

    local function GetLength(x, y, z)
        return math.sqrt(x * x + y * y + z * z)
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
                return "east"
            else
                return "west"
            end
        end

        if max == math.abs(y) then
            if y > 0 then
                return "up"
            else
                return "down"
            end
        end

        if max == math.abs(z) then
            if z > 0 then
                return "south"
            else
                return "north"
            end
        end

        return nil;
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
            local diffX, diffY, diffZ = x - transform.x(), y - transform.y(), z - transform.z();

            local prevDist = 1;
            local currDist = 0;
            
            while not (diffX == 0 and diffY == 0 and diffZ == 0) and prevDist >= currDist do
                prevDist = currDist
                
                diffX, diffY, diffZ = x - transform.x(), y - transform.y(), z - transform.z();
                QUARRY.move(GetEnumFromVector(diffX, diffY, diffZ), canBreak)
                currDist = GetLength(diffX, diffY, diffZ)

                console.log("diff", diffX, diffY, diffZ)
                console.log("tr", transform.x(), transform.y(), transform.z())
            end
        end,
        move = function(direction, canBreak)
            if direction == "up" then
                if turtle.detectUp() and canBreak then
                    if not turtle.digUp() then
                        return false;
                    end
                end

                return turtle.up();
            elseif direction == "down" then
                if turtle.detectDown() and canBreak then
                    if turtle.digDown() then
                        return false;
                    end
                end

                return turtle.down();
            else
                QUARRY.faceTowards(direction)
                
                if turtle.detect() and canBreak then
                    if turtle.dig() then
                        return false;
                    end
                end

                return turtle.forward();
            end
        end,
        faceTowards = function(direction)
            local current = transform.direction();
            transform.direction(direction);

            local dist = math.abs(EnumToYawIndex[current] - EnumToYawIndex[direction]);

            for i = 1, dist, 1 do
                turtle.turnRight()
            end
        end
    }
end

QUARRY = QUARRY_FUNC();
