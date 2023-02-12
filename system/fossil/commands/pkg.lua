local function printUsage()
    local programName = fs.getName(shell.getRunningProgram():gsub(".lua", ""))
    console.log("Usages:")
    console.log(programName .. " in <name>")
    console.log("\tInstalls the package.")
    console.log(programName .. " un <name>")
    console.log("\tUninstalls the package.")
    console.log(programName .. " mk <directory>")
    console.log("\tCompiles a local package.")
    console.log(programName .. " ls")
    console.log("\tLists all local packages.")
    console.log(programName .. " sr <name>")
    console.log("\tSearches for a package online.")
    console.log(programName .. " scan")
    console.log("\tScans local packages for metadata errors.")
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
    pkgmngr.packageList.install(args[2], false)
elseif args[1] == "un" then
    pkgmngr.packageLocal.uninstall(args[2])
elseif args[1] == "sr" then
    console.log(table.concat(util.table.map(pkgmngr.packageList.findByName(args[2]), function(e)
        return e.meta.name .. " " .. (e.meta.displayName or "nil") .. " -> " .. (e.meta.version or "nil")
    end), "\n"))
    console.log(table.concat(util.table.map(pkgmngr.packageList.findByTag(args[2]), function(e)
        return e.meta.name .. " " .. (e.meta.displayName or "nil") .. " -> " .. (e.meta.version or "nil")
    end), "\n"))
elseif args[1] == "ls" then
    console.write(table.concat(util.table.map(pkgmngr.packageLocal.getPaths(), function(e)
        local meta = textutils.unserializeJSON(util.fs.readFile(e));

        return meta.name .. " " .. (meta.displayName or "nil") .. " -> " .. (meta.version or "nil")
    end), "\n"), "\n")
elseif args[1] == "scan" then
    console.write("Scanning...\n")
    local locals = pkgmngr.packageLocal.scanAll()
    local counter = 0;

    for key, value in pairs(locals) do
        if value.status == "success" then
            console.write(value.message .. "\n")
        elseif value.status == "partial" then
            console.warn(value.message .. "\n")
        elseif value.status == "failed" then
            printError(value.message .. "\n")
        else
            console.write(value.message .. "\n")
        end
        counter = counter + 1;
    end

    console.write("Done scanning " .. counter .. " packages.\n")
elseif args[1] == "mk" then
    pkgmngr.packageLocal.compilePackage(args[2], false)
else
    printUsage()
end