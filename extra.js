// sdvplotR site behaviour that pkgdown's own scripts do not cover. pkgdown.js loads first and
// registers its jQuery ready handler first, so #toc is filled by the time this one runs.
$(function () {
  // Phones: pkgdown's "On this page" sits in an aside after the article. Copy its list into the
  // collapsed disclosure that pkgdown/templates/content-article.html puts under the title.
  var box = document.querySelector("details.toc-mobile");
  var list = document.querySelector("#toc > ul");
  if (box && list) {
    var copy = list.cloneNode(true);
    copy.querySelectorAll(".active").forEach(function (a) { a.classList.remove("active"); });
    box.querySelector("nav").appendChild(copy);
    // a tap on a heading link closes the disclosure, so the heading is not pushed down by it
    copy.addEventListener("click", function (e) {
      if (e.target.closest("a")) box.open = false;
    });
  } else if (box) {
    box.remove(); // an article without headings has nothing to list
  }

  // Code blocks and wide tables scroll sideways with no visible scrollbar on phones. Mark a
  // scroller while it has more content to its right; extra.css fades its right edge. The
  // scrollers are gt tables, gt_grid()'s outer div and reactable's .rt-table; htmlwidgets draw
  // after this handler runs, so they are collected again on load.
  var SCROLLERS =
    "main pre, main div:has(> table.gt_table), main table.table:not(.gt_table), " +
    'main div[style*="overflow-x: auto"], main .ReactTable .rt-table';
  function mark(el) {
    el.classList.toggle("is-clipped", el.scrollLeft + el.clientWidth < el.scrollWidth - 1);
  }
  function markAll() {
    document.querySelectorAll(SCROLLERS).forEach(function (el) {
      if (!el._sdvScroll) {
        el._sdvScroll = true;
        el.addEventListener("scroll", function () { mark(el); }, { passive: true });
      }
      mark(el);
    });
  }
  markAll();
  // logos and fonts load after this runs and change the widths
  window.addEventListener("load", markAll);
  window.addEventListener("resize", markAll);

  // Dark mode puts light gt tables on a light card (extra.css, .sdv-card). A table's theme sets
  // its background, so read it: an opaque, light background gets the card; a dark one does not.
  document.querySelectorAll("main table.gt_table").forEach(function (t) {
    var c = getComputedStyle(t).backgroundColor.match(/[\d.]+/g);
    if (!c || (c.length > 3 && Number(c[3]) === 0)) return;
    if (0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2] <= 160) return;
    // gt_grid() draws its title and caption outside the tables, in dark text with no
    // background of its own: put the whole grid on the card
    var grid = t.closest('div[style*="inline-block"]');
    var outer = grid && grid.parentElement;
    (outer && outer.matches('div[style*="display: flex"]') ? outer : t.parentElement).classList.add("sdv-card");
  });

  // Dark mode also puts light figures and widgets on a light card (extra.css, .sdv-card); a dark
  // one (the tier plots, a dark reactable theme) is drawn as it is. A picture is light when its
  // pixels average light (transparent counts as light); a widget when its first opaque
  // background is. If the pixels cannot be read, the picture gets the card.
  function isLight(c) { return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2] > 160; }
  function cardImg(img) {
    try {
      var cv = document.createElement("canvas");
      cv.width = cv.height = 16;
      var cx = cv.getContext("2d");
      cx.fillStyle = "#fff";
      cx.fillRect(0, 0, 16, 16);
      cx.drawImage(img, 0, 0, 16, 16);
      var d = cx.getImageData(0, 0, 16, 16).data, s = [0, 0, 0];
      for (var i = 0; i < d.length; i += 4) { s[0] += d[i]; s[1] += d[i + 1]; s[2] += d[i + 2]; }
      return isLight(s.map(function (v) { return v / 256; }));
    } catch (e) {
      return true;
    }
  }
  function cardWidget(w) {
    for (var el = w.querySelector(".ReactTable") || w; el && el !== document.body; el = el.parentElement) {
      var c = getComputedStyle(el).backgroundColor.match(/[\d.]+/g);
      if (c && !(c.length > 3 && Number(c[3]) === 0)) return isLight(c);
    }
    return true;
  }
  function markCards() {
    document.querySelectorAll(
      'main img.r-plt, main pre .r-plt.img img, main img[src*="figures/"], main img[src*="README-home"]'
    ).forEach(function (img) {
      if (img.closest(".sdv-gallery")) return;
      var go = function () { if (cardImg(img)) img.classList.add("sdv-card"); };
      if (img.complete && img.naturalWidth) go(); else img.addEventListener("load", go, { once: true });
    });
    // a widget draws after this handler runs: decide once its table exists (load runs this again)
    document.querySelectorAll("main .html-widget").forEach(function (w) {
      if (w.firstElementChild) w.classList.toggle("sdv-card", cardWidget(w));
    });
  }
  markCards();
  window.addEventListener("load", markCards);
  // htmlwidgets (reactable) draw after load: look again as they appear, for the first seconds
  var timer;
  var seen = new MutationObserver(function () { clearTimeout(timer); timer = setTimeout(function () { markCards(); markAll(); }, 100); });
  seen.observe(document.querySelector("main"), { childList: true, subtree: true });
  setTimeout(function () { seen.disconnect(); }, 5000);
});
