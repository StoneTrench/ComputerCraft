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
                            local meta = pkgmngr.getPackageMetadata(line);
                            if meta ~= nil then
                                table.insert(result, {
                                    metadata = meta,
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

                local packagef = textutils.unserializeJSON(SZIP.decompress(rec).files[packageFileName]);
                return packagef;
            end,
            find = function(name)
                return util.table.filter(pkgmngr.packageList.get(), function(e)
                        return e.meta.name:match(name);
                    end)
            end,
            install = function(address)
                local rec = git.get(address)

                if rec == nil then
                    return nil;
                end

                local files = SZIP.decompress(rec)
                local packagef = textutils.unserializeJSON(files.files[packageFileName]);

                SZIP.unserializeFiles(files, fs.combine(F.PATHS.downloads, packagef.name))

                --pkgmngr.packageLocal.find(packagef.name)
            end
        },
        packageLocal = {
            scan = function()
                local packages = pkgmngr.packageLocal.get();

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
            get = function()
                return util.table.map(util.fs.findFiles(F.PATHS.packages, packageFileName), function(e)
                        return fs.getDir(e)
                    end)
            end,
            find = function(name)
                return util.table.filter(pkgmngr.packageLocal.get(), function(e)
                    return e.meta.name:match(name);
                end)
            end
        },
    }
end

pkgmngr = pkgmngr_FUNC();
pkgmngr.refreshPackageList();
