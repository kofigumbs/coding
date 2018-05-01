const assert = require("assert");
const fs = require("fs");
const proc = require("child_process");
const util = require("util");

const shell = x => util.promisify(proc.exec)(x).then(y => y.stdout.trim());

exports.handler = async (body, callback) => {
  const input = await shell("mktemp");
  const output = await shell("mktemp");
  await util.promisify(fs.writeFile)(input, body.elm);
  try {
    await shell(`elm-make --yes --output=${output}.html ${input}`);
    const html = await util.promisify(fs.readFile)(`${output}.html`, "utf8");
    callback({ output: html });
  } catch(e) {
    callback({ error: e.stderr.split(input).join("") });
  }
};
