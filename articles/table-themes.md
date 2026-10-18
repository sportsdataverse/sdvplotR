# Table theme registry

On this page

sdvplotR ships one table theme for each of 122 surveyed sources, named
after the source: `datagolf`, `basketball-reference`, `wikipedia`,
`nejm`. The same registry is read by sdvplot (Python) and sdvtables
(JavaScript), so a name means the same table in every language. The list
below is built from
[`sdv_table_themes()`](https://sdvplotR.sportsdataverse.org/reference/sdv_table_themes.md)
when this article is knit, so it cannot drift from the package.

The full gallery, with filters, is at
<https://plot.sportsdataverse.org/guides/table-theme-registry>.

``` r

gt_object |> gt_theme_source("datagolf")             # a gt table
gt_object |> gt_theme_source("datagolf", mode = "dark")
reactable::reactable(df, theme = reactable_sdv_theme("datagolf"))
```

Both functions read the registry only. The 27 reactablefmtr names (such
as `espn`) raise an error pointing at the `reactablefmtr::` function;
the registry’s `espn-site` is the site’s own look. `mode = "dark"` works
for themes whose dark policy is `native` (measured) or `derived` (from
the light palette); on a `none` theme it raises, naming three
dark-capable themes in the same category.

## finance (13)

### `annual-report`

Annual-report financial statement, dark: none

![Annual-report financial statement table theme,
light](https://plot.sportsdataverse.org/img/table-themes/annual-report-light.webp)

`gt_theme_source(gt, "annual-report")` ·
`reactable_sdv_theme("annual-report")`

### `barrons-markets`

Barron’s markets data, dark: derived

![Barron's markets data table theme,
light](https://plot.sportsdataverse.org/img/table-themes/barrons-markets-light.webp)![Barron's
markets data table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/barrons-markets-dark.webp)

`gt_theme_source(gt, "barrons-markets")` ·
`reactable_sdv_theme("barrons-markets")`

### `bloomberg-markets`

Bloomberg.com Markets, dark: native

![Bloomberg.com Markets table theme,
light](https://plot.sportsdataverse.org/img/table-themes/bloomberg-markets-light.webp)![Bloomberg.com
Markets table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/bloomberg-markets-dark.webp)

`gt_theme_source(gt, "bloomberg-markets")` ·
`reactable_sdv_theme("bloomberg-markets")`

### `finviz`

Finviz screener, dark: native

![Finviz screener table theme,
light](https://plot.sportsdataverse.org/img/table-themes/finviz-light.webp)![Finviz
screener table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/finviz-dark.webp)

`gt_theme_source(gt, "finviz")` · `reactable_sdv_theme("finviz")`

### `ft-markets-data`

FT markets data, dark: none

![FT markets data table theme,
light](https://plot.sportsdataverse.org/img/table-themes/ft-markets-data-light.webp)

`gt_theme_source(gt, "ft-markets-data")` ·
`reactable_sdv_theme("ft-markets-data")`

### `koyfin`

Koyfin, dark: native

![Koyfin table theme,
light](https://plot.sportsdataverse.org/img/table-themes/koyfin-light.webp)![Koyfin
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/koyfin-dark.webp)

`gt_theme_source(gt, "koyfin")` · `reactable_sdv_theme("koyfin")`

### `macrotrends`

Macrotrends, dark: derived

![Macrotrends table theme,
light](https://plot.sportsdataverse.org/img/table-themes/macrotrends-light.webp)![Macrotrends
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/macrotrends-dark.webp)

`gt_theme_source(gt, "macrotrends")` ·
`reactable_sdv_theme("macrotrends")`

### `morningstar`

Morningstar, dark: derived

![Morningstar table theme,
light](https://plot.sportsdataverse.org/img/table-themes/morningstar-light.webp)![Morningstar
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/morningstar-dark.webp)

`gt_theme_source(gt, "morningstar")` ·
`reactable_sdv_theme("morningstar")`

### `sec-edgar`

SEC EDGAR financial statements (R viewer), dark: derived

![SEC EDGAR financial statements (R viewer) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/sec-edgar-light.webp)![SEC
EDGAR financial statements (R viewer) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/sec-edgar-dark.webp)

`gt_theme_source(gt, "sec-edgar")` · `reactable_sdv_theme("sec-edgar")`

### `seeking-alpha-quant`

Seeking Alpha Quant ratings, dark: native

![Seeking Alpha Quant ratings table theme,
light](https://plot.sportsdataverse.org/img/table-themes/seeking-alpha-quant-light.webp)![Seeking
Alpha Quant ratings table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/seeking-alpha-quant-dark.webp)

`gt_theme_source(gt, "seeking-alpha-quant")` ·
`reactable_sdv_theme("seeking-alpha-quant")`

### `tradingview-screener`

TradingView screener, dark: native

![TradingView screener table theme,
light](https://plot.sportsdataverse.org/img/table-themes/tradingview-screener-light.webp)![TradingView
screener table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/tradingview-screener-dark.webp)

`gt_theme_source(gt, "tradingview-screener")` ·
`reactable_sdv_theme("tradingview-screener")`

### `wsj-markets`

WSJ Markets data, dark: derived

![WSJ Markets data table theme,
light](https://plot.sportsdataverse.org/img/table-themes/wsj-markets-light.webp)![WSJ
Markets data table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/wsj-markets-dark.webp)

`gt_theme_source(gt, "wsj-markets")` ·
`reactable_sdv_theme("wsj-markets")`

### `yahoo-finance`

Yahoo Finance, dark: native

![Yahoo Finance table theme,
light](https://plot.sportsdataverse.org/img/table-themes/yahoo-finance-light.webp)![Yahoo
Finance table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/yahoo-finance-dark.webp)

`gt_theme_source(gt, "yahoo-finance")` ·
`reactable_sdv_theme("yahoo-finance")`

## gov (7)

### `bls`

US Bureau of Labor Statistics, dark: derived

![US Bureau of Labor Statistics table theme,
light](https://plot.sportsdataverse.org/img/table-themes/bls-light.webp)![US
Bureau of Labor Statistics table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/bls-dark.webp)

`gt_theme_source(gt, "bls")` · `reactable_sdv_theme("bls")`

### `eurostat`

Eurostat data browser, dark: derived

![Eurostat data browser table theme,
light](https://plot.sportsdataverse.org/img/table-themes/eurostat-light.webp)![Eurostat
data browser table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/eurostat-dark.webp)

`gt_theme_source(gt, "eurostat")` · `reactable_sdv_theme("eurostat")`

### `gov-uk`

GOV.UK Design System table, dark: derived

![GOV.UK Design System table table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gov-uk-light.webp)![GOV.UK
Design System table table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/gov-uk-dark.webp)

`gt_theme_source(gt, "gov-uk")` · `reactable_sdv_theme("gov-uk")`

### `ons`

UK Office for National Statistics, dark: derived

![UK Office for National Statistics table theme,
light](https://plot.sportsdataverse.org/img/table-themes/ons-light.webp)![UK
Office for National Statistics table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/ons-dark.webp)

`gt_theme_source(gt, "ons")` · `reactable_sdv_theme("ons")`

### `statistics-canada`

Statistics Canada, dark: derived

![Statistics Canada table theme,
light](https://plot.sportsdataverse.org/img/table-themes/statistics-canada-light.webp)![Statistics
Canada table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/statistics-canada-dark.webp)

`gt_theme_source(gt, "statistics-canada")` ·
`reactable_sdv_theme("statistics-canada")`

### `us-census`

US Census data.census.gov, dark: derived

![US Census data.census.gov table theme,
light](https://plot.sportsdataverse.org/img/table-themes/us-census-light.webp)![US
Census data.census.gov table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/us-census-dark.webp)

`gt_theme_source(gt, "us-census")` · `reactable_sdv_theme("us-census")`

### `uswds-table`

USWDS usa-table, dark: derived

![USWDS usa-table table theme,
light](https://plot.sportsdataverse.org/img/table-themes/uswds-table-light.webp)![USWDS
usa-table table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/uswds-table-dark.webp)

`gt_theme_source(gt, "uswds-table")` ·
`reactable_sdv_theme("uswds-table")`

## journal (11)

### `aer`

American Economic Review (AEA style), dark: none

![American Economic Review (AEA style) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/aer-light.webp)

`gt_theme_source(gt, "aer")` · `reactable_sdv_theme("aer")`

### `apa-7`

APA 7 table style, dark: none

![APA 7 table style table theme,
light](https://plot.sportsdataverse.org/img/table-themes/apa-7-light.webp)

`gt_theme_source(gt, "apa-7")` · `reactable_sdv_theme("apa-7")`

### `arxiv-booktabs`

arXiv / LaTeX booktabs, dark: none

![arXiv / LaTeX booktabs table theme,
light](https://plot.sportsdataverse.org/img/table-themes/arxiv-booktabs-light.webp)

`gt_theme_source(gt, "arxiv-booktabs")` ·
`reactable_sdv_theme("arxiv-booktabs")`

### `cell`

Cell (STAR Methods), dark: none

![Cell (STAR Methods) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/cell-light.webp)

`gt_theme_source(gt, "cell")` · `reactable_sdv_theme("cell")`

### `chicago-manual`

Chicago Manual of Style (ch. 3), dark: none

![Chicago Manual of Style (ch. 3) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/chicago-manual-light.webp)

`gt_theme_source(gt, "chicago-manual")` ·
`reactable_sdv_theme("chicago-manual")`

### `jama`

JAMA, dark: none

![JAMA table theme,
light](https://plot.sportsdataverse.org/img/table-themes/jama-light.webp)

`gt_theme_source(gt, "jama")` · `reactable_sdv_theme("jama")`

### `lancet`

The Lancet, dark: none

![The Lancet table theme,
light](https://plot.sportsdataverse.org/img/table-themes/lancet-light.webp)

`gt_theme_source(gt, "lancet")` · `reactable_sdv_theme("lancet")`

### `nature`

Nature, dark: none

![Nature table theme,
light](https://plot.sportsdataverse.org/img/table-themes/nature-light.webp)

`gt_theme_source(gt, "nature")` · `reactable_sdv_theme("nature")`

### `nejm`

New England Journal of Medicine, dark: none

![New England Journal of Medicine table theme,
light](https://plot.sportsdataverse.org/img/table-themes/nejm-light.webp)

`gt_theme_source(gt, "nejm")` · `reactable_sdv_theme("nejm")`

### `plos-one`

PLOS ONE, dark: none

![PLOS ONE table theme,
light](https://plot.sportsdataverse.org/img/table-themes/plos-one-light.webp)

`gt_theme_source(gt, "plos-one")` · `reactable_sdv_theme("plos-one")`

### `science`

Science, dark: none

![Science table theme,
light](https://plot.sportsdataverse.org/img/table-themes/science-light.webp)

`gt_theme_source(gt, "science")` · `reactable_sdv_theme("science")`

## library (25)

### `ag-grid-alpine`

AG Grid Alpine, dark: native

![AG Grid Alpine table theme,
light](https://plot.sportsdataverse.org/img/table-themes/ag-grid-alpine-light.webp)![AG
Grid Alpine table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/ag-grid-alpine-dark.webp)

`gt_theme_source(gt, "ag-grid-alpine")` ·
`reactable_sdv_theme("ag-grid-alpine")`

### `ag-grid-balham`

AG Grid Balham, dark: native

![AG Grid Balham table theme,
light](https://plot.sportsdataverse.org/img/table-themes/ag-grid-balham-light.webp)![AG
Grid Balham table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/ag-grid-balham-dark.webp)

`gt_theme_source(gt, "ag-grid-balham")` ·
`reactable_sdv_theme("ag-grid-balham")`

### `ag-grid-material`

AG Grid Material, dark: native

![AG Grid Material table theme,
light](https://plot.sportsdataverse.org/img/table-themes/ag-grid-material-light.webp)![AG
Grid Material table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/ag-grid-material-dark.webp)

`gt_theme_source(gt, "ag-grid-material")` ·
`reactable_sdv_theme("ag-grid-material")`

### `ag-grid-quartz`

AG Grid Quartz, dark: native

![AG Grid Quartz table theme,
light](https://plot.sportsdataverse.org/img/table-themes/ag-grid-quartz-light.webp)![AG
Grid Quartz table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/ag-grid-quartz-dark.webp)

`gt_theme_source(gt, "ag-grid-quartz")` ·
`reactable_sdv_theme("ag-grid-quartz")`

### `datatables`

DataTables (display class), dark: native

![DataTables (display class) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/datatables-light.webp)![DataTables
(display class) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/datatables-dark.webp)

`gt_theme_source(gt, "datatables")` ·
`reactable_sdv_theme("datatables")`

### `great-tables-stylize-1`

great_tables opt_stylize style 1 (blue), dark: derived

![great_tables opt_stylize style 1 (blue) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-1-light.webp)![great_tables
opt_stylize style 1 (blue) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-1-dark.webp)

`gt_theme_source(gt, "great-tables-stylize-1")` ·
`reactable_sdv_theme("great-tables-stylize-1")`

### `great-tables-stylize-2`

great_tables opt_stylize style 2 (green), dark: derived

![great_tables opt_stylize style 2 (green) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-2-light.webp)![great_tables
opt_stylize style 2 (green) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-2-dark.webp)

`gt_theme_source(gt, "great-tables-stylize-2")` ·
`reactable_sdv_theme("great-tables-stylize-2")`

### `great-tables-stylize-3`

great_tables opt_stylize style 3 (cyan), dark: derived

![great_tables opt_stylize style 3 (cyan) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-3-light.webp)![great_tables
opt_stylize style 3 (cyan) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-3-dark.webp)

`gt_theme_source(gt, "great-tables-stylize-3")` ·
`reactable_sdv_theme("great-tables-stylize-3")`

### `great-tables-stylize-4`

great_tables opt_stylize style 4 (pink), dark: derived

![great_tables opt_stylize style 4 (pink) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-4-light.webp)![great_tables
opt_stylize style 4 (pink) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-4-dark.webp)

`gt_theme_source(gt, "great-tables-stylize-4")` ·
`reactable_sdv_theme("great-tables-stylize-4")`

### `great-tables-stylize-5`

great_tables opt_stylize style 5 (gray), dark: derived

![great_tables opt_stylize style 5 (gray) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-5-light.webp)![great_tables
opt_stylize style 5 (gray) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-5-dark.webp)

`gt_theme_source(gt, "great-tables-stylize-5")` ·
`reactable_sdv_theme("great-tables-stylize-5")`

### `great-tables-stylize-6`

great_tables opt_stylize style 6 (red), dark: derived

![great_tables opt_stylize style 6 (red) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-6-light.webp)![great_tables
opt_stylize style 6 (red) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/great-tables-stylize-6-dark.webp)

`gt_theme_source(gt, "great-tables-stylize-6")` ·
`reactable_sdv_theme("great-tables-stylize-6")`

### `gtextras-538`

gtExtras gt_theme_538, dark: derived

![gtExtras gt_theme_538 table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gtextras-538-light.webp)![gtExtras
gt_theme_538 table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/gtextras-538-dark.webp)

`gt_theme_source(gt, "gtextras-538")` ·
`reactable_sdv_theme("gtextras-538")`

### `gtextras-dark`

gtExtras gt_theme_dark, dark: native

![gtExtras gt_theme_dark table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gtextras-dark-light.webp)![gtExtras
gt_theme_dark table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/gtextras-dark-dark.webp)

`gt_theme_source(gt, "gtextras-dark")` ·
`reactable_sdv_theme("gtextras-dark")`

### `gtextras-dot-matrix`

gtExtras gt_theme_dot_matrix, dark: none

![gtExtras gt_theme_dot_matrix table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gtextras-dot-matrix-light.webp)

`gt_theme_source(gt, "gtextras-dot-matrix")` ·
`reactable_sdv_theme("gtextras-dot-matrix")`

### `gtextras-espn`

gtExtras gt_theme_espn, dark: derived

![gtExtras gt_theme_espn table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gtextras-espn-light.webp)![gtExtras
gt_theme_espn table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/gtextras-espn-dark.webp)

`gt_theme_source(gt, "gtextras-espn")` ·
`reactable_sdv_theme("gtextras-espn")`

### `gtextras-excel`

gtExtras gt_theme_excel, dark: derived

![gtExtras gt_theme_excel table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gtextras-excel-light.webp)![gtExtras
gt_theme_excel table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/gtextras-excel-dark.webp)

`gt_theme_source(gt, "gtextras-excel")` ·
`reactable_sdv_theme("gtextras-excel")`

### `gtextras-guardian`

gtExtras gt_theme_guardian, dark: derived

![gtExtras gt_theme_guardian table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gtextras-guardian-light.webp)![gtExtras
gt_theme_guardian table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/gtextras-guardian-dark.webp)

`gt_theme_source(gt, "gtextras-guardian")` ·
`reactable_sdv_theme("gtextras-guardian")`

### `gtextras-nytimes`

gtExtras gt_theme_nytimes, dark: derived

![gtExtras gt_theme_nytimes table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gtextras-nytimes-light.webp)![gtExtras
gt_theme_nytimes table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/gtextras-nytimes-dark.webp)

`gt_theme_source(gt, "gtextras-nytimes")` ·
`reactable_sdv_theme("gtextras-nytimes")`

### `gtextras-pff`

gtExtras gt_theme_pff, dark: derived

![gtExtras gt_theme_pff table theme,
light](https://plot.sportsdataverse.org/img/table-themes/gtextras-pff-light.webp)![gtExtras
gt_theme_pff table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/gtextras-pff-dark.webp)

`gt_theme_source(gt, "gtextras-pff")` ·
`reactable_sdv_theme("gtextras-pff")`

### `ibm-carbon-data-table`

IBM Carbon data table, dark: native

![IBM Carbon data table table theme,
light](https://plot.sportsdataverse.org/img/table-themes/ibm-carbon-data-table-light.webp)![IBM
Carbon data table table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/ibm-carbon-data-table-dark.webp)

`gt_theme_source(gt, "ibm-carbon-data-table")` ·
`reactable_sdv_theme("ibm-carbon-data-table")`

### `material-data-table`

Material Design (M2) data table, dark: native

![Material Design (M2) data table table theme,
light](https://plot.sportsdataverse.org/img/table-themes/material-data-table-light.webp)![Material
Design (M2) data table table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/material-data-table-dark.webp)

`gt_theme_source(gt, "material-data-table")` ·
`reactable_sdv_theme("material-data-table")`

### `observable-inputs-table`

Observable Inputs.table, dark: native

![Observable Inputs.table table theme,
light](https://plot.sportsdataverse.org/img/table-themes/observable-inputs-table-light.webp)![Observable
Inputs.table table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/observable-inputs-table-dark.webp)

`gt_theme_source(gt, "observable-inputs-table")` ·
`reactable_sdv_theme("observable-inputs-table")`

### `shopify-polaris-indextable`

Shopify Polaris IndexTable, dark: derived

![Shopify Polaris IndexTable table theme,
light](https://plot.sportsdataverse.org/img/table-themes/shopify-polaris-indextable-light.webp)![Shopify
Polaris IndexTable table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/shopify-polaris-indextable-dark.webp)

`gt_theme_source(gt, "shopify-polaris-indextable")` ·
`reactable_sdv_theme("shopify-polaris-indextable")`

### `tabulator-simple`

Tabulator (simple theme), dark: native

![Tabulator (simple theme) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/tabulator-simple-light.webp)![Tabulator
(simple theme) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/tabulator-simple-dark.webp)

`gt_theme_source(gt, "tabulator-simple")` ·
`reactable_sdv_theme("tabulator-simple")`

### `tailwind-ui-table`

Tailwind UI tables, dark: native

![Tailwind UI tables table theme,
light](https://plot.sportsdataverse.org/img/table-themes/tailwind-ui-table-light.webp)![Tailwind
UI tables table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/tailwind-ui-table-dark.webp)

`gt_theme_source(gt, "tailwind-ui-table")` ·
`reactable_sdv_theme("tailwind-ui-table")`

## news (20)

### `axios`

Axios, dark: derived

![Axios table theme,
light](https://plot.sportsdataverse.org/img/table-themes/axios-light.webp)![Axios
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/axios-dark.webp)

`gt_theme_source(gt, "axios")` · `reactable_sdv_theme("axios")`

### `bbc-sport`

BBC Sport, dark: derived

![BBC Sport table theme,
light](https://plot.sportsdataverse.org/img/table-themes/bbc-sport-light.webp)![BBC
Sport table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/bbc-sport-dark.webp)

`gt_theme_source(gt, "bbc-sport")` · `reactable_sdv_theme("bbc-sport")`

### `bloomberg`

Bloomberg Graphics, dark: derived

![Bloomberg Graphics table theme,
light](https://plot.sportsdataverse.org/img/table-themes/bloomberg-light.webp)![Bloomberg
Graphics table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/bloomberg-dark.webp)

`gt_theme_source(gt, "bloomberg")` · `reactable_sdv_theme("bloomberg")`

### `datawrapper`

Datawrapper (default table), dark: native

![Datawrapper (default table) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/datawrapper-light.webp)![Datawrapper
(default table) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/datawrapper-dark.webp)

`gt_theme_source(gt, "datawrapper")` ·
`reactable_sdv_theme("datawrapper")`

### `der-spiegel`

Der Spiegel, dark: derived

![Der Spiegel table theme,
light](https://plot.sportsdataverse.org/img/table-themes/der-spiegel-light.webp)![Der
Spiegel table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/der-spiegel-dark.webp)

`gt_theme_source(gt, "der-spiegel")` ·
`reactable_sdv_theme("der-spiegel")`

### `economist`

The Economist, dark: derived

![The Economist table theme,
light](https://plot.sportsdataverse.org/img/table-themes/economist-light.webp)![The
Economist table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/economist-dark.webp)

`gt_theme_source(gt, "economist")` · `reactable_sdv_theme("economist")`

### `financial-times`

Financial Times (o-table core), dark: none

![Financial Times (o-table core) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/financial-times-light.webp)

`gt_theme_source(gt, "financial-times")` ·
`reactable_sdv_theme("financial-times")`

### `financial-times-bordered`

Financial Times (o-table lines + bordered), dark: none

![Financial Times (o-table lines + bordered) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/financial-times-bordered-light.webp)

`gt_theme_source(gt, "financial-times-bordered")` ·
`reactable_sdv_theme("financial-times-bordered")`

### `financial-times-internal`

Financial Times (o-table internal brand), dark: derived

![Financial Times (o-table internal brand) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/financial-times-internal-light.webp)![Financial
Times (o-table internal brand) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/financial-times-internal-dark.webp)

`gt_theme_source(gt, "financial-times-internal")` ·
`reactable_sdv_theme("financial-times-internal")`

### `fivethirtyeight-site`

FiveThirtyEight (forecast tables), dark: derived

![FiveThirtyEight (forecast tables) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/fivethirtyeight-site-light.webp)![FiveThirtyEight
(forecast tables) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/fivethirtyeight-site-dark.webp)

`gt_theme_source(gt, "fivethirtyeight-site")` ·
`reactable_sdv_theme("fivethirtyeight-site")`

### `guardian`

The Guardian, dark: derived

![The Guardian table theme,
light](https://plot.sportsdataverse.org/img/table-themes/guardian-light.webp)![The
Guardian table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/guardian-dark.webp)

`gt_theme_source(gt, "guardian")` · `reactable_sdv_theme("guardian")`

### `le-monde`

Le Monde, dark: derived

![Le Monde table theme,
light](https://plot.sportsdataverse.org/img/table-themes/le-monde-light.webp)![Le
Monde table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/le-monde-dark.webp)

`gt_theme_source(gt, "le-monde")` · `reactable_sdv_theme("le-monde")`

### `new-york-times`

The New York Times, dark: derived

![The New York Times table theme,
light](https://plot.sportsdataverse.org/img/table-themes/new-york-times-light.webp)![The
New York Times table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/new-york-times-dark.webp)

`gt_theme_source(gt, "new-york-times")` ·
`reactable_sdv_theme("new-york-times")`

### `nzz`

NZZ (Q table), dark: derived

![NZZ (Q table) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/nzz-light.webp)![NZZ
(Q table) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/nzz-dark.webp)

`gt_theme_source(gt, "nzz")` · `reactable_sdv_theme("nzz")`

### `propublica`

ProPublica (news apps), dark: native

![ProPublica (news apps) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/propublica-light.webp)![ProPublica
(news apps) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/propublica-dark.webp)

`gt_theme_source(gt, "propublica")` ·
`reactable_sdv_theme("propublica")`

### `reuters-graphics`

Reuters Graphics, dark: derived

![Reuters Graphics table theme,
light](https://plot.sportsdataverse.org/img/table-themes/reuters-graphics-light.webp)![Reuters
Graphics table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/reuters-graphics-dark.webp)

`gt_theme_source(gt, "reuters-graphics")` ·
`reactable_sdv_theme("reuters-graphics")`

### `scmp`

South China Morning Post, dark: derived

![South China Morning Post table theme,
light](https://plot.sportsdataverse.org/img/table-themes/scmp-light.webp)![South
China Morning Post table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/scmp-dark.webp)

`gt_theme_source(gt, "scmp")` · `reactable_sdv_theme("scmp")`

### `the-athletic`

The Athletic, dark: native

![The Athletic table theme,
light](https://plot.sportsdataverse.org/img/table-themes/the-athletic-light.webp)![The
Athletic table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/the-athletic-dark.webp)

`gt_theme_source(gt, "the-athletic")` ·
`reactable_sdv_theme("the-athletic")`

### `the-pudding`

The Pudding, dark: native

![The Pudding table theme,
light](https://plot.sportsdataverse.org/img/table-themes/the-pudding-light.webp)![The
Pudding table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/the-pudding-dark.webp)

`gt_theme_source(gt, "the-pudding")` ·
`reactable_sdv_theme("the-pudding")`

### `washington-post`

The Washington Post (WPDS), dark: derived

![The Washington Post (WPDS) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/washington-post-light.webp)![The
Washington Post (WPDS) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/washington-post-dark.webp)

`gt_theme_source(gt, "washington-post")` ·
`reactable_sdv_theme("washington-post")`

## periodical (5)

### `harpers-index`

Harper’s Magazine (Harper’s Index), dark: none

![Harper's Magazine (Harper's Index) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/harpers-index-light.webp)

`gt_theme_source(gt, "harpers-index")` ·
`reactable_sdv_theme("harpers-index")`

### `new-yorker`

The New Yorker, dark: none

![The New Yorker table theme,
light](https://plot.sportsdataverse.org/img/table-themes/new-yorker-light.webp)

`gt_theme_source(gt, "new-yorker")` ·
`reactable_sdv_theme("new-yorker")`

### `pew-research`

Pew Research Center, dark: derived

![Pew Research Center table theme,
light](https://plot.sportsdataverse.org/img/table-themes/pew-research-light.webp)![Pew
Research Center table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/pew-research-dark.webp)

`gt_theme_source(gt, "pew-research")` ·
`reactable_sdv_theme("pew-research")`

### `the-atlantic`

The Atlantic, dark: derived

![The Atlantic table theme,
light](https://plot.sportsdataverse.org/img/table-themes/the-atlantic-light.webp)![The
Atlantic table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/the-atlantic-dark.webp)

`gt_theme_source(gt, "the-atlantic")` ·
`reactable_sdv_theme("the-atlantic")`

### `wikipedia`

Wikipedia wikitable, dark: native

![Wikipedia wikitable table theme,
light](https://plot.sportsdataverse.org/img/table-themes/wikipedia-light.webp)![Wikipedia
wikitable table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/wikipedia-dark.webp)

`gt_theme_source(gt, "wikipedia")` · `reactable_sdv_theme("wikipedia")`

## sports (41)

### `barttorvik`

Bart Torvik (T-Rank), dark: none

![Bart Torvik (T-Rank) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/barttorvik-light.webp)

`gt_theme_source(gt, "barttorvik")` ·
`reactable_sdv_theme("barttorvik")`

### `baseball-prospectus`

Baseball Prospectus, dark: derived

![Baseball Prospectus table theme,
light](https://plot.sportsdataverse.org/img/table-themes/baseball-prospectus-light.webp)![Baseball
Prospectus table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/baseball-prospectus-dark.webp)

`gt_theme_source(gt, "baseball-prospectus")` ·
`reactable_sdv_theme("baseball-prospectus")`

### `baseball-reference`

Baseball-Reference, dark: derived

![Baseball-Reference table theme,
light](https://plot.sportsdataverse.org/img/table-themes/baseball-reference-light.webp)![Baseball-Reference
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/baseball-reference-dark.webp)

`gt_theme_source(gt, "baseball-reference")` ·
`reactable_sdv_theme("baseball-reference")`

### `baseball-savant`

Baseball Savant, dark: derived

![Baseball Savant table theme,
light](https://plot.sportsdataverse.org/img/table-themes/baseball-savant-light.webp)![Baseball
Savant table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/baseball-savant-dark.webp)

`gt_theme_source(gt, "baseball-savant")` ·
`reactable_sdv_theme("baseball-savant")`

### `basketball-reference`

Basketball-Reference, dark: derived

![Basketball-Reference table theme,
light](https://plot.sportsdataverse.org/img/table-themes/basketball-reference-light.webp)![Basketball-Reference
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/basketball-reference-dark.webp)

`gt_theme_source(gt, "basketball-reference")` ·
`reactable_sdv_theme("basketball-reference")`

### `chess-com`

Chess.com leaderboards, dark: native

![Chess.com leaderboards table theme,
light](https://plot.sportsdataverse.org/img/table-themes/chess-com-light.webp)![Chess.com
leaderboards table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/chess-com-dark.webp)

`gt_theme_source(gt, "chess-com")` · `reactable_sdv_theme("chess-com")`

### `cleaning-the-glass`

Cleaning the Glass, dark: derived

![Cleaning the Glass table theme,
light](https://plot.sportsdataverse.org/img/table-themes/cleaning-the-glass-light.webp)![Cleaning
the Glass table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/cleaning-the-glass-dark.webp)

`gt_theme_source(gt, "cleaning-the-glass")` ·
`reactable_sdv_theme("cleaning-the-glass")`

### `datagolf`

DataGolf, dark: native

![DataGolf table theme,
light](https://plot.sportsdataverse.org/img/table-themes/datagolf-light.webp)![DataGolf
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/datagolf-dark.webp)

`gt_theme_source(gt, "datagolf")` · `reactable_sdv_theme("datagolf")`

### `dunks-and-threes`

Dunks & Threes, dark: native

![Dunks & Threes table theme,
light](https://plot.sportsdataverse.org/img/table-themes/dunks-and-threes-light.webp)![Dunks
& Threes table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/dunks-and-threes-dark.webp)

`gt_theme_source(gt, "dunks-and-threes")` ·
`reactable_sdv_theme("dunks-and-threes")`

### `espn-site`

ESPN (BPI / FPI tables), dark: derived

![ESPN (BPI / FPI tables) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/espn-site-light.webp)![ESPN
(BPI / FPI tables) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/espn-site-dark.webp)

`gt_theme_source(gt, "espn-site")` · `reactable_sdv_theme("espn-site")`

### `espncricinfo-statsguru`

ESPNcricinfo Statsguru, dark: none

![ESPNcricinfo Statsguru table theme,
light](https://plot.sportsdataverse.org/img/table-themes/espncricinfo-statsguru-light.webp)

`gt_theme_source(gt, "espncricinfo-statsguru")` ·
`reactable_sdv_theme("espncricinfo-statsguru")`

### `evanmiya`

EvanMiya, dark: native

![EvanMiya table theme,
light](https://plot.sportsdataverse.org/img/table-themes/evanmiya-light.webp)![EvanMiya
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/evanmiya-dark.webp)

`gt_theme_source(gt, "evanmiya")` · `reactable_sdv_theme("evanmiya")`

### `evolving-hockey`

Evolving-Hockey, dark: derived

![Evolving-Hockey table theme,
light](https://plot.sportsdataverse.org/img/table-themes/evolving-hockey-light.webp)![Evolving-Hockey
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/evolving-hockey-dark.webp)

`gt_theme_source(gt, "evolving-hockey")` ·
`reactable_sdv_theme("evolving-hockey")`

### `fangraphs`

FanGraphs, dark: native

![FanGraphs table theme,
light](https://plot.sportsdataverse.org/img/table-themes/fangraphs-light.webp)![FanGraphs
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/fangraphs-dark.webp)

`gt_theme_source(gt, "fangraphs")` · `reactable_sdv_theme("fangraphs")`

### `fbref`

FBref, dark: derived

![FBref table theme,
light](https://plot.sportsdataverse.org/img/table-themes/fbref-light.webp)![FBref
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/fbref-dark.webp)

`gt_theme_source(gt, "fbref")` · `reactable_sdv_theme("fbref")`

### `fbref-scouting-report`

FBref scouting report, dark: derived

![FBref scouting report table theme,
light](https://plot.sportsdataverse.org/img/table-themes/fbref-scouting-report-light.webp)![FBref
scouting report table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/fbref-scouting-report-dark.webp)

`gt_theme_source(gt, "fbref-scouting-report")` ·
`reactable_sdv_theme("fbref-scouting-report")`

### `formula1`

Formula 1, dark: native

![Formula 1 table theme,
light](https://plot.sportsdataverse.org/img/table-themes/formula1-light.webp)![Formula
1 table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/formula1-dark.webp)

`gt_theme_source(gt, "formula1")` · `reactable_sdv_theme("formula1")`

### `fotmob`

FotMob, dark: native

![FotMob table theme,
light](https://plot.sportsdataverse.org/img/table-themes/fotmob-light.webp)![FotMob
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/fotmob-dark.webp)

`gt_theme_source(gt, "fotmob")` · `reactable_sdv_theme("fotmob")`

### `hockey-reference`

Hockey-Reference, dark: derived

![Hockey-Reference table theme,
light](https://plot.sportsdataverse.org/img/table-themes/hockey-reference-light.webp)![Hockey-Reference
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/hockey-reference-dark.webp)

`gt_theme_source(gt, "hockey-reference")` ·
`reactable_sdv_theme("hockey-reference")`

### `hockeyviz`

HockeyViz, dark: derived

![HockeyViz table theme,
light](https://plot.sportsdataverse.org/img/table-themes/hockeyviz-light.webp)![HockeyViz
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/hockeyviz-dark.webp)

`gt_theme_source(gt, "hockeyviz")` · `reactable_sdv_theme("hockeyviz")`

### `kaggle`

Kaggle leaderboards, dark: native

![Kaggle leaderboards table theme,
light](https://plot.sportsdataverse.org/img/table-themes/kaggle-light.webp)![Kaggle
leaderboards table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/kaggle-dark.webp)

`gt_theme_source(gt, "kaggle")` · `reactable_sdv_theme("kaggle")`

### `lichess`

Lichess leaderboards, dark: native

![Lichess leaderboards table theme,
light](https://plot.sportsdataverse.org/img/table-themes/lichess-light.webp)![Lichess
leaderboards table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/lichess-dark.webp)

`gt_theme_source(gt, "lichess")` · `reactable_sdv_theme("lichess")`

### `moneypuck`

MoneyPuck, dark: none

![MoneyPuck table theme,
light](https://plot.sportsdataverse.org/img/table-themes/moneypuck-light.webp)

`gt_theme_source(gt, "moneypuck")` · `reactable_sdv_theme("moneypuck")`

### `natural-stat-trick`

Natural Stat Trick, dark: none

![Natural Stat Trick table theme,
light](https://plot.sportsdataverse.org/img/table-themes/natural-stat-trick-light.webp)

`gt_theme_source(gt, "natural-stat-trick")` ·
`reactable_sdv_theme("natural-stat-trick")`

### `nba-stats`

NBA.com Stats, dark: derived

![NBA.com Stats table theme,
light](https://plot.sportsdataverse.org/img/table-themes/nba-stats-light.webp)![NBA.com
Stats table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/nba-stats-dark.webp)

`gt_theme_source(gt, "nba-stats")` · `reactable_sdv_theme("nba-stats")`

### `nfl-next-gen-stats`

NFL Next Gen Stats, dark: native

![NFL Next Gen Stats table theme,
light](https://plot.sportsdataverse.org/img/table-themes/nfl-next-gen-stats-light.webp)![NFL
Next Gen Stats table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/nfl-next-gen-stats-dark.webp)

`gt_theme_source(gt, "nfl-next-gen-stats")` ·
`reactable_sdv_theme("nfl-next-gen-stats")`

### `olympics`

Olympics medal table, dark: derived

![Olympics medal table table theme,
light](https://plot.sportsdataverse.org/img/table-themes/olympics-light.webp)![Olympics
medal table table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/olympics-dark.webp)

`gt_theme_source(gt, "olympics")` · `reactable_sdv_theme("olympics")`

### `opta-analyst`

Opta Analyst, dark: derived

![Opta Analyst table theme,
light](https://plot.sportsdataverse.org/img/table-themes/opta-analyst-light.webp)![Opta
Analyst table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/opta-analyst-dark.webp)

`gt_theme_source(gt, "opta-analyst")` ·
`reactable_sdv_theme("opta-analyst")`

### `our-world-in-data`

Our World in Data, dark: derived

![Our World in Data table theme,
light](https://plot.sportsdataverse.org/img/table-themes/our-world-in-data-light.webp)![Our
World in Data table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/our-world-in-data-dark.webp)

`gt_theme_source(gt, "our-world-in-data")` ·
`reactable_sdv_theme("our-world-in-data")`

### `pff-site`

PFF (grades), dark: derived

![PFF (grades) table theme,
light](https://plot.sportsdataverse.org/img/table-themes/pff-site-light.webp)![PFF
(grades) table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/pff-site-dark.webp)

`gt_theme_source(gt, "pff-site")` · `reactable_sdv_theme("pff-site")`

### `premier-league`

Premier League, dark: derived

![Premier League table theme,
light](https://plot.sportsdataverse.org/img/table-themes/premier-league-light.webp)![Premier
League table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/premier-league-dark.webp)

`gt_theme_source(gt, "premier-league")` ·
`reactable_sdv_theme("premier-league")`

### `pro-football-reference`

Pro-Football-Reference, dark: derived

![Pro-Football-Reference table theme,
light](https://plot.sportsdataverse.org/img/table-themes/pro-football-reference-light.webp)![Pro-Football-Reference
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/pro-football-reference-dark.webp)

`gt_theme_source(gt, "pro-football-reference")` ·
`reactable_sdv_theme("pro-football-reference")`

### `racing-reference`

Racing-Reference, dark: none

![Racing-Reference table theme,
light](https://plot.sportsdataverse.org/img/table-themes/racing-reference-light.webp)

`gt_theme_source(gt, "racing-reference")` ·
`reactable_sdv_theme("racing-reference")`

### `rbsdm`

rbsdm.com, dark: derived

![rbsdm.com table theme,
light](https://plot.sportsdataverse.org/img/table-themes/rbsdm-light.webp)![rbsdm.com
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/rbsdm-dark.webp)

`gt_theme_source(gt, "rbsdm")` · `reactable_sdv_theme("rbsdm")`

### `sofascore`

SofaScore, dark: native

![SofaScore table theme,
light](https://plot.sportsdataverse.org/img/table-themes/sofascore-light.webp)![SofaScore
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/sofascore-dark.webp)

`gt_theme_source(gt, "sofascore")` · `reactable_sdv_theme("sofascore")`

### `stathead`

Stathead, dark: derived

![Stathead table theme,
light](https://plot.sportsdataverse.org/img/table-themes/stathead-light.webp)![Stathead
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/stathead-dark.webp)

`gt_theme_source(gt, "stathead")` · `reactable_sdv_theme("stathead")`

### `tennis-abstract`

Tennis Abstract, dark: none

![Tennis Abstract table theme,
light](https://plot.sportsdataverse.org/img/table-themes/tennis-abstract-light.webp)

`gt_theme_source(gt, "tennis-abstract")` ·
`reactable_sdv_theme("tennis-abstract")`

### `transfermarkt`

Transfermarkt, dark: derived

![Transfermarkt table theme,
light](https://plot.sportsdataverse.org/img/table-themes/transfermarkt-light.webp)![Transfermarkt
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/transfermarkt-dark.webp)

`gt_theme_source(gt, "transfermarkt")` ·
`reactable_sdv_theme("transfermarkt")`

### `ultimate-tennis-statistics`

Ultimate Tennis Statistics, dark: derived

![Ultimate Tennis Statistics table theme,
light](https://plot.sportsdataverse.org/img/table-themes/ultimate-tennis-statistics-light.webp)![Ultimate
Tennis Statistics table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/ultimate-tennis-statistics-dark.webp)

`gt_theme_source(gt, "ultimate-tennis-statistics")` ·
`reactable_sdv_theme("ultimate-tennis-statistics")`

### `understat`

Understat, dark: native

![Understat table theme,
light](https://plot.sportsdataverse.org/img/table-themes/understat-light.webp)![Understat
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/understat-dark.webp)

`gt_theme_source(gt, "understat")` · `reactable_sdv_theme("understat")`

### `whoscored`

WhoScored, dark: derived

![WhoScored table theme,
light](https://plot.sportsdataverse.org/img/table-themes/whoscored-light.webp)![WhoScored
table theme,
dark](https://plot.sportsdataverse.org/img/table-themes/whoscored-dark.webp)

`gt_theme_source(gt, "whoscored")` · `reactable_sdv_theme("whoscored")`
