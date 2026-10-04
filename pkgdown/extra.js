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
  // scroller while it has more content to its right; extra.css fades its right edge.
  var scrollers = document.querySelectorAll(
    "main pre, main div:has(> table.gt_table), main table.table:not(.gt_table)"
  );
  function mark(el) {
    el.classList.toggle("is-clipped", el.scrollLeft + el.clientWidth < el.scrollWidth - 1);
  }
  function markAll() { scrollers.forEach(mark); }
  scrollers.forEach(function (el) {
    el.addEventListener("scroll", function () { mark(el); }, { passive: true });
  });
  markAll();
  // logos and fonts load after this runs and change the widths
  window.addEventListener("load", markAll);
  window.addEventListener("resize", markAll);
});
