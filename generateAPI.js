return

const fs = require("fs")
const { join } = require("path")

const paths = [
    "system/fossil/global",
    "system/fossil/programs"
]

paths.forEach(path => {
    const files = fs.readdirSync(path).filter(e => e.endsWith(".lua"))
    files.push("../F.lua")

    files.forEach(e => {
        const file = fs.readFileSync(join(path, e), "utf-8")
            .split(" ").filter(e => e != "")
            .map((e, i, a) => {
                if (a[i + 1] == "=" && a[i + 2].startsWith("function")) {
                    return e + `${a.slice(i + 2, i + a.slice(i).findIndex(e => e.includes(")")) + 1).join(" ").replace("function", "")}`
                }
                return e
            })
            .filter((e, i, a) => a[i + 1] == "=" && (a[i + 2].startsWith("function") || a[i + 2].startsWith("{")) && a[i - 1] != "local")

        if (e.includes("/"))
            e = e.slice(e.lastIndexOf("/"))

        fs.writeFileSync(join("system/fossil/api/", e.replace(".lua", ".txt")),
            file.join("\n\n"), "utf-8"
        )
    })
})