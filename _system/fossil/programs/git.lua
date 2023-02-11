local function git_FUNC()
    if not http then
        error("Git requires the http API")
        error("Set http.enabled to true in the config")
        return
    end

    return {
        get = function(address)
            local rawPath = "https://raw.githubusercontent.com/" ..
                address:gsub("https://github.com/", ""):gsub("https://raw.githubusercontent.com/", ""):gsub(
                    "blob/", "");

            local response = http.get(rawPath)

            if response then
                local headers = response.getResponseHeaders()
                if not headers["Content-Type"] or not
                    (headers["Content-Type"]:find("^text/plain") or headers["Content-Type"]:find("^application/octet-stream")) then
                    return nil;
                end

                local data = response.readAll()
                response.close()
                return data;
            end
            return nil;
        end,
        run = function(address, ...)
            local data = git.get(address)

            if data == nil then
                return false;
            end

            local func, err = load(data, address, "t", _ENV)

            if not func then
                error(err)
            end

            return pcall(func, select(3, ...))
        end
    }
end

git = git_FUNC();
