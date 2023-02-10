local function printUsage()
    local programName = fs.getName(shell.getRunningProgram():gsub(".lua", ""))
    console.log("Usages:\n")
    console.log(programName .. " get <name>\n")
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

if args[1] == "get" then
    pkgmngr.packageList.install(pkgmngr.packageList.find(args[2])[1])
elseif args[1] == "search" then
    console.log(table.concat(util.table.map(pkgmngr.packageList.find(args[2]), function (e)
        return e.name.." -> \""..e.address:sub(#e.address - 16, #e.address).."\""
    end), "\n").."\n")
elseif args[1] == "list" then
    console.log(pkgmngr.packageList.get().."\n")
elseif "scan" then

    console.log("Scanning...\n")
    local locals = pkgmngr.scanLocalPackages()

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

end
