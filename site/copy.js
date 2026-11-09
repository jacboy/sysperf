// Copy buttons and the curl/wget tabs. Kept in a separate file so the
// Content-Security-Policy can forbid inline scripts.
(function () {
  "use strict";

  function visibleCommand(group) {
    var nodes = group.querySelectorAll("[data-copy-text]");
    for (var i = 0; i < nodes.length; i++) {
      var code = nodes[i].closest("code");
      if (!code || !code.hidden) return nodes[i].textContent;
    }
    return "";
  }

  function fallbackCopy(text) {
    var area = document.createElement("textarea");
    area.value = text;
    area.setAttribute("readonly", "");
    area.style.position = "fixed";
    area.style.opacity = "0";
    document.body.appendChild(area);
    area.select();
    var ok = false;
    try { ok = document.execCommand("copy"); } catch (e) { ok = false; }
    document.body.removeChild(area);
    return ok;
  }

  function flash(button, label) {
    button.textContent = label;
    clearTimeout(button._resetTimer);
    button._resetTimer = setTimeout(function () { button.textContent = "Copy"; }, 1600);
  }

  document.querySelectorAll("[data-copy]").forEach(function (button) {
    button.addEventListener("click", function () {
      var text = visibleCommand(button.closest("[data-copy-group]"));
      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(
          function () { flash(button, "Copied"); },
          function () { flash(button, fallbackCopy(text) ? "Copied" : "Select it"); }
        );
      } else {
        flash(button, fallbackCopy(text) ? "Copied" : "Select it");
      }
    });
  });

  document.querySelectorAll(".cmd-tabs [data-tab]").forEach(function (tab) {
    tab.addEventListener("click", function () {
      var group = tab.closest("[data-copy-group]");
      group.querySelectorAll("[data-tab]").forEach(function (t) {
        t.setAttribute("aria-selected", t === tab ? "true" : "false");
      });
      group.querySelectorAll("[data-panel]").forEach(function (panel) {
        panel.hidden = panel.getAttribute("data-panel") !== tab.getAttribute("data-tab");
      });
    });
  });
})();
