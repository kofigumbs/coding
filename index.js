function newEditor(app, id, value) {
  const element = document.getElementById(id);
  const editor = monaco.editor.create(element, {
    language: "elm",
    theme: "vs-dark",
    minimap: { enabled: false },
    scrollBeyondLastLine: false,
    value: value,
  });

  editor.onDidChangeModelContent(function() {
    element.dispatchEvent(new CustomEvent("editor-change", {
      detail: editor.getValue(),
    }));
  });

  element._editor = editor;
  resetEditorLayout(element);
}

function resizeEditor(id) {
  resetEditorLayout(document.getElementById(id));
}

function resetEditorLayout(element) {
  element._editor.layout({
    width: element.parentElement.offsetWidth,
    height: element.parentElement.offsetHeight,
  });
}

window.onload = function() {
  const app = Elm.Main.init();
  app.ports.toJs.subscribe(function(msg) {
    switch(msg.tag) {
      case "NEW_EDITOR":
        requestAnimationFrame(function() {
          newEditor(app, msg.id, msg.value);
        });
        break;
      case "RESIZE_EDITORS":
        resizeEditor(msg.id);
        break;
    }
  });
};
