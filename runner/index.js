const app = require("express")();
const cors = require('cors')
const bodyParser = require("body-parser");
const worker = require("./worker");

app.use(cors());
app.use(bodyParser.json());
app.post("/compile", async (request, response) => {
  await worker.handler(request.body, data => response.send(data));
});

const port = process.env["PORT"] || 3001;
app.listen(port, () => console.log(`Listening on port ${port}...`));
