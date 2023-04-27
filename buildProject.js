/**
 * For GAPLS, use it wisely.
 * It needs luamin to function but i think you can remove it without breaking too much.
 */


const luamin = require("luamin")
const fs = require("fs")

const libs = "./libraries/builds/";
const build = "build/"
const entry_req = "startup";
const extension = ".lua";
const entry = entry_req + extension;

function ReplaceRequires(text = "") {
    const requirements = []

    while (true) {
        const m = text.match(/require\(\"(.*?)\"\)/m);

        if (!m) break;

        text = text.replace(m[0], `${m[1]}()`)
        requirements.push(m[1])
    }

    return {
        text: text,
        requirements: requirements
    }
}

fs.readdirSync(libs).forEach(e => {
    try {
        const path = libs + e + "/"
        const build_dir = path + build;

        let files = [{
            req: entry_req,
            text: fs.readFileSync(path + entry, "utf-8")
        }]

        let result = "\r\nreturn startup()"

        while (files.length > 0) {
            const file = files.splice(0, 1)[0]
            let text = file.text;

            console.log(file.req)

            const repRes = ReplaceRequires(text);
            text = repRes.text;

            for (let i = 0; i < repRes.requirements.length; i++) {
                const ei = repRes.requirements[i]
                const req_path = path + ei + extension;
                if (fs.existsSync(req_path)) {
                    files.push({
                        req: ei,
                        text: fs.readFileSync(req_path, "utf-8")
                    })
                }
            }

            text = `\r\nlocal function ${file.req}()\r\n${text}\r\nend`

            result = text + result;
        }

        if (!fs.existsSync(build_dir))
            fs.mkdirSync(build_dir)

        fs.writeFileSync(build_dir + e + extension, luamin.minify(result), "utf-8");
    }
    catch (e) {
        console.log(e.message)
    }
})
