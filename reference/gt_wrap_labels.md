# Break long column labels across lines in a `gt` table

Wraps a column label onto several short lines so a wide heading stops
forcing a narrow column wider than its data needs. "Strength of
Schedule" over a two-digit column becomes three stacked lines instead of
one long one.

## Usage

``` r
gt_wrap_labels(
  gt_object,
  columns = gt::everything(),
  width = 12,
  balance = TRUE
)
```

## Arguments

- gt_object:

  A `gt` table object to modify.

- columns:

  The columns whose labels should wrap. Defaults to
  [`gt::everything()`](https://tidyselect.r-lib.org/reference/everything.html).

- width:

  Integer. The target line length in characters. Defaults to `12`.

- balance:

  Logical. Should the lines be evened out rather than filled greedily
  left to right? Defaults to `TRUE`.

## Value

Returns a modified `gt` table with the selected labels wrapped.

## Details

The hand-rolled version is `gt::cols_label(x = gt::html("A<br>B"))`,
written out per column. This wraps at a width for you, and by default
balances the lines so they come out close to even rather than a long
first line over a short last one.

A label of one word, or one already shorter than `width`, is left alone.
The wrap is on whitespace only, so a single long word is never split.

## Examples

``` r
library(gt)

afc_east <- subset(sdv_example_standings, division == "AFC East",
  c(team_name, win_pct, conference_rank))

gt(afc_east) %>%
  cols_label(
    win_pct = "Winning Percentage",
    conference_rank = "Final Conference Rank"
  ) %>%
  gt_wrap_labels(c(win_pct, conference_rank), width = 10)


  

team_name
```
