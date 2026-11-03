// Parity oracle for sdv_bins() / sdv_bin_ids(): sdvplot-js's own binner() run in node on 2000 real shots.
// Writes tests/testthat/fixtures/bins_bkn_2000.csv(.gz): each shot's x_legacy, y_legacy, made, and its cell id
// ("x,y", the centre as JavaScript writes it) under six lattices. Last run on sdvplot-js main @ fffc941, Node 24.15.0.
//
// From the package root, with a sibling sdvplot-js checkout:
//   J=../sdvplot-js; O=$(mktemp -d)
//   git -C $J show origin/main:packages/sdvplot/src/bins/hexbin.ts | sed 's#"../errors.js"#"./errors.ts"#' > $O/hexbin.ts
//   git -C $J show origin/main:packages/sdvplot/src/bins/squarebin.ts \
//     | sed -e 's#"../errors.js"#"./errors.ts"#' -e 's#"./hexbin.js"#"./hexbin.ts"#' > $O/squarebin.ts
//   echo 'export class InputError extends Error {}' > $O/errors.ts
//   git -C $J show origin/main:fixtures/shots/nba-2026-bkn-2000-columns.json > $O/columns.json
//   cp data-raw/sdvplot_bins_oracle.mts $O/ && (cd $O && node sdvplot_bins_oracle.mts)
//   gzip -9 -n -c $O/bkn_2000_bins.csv > tests/testthat/fixtures/bins_bkn_2000.csv.gz
import { readFileSync, writeFileSync } from "node:fs";
import { binner } from "./squarebin.ts";
const c = JSON.parse(readFileSync("columns.json", "utf8"));
const pts = c.x_legacy.map((x: number, i: number) => ({ i, x, y: c.y_legacy[i] }));
const lattices: Record<string, any> = {
  hex10: { radius: 10 }, hex15: { radius: 15 },
  sq10: { shape: "square", side: 10 }, sq15: { shape: "square", side: 15 },
  eq10: { shape: "square", radius: 10, equalArea: true }, eq15: { shape: "square", radius: 15, equalArea: true },
};
const cols: Record<string, string[]> = {};
for (const [k, o] of Object.entries(lattices)) {
  const id = new Array(pts.length).fill("");
  const bins = binner(o).bins(pts, { x: (p: any) => p.x, y: (p: any) => p.y });
  for (const b of bins) for (const p of b) id[p.i] = `${b.x},${b.y}`;
  cols[k] = id;
}
const keys = Object.keys(lattices);
const lines = ["x_legacy,y_legacy,made," + keys.join(",")];
for (let i = 0; i < pts.length; i++) lines.push([c.x_legacy[i], c.y_legacy[i], c.made[i], ...keys.map((k) => `"${cols[k][i]}"`)].join(","));
writeFileSync("bkn_2000_bins.csv", lines.join("\n") + "\n");
console.log(keys.map((k) => `${k}:${new Set(cols[k]).size}`).join(" "));
