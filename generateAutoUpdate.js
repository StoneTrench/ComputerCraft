const fs = require("fs")

const githubRepoLink = "https://github.com/StoneTrench/ComputerCraft/blob/master/";
const autoUpdateTitle = "autoUpdate.lua"
const files = fs.readdirSync("./").filter(e => e.endsWith(".lua") && e != autoUpdateTitle);
const links = files.map(e => githubRepoLink + e)

let script = `local sPath = ""
`;

for (let l = 0; l < links.length; l++) {
    script += `
sPath = shell.resolve("${files[l]}")
if fs.exists(sPath) then
    shell.execute("delete"..sPath)
    shell.execute("./git get ${links[l]} ${files[l]}")
end
`
}

fs.writeFileSync(autoUpdateTitle, script)
