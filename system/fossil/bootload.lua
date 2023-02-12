local enableDebug = false;
require(".system.fossil.F")

-- load globals
for i, value in pairs(fs.list(F.PATHS.global)) do
    local path = value:gsub(".lua", "")
    require(fs.combine("../", F.PATHS.global, path))
end

-- so fell doesn't crash
if os.getComputerLabel() == nil then
    os.setComputerLabel("computer")
end

if enableDebug then
    -- setup defailt console
    local w, h = term.getSize();
    _G.console = CONSOLE.createConsole(window.create(term.current(), 1, 1, w / 2 - 1, h), 0);
    console.clear();

    -- logger to debug
    _G.logger = CONSOLE.createConsole(window.create(term.current(), w / 2, 1, w / 2 - 1, h), 1);
    _G.logger.clear();
else
    local w, h = term.getSize();
    _G.console = CONSOLE.createConsole(window.create(term.current(), 1, 1, w, h), 0);
    console.clear();
end

-- print header
local name, version      = F.getName();
local license, copyright = F.getLicenseCopyright();
console.log(CONSOLE.getColorSymbol("yellow") .. name .. "\t" .. version)
console.log(license .. "\t" .. copyright .. CONSOLE.getColorSymbol("white"))

-- start fell
fell.startInstance("0")

-- start threading
threading.Start();
threading.End();
