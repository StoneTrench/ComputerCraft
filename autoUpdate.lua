
if fs.exists(shell.resolve("fax.lua")) then
    shell.execute("delete fax.lua")
    shell.execute("git get https://github.com/StoneTrench/ComputerCraft/blob/master/fax.lua fax.lua")
end

if fs.exists(shell.resolve("git.lua")) then
    shell.execute("delete git.lua")
    shell.execute("git get https://github.com/StoneTrench/ComputerCraft/blob/master/git.lua git.lua")
end

if fs.exists(shell.resolve("LSON.lua")) then
    shell.execute("delete LSON.lua")
    shell.execute("git get https://github.com/StoneTrench/ComputerCraft/blob/master/LSON.lua LSON.lua")
end

if fs.exists(shell.resolve("quickPull.lua")) then
    shell.execute("delete quickPull.lua")
    shell.execute("git get https://github.com/StoneTrench/ComputerCraft/blob/master/quickPull.lua quickPull.lua")
end

if fs.exists(shell.resolve("SERIALIZER.lua")) then
    shell.execute("delete SERIALIZER.lua")
    shell.execute("git get https://github.com/StoneTrench/ComputerCraft/blob/master/SERIALIZER.lua SERIALIZER.lua")
end

if fs.exists(shell.resolve("SPm.lua")) then
    shell.execute("delete SPm.lua")
    shell.execute("git get https://github.com/StoneTrench/ComputerCraft/blob/master/SPm.lua SPm.lua")
end

if fs.exists(shell.resolve("test.lua")) then
    shell.execute("delete test.lua")
    shell.execute("git get https://github.com/StoneTrench/ComputerCraft/blob/master/test.lua test.lua")
end
