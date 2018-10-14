const worker = require("./worker");
const WebSocket = require("ws");
const http = require("http");

const server = http.createServer((request, response) => {
  response.setHeader("Content-Type", "application/json");

  var body = "";
  request.on("data", chunk => body += chunk);

  request.on("end", () => {
    worker.handler(JSON.parse(body))
      .then(data => response.end(JSON.stringify(data)))
      .catch(e => console.log(e, response.end("500")));
  });
});


const wss = new WebSocket.Server({ server: server });
wss.on("connection", (socket) => {
  socket.on("message", async (message) => {
    worker.handler(JSON.parse(message))
      .then(data => socket.send(JSON.stringify(data)))
      .catch(e => console.log(e, socket.send("500")));
  });
});

server.listen(process.env["PORT"] || 3001);
