const assert = require("assert");
const fs = require("fs");
const proc = require("child_process");
const util = require("util");

const shell = x => util.promisify(proc.exec)(x).then(y => y.stdout.trim());

const toHtml = js => `
<!DOCTYPE HTML>
<html>
  <head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.7.1/css/bulma.min.css">
    <script type="text/javascript">${js}</script>
  </head>
  <body></body>
  <script type="text/javascript">Elm.Main.fullscreen();</script>
</html>
`;

exports.handler = async body => {
  const input = await shell("mktemp");
  const output = await shell("mktemp");
  await util.promisify(fs.writeFile)(input, body.elm);
  try {
    await shell(`elm-make --yes --debug --output=${output}.js ${input}`);
    const js = await util.promisify(fs.readFile)(`${output}.js`, "utf8");
    return { output: toHtml(js) };
  } catch(e) {
    return { error: e.stderr.split(input).join("") };
  }
};
