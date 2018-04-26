import 'bulma/css/bulma.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

var app = Main.embed(document.getElementById('root'), {
  api: {
    content: "/content",
    runner: "http://localhost:3001",
    user: "/user",
  },
});

app.ports.outgoing.subscribe(function(msg) {
  switch(msg.tag) {
    case "SCROLL_TOP":
      document.querySelector('html').scrollTop = 0;
      return;
  }
});

registerServiceWorker();
