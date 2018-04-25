import 'bulma/css/bulma.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

Main.embed(document.getElementById('root'), {
  api: {
    content: "/content",
    runner: "http://localhost:3001",
    user: "/user",
  },
});

registerServiceWorker();
