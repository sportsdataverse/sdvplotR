# Preview data in every theme

Renders the same few rows through each `gt_theme_*` function in the
package and lays the results out in a grid, one panel per theme, labeled
with its name.

## Usage

``` r
gt_theme_preview(
  data,
  themes = NULL,
  n = 5,
  ncol = 3,
  density = "compact",
  file = NULL,
  ...
)
```

## Arguments

- data:

  A data frame. A `gt` table is also accepted, in which case its
  underlying data is used.

- themes:

  Character. The theme functions to show, by name. If `NULL`, every
  `gt_theme_*` in the package that needs nothing but the table is used,
  which leaves out
  [`gt_theme_source()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_source.md)
  (it needs a registry `name`) and
  [`gt_theme_sdv_team()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sdv_team.md)
  (its `league` argument has no default). Defaults to `NULL`.

- n:

  Integer. How many rows of `data` to show in each panel. Defaults to
  `5`.

- ncol:

  Integer. The number of panels across. Defaults to `3`.

- density:

  Character. A `density` passed to every theme, so the panels are
  comparable. If `NULL`, each theme uses its own default. Defaults to
  `"compact"`.

- file:

  Optional. A path to write a PNG to. If `NULL`, the grid is returned
  for the viewer. Defaults to `NULL`.

- ...:

  Further arguments passed to
  [`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md),
  such as `gap` or `bg`.

## Value

What
[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md)
returns: an
[`htmltools::browsable()`](https://rstudio.github.io/htmltools/reference/browsable.html)
tag list of the previews, which prints in the viewer; with `file`,
invisibly `file` after writing the PNG to it.

## Details

Each panel is captioned with the theme's name in a neutral style, set
outside the table. Using each theme's own heading instead would let a
wide display title stretch its panel out of shape.

Themes that take extra arguments, such as `style` on
[`gt_theme_sofa()`](https://sdvplotR.sportsdataverse.org/reference/gt_theme_sofa.md),
are shown at their defaults.

## See also

[`gt_grid()`](https://sdvplotR.sportsdataverse.org/reference/gt_grid.md),
which does the layout.

## Examples

``` r
nfl <- subset(
  sdv_example_standings, league == "nfl",
  c(team_name, wins, losses, win_pct)
)
gt_theme_preview(
  nfl,
  themes = c("gt_theme_sdv", "gt_theme_kenpom", "gt_theme_athletic")
)

  
    sdv
    
      
        @import url("https://fonts.googleapis.com/css2?family=Chivo:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Chivo:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Chivo:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
@import url("https://fonts.googleapis.com/css2?family=Lato:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap");
#tqjeqqpjwv table {
  font-family: Lato, system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#tqjeqqpjwv thead, #tqjeqqpjwv tbody, #tqjeqqpjwv tfoot, #tqjeqqpjwv tr, #tqjeqqpjwv td, #tqjeqqpjwv th {
  border-style: none;
}

#tqjeqqpjwv p {
  margin: 0;
  padding: 0;
}

#tqjeqqpjwv .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #0B1A33;
  font-size: 12.9px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
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

#tqjeqqpjwv .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#tqjeqqpjwv .gt_title {
  color: #0B1A33;
  font-size: 125%;
  font-weight: initial;
  padding-top: 2px;
  padding-bottom: 2px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#tqjeqqpjwv .gt_subtitle {
  color: #0B1A33;
  font-size: 85%;
  font-weight: initial;
  padding-top: 1px;
  padding-bottom: 3px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#tqjeqqpjwv .gt_heading {
  background-color: #FFFFFF;
  text-align: left;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#tqjeqqpjwv .gt_bottom_border {
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#tqjeqqpjwv .gt_col_headings {
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#tqjeqqpjwv .gt_col_heading {
  color: #0B1A33;
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
  padding-top: 3px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#tqjeqqpjwv .gt_column_spanner_outer {
  color: #0B1A33;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#tqjeqqpjwv .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#tqjeqqpjwv .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#tqjeqqpjwv .gt_column_spanner {
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 3px;
  padding-bottom: 3px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#tqjeqqpjwv .gt_spanner_row {
  border-bottom-style: hidden;
}

#tqjeqqpjwv .gt_group_heading {
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  color: #0B1A33;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
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

#tqjeqqpjwv .gt_empty_group_heading {
  padding: 0.5px;
  color: #0B1A33;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#tqjeqqpjwv .gt_from_md > :first-child {
  margin-top: 0;
}

#tqjeqqpjwv .gt_from_md > :last-child {
  margin-bottom: 0;
}

#tqjeqqpjwv .gt_row {
  padding-top: 3.5px;
  padding-bottom: 3.5px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #E3E8F1;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#tqjeqqpjwv .gt_stub {
  color: #0B1A33;
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

#tqjeqqpjwv .gt_stub_row_group {
  color: #0B1A33;
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

#tqjeqqpjwv .gt_row_group_first td {
  border-top-width: 2px;
}

#tqjeqqpjwv .gt_row_group_first th {
  border-top-width: 2px;
}

#tqjeqqpjwv .gt_summary_row {
  color: #0B1A33;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#tqjeqqpjwv .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#tqjeqqpjwv .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#tqjeqqpjwv .gt_last_summary_row {
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#tqjeqqpjwv .gt_grand_summary_row {
  color: #0B1A33;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#tqjeqqpjwv .gt_first_grand_summary_row {
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#tqjeqqpjwv .gt_last_grand_summary_row_top {
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#tqjeqqpjwv .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#tqjeqqpjwv .gt_table_body {
  border-top-style: none;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#tqjeqqpjwv .gt_footnotes {
  color: #0B1A33;
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

#tqjeqqpjwv .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 2px;
  padding-bottom: 2px;
  padding-left: 5px;
  padding-right: 5px;
}

#tqjeqqpjwv .gt_sourcenotes {
  color: #0B1A33;
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

#tqjeqqpjwv .gt_sourcenote {
  font-size: 90%;
  padding-top: 2px;
  padding-bottom: 2px;
  padding-left: 5px;
  padding-right: 5px;
}

#tqjeqqpjwv .gt_left {
  text-align: left;
}

#tqjeqqpjwv .gt_center {
  text-align: center;
}

#tqjeqqpjwv .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#tqjeqqpjwv .gt_font_normal {
  font-weight: normal;
}

#tqjeqqpjwv .gt_font_bold {
  font-weight: bold;
}

#tqjeqqpjwv .gt_font_italic {
  font-style: italic;
}

#tqjeqqpjwv .gt_super {
  font-size: 65%;
}

#tqjeqqpjwv .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#tqjeqqpjwv .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#tqjeqqpjwv .gt_indent_1 {
  text-indent: 5px;
}

#tqjeqqpjwv .gt_indent_2 {
  text-indent: 10px;
}

#tqjeqqpjwv .gt_indent_3 {
  text-indent: 15px;
}

#tqjeqqpjwv .gt_indent_4 {
  text-indent: 20px;
}

#tqjeqqpjwv .gt_indent_5 {
  text-indent: 25px;
}

#tqjeqqpjwv .katex-display {
  display: inline-flex !important;
  margin-bottom: 0.75em !important;
}

#tqjeqqpjwv div.Reactable > div.rt-table > div.rt-thead > div.rt-tr.rt-tr-group-header > div.rt-th-group:after {
  height: 0px !important;
}

#tqjeqqpjwv thead {
  position: relative;
}

#tqjeqqpjwv thead::after {
  content: "";
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  height: 4px;
  background: linear-gradient(90deg, #3346F0, #7FE6DC);
}

#tqjeqqpjwv .gt_col_headings th {
  padding-bottom: 10px;
}

#tqjeqqpjwv .gt_heading, #tqjeqqpjwv .gt_sourcenote, #tqjeqqpjwv .gt_footnote, #tqjeqqpjwv .gt_col_headings th:first-child, #tqjeqqpjwv tbody td:first-child {
  padding-left: 14px !important;
}

#tqjeqqpjwv .gt_heading, #tqjeqqpjwv .gt_sourcenote, #tqjeqqpjwv .gt_footnote, #tqjeqqpjwv .gt_col_headings th:last-child, #tqjeqqpjwv tbody td:last-child {
  padding-right: 14px !important;
}

#tqjeqqpjwv .gt_title {
  padding-top: 12px !important;
}

#tqjeqqpjwv .gt_subtitle {
  padding-bottom: 12px !important;
}

#tqjeqqpjwv tbody tr:last-child {
  border-bottom: 2px solid #FFFFFF;
}

#tqjeqqpjwv td {
  font-variant-numeric: tabular-nums;
}

#tqjeqqpjwv .gt_table {
  --bs-table-bg: transparent;
  --bs-table-color: currentcolor;
}



team_name
```
