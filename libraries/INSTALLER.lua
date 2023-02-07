local function INSTALLER_FUNC()
    if not http then
        error("Git requires the http API")
        error("Set http.enabled to true in the config")
        return
    end

    local function get(address)
        local path = address:gsub("https://github.com/", ""):gsub("https://raw.githubusercontent.com/", ""):gsub("blob/"
                , "")

        local response, err = http.get("https://raw.githubusercontent.com/" .. path)

        if response then
            local headers = response.getResponseHeaders()
            if not headers["Content-Type"] or not headers["Content-Type"]:find("^text/plain") then
                return nil;
            end

            local data = response.readAll()
            response.close()
            return data;
        else
            return nil;
        end
    end

    return {
        install = function(package_address, destinationFolder, silent)
            if destinationFolder == nil then destinationFolder = "." end
            if destinationFolder:sub(#destinationFolder, #destinationFolder) ~= "/" then
                destinationFolder = destinationFolder .. "/";
            end
            if silent == nil then
                silent = false
            end

            local package = get(package_address)

            if package == nil then
                error("Package not found!")
            end

            local files = {}

            for val in package:gmatch("([^\n]+)") do
                if not ((#val == 0) or (val:sub(1, 2) == "//")) then
                    table.insert(files, val);
                end
            end

            for i = 2, #files, 1 do
                local dirPath = files[i]:match("(.*/)");
                if dirPath == nil then dirPath = "" end
                fs.makeDir(destinationFolder .. dirPath)

                if not silent then
                    print("Downloading: " .. destinationFolder .. files[i])
                end

                local fileStream = fs.open(destinationFolder .. files[i], "w");

                local data = get(files[1] .. files[i]);
                if data == nil then
                    printError("Failed to get file: " .. files[i] .. "!");
                else
                    fileStream.write(data);
                    fileStream.close();
                end
            end

            print("Done.")
        end
    }
end


INSTALLER = INSTALLER_FUNC();
