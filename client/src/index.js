import 'bulma/css/bulma.css';
import './main.css';
import Elm from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

Elm.Main.embed(document.getElementById('root'), {
  contentApi: "/content",
  runnerApi: "http://localhost:3001",
  user: JSON.parse(localStorage.getItem("user")),
});

registerServiceWorker();
