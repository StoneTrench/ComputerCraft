local function printUsage()
    local programName = fs.getName(shell.getRunningProgram():gsub(".lua", ""))
    console.log("Usages:\n")
    console.log(programName .. " pack <filepath> <destination>")
    console.log(programName .. " unpack <filepath> <destination>")
end

local args = { ... }

if #args < 3 then
    printUsage()
    return
end

require(F.PATHS.DIR.programs .. "sziplib")

if args[1] == "pack" then
    SZIP.packFiles(args[2], args[3])
    return
elseif args[1] == "unpack" then
    SZIP.unpackFiles(args[2], args[3])
    return
else
    printUsage()
    return
end
