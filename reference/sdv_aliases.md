# Team aliases in the sdvplotR index

Every team name, abbreviation and provider id the index resolves, one
row per alias: what
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
reads. The counterpart of cfbplotR's `team_name_mapping` (see the
examples). The R counterpart of sdvplot's alias table.

## Usage

``` r
sdv_aliases(league = NULL)
```

## Arguments

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md),
  or `NULL` for every league.

## Value

A data frame:

|  |  |  |
|----|----|----|
| col_name | type | description |
| league | character | League key |
| id_system | character | The id system of `value` (`"name"`, `"espn"`, `"cfbd"`, ...; see [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)). `"mark"`, `"conference"` and `"competition"` rows serve the logo helpers only |
| value | character | The alias as the index stores it (lookups ignore case and accents) |
| team_id | character | The [`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md) `team_id` it names |
| valid_from | integer | First season the alias names this team (`NA`: always) |
| valid_to | integer | Last season the alias names this team (`NA`: still) |

## See also

[`sdv_clean_names()`](https://sdvplotR.sportsdataverse.org/reference/sdv_clean_names.md),
[`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md),
[`sdv_teams()`](https://sdvplotR.sportsdataverse.org/reference/sdv_teams.md).

## Examples

``` r
a <- sdv_aliases("cfb")
head(a[a$id_system == "name", ])
#>      league id_system                      value team_id valid_from valid_to
#> 4972    cfb      name              AR-Pine Bluff    2029         NA       NA
#> 4973    cfb      name                  ARK STATE    2032         NA       NA
#> 4974    cfb      name          Abilene Christian    2000         NA       NA
#> 4975    cfb      name Abilene Christian Wildcats    2000         NA       NA
#> 4976    cfb      name             Abilene Chrstn    2000         NA       NA
#> 4977    cfb      name                   Adams St    2001         NA       NA

# cfbplotR's team_name_mapping: each name -> its school
nm <- a[a$id_system %in% c("name", "cfbd", "sdvplotr"), ]
t <- sdv_teams("cfb")
mapping <- stats::setNames(t$location[match(nm$team_id, t$team_id)], nm$value)
head(mapping)
#>                AAMU                ABSU                 ACU                 ADR 
#>       "Alabama A&M"      "Albany State" "Abilene Christian"            "Adrian" 
#>                ADSU                  AF 
#>       "Adams State"         "Air Force" 
```
