const fs = require("fs")
const path = require("path")

const actualSystemName = "system"

const blackList = [
    "system\\packages",
    "system\\commands",
    "system\\programData",
    "system\\autorum",
    "system\\fossil\\.settings",
    "system\\fossil\\.commandHistory",
]
function tree(p, prev = []) {
    var files = fs.readdirSync(p)
    files.forEach(e => {
        var fullPath = path.join(p, e)
        var stats = fs.lstatSync(fullPath)

        if (blackList.find(e => e == fullPath.replace(actualSystemName, "system"))) {
            if (stats.isDirectory()){
                prev.push({
                    a: path.join(fullPath.replace(actualSystemName, "system"), "nil")
                })
            }
            return;
        }

        if (stats.isDirectory())
            tree(fullPath, prev)
        else
            prev.push({
                a: fullPath.replace(actualSystemName, "system"),
                b: fs.readFileSync(fullPath, "utf-8")
            })
    })
    return prev;
}

var luaCode = `
--[[https://raw.github.com/StoneTrench/ComputerCraft/master/FullFossilOSInstaller.lua]]

if fs.exists("./system/fossil/bootload.lua") then
    error("System already installed!");
    return;
end;

for a, b in pairs(textutils.unserializeJSON({1})) do 
    fs.makeDir(fs.getDir(b.a));

    if b.b ~= nil then
        local c = fs.open(b.a, "w");

        c.write(b.b);
        c.close();
    end;
end;

fs.makeDir("./startup/");
local d = fs.open("./startup/startup.lua", "w");
d.write("require(\\".system.fossil.bootload\\")");
d.close();
`

fs.writeFileSync("./FullFossilOSInstaller.lua", (() => {
    return luaCode
    .replace(/(\n)/g, "")
    .split(" ").filter(e => e != "").join(" ").split("; ").join(" ")
    .replace("{1}", JSON.stringify(JSON.stringify(tree(actualSystemName))))
})(), "utf-8")