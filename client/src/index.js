import 'bulma/css/bulma.css';
import Elm from './Main.elm';
import netlifyIdentity from 'netlify-identity-widget';
import registerServiceWorker from './registerServiceWorker';

netlifyIdentity.init();

var app = Elm.Main.embed(document.getElementById('root'), {
  contentApi: "/content",
  runnerApi: "http://localhost:3001",
  user: netlifyIdentity.currentUser(),
});

app.ports.outgoing.subscribe(function(payload) {
  switch (payload.tag) {
    case "LOGIN":
      netlifyIdentity.open();
      return;
  }
});

registerServiceWorker();
