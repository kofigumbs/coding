// JSON API

const app = require("express")();
var cors = require('cors')
const bodyParser = require("body-parser");

app.use(cors());
app.use(bodyParser.json());


// COMPILE

const assert = require("assert");
const fs = require("fs");
const temp = require("temp");
const elm = require("node-elm-compiler");

const flags = { warn: true, yes: true, report: "json", output: "elm.html" };

app.post("/compile", (request, response) => {
  temp.open({ suffix: 'elm' }, (tempError, { fd, path }) => {
    assert(!tempError);
    fs.write(fd, request.body.elm, fsError => {
      assert(!fsError);
      elm.compileToString(path, flags).then(
        output => response.send({ output }),
        error => response.send({ error })
      );
    });
  });
});


// START SERVER

const port = process.env["PORT"] || 3000;

app.listen(port, () => console.log(`Listening on port ${port}...`));
