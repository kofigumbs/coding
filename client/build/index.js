function newEditor(id, value) {
  const element = document.getElementById(id);

  if (!element) return;
  if (!!element.editor) return setValue(element.editor, value);

  element.editor = monaco.editor.create(element, {
    language: "elm",
    theme: "vs-dark",
    minimap: { enabled: false },
    scrollBeyondLastLine: false,
    value: value,
  });

  element.editor.onDidChangeModelContent(function() {
    element.dispatchEvent(new CustomEvent("editor-change", {
      detail: element.editor.getValue(),
    }));
  });

  resetEditorLayout(element);
}

function setValue(editor, value) {
  if (editor.getValue() !== value) editor.setValue(value);
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
          newEditor(msg.id, msg.value);
        });
        break;
      case "RESIZE_EDITOR":
        resizeEditor(msg.id);
        break;
    }
  });
};
