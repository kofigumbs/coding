// SETUP MONACO EDITOR

var EDITOR_NODE = "code-editor";
var Editor = Object.create(HTMLElement.prototype);

Editor.createdCallback = function() {
  var element = this;
  element.__editor = monaco.editor.create(element, {
    language: "elm",
    minimap: { enabled: false },
    scrollBeyondLastLine: false,
  });

  // Set editor size to that of container
  requestAnimationFrame(function() {
    element.setAttribute("style", "flex-grow: 1");
    element.__editor.layout({
      width: element.offsetWidth,
      height: element.offsetHeight,
    });
    element.setAttribute("style", "max-height: 0");
  });

  // Listen for typing
  element.__editor.onDidChangeModelContent(function(x) {
    element.dispatchEvent(
      new CustomEvent("editor-change", { detail: element.__editor.getValue() })
    );
  });
};

Editor.attributeChangedCallback = function(name, oldValue, newValue) {
  switch (name) {
    case 'data-value':
      if (newValue !== this.__editor.getValue()) {
        this.__editor.setValue(newValue);
      }
      break;
  }
}

document.registerElement(EDITOR_NODE, { prototype: Editor });


// SETUP ELM APP

window.onload = function() {
  window.app = Elm.Main.init({
    flags: { editorNode: EDITOR_NODE },
  });
};
