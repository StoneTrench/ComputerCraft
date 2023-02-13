local function printUsage()
    local programName = fs.getName(shell.getRunningProgram():gsub(".lua", ""))
    console.log("Usages:")
    console.log(programName .. " get <code> <filename>")
    console.log(programName .. " run <code> <arguments>")
end

local args = { ... }

if #args < 2 then
    printUsage()
    return
end

if not http then
    printError("Git requires the http API")
    printError("Set http.enabled to true in the config")
    return
end

require(F.PATHS.DIR.programs .. "git")

if args[1] == "get" then
    if #args == 2 then
        args[3] = F.PATHS.downloads
    end
    local sPath = shell.resolve(args[3]);

    local res = git.get(args[2])
    if res then
        util.fs.writeFile(sPath, res)

        console.log("Downloaded at " .. sPath)
    end
elseif args[1] == "run" then
    git.run(args[2])
else
    printUsage()
    return
end
