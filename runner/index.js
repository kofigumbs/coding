// https://stackoverflow.com/questions/19336435/restart-node-js-application-when-uncaught-exception-occurs

const cluster = require("cluster");

if (cluster.isMaster) {
  cluster.fork();
  cluster.on("exit", function(worker, code, signal) {
    console.log(`Worker ${worker.id} died.\nRestarting...`)
    cluster.fork();
  });
}


// RUN SERVER WORKER

cluster.isWorker && require("./worker");
