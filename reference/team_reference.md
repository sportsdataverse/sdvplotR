# Get Team Reference Data

Returns the team reference data frame for a given sport, containing team
names, abbreviations, logo and wordmark URLs, colors and conference /
division.

## Usage

``` r
team_reference(
  sport = c("nfl", "nba", "wnba", "mlb", "nhl", "cfb", "mbb", "wbb")
)
```

## Arguments

- sport:

  Character string identifying the sport. One of
  [`supported_sports()`](https://sdvplotR.sportsdataverse.org/reference/supported_sports.md).

## Value

A data frame with one row per team and columns:

|                     |           |                                       |
|---------------------|-----------|---------------------------------------|
| col_name            | type      | description                           |
| sport               | character | Sport key (`"nfl"`, `"nba"`, ...)     |
| espn_team_id        | character | ESPN team id                          |
| team_abbr           | character | Canonical team abbreviation           |
| team_name           | character | Full team name                        |
| team_short_name     | character | Short display name                    |
| team_location       | character | City / school                         |
| team_mascot         | character | Mascot / nickname                     |
| logo_url            | character | Primary logo URL                      |
| logo_dark_url       | character | Dark-background logo URL              |
| logo_scoreboard_url | character | Scoreboard logo URL                   |
| wordmark_url        | character | Wordmark URL (`NA` when none)         |
| color1              | character | Primary team color (hex)              |
| color2              | character | Secondary team color (hex)            |
| conference          | character | Conference (`NA` for leagues without) |
| division            | character | Division (`NA` for leagues without)   |

## Examples

``` r
team_reference("nfl")
#>    sport espn_team_id team_abbr             team_name team_short_name
#> 61   nfl           22       ARI     Arizona Cardinals       Cardinals
#> 62   nfl            1       ATL       Atlanta Falcons         Falcons
#> 63   nfl           33       BAL      Baltimore Ravens          Ravens
#> 64   nfl            2       BUF         Buffalo Bills           Bills
#> 65   nfl           29       CAR     Carolina Panthers        Panthers
#> 66   nfl            3       CHI         Chicago Bears           Bears
#> 67   nfl            4       CIN    Cincinnati Bengals         Bengals
#> 68   nfl            5       CLE      Cleveland Browns          Browns
#> 69   nfl            6       DAL        Dallas Cowboys         Cowboys
#> 70   nfl            7       DEN        Denver Broncos         Broncos
#> 71   nfl            8       DET         Detroit Lions           Lions
#> 72   nfl            9        GB     Green Bay Packers         Packers
#> 73   nfl           34       HOU        Houston Texans          Texans
#> 74   nfl           11       IND    Indianapolis Colts           Colts
#> 75   nfl           30       JAX  Jacksonville Jaguars         Jaguars
#> 76   nfl           12        KC    Kansas City Chiefs          Chiefs
#> 77   nfl           14        LA      Los Angeles Rams            Rams
#> 78   nfl           24       LAC  Los Angeles Chargers        Chargers
#> 79   nfl           13        LV     Las Vegas Raiders         Raiders
#> 80   nfl           15       MIA        Miami Dolphins        Dolphins
#> 81   nfl           16       MIN     Minnesota Vikings         Vikings
#> 82   nfl           17        NE  New England Patriots        Patriots
#> 83   nfl           18        NO    New Orleans Saints          Saints
#> 84   nfl           19       NYG       New York Giants          Giants
#> 85   nfl           20       NYJ         New York Jets            Jets
#> 86   nfl           21       PHI   Philadelphia Eagles          Eagles
#> 87   nfl           23       PIT   Pittsburgh Steelers        Steelers
#> 88   nfl           26       SEA      Seattle Seahawks        Seahawks
#> 89   nfl           25        SF   San Francisco 49ers           49ers
#> 90   nfl           27        TB  Tampa Bay Buccaneers      Buccaneers
#> 91   nfl           10       TEN      Tennessee Titans          Titans
#> 92   nfl           28       WAS Washington Commanders      Commanders
#>    team_location team_mascot                                          logo_url
#> 61       Arizona   Cardinals https://a.espncdn.com/i/teamlogos/nfl/500/ari.png
#> 62       Atlanta     Falcons https://a.espncdn.com/i/teamlogos/nfl/500/atl.png
#> 63     Baltimore      Ravens https://a.espncdn.com/i/teamlogos/nfl/500/bal.png
#> 64       Buffalo       Bills https://a.espncdn.com/i/teamlogos/nfl/500/buf.png
#> 65      Carolina    Panthers https://a.espncdn.com/i/teamlogos/nfl/500/car.png
#> 66       Chicago       Bears https://a.espncdn.com/i/teamlogos/nfl/500/chi.png
#> 67    Cincinnati     Bengals https://a.espncdn.com/i/teamlogos/nfl/500/cin.png
#> 68     Cleveland      Browns https://a.espncdn.com/i/teamlogos/nfl/500/cle.png
#> 69        Dallas     Cowboys https://a.espncdn.com/i/teamlogos/nfl/500/dal.png
#> 70        Denver     Broncos https://a.espncdn.com/i/teamlogos/nfl/500/den.png
#> 71       Detroit       Lions https://a.espncdn.com/i/teamlogos/nfl/500/det.png
#> 72     Green Bay     Packers  https://a.espncdn.com/i/teamlogos/nfl/500/gb.png
#> 73       Houston      Texans https://a.espncdn.com/i/teamlogos/nfl/500/hou.png
#> 74  Indianapolis       Colts https://a.espncdn.com/i/teamlogos/nfl/500/ind.png
#> 75  Jacksonville     Jaguars https://a.espncdn.com/i/teamlogos/nfl/500/jax.png
#> 76   Kansas City      Chiefs  https://a.espncdn.com/i/teamlogos/nfl/500/kc.png
#> 77   Los Angeles        Rams https://a.espncdn.com/i/teamlogos/nfl/500/lar.png
#> 78   Los Angeles    Chargers https://a.espncdn.com/i/teamlogos/nfl/500/lac.png
#> 79     Las Vegas     Raiders  https://a.espncdn.com/i/teamlogos/nfl/500/lv.png
#> 80         Miami    Dolphins https://a.espncdn.com/i/teamlogos/nfl/500/mia.png
#> 81     Minnesota     Vikings https://a.espncdn.com/i/teamlogos/nfl/500/min.png
#> 82   New England    Patriots  https://a.espncdn.com/i/teamlogos/nfl/500/ne.png
#> 83   New Orleans      Saints  https://a.espncdn.com/i/teamlogos/nfl/500/no.png
#> 84      New York      Giants https://a.espncdn.com/i/teamlogos/nfl/500/nyg.png
#> 85      New York        Jets https://a.espncdn.com/i/teamlogos/nfl/500/nyj.png
#> 86  Philadelphia      Eagles https://a.espncdn.com/i/teamlogos/nfl/500/phi.png
#> 87    Pittsburgh    Steelers https://a.espncdn.com/i/teamlogos/nfl/500/pit.png
#> 88       Seattle    Seahawks https://a.espncdn.com/i/teamlogos/nfl/500/sea.png
#> 89 San Francisco       49ers  https://a.espncdn.com/i/teamlogos/nfl/500/sf.png
#> 90     Tampa Bay  Buccaneers  https://a.espncdn.com/i/teamlogos/nfl/500/tb.png
#> 91     Tennessee      Titans https://a.espncdn.com/i/teamlogos/nfl/500/ten.png
#> 92    Washington  Commanders https://a.espncdn.com/i/teamlogos/nfl/500/wsh.png
#>                                             logo_dark_url
#> 61 https://a.espncdn.com/i/teamlogos/nfl/500-dark/ari.png
#> 62 https://a.espncdn.com/i/teamlogos/nfl/500-dark/atl.png
#> 63 https://a.espncdn.com/i/teamlogos/nfl/500-dark/bal.png
#> 64 https://a.espncdn.com/i/teamlogos/nfl/500-dark/buf.png
#> 65 https://a.espncdn.com/i/teamlogos/nfl/500-dark/car.png
#> 66 https://a.espncdn.com/i/teamlogos/nfl/500-dark/chi.png
#> 67 https://a.espncdn.com/i/teamlogos/nfl/500-dark/cin.png
#> 68 https://a.espncdn.com/i/teamlogos/nfl/500-dark/cle.png
#> 69 https://a.espncdn.com/i/teamlogos/nfl/500-dark/dal.png
#> 70 https://a.espncdn.com/i/teamlogos/nfl/500-dark/den.png
#> 71 https://a.espncdn.com/i/teamlogos/nfl/500-dark/det.png
#> 72  https://a.espncdn.com/i/teamlogos/nfl/500-dark/gb.png
#> 73 https://a.espncdn.com/i/teamlogos/nfl/500-dark/hou.png
#> 74 https://a.espncdn.com/i/teamlogos/nfl/500-dark/ind.png
#> 75 https://a.espncdn.com/i/teamlogos/nfl/500-dark/jax.png
#> 76  https://a.espncdn.com/i/teamlogos/nfl/500-dark/kc.png
#> 77 https://a.espncdn.com/i/teamlogos/nfl/500-dark/lar.png
#> 78 https://a.espncdn.com/i/teamlogos/nfl/500-dark/lac.png
#> 79  https://a.espncdn.com/i/teamlogos/nfl/500-dark/lv.png
#> 80 https://a.espncdn.com/i/teamlogos/nfl/500-dark/mia.png
#> 81 https://a.espncdn.com/i/teamlogos/nfl/500-dark/min.png
#> 82  https://a.espncdn.com/i/teamlogos/nfl/500-dark/ne.png
#> 83  https://a.espncdn.com/i/teamlogos/nfl/500-dark/no.png
#> 84 https://a.espncdn.com/i/teamlogos/nfl/500-dark/nyg.png
#> 85 https://a.espncdn.com/i/teamlogos/nfl/500-dark/nyj.png
#> 86 https://a.espncdn.com/i/teamlogos/nfl/500-dark/phi.png
#> 87 https://a.espncdn.com/i/teamlogos/nfl/500-dark/pit.png
#> 88 https://a.espncdn.com/i/teamlogos/nfl/500-dark/sea.png
#> 89  https://a.espncdn.com/i/teamlogos/nfl/500-dark/sf.png
#> 90  https://a.espncdn.com/i/teamlogos/nfl/500-dark/tb.png
#> 91 https://a.espncdn.com/i/teamlogos/nfl/500-dark/ten.png
#> 92 https://a.espncdn.com/i/teamlogos/nfl/500-dark/wsh.png
#>                                             logo_scoreboard_url
#> 61 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/ari.png
#> 62 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/atl.png
#> 63 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/bal.png
#> 64 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/buf.png
#> 65 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/car.png
#> 66 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/chi.png
#> 67 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/cin.png
#> 68 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/cle.png
#> 69 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/dal.png
#> 70 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/den.png
#> 71 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/det.png
#> 72  https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/gb.png
#> 73 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/hou.png
#> 74 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/ind.png
#> 75 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/jax.png
#> 76  https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/kc.png
#> 77 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/lar.png
#> 78 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/lac.png
#> 79  https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/lv.png
#> 80 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/mia.png
#> 81 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/min.png
#> 82  https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/ne.png
#> 83  https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/no.png
#> 84 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/nyg.png
#> 85 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/nyj.png
#> 86 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/phi.png
#> 87 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/pit.png
#> 88 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/sea.png
#> 89  https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/sf.png
#> 90  https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/tb.png
#> 91 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/ten.png
#> 92 https://a.espncdn.com/i/teamlogos/nfl/500/scoreboard/wsh.png
#>                                                             wordmark_url
#> 61 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/ARI.png
#> 62 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/ATL.png
#> 63 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/BAL.png
#> 64 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/BUF.png
#> 65 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/CAR.png
#> 66 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/CHI.png
#> 67 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/CIN.png
#> 68 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/CLE.png
#> 69 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/DAL.png
#> 70 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/DEN.png
#> 71 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/DET.png
#> 72  https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/GB.png
#> 73 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/HOU.png
#> 74 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/IND.png
#> 75 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/JAX.png
#> 76  https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/KC.png
#> 77  https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/LA.png
#> 78 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/LAC.png
#> 79  https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/LV.png
#> 80 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/MIA.png
#> 81 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/MIN.png
#> 82  https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/NE.png
#> 83  https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/NO.png
#> 84 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/NYG.png
#> 85 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/NYJ.png
#> 86 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/PHI.png
#> 87 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/PIT.png
#> 88 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/SEA.png
#> 89  https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/SF.png
#> 90  https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/TB.png
#> 91 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/TEN.png
#> 92 https://github.com/nflverse/nflverse-pbp/raw/master/wordmarks/WAS.png
#>     color1  color2 conference  division
#> 61 #97233F #000000        NFC  NFC West
#> 62 #A71930 #000000        NFC NFC South
#> 63 #241773 #9E7C0C        AFC AFC North
#> 64 #00338D #C60C30        AFC  AFC East
#> 65 #0085CA #000000        NFC NFC South
#> 66 #0B162A #E64100        NFC NFC North
#> 67 #FB4F14 #000000        AFC AFC North
#> 68 #FF3C00 #311D00        AFC AFC North
#> 69 #002244 #B0B7BC        NFC  NFC East
#> 70 #002244 #FB4F14        AFC  AFC West
#> 71 #0076B6 #B0B7BC        NFC NFC North
#> 72 #203731 #FFB612        NFC NFC North
#> 73 #03202F #A71930        AFC AFC South
#> 74 #002C5F #a5acaf        AFC AFC South
#> 75 #006778 #000000        AFC AFC South
#> 76 #E31837 #FFB612        AFC  AFC West
#> 77 #003594 #FFD100        NFC  NFC West
#> 78 #007BC7 #ffc20e        AFC  AFC West
#> 79 #000000 #A5ACAF        AFC  AFC West
#> 80 #008E97 #F58220        AFC  AFC East
#> 81 #4F2683 #FFC62F        NFC NFC North
#> 82 #002244 #C60C30        AFC  AFC East
#> 83 #D3BC8D #000000        NFC NFC South
#> 84 #0B2265 #A71930        NFC  NFC East
#> 85 #003F2D #000000        AFC  AFC East
#> 86 #004C54 #A5ACAF        NFC  NFC East
#> 87 #000000 #FFB612        AFC AFC North
#> 88 #002244 #69be28        NFC  NFC West
#> 89 #AA0000 #B3995D        NFC  NFC West
#> 90 #A71930 #322F2B        NFC NFC South
#> 91 #4495D2 #D50A0A        AFC AFC South
#> 92 #5A1414 #FFB612        NFC  NFC East
head(team_reference("nba"))
#>    sport espn_team_id team_abbr           team_name team_short_name
#> 31   nba            1       ATL       Atlanta Hawks           Hawks
#> 32   nba           17       BKN       Brooklyn Nets            Nets
#> 33   nba            2       BOS      Boston Celtics         Celtics
#> 34   nba           30       CHA   Charlotte Hornets         Hornets
#> 35   nba            4       CHI       Chicago Bulls           Bulls
#> 36   nba            5       CLE Cleveland Cavaliers       Cavaliers
#>    team_location team_mascot                                          logo_url
#> 31       Atlanta       Hawks https://a.espncdn.com/i/teamlogos/nba/500/atl.png
#> 32      Brooklyn        Nets https://a.espncdn.com/i/teamlogos/nba/500/bkn.png
#> 33        Boston     Celtics https://a.espncdn.com/i/teamlogos/nba/500/bos.png
#> 34     Charlotte     Hornets https://a.espncdn.com/i/teamlogos/nba/500/cha.png
#> 35       Chicago       Bulls https://a.espncdn.com/i/teamlogos/nba/500/chi.png
#> 36     Cleveland   Cavaliers https://a.espncdn.com/i/teamlogos/nba/500/cle.png
#>                                             logo_dark_url
#> 31 https://a.espncdn.com/i/teamlogos/nba/500-dark/atl.png
#> 32 https://a.espncdn.com/i/teamlogos/nba/500-dark/bkn.png
#> 33 https://a.espncdn.com/i/teamlogos/nba/500-dark/bos.png
#> 34 https://a.espncdn.com/i/teamlogos/nba/500-dark/cha.png
#> 35 https://a.espncdn.com/i/teamlogos/nba/500-dark/chi.png
#> 36 https://a.espncdn.com/i/teamlogos/nba/500-dark/cle.png
#>                                             logo_scoreboard_url wordmark_url
#> 31 https://a.espncdn.com/i/teamlogos/nba/500/scoreboard/atl.png         <NA>
#> 32 https://a.espncdn.com/i/teamlogos/nba/500/scoreboard/bkn.png         <NA>
#> 33 https://a.espncdn.com/i/teamlogos/nba/500/scoreboard/bos.png         <NA>
#> 34 https://a.espncdn.com/i/teamlogos/nba/500/scoreboard/cha.png         <NA>
#> 35 https://a.espncdn.com/i/teamlogos/nba/500/scoreboard/chi.png         <NA>
#> 36 https://a.espncdn.com/i/teamlogos/nba/500/scoreboard/cle.png         <NA>
#>     color1  color2 conference division
#> 31 #C8102E #FDB927    Eastern     <NA>
#> 32 #000000 #FFFFFF    Eastern     <NA>
#> 33 #008348 #FFFFFF    Eastern     <NA>
#> 34 #008CA8 #1D1060    Eastern     <NA>
#> 35 #CE1141 #000000    Eastern     <NA>
#> 36 #860038 #BC945C    Eastern     <NA>
```
