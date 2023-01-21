const fs = require("fs")

const githubRepoLink = "https://github.com/StoneTrench/ComputerCraft/blob/master/";
const autoUpdateTitle = "autoUpdate.lua"
const files = fs.readdirSync("./").filter(e => e.endsWith(".lua") && e != autoUpdateTitle);
const links = files.map(e => githubRepoLink + e)

let script = "";

for (let l = 0; l < links.length; l++) {
    script += `
if fs.exists(shell.resolve("${files[l]}")) then
    shell.execute("delete ${files[l]}")
    shell.execute("git get ${links[l]} ${files[l]}")
end
`
}

fs.writeFileSync(autoUpdateTitle, script)
