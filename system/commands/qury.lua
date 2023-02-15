require(F.PATHS.DIR.packages .. "quarry/quarry")
require(F.PATHS.DIR.packages .. "turtle_queue/turtle_queue")

local args = { ... }

if args[1] == "q" then
    TURT_Q.queueFunctionCall("QUARRY.moveTo", tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), args[5] == "yes" or args[5] == "true");
elseif args[1] == "r" then
    TURT_Q.cancelAll();
    TURT_Q.queueFunctionCall("QUARRY.reset");
end
