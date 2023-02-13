local function pkgmngr_FUNC()
    require(F.PATHS.DIR.programs .. "git")
    require(F.PATHS.DIR.programs .. "sziplib")

    local packageFileName = "package.json";
    local packageAddrassesFile = F.PATHS.DIR.programs .. ".pkgListAddr"

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
                            local packagef = pkgmngr.packageList.getPackageMetadata(line);
                            if packagef ~= nil then
                                table.insert(result, {
                                    packagef = packagef,
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
            findByName = function(name)
                return util.table.toArray(util.table.filter(pkgmngr.packageList.get(), function(e)
                        local result = false;
                        if e.packagef.name ~= nil then
                            result = e.packagef.name:match(name)
                        end
                        return result;
                    end))
            end,
            findByTag = function(tag)
                return util.table.toArray(util.table.filter(pkgmngr.packageList.get(), function(e)
                        local result = false;
                        if e.packagef.tags ~= nil then
                            util.table.contains(e.packagef.tags, tag)
                        end
                        return result;
                    end))
            end,
            install = function(name, silent)
                if silent == nil then
                    silent = true;
                end

                if not silent then
                    console.log("Installing " .. name .. "...")
                end

                local rec = git.get(pkgmngr.packageList.findByName(name)[1].address)

                if rec == nil then
                    error(name .. " not found!")
                end
                local files = SZIP.decompress(rec)

                local packagefZIP = SZIP.getFileFromFiles(files, packageFileName);
                if packagefZIP == nil then
                    error(packageFileName .. " not found!")
                end
                SZIP.unserializeFiles(files, F.PATHS.DIR.packages)

                local packagef = textutils.unserializeJSON(packagefZIP.content)
                local packagePath = fs.combine(F.PATHS.DIR.packages, fs.getDir(packagefZIP.path));

                if packagef.commands then
                    console.log("Installing commands.")
                    for key, value in pairs(packagef.commands) do
                        local cmd_src = fs.combine(packagePath, value);
                        local cmd_dest = fs.combine(F.PATHS.DIR.commands, value);

                        if not fs.exists(cmd_dest) then
                            fs.copy(cmd_src, cmd_dest)
                            if not silent then
                                console.log("\t" .. value .. "...")
                            end
                        else
                            if not silent then
                                console.warn("\t" .. value .. " already found in destination!")
                            end
                        end
                    end
                end
                if packagef.dependencies then
                    for key, value in pairs(packagef.dependencies) do
                        pkgmngr.packageList.install(value, true)
                        if not silent then
                            console.log("Installing dependency " .. value .. "...")
                        end
                    end
                end

                if not silent then
                    console.log((packagef.displayName or packagef.name) .. " installed.")
                end

                return packagef
            end
        },
        packageLocal = {
            scanAll = function()
                local packages = pkgmngr.packageLocal.getPaths();

                local result = {};

                for key, value in pairs(packages) do
                    local packagef, name, status, message = pkgmngr.packageLocal.scan(value)
                    result[name] = {
                        packagef = packagef,
                        message = message,
                        status = status,
                    }
                end

                return result;
            end,
            scan = function(packageDir)
                local packagef = textutils.unserialiseJSON(util.fs.readFile(packageDir));

                local message = "";
                local status = "";
                local name = nil;

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

                    name = (packagef.displayName or packagef.name or fs.getName(packageDir));
                    if #missing > 0 then
                        message = "Package " .. name .. " is missing: " .. table.concat(missing, ", ") .. "!";
                        status = "parial";
                    else
                        message = "Scanned package " .. name .. ".";
                        status = "success";
                    end
                else
                    name = fs.getName(packageDir);
                    message = "Failed to scan package " .. name .. "!";
                    status = "failed";
                end

                return packagef, name, status, message;
            end,
            getPaths = function()
                return util.table.map(util.fs.findFiles(F.PATHS.DIR.packages, packageFileName), function(e)
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
                        fs.delete(fs.combine(F.PATHS.DIR.commands, value))
                    end
                end

                fs.delete(fs.getDir(packagePath))
            end,
            compilePackage = function(packageFilePath, destinationDirectory, silent, enableCommandFileWarn)
                if silent == nil then
                    silent = true;
                end
                if enableCommandFileWarn == nil then
                    enableCommandFileWarn = not silent;
                end

                packageFilePath = shell.resolve(packageFilePath);

                if not fs.exists(packageFilePath) then
                    error(packageFilePath .. " doesn't exist!")
                end

                local packagef, name, status, message = pkgmngr.packageLocal.scan(packageFilePath)

                local packageDirectory = fs.getDir(packageFilePath);

                if status == "failed" then
                    error(message);
                end
                if not silent then
                    if status == "partial" then
                        console.warn(message)
                    end
                    if status == "success" then
                        console.log(message)
                    end
                end

                if enableCommandFileWarn then
                    console.warn(
                        "Warning the compiler will move the command file into the package and overwite it if there's one!")
                    console.warn("Do you still wish to proceed? (y/n)")
                    console.write("\t")
                    local option = console.input.read({ "y", "n" }, nil):lower()
                    if option == "n" then
                        console.log("Cancelled.")
                        return;
                    elseif option == "y" then
                        console.log("Continuing.")
                    end
                end

                if packagef.commands then
                    if not silent then
                        console.log("Copying commands.")
                    end
                    for key, value in pairs(packagef.commands) do
                        local cmd_src = fs.combine(F.PATHS.DIR.commands, value);
                        local cmd_dest = fs.combine(packageDirectory, value);

                        fs.delete(cmd_dest)
                        fs.copy(cmd_src, cmd_dest)
                    end
                end

                local fileName = packagef.name;

                if packagef.version then
                    fileName = fileName .. "-" .. packagef.version
                end

                fileName = fileName .. ".spac"
                if not silent then
                    console.log("Packing " .. fileName)
                end

                local filepath = SZIP.packFiles(packageDirectory, fs.combine(destinationDirectory, fileName))
                if not silent then
                    console.log("Done.")
                end

                return filepath;
            end
        },
    }
end

pkgmngr = pkgmngr_FUNC();
pkgmngr.packageList.refresh();
