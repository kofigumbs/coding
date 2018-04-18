// JSON API

const app = require("express")();
const cors = require('cors')
const bodyParser = require("body-parser");

app.use(cors());
app.use(bodyParser.json());


// COMPILE

const assert = require("assert");
const fs = require("fs");
const proc = require("child_process");
const util = require("util");

const shell = x => util.promisify(proc.exec)(x).then(y => y.stdout.trim());

app.post("/compile", async (request, response) => {
  try {
    const input = await shell("mktemp");
    const output = await shell("mktemp");
    await util.promisify(fs.writeFile)(input, request.body.elm);
    await shell(`elm-make --yes --output=${output}.html ${input}`);
    const html = await util.promisify(fs.readFile)(`${output}.html`, "utf8");
    response.send({ output: html });
  } catch(e) {
    response.send({ error: e.stderr });
  }
});


// START SERVER

const port = process.env["PORT"] || 3001;

app.listen(port, () => console.log(`Listening on port ${port}...`));
