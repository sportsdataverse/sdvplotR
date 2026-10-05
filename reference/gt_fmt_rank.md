# Format numbers as ordinals in a `gt` table

Turns plain integers into ordinals: 1 becomes 1st, 2 becomes 2nd, 23
becomes 23rd. The suffix can be rendered as superscript, which is the
usual treatment in a ranked column.

## Usage

``` r
gt_fmt_rank(gt_object, columns, superscript = TRUE, suffix_size = "0.7em")
```

## Arguments

- gt_object:

  A `gt` table object to modify.

- columns:

  The column or columns to format.

- superscript:

  Logical. Should the suffix be rendered as superscript? Defaults to
  `TRUE`.

- suffix_size:

  Character. The size of the suffix, as a CSS size. Defaults to
  `"0.7em"`.

## Value

Returns a modified `gt` table with ordinal formatting applied.

## Details

Teens are handled correctly, so 11, 12 and 13 take "th" and not "st",
"nd" and "rd". Values that are not numeric are left alone.

## Examples

``` r
library(gt)

nfc <- subset(sdv_example_standings, conference == "NFC" & conference_rank <= 5,
  c(team_name, conference_rank))
nfc <- nfc[order(nfc$conference_rank), ]

gt(nfc) %>% gt_fmt_rank(conference_rank)


  

team_name
```
