require(".system.fossil.F")

for i, value in pairs(fs.list(F.PATHS.global)) do
    local path = value:gsub(".lua", "")
    require(fs.combine("../", F.PATHS.global, path))
end

_G.console = CONSOLE.createConsole(term, 0);

console.clear();
local name, version = F.getName();
local license       = F.getLicense();
console.write(CONSOLE.getColorSymbol("yellow") .. name .. " " ..
version .. "\n" .. license .. CONSOLE.getColorSymbol("white") .. "\n")
while true do
    fell.readCommand();
end
