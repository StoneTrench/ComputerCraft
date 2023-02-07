local function GIT_FUNC()
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
        get = get,
        run = function(address, ...)
            local data = get(address)

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

GIT = GIT_FUNC();
