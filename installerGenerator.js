const fs = require("fs")
const path = require("path")

function tree(p, prev) {
    var files = fs.readdirSync(p)

    files.forEach(e => {
        var fullPath = path.join(p, e)
        var stats = fs.lstatSync(fullPath)

        if (stats.isDirectory())
            tree(fullPath, prev[e])
        else
            prev[e] = stats.size;
    })
}

console.log(tree("./system", {}));