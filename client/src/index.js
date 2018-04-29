import 'bulma/css/bulma.css';
import './main.css';
import Elm from './Main.elm';
import GoTrue from 'gotrue-js';
import registerServiceWorker from './registerServiceWorker';

var auth = new GoTrue();

var app = Elm.Main.embed(document.getElementById('root'), {
  contentApi: "/content",
  runnerApi: "http://localhost:3001",
  user: auth.currentUser(),
});

app.ports.outgoing.subscribe(function(payload) {
  switch (payload.tag) {
    case "LOGIN":
      auth.login("h.kofigumbs+test@gmail.com", "weFyEwPXuAdh3egaCzzREuTB", true);
      return;
  }
});

registerServiceWorker();
