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
  highlight_color = NULL,
  row = NULL,
  filter_statement = NULL
)
```

## Arguments

- gt_object:

  A `gt` table object to modify.

- rows:

  The rows to bold. Either an expression evaluated against the table's
  data, such as `mpg > 20`, or a numeric vector of row indices. If
  `NULL`, every row is bolded. Defaults to `NULL`.

- text_color:

  Character. The text color for the bolded rows. Defaults to `"black"`.

- highlight_color:

  Character. The background fill for the bolded rows. Set to `NULL` for
  no fill. Defaults to `NULL`.

- row:

  Deprecated. Use `rows`.

- filter_statement:

  Deprecated. Use `rows`, which takes the expression directly rather
  than as a string.

## Value

Returns a modified `gt` table with the chosen rows bolded.

## Details

`rows` is evaluated against the table's underlying data, so
`rows = mpg > 20` bolds the rows where that is `TRUE`; a numeric vector
picks rows by index. The deprecated `row` is passed on to `rows`, and
the deprecated `filter_statement` string, when given, takes precedence
over `rows`. The styling is applied with a single
[`gt::tab_style()`](https://gt.rstudio.com/reference/tab_style.html)
over
[`gt::cells_body()`](https://gt.rstudio.com/reference/cells_body.html),
so it covers every column of the chosen rows.

## Examples

``` r
if (FALSE) { # \dontrun{
library(gt)

# bold every row
gt(head(mtcars)) %>% gt_bold_rows()

# bold and fill the rows above 20 mpg
gt(head(mtcars)) %>%
  gt_bold_rows(rows = mpg > 20, highlight_color = "#FFF3B0")
} # }
```
