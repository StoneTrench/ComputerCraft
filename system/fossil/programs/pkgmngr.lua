local function pkgmngr_FUNC()
    require(F.PATHS.programs .. "git")
    require(F.PATHS.programs .. "sziplib")

    local packageFileName = "package.json";
    local packageAddrassesFile = F.PATHS.programs .. ".pkgListAddr"

    local packageListAddresses = textutils.unserialise(util.fs.readFile(packageAddrassesFile))

    local packageList = {};

    return {
        removePackageListAddress = function(index)
            table.remove(packageListAddresses, index)
            util.fs.writeFile(packageAddrassesFile, textutils.serialise(packageListAddresses))
        end,
        addPackageListAddress = function(address)
            table.insert(packageListAddresses, address)
            util.fs.writeFile(packageAddrassesFile, textutils.serialise(packageListAddresses))
        end,
        getPackageListAddress = function()
            return util.clone(packageListAddresses)
        end,
        refreshPackageList = function()
            packageList = util.table.reduce(util.table.map(packageListAddresses, function(e)
                    local rec = git.get(e)

                    if rec == nil then
                        return { "Failed to get package list." }
                    end

                    local result = {};

                    for line in rec:gmatch("([^\n]+)") do
                        table.insert(result, {
                            metadata = pkgmngr.getPackageMetadata(line),
                            address = line,
                        })
                    end

                    return result;
                end), function(a, b)
                    return util.table.combine(a, b)
                end)
        end,
        getPackageMetadata = function (address)
            local rec, err = git.get(address);

            if rec == nil then
                error("Address not found! "..(address))
                return nil;
            end

            console.log(rec)

            local packagef = textutils.unserializeJSON(SZIP.decompress(rec)[packageFileName]);

            return packagef;
        end,
        find = function(name)
            return util.table.filter(pkgmngr.getPackages(), function(e)
                    return e.name:match(name);
                end)
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
            return util.clone(packageList)
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
pkgmngr.refreshPackageList();
