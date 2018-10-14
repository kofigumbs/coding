const fs = require("fs");
const proc = require("child_process");
const util = require("util");
const locks = require("locks");

const mutex = locks.createMutex();
const lock = x => new Promise((resolve, reject) => x.lock(() => resolve()));
const shell = x => util.promisify(proc.exec)(x).then(y => y.stdout.trim());

const toHtml = js => `
<!DOCTYPE HTML>
<html>
  <head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://raw.githubusercontent.com/jgthms/wysiwyg.css/master/wysiwyg.css">
    <script type="text/javascript">${js}</script>
  </head>
  <body class="wysiwyg"></body>
  <script type="text/javascript">Elm.Main.fullscreen();</script>
</html>
`;

exports.handler = async body => {
  const input = await shell("mktemp");
  const output = await shell("mktemp");
  await util.promisify(fs.writeFile)(input, body.elm);
  try {
    await lock(mutex);
    await shell(`elm-make --yes --output=${output}.js ${input}`);
    const js = await util.promisify(fs.readFile)(`${output}.js`, "utf8");
    return { id: body.id, output: toHtml(js) };
  } catch(e) {
    return { id: body.id, error: e.stderr.split(input).join("") };
  } finally {
    mutex.unlock();
  }
};
