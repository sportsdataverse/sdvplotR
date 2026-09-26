# Arrange several `gt` tables in a grid

Lays a list of tables out in rows and columns as small multiples, one
table per region or per quarter.
[`gtExtras::gt_two_column_layout()`](https://jthomasmock.github.io/gtExtras/reference/gt_two_column_layout.html)
handles exactly two tables and
[`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md)
stacks any number of them vertically. This covers the rest.

## Usage

``` r
gt_grid(
  tables = NULL,
  ncol = 2,
  labels = NULL,
  label_style = list(),
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  source_note = NULL,
  caption_rule = FALSE,
  title_style = list(),
  subtitle_style = list(),
  caption_style = list(),
  source_note_style = list(),
  gap = 24,
  align = c("top", "center", "bottom"),
  file = NULL,
  bg = "white",
  whitespace = 50,
  zoom = 2
)
```

## Arguments

- tables:

  A list of `gt` table objects.

- ncol:

  Integer. The number of tables across. The number of rows follows from
  the length of `tables`. Defaults to `2`.

- labels:

  Character. An optional caption above each table, recycled against
  `tables`. Rendered in a neutral style rather than each table's own,
  and placed outside the table so a wide label does not stretch its
  panel. Defaults to `NULL`.

- label_style:

  A list of style options for the per-table captions. See `title_style`
  for the keys. Defaults to an empty list.

- title:

  Character. An optional heading above the whole grid. Set this instead
  of giving each table its own
  [`gt::tab_header()`](https://gt.rstudio.com/reference/tab_header.html).
  Defaults to `NULL`.

- subtitle:

  Character. An optional line below `title`. Defaults to `NULL`.

- caption:

  Character. An optional note below the grid. Defaults to `NULL`.

- source_note:

  Character. An optional second line below `caption`, right-aligned by
  default. Set both, with `caption_rule = TRUE`, for the split caption
  [`gt_538_caption()`](https://sdvplotR.sportsdataverse.org/reference/gt_538_caption.md)
  gives a single table. Defaults to `NULL`.

- caption_rule:

  Logical. Should a hairline rule sit between `caption` and
  `source_note`? Defaults to `FALSE`.

- title_style, subtitle_style, caption_style, source_note_style:

  Lists of style options. Recognized keys are `font` (a Google font
  name), `size`, `color`, `weight`, `italic`, `spacing` (letter
  spacing), `transform` (such as `"uppercase"`), and `align`, plus
  `line_height`, `margin_top`, `margin_bottom`, `padding_top`, and
  `padding_bottom` for nudging the blocks closer together or further
  apart. Any key you leave out keeps its default, so
  `title_style = list(size = "34px")` changes only the size. Same
  convention as
  [`gt_title_header()`](https://sdvplotR.sportsdataverse.org/reference/gt_title_header.md).
  Lengths take a number, read as pixels, or a CSS string such as
  `"2rem"`; a negative margin pulls an element up tight against the one
  above it.

- gap:

  Numeric. The space between tables in pixels. Defaults to `24`.

- align:

  Character. How tables of differing height line up within a row. Either
  `"top"`, `"center"`, or `"bottom"`. Defaults to `"top"`.

- file:

  Optional. A path to write a PNG to. If `NULL`, the grid is returned
  for the viewer instead. Defaults to `NULL`.

- bg:

  Character. The background color, used when saving. Defaults to
  `"white"`.

- whitespace:

  Numeric. Padding left around the grid when saving, in pixels. Defaults
  to `50`.

- zoom:

  Numeric. The rendering zoom factor used when saving. Defaults to `2`.

## Value

Displays the grid in the viewer, or writes it to `file`.

## Details

Unlike most of this package, this does not return a `gt` table. Separate
tables have their own columns, widths, and headers, so there is no
single table to hand back; the grid is assembled as HTML. That makes it
a last step, after each table is themed and formatted, and it is why
saving happens here through `file` rather than through
[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md).

Each table also keeps its own heading. Use `title` when the tables are
blocks of a single thing, as with a long ranking split in two, and
per-table
[`gt::tab_header()`](https://gt.rstudio.com/reference/tab_header.html)s
when they are genuinely separate exhibits.

Saving needs the `webshot2` package.

## See also

[`gt_stack_tables()`](https://sdvplotR.sportsdataverse.org/reference/gt_stack_tables.md)
for a vertical stack, and
[`gt_snake()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake.md)
for folding a single long table into blocks.

## Examples

``` r
library(gt)

by_cyl <- lapply(split(mtcars, mtcars$cyl), function(d) {
  gt(head(d[c("mpg", "hp", "wt")], 5)) %>%
    gt_theme_broadsheet() %>%
    tab_header(title = paste(d$cyl[[1]], "cylinders"))
})

gt_grid(by_cyl, ncol = 2)

  
    
      @import url("https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Newsreader:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Newsreader:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Source+Serif+4:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
#kbjkhrvvqe table {
  font-family: 'Source Serif 4', system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#kbjkhrvvqe thead, #kbjkhrvvqe tbody, #kbjkhrvvqe tfoot, #kbjkhrvvqe tr, #kbjkhrvvqe td, #kbjkhrvvqe th {
  border-style: none;
}

#kbjkhrvvqe p {
  margin: 0;
  padding: 0;
}

#kbjkhrvvqe .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 14px;
  font-weight: normal;
  font-style: normal;
  background-color: #FBFAF7;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A6081A;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#kbjkhrvvqe .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#kbjkhrvvqe .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 6px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FBFAF7;
  border-bottom-width: 0;
}

#kbjkhrvvqe .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 5px;
  padding-bottom: 7px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FBFAF7;
  border-top-width: 0;
}

#kbjkhrvvqe .gt_heading {
  background-color: #FBFAF7;
  text-align: left;
  border-bottom-color: #FBFAF7;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#kbjkhrvvqe .gt_bottom_border {
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kbjkhrvvqe .gt_col_headings {
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 1.5px;
  border-bottom-color: #16130F;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#kbjkhrvvqe .gt_col_heading {
  color: #333333;
  background-color: #FBFAF7;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 4px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#kbjkhrvvqe .gt_column_spanner_outer {
  color: #333333;
  background-color: #FBFAF7;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#kbjkhrvvqe .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#kbjkhrvvqe .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#kbjkhrvvqe .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 1.5px;
  border-bottom-color: #16130F;
  vertical-align: bottom;
  padding-top: 4px;
  padding-bottom: 4px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#kbjkhrvvqe .gt_spanner_row {
  border-bottom-style: hidden;
}

#kbjkhrvvqe .gt_group_heading {
  padding-top: 3px;
  padding-bottom: 3px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FBFAF7;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #16130F;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#kbjkhrvvqe .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FBFAF7;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #16130F;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#kbjkhrvvqe .gt_from_md > :first-child {
  margin-top: 0;
}

#kbjkhrvvqe .gt_from_md > :last-child {
  margin-bottom: 0;
}

#kbjkhrvvqe .gt_row {
  padding-top: 6px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #DEDAD2;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#kbjkhrvvqe .gt_stub {
  color: #333333;
  background-color: #FBFAF7;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#kbjkhrvvqe .gt_stub_row_group {
  color: #333333;
  background-color: #FBFAF7;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#kbjkhrvvqe .gt_row_group_first td {
  border-top-width: 1px;
}

#kbjkhrvvqe .gt_row_group_first th {
  border-top-width: 1px;
}

#kbjkhrvvqe .gt_summary_row {
  color: #333333;
  background-color: #FBFAF7;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#kbjkhrvvqe .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#kbjkhrvvqe .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#kbjkhrvvqe .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kbjkhrvvqe .gt_grand_summary_row {
  color: #333333;
  background-color: #FBFAF7;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#kbjkhrvvqe .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#kbjkhrvvqe .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#kbjkhrvvqe .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#kbjkhrvvqe .gt_table_body {
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 1px;
  border-bottom-color: #16130F;
}

#kbjkhrvvqe .gt_footnotes {
  color: #333333;
  background-color: #FBFAF7;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#kbjkhrvvqe .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#kbjkhrvvqe .gt_sourcenotes {
  color: #333333;
  background-color: #FBFAF7;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#kbjkhrvvqe .gt_sourcenote {
  font-size: 90%;
  padding-top: 6px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
}

#kbjkhrvvqe .gt_left {
  text-align: left;
}

#kbjkhrvvqe .gt_center {
  text-align: center;
}

#kbjkhrvvqe .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#kbjkhrvvqe .gt_font_normal {
  font-weight: normal;
}

#kbjkhrvvqe .gt_font_bold {
  font-weight: bold;
}

#kbjkhrvvqe .gt_font_italic {
  font-style: italic;
}

#kbjkhrvvqe .gt_super {
  font-size: 65%;
}

#kbjkhrvvqe .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#kbjkhrvvqe .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#kbjkhrvvqe .gt_indent_1 {
  text-indent: 5px;
}

#kbjkhrvvqe .gt_indent_2 {
  text-indent: 10px;
}

#kbjkhrvvqe .gt_indent_3 {
  text-indent: 15px;
}

#kbjkhrvvqe .gt_indent_4 {
  text-indent: 20px;
}

#kbjkhrvvqe .gt_indent_5 {
  text-indent: 25px;
}

#kbjkhrvvqe .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#kbjkhrvvqe div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}

#kbjkhrvvqe td {
  font-variant-numeric: tabular-nums;
}

#kbjkhrvvqe tbody tr:last-child {
  border-bottom: 2px solid #FBFAF7;
}

#kbjkhrvvqe .gt_col_heading, #kbjkhrvvqe .gt_column_spanner {
  letter-spacing: 0.09em;
}

#kbjkhrvvqe .gt_row_group_first td {
  padding-top: 4px;
}

#kbjkhrvvqe .gt_group_heading {
  letter-spacing: 0.08em;
}

#kbjkhrvvqe .gt_subtitle {
  padding-bottom: 14px !important;
}

#kbjkhrvvqe .gt_title {
  padding-bottom: 3px !important;
}

#kbjkhrvvqe .gt_sourcenote {
  padding-top: 10px;
}




4 cylinders
```
