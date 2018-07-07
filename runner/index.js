const worker = require("./worker");
const WebSocket = require("ws");
const server = new WebSocket.Server({ port: process.env["PORT"] || 3001 });

server.on("connection", (socket) => {
  socket.on("message", async (message) => {
    worker.handler(JSON.parse(message))
      .then(data => socket.send(JSON.stringify(data)))
      .catch(e => console.log(e, socket.send("500")));
  });
});
