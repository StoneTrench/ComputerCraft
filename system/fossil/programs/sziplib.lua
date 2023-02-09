local function SZIP_FUNC()
    return {
        packFiles = function(directory, destination)
            if destination == nil then destination = fs.getDir(directory) .. "/" end
            if destination:sub(#destination, #destination) ~= "/" then destination = destination .. "/" end

            directory = shell.resolve(directory);

            if not fs.exists(directory) then
                error("The directory does not exist!")
            end
            if not fs.isDir(directory) then
                error("The path was not a directory!")
            end


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

            local fileStream = fs.open(fs.combine(destination, fs.getName(directory) .. ".spac"), "wb")

            local RedData = lualzw.compress(textutils.serialise(data));

            if RedData == nil then
                error("Failed to compress!")
            end

            fileStream.write(RedData)
            fileStream.close()
        end,
        decompress = function (data)
            local redData, err = lualzw.decompress(data);

            if redData == nil then
                error("Failed to decompress the file!\n" .. err)
            end

            return textutils.unserialize(redData);
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

            local fileStream = fs.open(packagePath, "rb")
            local data = SZIP.decompress(fileStream.readAll())
            fileStream.close();

            for key, value in pairs(data.files) do
                fs.makeDir(fs.getDir(fs.combine(destination, value.path)))

                fileStream = fs.open(fs.combine(destination, value.path), "w");
                fileStream.write(value.content);
                fileStream.close();
            end
        end
    }
end

SZIP = SZIP_FUNC();
