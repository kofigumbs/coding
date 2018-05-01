import 'bulma/css/bulma.css';
import './main.css';
import Elm from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const getProgress = () => {
  return JSON.parse(localStorage.getItem("user-progress") || "[]");
};

const app = Elm.Main.embed(document.getElementById('root'), {
  contentApi: "/content",
  runnerApi: "http://localhost:3001",
  user: getProgress(),
});

app.ports.outgoing.subscribe(msg => {
  switch (msg.tag) {
    case "SAVE_PROGRESS":
      const progress = getProgress();
      progress.push(msg.lesson);
      localStorage.setItem("user-progress", JSON.stringify(progress));
      app.ports.incoming.send({ tag: "NEW_USER", user: progress });
      return;
  }
});

registerServiceWorker();
