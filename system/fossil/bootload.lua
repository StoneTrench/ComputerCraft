local enableDebug = false;
require(".system.fossil.F")

-- load globals
for i, value in pairs(fs.list(F.PATHS.DIR.global)) do
    local path = value:gsub(".lua", "")
    require(fs.combine("../", F.PATHS.DIR.global, path))
end

-- so fell doesn't crash
if os.getComputerLabel() == nil then
    os.setComputerLabel("computer")
end

local w, h = term.getSize();

if enableDebug then
    -- setup defailt console
    _G.console = CONSOLE.createConsole(window.create(term.current(), 1, 1, w / 2 - 1, h), 0);
    -- logger to debug
    _G.logger = CONSOLE.createConsole(window.create(term.current(), w / 2, 1, w / 2 - 1, h), 1);
else
    -- setup defailt console
    _G.console = CONSOLE.createConsole(window.create(term.current(), 1, 1, w, h), 0);
    -- hidden logger
    _G.logger = CONSOLE.createConsole(window.create(term.current(), w / 2, 1, w / 2 - 1, h, false), 1);
end

_G.console.clear();
_G.logger.clear();

_G.console.redirectGlobalCommands();

-- start fell
fell.startInstance("0")

-- start threading
threading.Start();
