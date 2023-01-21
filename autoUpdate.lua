local sPath = ""

sPath = shell.resolve("fax.lua")
if fs.exists(sPath) then
    print("deleting")

    shell.execute("delete "..sPath)

    print("gitting")

    local response = http.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/fax.lua");
    local file = fs.open(sPath, "w");
    file.write(response.readAll());
    file.close();
    response.close();
end

sPath = shell.resolve("git.lua")
if fs.exists(sPath) then
    print("deleting")

    shell.execute("delete "..sPath)

    print("gitting")

    local response = http.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/git.lua");
    local file = fs.open(sPath, "w");
    file.write(response.readAll());
    file.close();
    response.close();
end

sPath = shell.resolve("LSON.lua")
if fs.exists(sPath) then
    print("deleting")

    shell.execute("delete "..sPath)

    print("gitting")

    local response = http.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/LSON.lua");
    local file = fs.open(sPath, "w");
    file.write(response.readAll());
    file.close();
    response.close();
end

sPath = shell.resolve("quickPull.lua")
if fs.exists(sPath) then
    print("deleting")

    shell.execute("delete "..sPath)

    print("gitting")

    local response = http.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/quickPull.lua");
    local file = fs.open(sPath, "w");
    file.write(response.readAll());
    file.close();
    response.close();
end

sPath = shell.resolve("SERIALIZER.lua")
if fs.exists(sPath) then
    print("deleting")

    shell.execute("delete "..sPath)

    print("gitting")

    local response = http.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/SERIALIZER.lua");
    local file = fs.open(sPath, "w");
    file.write(response.readAll());
    file.close();
    response.close();
end

sPath = shell.resolve("SPm.lua")
if fs.exists(sPath) then
    print("deleting")

    shell.execute("delete "..sPath)

    print("gitting")

    local response = http.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/SPm.lua");
    local file = fs.open(sPath, "w");
    file.write(response.readAll());
    file.close();
    response.close();
end

sPath = shell.resolve("test.lua")
if fs.exists(sPath) then
    print("deleting")

    shell.execute("delete "..sPath)

    print("gitting")

    local response = http.get("https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/test.lua");
    local file = fs.open(sPath, "w");
    file.write(response.readAll());
    file.close();
    response.close();
end
