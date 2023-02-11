const fs = require("fs")
const path = require("path")

const blackList = [
    "system\\packages",
    "system\\fossil\\.settings",
    "system\\commands",
    "system\\fossil\\.commandHistory"
]

function tree(p, prev = []) {
    var files = fs.readdirSync(p)
    files.forEach(e => {
        var fullPath = path.join(p, e)
        var stats = fs.lstatSync(fullPath)

        if (blackList.find(e => e == fullPath.replace("_system", "system"))) {
            return;
        }

        if (stats.isDirectory())
            tree(fullPath, prev)
        else
            prev.push({
                a: fullPath.replace("_system", "system"),
                b: fs.readFileSync(fullPath, "utf-8")
            })
    })
    return prev;
}

var luaCode = `
if fs.exists("./system") then 
    error("Trying to overwrite current system!");
end

for a, b in pairs(textutils.unserializeJSON(|)) do 
    fs.makeDir(fs.getDir(b.a));

    local c = fs.open(b.a, "w");
    c.write(b.b);
    c.close();
end;

fs.makeDir("./startup/");
local d = fs.open("./startup/startup.lua", "w");
d.write("require(\\".system.fossil.bootload\\")");
d.close();
`

fs.writeFileSync("./installer.lua", (() => {
    var [codeLeft, codeRight] = luaCode.split("|")
    return codeLeft + JSON.stringify(JSON.stringify(tree("./_system"))) + codeRight;
})(), "utf-8")