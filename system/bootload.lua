require(".system.F")

for i, value in pairs(fs.list(F.PATHS.global)) do
    local path = value:gsub(".lua", "")
    require(fs.combine("../", F.PATHS.global, path))
end

console.clear();
local name, version = F.getName();
local license       = F.getLicense();
console.log(console.getColorSymbol("yellow") .. name .. " " ..
version .. "\n" .. license .. console.getColorSymbol("white") .. "\n")
while true do
    fell.readCommand();
end
