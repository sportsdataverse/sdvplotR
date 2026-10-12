# Bold rows in a `gt` table

Bolds the body cells of chosen rows, with an option to recolor their
text and fill their background. Rows are chosen by index or by a filter
expression; with neither, every row is bolded.

## Usage

``` r
gt_bold_rows(
  gt_object,
  rows = NULL,
  text_color = "black",
  highlight_color = NULL
)
```

## Arguments

- gt_object:

  A `gt` table object to modify.

- rows:

  The rows to bold. Either an expression evaluated against the table's
  data, such as `wins > 10`, or a numeric vector of row indices. If
  `NULL`, every row is bolded. Defaults to `NULL`.

- text_color:

  Character. The text color for the bolded rows. Defaults to `"black"`.

- highlight_color:

  Character. The background fill for the bolded rows. Set to `NULL` for
  no fill. Defaults to `NULL`.

## Value

Returns a modified `gt` table with the chosen rows bolded.

## Details

`rows` is evaluated against the table's underlying data, so
`rows = wins > 10` bolds the rows where that is `TRUE`; a numeric vector
picks rows by index. The styling is applied with a single
[`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
over
[`gt::cells_body()`](https://gt.rstudio.com/reference/cells_body.html),
so it covers every column of the chosen rows.

## Examples

``` r
library(gt)

nfc_west <- subset(
  sdv_example_standings, division == "NFC West",
  c(team_name, wins:points_against)
)

# bold every row
gt(nfc_west) |> gt_bold_rows()


  

team_name
```
