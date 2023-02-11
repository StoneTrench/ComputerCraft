local function SZIP_FUNC()
    return {
        getFileExtention = function ()
            return ".szip"
        end,
        packFiles = function(directory, destination)
            if destination == nil then destination = fs.getDir(directory) .. "/" end

            directory = shell.resolve(directory);

            if not fs.exists(directory) then
                error("The directory does not exist!")
            end
            if not fs.isDir(directory) then
                error("The path was not a directory!")
            end

            local RedData = SZIP.compress(SZIP.serializeFiles(directory));
            if RedData == nil then
                error("Failed to compress!")
            end

            if destination:sub(#destination - 5, #destination) ~= SZIP.getFileExtention() then
                destination = destination .. SZIP.getFileExtention()
            end

            -- if fs.exists(destination) then
            --     error("The destination already exists!")
            -- end

            local fileStream = fs.open(destination, "w")
            fileStream.write(RedData)
            fileStream.close()
        end,
        unpackFiles = function(packagePath, destination)
            packagePath = shell.resolve(packagePath);
            destination = shell.resolve(destination);

            if not fs.exists(packagePath) then
                error("The file does not exist!")
            end
            if fs.isDir(packagePath) then
                error("The path was a directory!")
            end

            local fileStream = fs.open(packagePath, "r")
            local data = SZIP.decompress(fileStream.readAll())
            fileStream.close();

            SZIP.unserializeFiles(data, destination)
        end,
        compress = function(data)
            return textutils.serializeJSON(data);
        end,
        decompress = function(data)
            return textutils.unserializeJSON(data);
        end,
        unserializeFiles = function(data, destination)
            destination = shell.resolve(destination);

            for key, value in pairs(data.files) do
                fs.makeDir(fs.getDir(fs.combine(destination, value.path)))

                fileStream = fs.open(fs.combine(destination, value.path), "w");
                fileStream.write(value.content);
                fileStream.close();
            end
        end,
        serializeFiles = function(directory)
            directory = shell.resolve(directory);

            local filesToPack = {};

            local function tree(dirPath)
                local subPaths = fs.list(dirPath)

                for i = 1, #subPaths, 1 do
                    local path = fs.combine(dirPath, subPaths[i]);

                    if fs.isDir(path) then
                        tree(path)
                    else
                        table.insert(filesToPack, path)
                    end
                end
            end
            tree(directory)

            local data = {
                files = {}
            }

            for i = 1, #filesToPack, 1 do
                local fileStream = fs.open(filesToPack[i], "r")
                table.insert(data.files, {
                    path = filesToPack[i]:gsub(fs.getDir(directory), ""),
                    content = fileStream.readAll()
                })
                fileStream.close();
            end

            return data;
        end,
        getFileFromFiles = function(serializedFile, pattern)
            for key, value in pairs(serializedFile.files) do
                if value.path:match(pattern) then
                    return value
                end
            end

            return nil
        end
    }
end

SZIP = SZIP_FUNC();
