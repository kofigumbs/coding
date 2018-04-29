import 'bulma/css/bulma.css';
import './main.css';
import Elm from './Main.elm';
// import netlifyIdentity from 'netlify-identity-widget';
import registerServiceWorker from './registerServiceWorker';

// netlifyIdentity.init();

var app = Elm.Main.embed(document.getElementById('root'), {
  contentApi: "/content",
  runnerApi: "http://localhost:3001",
  user: window.netlifyIdentity.currentUser(),
});

app.ports.outgoing.subscribe(function(payload) {
  switch (payload.tag) {
    case "LOGIN":
      window.netlifyIdentity.open();
      return;
  }
});

registerServiceWorker();
