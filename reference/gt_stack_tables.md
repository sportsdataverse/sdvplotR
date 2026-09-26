# Stack several `gt` tables vertically

Places a list of tables one above another in a single block, with an
optional shared heading and footer. Each table keeps its own columns,
widths, and header.
[`gt_snake()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake.md)
folds one table into blocks instead, and
[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
arranges tables side by side.

## Usage

``` r
gt_stack_tables(
  tables = NULL,
  gap = 16,
  align = c("center", "left", "right"),
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  source_note = NULL,
  caption_rule = FALSE,
  title_style = list(),
  subtitle_style = list(),
  caption_style = list(),
  source_note_style = list(),
  file = NULL,
  bg = "white",
  whitespace = 50,
  zoom = 2
)
```

## Arguments

- tables:

  A list of `gt` table objects to stack.

- gap:

  Numeric. The space between tables in pixels. Defaults to `16`.

- align:

  Character. How tables of differing width line up, one of `"center"`,
  `"left"`, or `"right"`. Defaults to `"center"`.

- title:

  Character. An optional heading above the stack. Defaults to `NULL`.

- subtitle:

  Character. An optional line below `title`. Defaults to `NULL`.

- caption:

  Character. An optional note below the stack. Defaults to `NULL`.

- source_note:

  Character. An optional second line below `caption`, right-aligned by
  default. Set both, with `caption_rule = TRUE`, for the split caption
  [`gt_538_caption()`](https://sdvplotR.sportsdataverse.org/reference/gt_538_caption.md)
  gives a single table. Defaults to `NULL`.

- caption_rule:

  Logical. Should a hairline sit between `caption` and `source_note`?
  Defaults to `FALSE`.

- title_style, subtitle_style, caption_style, source_note_style:

  Named lists of style options. See Styling. Each defaults to an empty
  list.

- file:

  Optional. A path to write a PNG to. If `NULL`, the stack is returned
  for the viewer instead. Defaults to `NULL`.

- bg:

  Character. The background color, used when saving. Defaults to
  `"white"`.

- whitespace:

  Numeric. Padding left around the stack when saving, in pixels.
  Defaults to `50`.

- zoom:

  Numeric. The rendering zoom factor used when saving. Defaults to `2`.

## Value

Displays the stacked tables in the viewer, or writes them to `file`.

## Details

The stack is assembled as HTML rather than a `gt` table, since each
table keeps its own columns and header. That makes it a last step, after
every table is themed and formatted, and it means the output cannot be
passed back into further `gt` calls. Saving happens here through
`webshot2` rather than through
[`gt_save_crop()`](https://sdvplotR.sportsdataverse.org/reference/gt_save_crop.md),
so a `file` write needs the `webshot2` package.

A shared heading and footer sit outside the stack in a shrink-to-fit
wrapper, so they line up with the tables rather than the page. Google
fonts named in a style list are loaded through a stylesheet link, since
the composed HTML does not run through `gt`'s own font machinery.

## Styling

`title_style`, `subtitle_style`, `caption_style`, and
`source_note_style` are named lists following the same convention as
[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
and
[`gt_title_header()`](https://sdvplotR.sportsdataverse.org/reference/gt_title_header.md).
Recognized keys are `font` (a Google font name), `size`, `color`,
`weight`, `italic`, `spacing` (letter spacing), `transform` (such as
`"uppercase"`), and `align`, plus `line_height`, `margin_top`,
`margin_bottom`, `padding_top`, and `padding_bottom`. Any length takes a
number, read as pixels, or a CSS string. Any key left out keeps its
default.

## See also

[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
for a side-by-side grid and
[`gt_snake()`](https://sdvplotR.sportsdataverse.org/reference/gt_snake.md)
for folding one long table into blocks.

## Examples

``` r
library(gt)

t1 <- gt(head(mtcars[c("mpg", "hp")]))
t2 <- gt(head(iris[c("Sepal.Length", "Species")]))

gt_stack_tables(list(t1, t2))

  
    
      #aujdxuwqoq table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#aujdxuwqoq thead, #aujdxuwqoq tbody, #aujdxuwqoq tfoot, #aujdxuwqoq tr, #aujdxuwqoq td, #aujdxuwqoq th {
  border-style: none;
}

#aujdxuwqoq p {
  margin: 0;
  padding: 0;
}

#aujdxuwqoq .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#aujdxuwqoq .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#aujdxuwqoq .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#aujdxuwqoq .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#aujdxuwqoq .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#aujdxuwqoq .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#aujdxuwqoq .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#aujdxuwqoq .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
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
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#aujdxuwqoq .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#aujdxuwqoq .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#aujdxuwqoq .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#aujdxuwqoq .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#aujdxuwqoq .gt_spanner_row {
  border-bottom-style: hidden;
}

#aujdxuwqoq .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
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

#aujdxuwqoq .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#aujdxuwqoq .gt_from_md > :first-child {
  margin-top: 0;
}

#aujdxuwqoq .gt_from_md > :last-child {
  margin-bottom: 0;
}

#aujdxuwqoq .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#aujdxuwqoq .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#aujdxuwqoq .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
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

#aujdxuwqoq .gt_row_group_first td {
  border-top-width: 2px;
}

#aujdxuwqoq .gt_row_group_first th {
  border-top-width: 2px;
}

#aujdxuwqoq .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#aujdxuwqoq .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#aujdxuwqoq .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#aujdxuwqoq .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#aujdxuwqoq .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#aujdxuwqoq .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#aujdxuwqoq .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#aujdxuwqoq .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#aujdxuwqoq .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#aujdxuwqoq .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
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

#aujdxuwqoq .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#aujdxuwqoq .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
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

#aujdxuwqoq .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#aujdxuwqoq .gt_left {
  text-align: left;
}

#aujdxuwqoq .gt_center {
  text-align: center;
}

#aujdxuwqoq .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#aujdxuwqoq .gt_font_normal {
  font-weight: normal;
}

#aujdxuwqoq .gt_font_bold {
  font-weight: bold;
}

#aujdxuwqoq .gt_font_italic {
  font-style: italic;
}

#aujdxuwqoq .gt_super {
  font-size: 65%;
}

#aujdxuwqoq .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#aujdxuwqoq .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#aujdxuwqoq .gt_indent_1 {
  text-indent: 5px;
}

#aujdxuwqoq .gt_indent_2 {
  text-indent: 10px;
}

#aujdxuwqoq .gt_indent_3 {
  text-indent: 15px;
}

#aujdxuwqoq .gt_indent_4 {
  text-indent: 20px;
}

#aujdxuwqoq .gt_indent_5 {
  text-indent: 25px;
}

#aujdxuwqoq .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#aujdxuwqoq div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}



mpg
```
