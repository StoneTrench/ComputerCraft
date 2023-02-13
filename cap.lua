require(".system.fossil.programs.pkgmngr")

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

console.log("Compiling...")
local paths = pkgmngr.packageLocal.getPaths();

local resultPaths = {}
for i = 1, #paths, 1 do
    table.insert(resultPaths, pkgmngr.packageLocal.compilePackage(paths[i], "packageList", false, false))
end

console.log("Compiled " .. #paths)

console.log("Adding to package.list")

util.fs.writeFile("./packageList/packages.list", table.concat(util.table.map(resultPaths, function(e)
    return  "https://github.com/StoneTrench/ComputerCraft/blob/master/" .. e
end), "\n"))

console.log("Added")
