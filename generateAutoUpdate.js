const fs = require("fs")

const githubRepoLink = "https://raw.githubusercontent.com/StoneTrench/ComputerCraft/master/";
const autoUpdateTitle = "autoUpdate.lua"
const files = fs.readdirSync("./").filter(e => e.endsWith(".lua") && e != autoUpdateTitle);
const links = files.map(e => githubRepoLink + e)

let script = `local sPath = ""
`;

for (let l = 0; l < links.length; l++) {
    script += `
sPath = shell.resolve("${files[l]}")
if fs.exists(sPath) then
    print("deleting")

    shell.execute("delete "..sPath)

    print("gitting")

    local response = http.get("${links[l]}");
    local file = fs.open(sPath, "w");
    file.write(response.readAll());
    file.close();
    response.close();
end
`
}

fs.writeFileSync(autoUpdateTitle, script)
