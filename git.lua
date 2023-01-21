local function printUsage()
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    print("Usages:")
    print(programName .. " get <code> <filename>")
    print(programName .. " run <code> <arguments>")
    print(programName .. " clone <code>")
end

local args = { ... }

if #args < 2 then
    printUsage()
    return
end

if not http then
    printError("Git requires the http API")
    printError("Set http.enabled to true in the config")
    return
end

function GetData(address)
    local path = string.gsub(string.gsub(address, "https://github.com/", ""), "blob/", "")

    local response, err = http.get("https://raw.githubusercontent.com/" .. path)

    if response then
        local headers = response.getResponseHeaders()
        if not headers["Content-Type"] or not headers["Content-Type"]:find("^text/plain") then
            printError("Failure")
            return nil;
        end

        local sResponse = response.readAll()
        response.close()
        return sResponse;
    else
        printError(err)
        return nil;
    end
end

if args[1] == "get" then
    if #args < 3 then
        printUsage()
        return
    end

    -- Determine file to download
    local sPath = shell.resolve(args[3])
    if fs.exists(sPath) then
        printError("File already exists!")
        return;
    end

    -- GET the contents from pastebin
    local res = GetData(args[2])
    if res then
        local file = fs.open(sPath, "w")
        file.write(res)
        file.close()

        print("Downloaded as " .. args[3])
    end
elseif args[1] == "run" then
    local res = GetData(args[2])
    if res then
        local func, err = load(res, args[2], "t", _ENV)
        if not func then
            printError(err)
            return
        end
        local success, msg = pcall(func, select(3, ...))
        if not success then
            printError(msg)
        end
    end
elseif args[1] == "clone" then
    print("Not implemented!")
else
    printUsage()
    return
end
