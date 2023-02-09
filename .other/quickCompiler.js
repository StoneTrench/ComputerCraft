const fs = require("fs")
const path = require("path")

const output = "LIBS.lua"

const files = fs.readdirSync(__dirname).filter(e => e.endsWith(".lua") && e != output);

console.log(files);

var text = "";

for (let index = 0; index < files.length; index++) {
    text += fs.readFileSync(path.join(__dirname, files[index]), "utf-8") + "\n\n\n\n"
}

fs.writeFileSync(path.join(__dirname, output), text, { encoding: 'utf8', flag: 'w' })