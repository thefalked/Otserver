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

function headlineBar(id) {
  var el = document.getElementById(id);
  if (!el) {
    return null;
  }
  if (el.className.indexOf("NewsHeadlineBackground") !== -1) {
    return el;
  }
  return el.querySelector(".NewsHeadlineBackground");
}

function OpenNews(id) {
  var idShort = id.concat("-ShortText");
  var idMore = id.concat("-FullText");
  var idButton = id.concat("-Button");
  document.getElementById(idShort).style.display = "none";
  document.getElementById(idMore).style.display = "block";
  document.getElementById(idButton).style.backgroundImage =
    "url('" + IMAGES + "/general/minus.gif')";
  var bar = headlineBar(id);
  if (bar && bar.className.indexOf("NewsHeadlineOpen") === -1) {
    bar.className += " NewsHeadlineOpen";
  }
}

function CloseNews(id) {
  var idShort = id.concat("-ShortText");
  var idMore = id.concat("-FullText");
  var idButton = id.concat("-Button");
  document.getElementById(idShort).style.display = "block";
  document.getElementById(idMore).style.display = "none";
  document.getElementById(idButton).style.backgroundImage =
    "url('" + IMAGES + "/general/plus.gif')";
  var bar = headlineBar(id);
  if (bar) {
    bar.className = bar.className.replace(/\s*NewsHeadlineOpen\b/g, "");
  }
}
