const worker = require("./worker");
const WebSocket = require("ws");
const http = require("http");

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Credentials": false,
  "Access-Control-Max-Age": '86400',
  "Access-Control-Allow-Headers": "X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept",
};

const server = http.createServer((request, response) => {
  if (request.method === "OPTIONS") {
    response.writeHead(200, CORS_HEADERS);
    response.end();
  } else {
    var body = "";
    request.on("data", chunk => body += chunk);
    response.writeHead(200, CORS_HEADERS);
    request.on("end", () => {
      worker.handler(JSON.parse(body))
        .then(data => response.end(JSON.stringify(data)))
        .catch(e => console.log(e, response.end("500")));
    });
  }
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
