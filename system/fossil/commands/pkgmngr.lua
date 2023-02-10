local function printUsage()
    local programName = fs.getName(shell.getRunningProgram():gsub(".lua", ""))
    console.log("Usages:\n")
    console.log(programName .. " in <name>\n")
    console.log(programName .. " un <name>\n")
    console.log(programName .. " list\n")
    console.log(programName .. " search <name>\n")
    console.log(programName .. " scan\n")
end

local args = { ... }

if #args < 1 then
    printUsage()
    return
end

if not http then
    printError("Package manager requires the http API")
    printError("Set http.enabled to true in the config")
    return
end

require(F.PATHS.programs .. "pkgmngr")

if args[1] == "in" then
    console.log("Installing...\n")
    console.log("Installed " .. pkgmngr.packageList.install(args[2]).displayName .. ".\n")
elseif args[1] == "un" then
    pkgmngr.packageLocal.uninstall(args[2])
elseif args[1] == "search" then
    console.log(table.concat(util.table.map(pkgmngr.packageList.find(args[2]), function(e)
        return e.meta.name .. " " .. e.meta.displayName .. " -> " .. e.meta.version
    end), "\n") .. "\n")
elseif args[1] == "list" then
    console.log(table.concat(util.table.map(pkgmngr.packageLocal.getPaths(), function(e)
        local meta = textutils.unserializeJSON(util.fs.readFile(e));

        return meta.name .. " " .. meta.displayName .. " -> " .. meta.version
    end), "\n"), "\n")
elseif args[1] == "scan" then
    console.log("Scanning...\n")
    local locals = pkgmngr.packageLocal.scan()

    for key, value in pairs(locals) do
        if value.status == "success" then
            console.log(value.message .. "\n")
        elseif value.status == "partial" then
            console.warn(value.message .. "\n")
        elseif value.status == "failed" then
            printError(value.message .. "\n")
        else
            console.log(value.message .. "\n")
        end
    end

    console.log("Done scanning " .. #locals .. " packages.\n")
else
    printUsage()
end
