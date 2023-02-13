local args = { ... }
console.log(util.fs.readFile(fs.combine(F.PATHS.DIR.docs, args[1])))