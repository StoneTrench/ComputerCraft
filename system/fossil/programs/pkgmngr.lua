local function pkgmngr_FUNC()
    local packageFileName = "package.json";

    return {
        download = function(address)
            
        end,
        getPackages = function()
            return util.table.map(util.fs.findFiles(F.PATHS.packages, packageFileName), function(e)
                    return fs.getDir(e)
                end)
        end,
        scanPackages = function()
            local packages = pkgmngr.getPackages();

            console.log("Scanning...\n")

            for key, value in pairs(packages) do
                local packagef = textutils.unserialiseJSON(util.fs.readFile(fs.combine(value, packageFileName)));

                if packagef then
                    local check = {
                        "name",
                        "description",
                        "version",
                        "authors",
                    };
                    local missing = {}

                    for key, value in pairs(check) do
                        if not packagef[value] then
                            table.insert(missing, value)
                        end
                    end

                    if #missing > 0 then
                        console.warn("Package " .. (packagef.name or fs.getName(value)) .. " is missing: " ..
                        table.concat(missing, ", ") .. "!\n")
                    else
                        console.log("Package " .. packagef.name .. " scanned.\n")
                    end
                else
                    console.warn("Failed to scan package " .. fs.getName(value) .. "!\n")
                end
            end

            console.log("Done scanning " .. #packages .. " packages.\n")
        end
    }
end

pkgmngr = pkgmngr_FUNC();
