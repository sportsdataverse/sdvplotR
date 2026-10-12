"""sdvplot's team index in the CDN's format, plus sdvplotR's test fixtures and the resolve() golden file.

Run from the sdvplotR root:  uv run --project ../sdvplot --frozen python data-raw/export_index.py
Writes data-raw/index/ (the full index, read by build_index_snapshot.R; also what sdv-assets stage 25 publishes),
tests/testthat/fixtures/index/ + fixtures/marks.csv (a two-league subset), data-raw/index/fold.txt, and
tests/testthat/fixtures/resolve_golden.csv (Python's answers, which test-resolve.R holds R to).
"""

import csv
import gzip
import random
import sys
import unicodedata
import urllib.request
import warnings
from pathlib import Path

import polars as pl
import sdvplot
from sdvplot import _index, _resolve

MANIFEST = (
    "https://sdv.nyc3.cdn.digitaloceanspaces.com/assets/public/manifest/marks.csv"
)
FIXTURE_LEAGUES = ("nfl", "nhl")


def write_index(
    teams: pl.DataFrame, aliases: pl.DataFrame, out: Path, ver: str
) -> None:
    d = out / ver
    d.mkdir(parents=True, exist_ok=True)
    for name, df in (("teams", teams), ("aliases", aliases)):
        with gzip.GzipFile(
            d / f"{name}.csv.gz", "wb", mtime=0
        ) as f:  # mtime=0: byte-identical reruns
            df.write_csv(f, null_value="")
    (out / "latest.txt").write_text(ver + "\n", encoding="utf-8")


def fold_table() -> tuple[str, str]:
    """Latin letters whose NFKD form minus combining marks is one ASCII character (what sdvplot's norm_value does)."""
    src, dst = [], []
    for cp in [*range(0xC0, 0x250), *range(0x1E00, 0x1F00)]:
        c = chr(cp)
        d = "".join(
            x for x in unicodedata.normalize("NFKD", c) if not unicodedata.combining(x)
        )
        if d != c and len(d) == 1 and d.isascii() and d.isalpha():
            src.append(c)
            dst.append(d)
    return "".join(src), "".join(dst)


def golden(aliases: pl.DataFrame, ver: str) -> list[dict]:
    rng = random.Random(20261011)
    a = aliases.filter(pl.col("id_system") != "mark")
    rows: list[dict] = []

    def case(league, value, season, id_system, value_type="character"):
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            try:
                v = int(value) if value_type == "integer" else value
                got = sdvplot.resolve(v, league, season=season, id_system=id_system)
            except (
                ValueError
            ):  # a season outside the league's bounds: not a resolve() answer
                return
        # Python's own classification, called the way _resolve._resolve() does: ok, none (the value normalizes
        # to nothing, so it is neither resolved nor reported), else the unresolved reason's prefix
        ids, unresolved = _resolve._resolve_ids(
            [v], league, _resolve._seasons(season, 1, league), id_system
        )
        if ids[0] is not None:
            reason = "ok"
        elif not unresolved:
            reason = "none"
        else:
            reason = next(iter(unresolved.values())).split(":")[0]
        rows.append(
            dict(
                kind="resolve",
                league=league,
                value=str(value),
                value_type=value_type,
                season="" if season is None else season,
                id_system=id_system,
                expected=got or "",
                reason=reason,
                index_version=ver,
            )
        )

    for (system,), g in sorted(a.group_by("id_system"), key=lambda t: t[0]):
        picks = g.sample(n=min(10, g.height), seed=rng.randrange(10**6))
        for r in picks.iter_rows(named=True):
            explicit = system if (system == "nhl_id" or rng.random() < 0.33) else "auto"
            case(r["league"], r["value"], None, explicit)
    dated = a.filter(
        pl.col("valid_from").is_not_null() | pl.col("valid_to").is_not_null()
    )
    for r in dated.sample(n=40, seed=7).iter_rows(named=True):
        case(
            r["league"],
            r["value"],
            r["valid_from"] if r["valid_from"] is not None else r["valid_to"],
            "auto",
        )
    amb = (
        # maintain_order: group_by's row order is otherwise arbitrary, so sample(seed=) picked different rows per run
        a.group_by("league", "id_system", "value", maintain_order=True)
        .agg(pl.col("team_id").n_unique().alias("n"))
        .filter(pl.col("n") > 1)
    )
    for r in amb.sample(n=min(15, amb.height), seed=11).iter_rows(named=True):
        case(r["league"], r["value"], None, "auto")
    for r in (
        a.filter(pl.col("id_system") == "team_id")
        .sample(n=10, seed=13)
        .iter_rows(named=True)
    ):
        case(
            r["league"], r["value"], None, "auto", value_type="integer"
        )  # an id passed as a number
    for league, value in (
        ("nfl", "zzz not a team"),
        ("cfb", ""),
        ("soccer", "Atlético Madrid"),
        ("mlb", "Montréal Expos"),
    ):
        case(league, value, None, "auto")
    names = (
        sdvplot.teams().filter(pl.col("name").str.len_chars() > 8).sample(n=15, seed=17)
    )
    for r in names.iter_rows(named=True):
        typo = r["name"][:4] + r["name"][5:]  # drop one character
        top = sdvplot.suggest(typo, r["league"], n=1)
        rows.append(
            dict(
                kind="suggest",
                league=r["league"],
                value=typo,
                value_type="character",
                season="",
                id_system="",
                expected=top[0][0] if top else "",
                reason="",
                index_version=ver,
            )
        )
    return rows


def main() -> None:
    root = Path.cwd()
    if not (root / "DESCRIPTION").exists():
        sys.exit("run from the sdvplotR root")
    ver = _index.index_version()
    teams = pl.read_parquet(_index.data_dir() / "teams.parquet")
    aliases = _index.alias_table()
    write_index(teams, aliases, root / "data-raw" / "index", ver)
    src, dst = fold_table()
    (root / "data-raw" / "index" / "fold.txt").write_text(
        src + "\n" + dst + "\n", encoding="utf-8"
    )

    fx = root / "tests" / "testthat" / "fixtures"
    keep = pl.col("league").is_in(FIXTURE_LEAGUES)
    write_index(teams.filter(keep), aliases.filter(keep), fx / "index", ver)
    with urllib.request.urlopen(MANIFEST) as r:  # noqa: S310 (a fixed https URL)
        marks = pl.read_csv(r.read(), infer_schema=False)
    marks.write_csv(root / "data-raw" / "index" / "marks.csv")
    marks.filter(
        pl.col("league").is_in(FIXTURE_LEAGUES) & (pl.col("level") == "team")
    ).write_csv(fx / "marks.csv")

    rows = golden(aliases, ver)
    with open(fx / "resolve_golden.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print(
        f"index {ver}: {teams.height} teams, {aliases.height} aliases, {marks.height} marks, {len(rows)} golden rows"
    )


if __name__ == "__main__":
    main()
