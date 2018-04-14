// JSON API

const app = require("express")();
var cors = require('cors')
const bodyParser = require("body-parser");

app.use(cors());
app.use(bodyParser.json());


// COMPILE

const assert = require("assert");
const fs = require("fs");
const proc = require("child_process");

const flags = { warn: true, yes: true, report: "json", output: "elm.html" };

const exec = (cmd, callback) => {
  proc.exec(cmd, (err, output) => assert(!err) || callback(output.trim()));
};

const write = (path, data, callback) => {
  fs.writeFile(path, data, err => assert(!err) || callback());
};

app.post("/compile", (request, response) => {
  exec("mktemp", input => {
    exec("mktemp", output => {
      write(input, request.body.elm, () => {
        const compile = `elm-make --yes --output=${output}.html ${input} > /dev/null`;
        const collect = `cat ${output}.html`;
        exec(`${compile} && ${collect}`, html => response.send({ output: html }));
      });
    });
  });
});


// START SERVER

const port = process.env["PORT"] || 3000;

app.listen(port, () => console.log(`Listening on port ${port}...`));
