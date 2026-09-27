/** ------------------------
 * News Ticker functionality
 * -------------------------
 */

// status of ticker / headline entries (0 = closed / 1 = open), keyed by element id
state = {};

function TickerAction(id) {
  if (state[id] != "1") {
    state[id] = "1";
    OpenNews(id);
  } else {
    state[id] = "0";
    CloseNews(id);
  }
}

function OpenNews(id) {
  var idShort = id.concat("-ShortText");
  var idMore = id.concat("-FullText");
  var idButton = id.concat("-Button");
  document.getElementById(idShort).style.display = "none";
  document.getElementById(idMore).style.display = "block";
  document.getElementById(idButton).style.backgroundImage =
    "url('" + IMAGES + "/general/minus.gif')";
}

function CloseNews(id) {
  var idShort = id.concat("-ShortText");
  var idMore = id.concat("-FullText");
  var idButton = id.concat("-Button");
  document.getElementById(idShort).style.display = "block";
  document.getElementById(idMore).style.display = "none";
  document.getElementById(idButton).style.backgroundImage =
    "url('" + IMAGES + "/general/plus.gif')";
}

/** News headline: grow the green bar; title stays inside it. */
function HeadlineAction(id) {
  var el = document.getElementById(id);
  var idButton = id.concat("-Button");
  var btn = document.getElementById(idButton);
  if (!el) {
    return;
  }
  if (state[id] != "1") {
    state[id] = "1";
    el.className += " NewsHeadlineOpen";
    if (btn) {
      btn.style.backgroundImage = "url('" + IMAGES + "/general/minus.gif')";
    }
  } else {
    state[id] = "0";
    el.className = el.className.replace(/\s*NewsHeadlineOpen\b/g, "");
    if (btn) {
      btn.style.backgroundImage = "url('" + IMAGES + "/general/plus.gif')";
    }
  }
}
