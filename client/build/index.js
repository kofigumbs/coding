function newEditor(app, id) {
  const element = document.getElementById(id);
  element.editor = monaco.editor.create(element, {
    language: "elm",
    theme: "vs-dark",
    minimap: { enabled: false },
    scrollBeyondLastLine: false,
    value: element.dataset.value,
  });

  element.editor.onDidChangeModelContent(function() {
    element.dispatchEvent(new CustomEvent("editor-change", {
      detail: element.editor.getValue(),
    }));
  });

  resetEditorLayout(element);
}

function resizeEditor(id) {
  resetEditorLayout(document.getElementById(id));
}

function resetEditorLayout(element) {
  element.editor.layout({
    width: element.parentElement.offsetWidth,
    height: element.parentElement.offsetHeight,
  });
}

window.onload = function() {
  const flags = location.hostname === "localhost"
    ? { runner : "http://localhost:3001" }
    : { runner : "https://excel-to-code--runner.herokuapp.com" };
  const app = Elm.Main.init({ flags: flags });
  app.ports.toJs.subscribe(function(msg) {
    switch(msg.tag) {
      case "NEW_EDITOR":
        requestAnimationFrame(function() {
          newEditor(app, msg.id);
        });
        break;
      case "RESIZE_EDITORS":
        resizeEditor(msg.id);
        break;
    }
  });
};
