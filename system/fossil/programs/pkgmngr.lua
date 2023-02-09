local function pkgmngr_FUNC()
    local packageFileName = "package.json";
    require(F.PATHS.programs .. "git")
    require(F.PATHS.programs .. "sziplib")

    local packageListAddresses = {
        "https://github.com/StoneTrench/ComputerCraft/blob/master/packages.list"
    }

    return {
        removePackageListAddress = function(index)
            table.remove(packageListAddresses, index)
        end,
        addPackageListAddress = function(address)
            table.insert(packageListAddresses, address)
        end,
        getPackageListAddress = function()
            return util.clone(packageListAddresses)
        end,
        download = function(address)
            local rec = git.get(address)

            if rec == nil then
                error("Address not found!")
                return nil;
            end

            local downloadPath = fs.combine(F.PATHS.downloads, "package/", fs.getName(address))

            util.fs.writeFile(downloadPath, rec)
        end,
        getPackages = function()
            return util.table.reduce(util.table.map(packageListAddresses, function(e)
                    local rec = git.get(e)

                    if rec == nil then
                        return { "Failed to get package list." }
                    end

                    local result = {};

                    for line in rec:gmatch("([^\n]+)") do
                        table.insert(result, {
                            name = fs.getName(line),
                            address = line,
                        })
                    end

                    return result;
                end), function(a, b)
                    return util.table.combine(a, b)
                end)
        end,
        scanLocalPackages = function()
            local packages = util.table.map(util.fs.findFiles(F.PATHS.packages, packageFileName), function(e)
                    return fs.getDir(e)
                end)

            local result = {};

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
                        local name = (packagef.name or fs.getName(value));

                        result[name] = {
                            meta = packagef,
                            message = "Package " .. name .. " is missing: " .. table.concat(missing, ", ") .. "!",
                            status = "parial"
                        }
                    else
                        result[packagef.name] = {
                            meta = packagef,
                            message = "Scanned package " .. packagef.name .. ".",
                            status = "success"
                        };
                    end
                else
                    result[fs.getName(value)] = {
                        meta = nil,
                        message = "Failed to scan package " .. fs.getName(value) .. "!",
                        status = "failed"
                    }
                end
            end

            return result;
        end
    }
end

pkgmngr = pkgmngr_FUNC();
