local function pkgmngr_FUNC()
    require(F.PATHS.programs .. "git")
    require(F.PATHS.programs .. "sziplib")

    local packageFileName = "package.json";
    local packageAddrassesFile = F.PATHS.programs .. ".pkgListAddr"

    local packageListAddresses = textutils.unserialise(util.fs.readFile(packageAddrassesFile))

    local packageList = {};

    return {
        packageListAddress = {
            remove = function(index)
                table.remove(packageListAddresses, index)
                util.fs.writeFile(packageAddrassesFile, textutils.serialise(packageListAddresses))
            end,
            add = function(address)
                table.insert(packageListAddresses, address)
                util.fs.writeFile(packageAddrassesFile, textutils.serialise(packageListAddresses))
            end,
            get = function()
                return util.clone(packageListAddresses)
            end,
        },
        packageList = {
            refresh = function()
                packageList = util.table.reduce(util.table.map(packageListAddresses, function(e)
                        local rec = git.get(e)

                        if rec == nil then
                            return { "Failed to get package list." }
                        end

                        local result = {};

                        for line in rec:gmatch("([^\n]+)") do
                            local meta = pkgmngr.packageList.getPackageMetadata(line);
                            if meta ~= nil then
                                table.insert(result, {
                                    meta = meta,
                                    address = line,
                                })
                            end
                        end

                        return result;
                    end), function(a, b)
                        return util.table.combine(a, b)
                    end)
            end,
            get = function()
                return util.clone(packageList)
            end,
            getPackageMetadata = function(address)
                local rec = git.get(address);

                if rec == nil then
                    return nil;
                end

                local packagef = textutils.unserializeJSON(SZIP.getFileFromFiles(SZIP.decompress(rec), packageFileName)
                    .content);
                return packagef;
            end,
            find = function(name)
                return util.table.toArray(util.table.filter(pkgmngr.packageList.get(), function(e)
                        return e.meta.name:match(name);
                    end))
            end,
            install = function(name)
                local rec = git.get(pkgmngr.packageList.find(name)[1].address)

                if rec == nil then
                    return nil;
                end

                local files = SZIP.decompress(rec)
                local packagef = textutils.unserializeJSON(SZIP.getFileFromFiles(files, packageFileName).content);

                SZIP.unserializeFiles(files, F.PATHS.packages)
                local packagePath = pkgmngr.packageLocal.find(packagef.name)[1];

                if packagef.commands then
                    for key, value in pairs(packagef.commands) do
                        fs.copy(fs.combine(packagePath, value), fs.combine(F.PATHS.commands, value))
                    end
                end

                return packagef
            end
        },
        packageLocal = {
            scan = function()
                local packages = pkgmngr.packageLocal.getPaths();

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

                        local name = (packagef.displayName or packagef.name or fs.getName(value));
                        if #missing > 0 then
                            result[name] = {
                                meta = packagef,
                                message = "Package " .. name .. " is missing: " .. table.concat(missing, ", ") .. "!",
                                status = "parial"
                            }
                        else
                            result[name] = {
                                meta = packagef,
                                message = "Scanned package " .. name .. ".",
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
            end,
            getPaths = function()
                return util.table.map(util.fs.findFiles(F.PATHS.packages, packageFileName), function(e)
                        return e
                    end)
            end,
            find = function(name)
                return util.table.toArray(util.table.filter(pkgmngr.packageLocal.getPaths(), function(e)
                        return textutils.unserializeJSON(util.fs.readFile(e)).name:match(name);
                    end))
            end,
            uninstall = function(name)
                local packagePath = pkgmngr.packageLocal.find(name)[1]
                local packagef = util.fs.readFile(packagePath)

                if packagef.commands then
                    for key, value in pairs(packagef.commands) do
                        fs.delete(fs.combine(F.PATHS.commands, value))
                    end
                end

                fs.delete(fs.getDir(packagePath))
            end
        },
    }
end

pkgmngr = pkgmngr_FUNC();
pkgmngr.packageList.refresh();
