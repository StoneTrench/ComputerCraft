require(".system.fossil.F")

for i, value in pairs(fs.list(F.PATHS.global)) do
    local path = value:gsub(".lua", "")
    require(fs.combine("../", F.PATHS.global, path))
end

local w, h = term.getSize();
_G.console = CONSOLE.createConsole(window.create(term.current(), 1, 1, w, h), 0);

console.clear();
local name, version      = F.getName();
local license, copyright = F.getLicenseCopyright();
console.log(CONSOLE.getColorSymbol("yellow") .. name .. "\t" .. version)
console.log(license .. "\t" .. copyright .. CONSOLE.getColorSymbol("white"))

fell.startInstance("0")

threading.Start();
threading.End();