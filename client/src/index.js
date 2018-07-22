import 'bulma/css/bulma.css';
import './main.css';
import Elm from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const getLocals = () => {
  return JSON.parse(localStorage.getItem("locals") || "{}");
};

const runnerApi =
  process.env.NODE_ENV === "production"
    ? "wss://excel-to-code--runner.herokuapp.com"
    : "ws://localhost:3001";

const app = Elm.Main.embed(document.getElementById('root'), {
  runnerApi: runnerApi,
  localStorage: getLocals(),
});

app.ports.outgoing.subscribe(msg => {
  switch (msg.tag) {
    case "SAVE_LOCAL":
      var locals = getLocals();
      locals[msg.key] = msg.value;
      localStorage.setItem("locals", JSON.stringify(locals));
      return;
  }
});

registerServiceWorker();
