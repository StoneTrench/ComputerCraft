require(".system.fossil.F")

for i, value in pairs(fs.list(F.PATHS.global)) do
    local path = value:gsub(".lua", "")
    require(fs.combine("../", F.PATHS.global, path))
end

local w, h = term.getSize();
_G.console = CONSOLE.createConsole(window.create(term.current(), 1, 1, w / 2 - 1, h), 0);
console.clear();

local name, version      = F.getName();
local license, copyright = F.getLicenseCopyright();
console.log(CONSOLE.getColorSymbol("yellow") .. name .. "\t" .. version)
console.log(license .. "\t" .. copyright .. CONSOLE.getColorSymbol("white"))

_G.logger = CONSOLE.createConsole(window.create(term.current(), w / 2, 1, w / 2 - 1, h), 1);
_G.logger.clear();

fell.startInstance("0")

threading.Start();
threading.End();
