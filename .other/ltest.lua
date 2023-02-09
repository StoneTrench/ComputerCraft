require("libraries.UTILITY")

term.clear()

local wind = window.create(term.current(), 8, 9, 16, 16)

util.draw.rect(wind, 1, 1, 16, 16, util.draw.createMaterial(" ", colors.white, colors.orange))
util.draw.polygon(wind, {
    1, 1,
    16, 1,
    16, 16,
    1, 16
}, false, util.draw.createMaterial("#", colors.white, colors.orange))
term.setCursorPos(1, 1)

-- local x, y = term.getSize()
-- local hx, hy = x / 2, y / 2

-- local angle = 0;
-- local radius = 16;

-- local t = 0;
-- while true do
--     angle = (t * 90 / math.pi) % 360;
--     t = t + 1;

--     term.clear();

--     UTILITY.draw.circle(term, hx, hy, radius, 0, angle);
--     UTILITY.draw.line(term, hx, hy,
--         hx + (radius * math.cos(angle * math.pi / 180)),
--         hy + (radius * math.sin(angle * math.pi / 180))
--     );
--     UTILITY.draw.line(term, hx, hy,
--         hx + 16,
--         hy
--     );
--     sleep(0.1)

--     if t > 100 then
--         break;
--     end
-- end
