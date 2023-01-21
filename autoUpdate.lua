local sPath = ""

sPath = shell.resolve("fax.lua")
if fs.exists(sPath) then
    shell.execute("delete"..sPath)
    shell.execute("./git get https://github.com/StoneTrench/ComputerCraft/blob/master/fax.lua fax.lua")
end

sPath = shell.resolve("git.lua")
if fs.exists(sPath) then
    shell.execute("delete"..sPath)
    shell.execute("./git get https://github.com/StoneTrench/ComputerCraft/blob/master/git.lua git.lua")
end

sPath = shell.resolve("LSON.lua")
if fs.exists(sPath) then
    shell.execute("delete"..sPath)
    shell.execute("./git get https://github.com/StoneTrench/ComputerCraft/blob/master/LSON.lua LSON.lua")
end

sPath = shell.resolve("quickPull.lua")
if fs.exists(sPath) then
    shell.execute("delete"..sPath)
    shell.execute("./git get https://github.com/StoneTrench/ComputerCraft/blob/master/quickPull.lua quickPull.lua")
end

sPath = shell.resolve("SERIALIZER.lua")
if fs.exists(sPath) then
    shell.execute("delete"..sPath)
    shell.execute("./git get https://github.com/StoneTrench/ComputerCraft/blob/master/SERIALIZER.lua SERIALIZER.lua")
end

sPath = shell.resolve("SPm.lua")
if fs.exists(sPath) then
    shell.execute("delete"..sPath)
    shell.execute("./git get https://github.com/StoneTrench/ComputerCraft/blob/master/SPm.lua SPm.lua")
end

sPath = shell.resolve("test.lua")
if fs.exists(sPath) then
    shell.execute("delete"..sPath)
    shell.execute("./git get https://github.com/StoneTrench/ComputerCraft/blob/master/test.lua test.lua")
end
