# Teams in the sdvplotR index

One row per team: its canonical `team_id` (the key every helper resolves
to), names, abbreviation, conference and colours. The R counterpart of
sdvplot's `teams()`.

## Usage

``` r
sdv_teams(league = NULL, include_conferences = FALSE)
```

## Arguments

- league:

  A league key from
  [`sdv_leagues()`](https://sdvplotR.sportsdataverse.org/reference/sdv_leagues.md),
  or `NULL` for every league.

- include_conferences:

  Also list the conference and league rows (the college conferences, and
  the AFC, NFC and NFL). Their `program` is `"conference"` or `"league"`
  and their `team_id` is the short name (`"SEC"`, `"AFC"`). The logo
  helpers draw them by that key; colour helpers and
  [`sdv_resolve()`](https://sdvplotR.sportsdataverse.org/reference/sdv_resolve.md)
  never answer one.

## Value

A data frame:

|  |  |  |
|----|----|----|
| col_name | type | description |
| league | character | League key |
| team_id | character | Canonical team id (the ESPN id where ESPN has the team) |
| abbr | character | Abbreviation (`NA` where the league has none) |
| name | character | Full name |
| short_name | character | Short display name |
| location | character | City or school |
| program | character | `NA` for a team; `"conference"` or `"league"` for those rows |
| conference_id | character | The team's conference row `team_id` |
| conference | character | Conference name |
| color_primary | character | Primary colour (hex) |
| color_secondary | character | Secondary colour (hex) |
| color_source | character | `"nflverse"`, `"espn"`, `"logo"`, `"cbbplotR"` or `"fallback"` |

## Examples

``` r
sdv_teams("nfl")
#>    league team_id abbr                  name short_name      location program
#> 1     nfl       1  ATL       Atlanta Falcons    Falcons       Atlanta     pro
#> 2     nfl      10  TEN      Tennessee Titans     Titans     Tennessee     pro
#> 3     nfl      11  IND    Indianapolis Colts      Colts  Indianapolis     pro
#> 4     nfl      12   KC    Kansas City Chiefs     Chiefs   Kansas City     pro
#> 5     nfl      13   LV     Las Vegas Raiders    Raiders     Las Vegas     pro
#> 6     nfl      14   LA      Los Angeles Rams       Rams   Los Angeles     pro
#> 7     nfl      15  MIA        Miami Dolphins   Dolphins         Miami     pro
#> 8     nfl      16  MIN     Minnesota Vikings    Vikings     Minnesota     pro
#> 9     nfl      17   NE  New England Patriots   Patriots   New England     pro
#> 10    nfl      18   NO    New Orleans Saints     Saints   New Orleans     pro
#> 11    nfl      19  NYG       New York Giants     Giants      New York     pro
#> 12    nfl       2  BUF         Buffalo Bills      Bills       Buffalo     pro
#> 13    nfl      20  NYJ         New York Jets       Jets      New York     pro
#> 14    nfl      21  PHI   Philadelphia Eagles     Eagles  Philadelphia     pro
#> 15    nfl      22  ARI     Arizona Cardinals  Cardinals       Arizona     pro
#> 16    nfl      23  PIT   Pittsburgh Steelers   Steelers    Pittsburgh     pro
#> 17    nfl      24  LAC  Los Angeles Chargers   Chargers   Los Angeles     pro
#> 18    nfl      25   SF   San Francisco 49ers      49ers San Francisco     pro
#> 19    nfl      26  SEA      Seattle Seahawks   Seahawks       Seattle     pro
#> 20    nfl      27   TB  Tampa Bay Buccaneers Buccaneers     Tampa Bay     pro
#> 21    nfl      28  WAS Washington Commanders Commanders    Washington     pro
#> 22    nfl      29  CAR     Carolina Panthers   Panthers      Carolina     pro
#> 23    nfl       3  CHI         Chicago Bears      Bears       Chicago     pro
#> 24    nfl      30  JAX  Jacksonville Jaguars    Jaguars  Jacksonville     pro
#> 25    nfl      33  BAL      Baltimore Ravens     Ravens     Baltimore     pro
#> 26    nfl      34  HOU        Houston Texans     Texans       Houston     pro
#> 27    nfl       4  CIN    Cincinnati Bengals    Bengals    Cincinnati     pro
#> 28    nfl       5  CLE      Cleveland Browns     Browns     Cleveland     pro
#> 29    nfl       6  DAL        Dallas Cowboys    Cowboys        Dallas     pro
#> 30    nfl       7  DEN        Denver Broncos    Broncos        Denver     pro
#> 31    nfl       8  DET         Detroit Lions      Lions       Detroit     pro
#> 32    nfl       9   GB     Green Bay Packers    Packers     Green Bay     pro
#>    conference_id                   conference color_primary color_secondary
#> 1        nfl:nfc National Football Conference       #a71930         #000000
#> 2        nfl:afc American Football Conference       #4495d2         #d50a0a
#> 3        nfl:afc American Football Conference       #002c5f         #a5acaf
#> 4        nfl:afc American Football Conference       #e31837         #ffb612
#> 5        nfl:afc American Football Conference       #000000         #a5acaf
#> 6        nfl:nfc National Football Conference       #003594         #ffd100
#> 7        nfl:afc American Football Conference       #008e97         #f58220
#> 8        nfl:nfc National Football Conference       #4f2683         #ffc62f
#> 9        nfl:afc American Football Conference       #002244         #c60c30
#> 10       nfl:nfc National Football Conference       #d3bc8d         #000000
#> 11       nfl:nfc National Football Conference       #0b2265         #a71930
#> 12       nfl:afc American Football Conference       #00338d         #c60c30
#> 13       nfl:afc American Football Conference       #003f2d         #000000
#> 14       nfl:nfc National Football Conference       #004c54         #a5acaf
#> 15       nfl:nfc National Football Conference       #97233f         #000000
#> 16       nfl:afc American Football Conference       #000000         #ffb612
#> 17       nfl:afc American Football Conference       #007bc7         #ffc20e
#> 18       nfl:nfc National Football Conference       #aa0000         #b3995d
#> 19       nfl:nfc National Football Conference       #002244         #69be28
#> 20       nfl:nfc National Football Conference       #a71930         #322f2b
#> 21       nfl:nfc National Football Conference       #5a1414         #ffb612
#> 22       nfl:nfc National Football Conference       #0085ca         #000000
#> 23       nfl:nfc National Football Conference       #0b162a         #e64100
#> 24       nfl:afc American Football Conference       #006778         #000000
#> 25       nfl:afc American Football Conference       #241773         #9e7c0c
#> 26       nfl:afc American Football Conference       #03202f         #a71930
#> 27       nfl:afc American Football Conference       #fb4f14         #000000
#> 28       nfl:afc American Football Conference       #ff3c00         #311d00
#> 29       nfl:nfc National Football Conference       #002244         #b0b7bc
#> 30       nfl:afc American Football Conference       #002244         #fb4f14
#> 31       nfl:nfc National Football Conference       #0076b6         #b0b7bc
#> 32       nfl:nfc National Football Conference       #203731         #ffb612
#>    color_source
#> 1      nflverse
#> 2      nflverse
#> 3      nflverse
#> 4      nflverse
#> 5      nflverse
#> 6      nflverse
#> 7      nflverse
#> 8      nflverse
#> 9      nflverse
#> 10     nflverse
#> 11     nflverse
#> 12     nflverse
#> 13     nflverse
#> 14     nflverse
#> 15     nflverse
#> 16     nflverse
#> 17     nflverse
#> 18     nflverse
#> 19     nflverse
#> 20     nflverse
#> 21     nflverse
#> 22     nflverse
#> 23     nflverse
#> 24     nflverse
#> 25     nflverse
#> 26     nflverse
#> 27     nflverse
#> 28     nflverse
#> 29     nflverse
#> 30     nflverse
#> 31     nflverse
#> 32     nflverse
sdv_teams("cfb", include_conferences = TRUE)
#>     league       team_id          abbr                                     name
#> 1      cfb           101          ERKA                        Eureka Red Devils
#> 2      cfb        101442          CTLA                 Centenary (LA) Gentlemen
#> 3      cfb        101784          ERSK                     Erskine Flying Fleet
#> 4      cfb           103            BC                    Boston College Eagles
#> 5      cfb           107            HC                     Holy Cross Crusaders
#> 6      cfb           108          HARV                          Harvard Crimson
#> 7      cfb           109           MIT                            MIT Engineers
#> 8      cfb            11          COMU                  Colorado Mesa Mavericks
#> 9      cfb           110           MMT                 Mass Maritime Buccaneers
#> 10     cfb        110242           UWF                   West Florida Argonauts
#> 11     cfb        110243          UTPB                 UT Permian Basin Falcons
#> 12     cfb        110438          DEAN                            Dean Bulldogs
#> 13     cfb        111610          STAU                      St. Andrews Knights
#> 14     cfb        111674          ALVR                   Alvernia Golden Wolves
#> 15     cfb        111675           UNE                  New England Nor'easters
#> 16     cfb           112          TUFT                             Tufts Jumbos
#> 17     cfb        112334            FP                   Franklin Pierce Ravens
#> 18     cfb        112335          WHLG                       Wheeling Cardinals
#> 19     cfb           113          MASS                  Massachusetts Minutemen
#> 20     cfb           114          FBSU                  Fitchburg State Falcons
#> 21     cfb           118           JHU                  Johns Hopkins Blue Jays
#> 22     cfb           119           TOW                            Towson Tigers
#> 23     cfb            12          ARIZ                         Arizona Wildcats
#> 24     cfb           120            MD                       Maryland Terrapins
#> 25     cfb           121          BATE                            Bates Bobcats
#> 26     cfb        122666          BART                          Barton Bulldogs
#> 27     cfb        122774          KYSN                          Keystone Giants
#> 28     cfb        123086          NAMU                 North American Stallions
#> 29     cfb           124          AUGS                         Augsburg Auggies
#> 30     cfb        124179          LNCA                  Lincoln (CA) Oaklanders
#> 31     cfb        124180          BLUS                 Bluefield State Big Blue
#> 32     cfb           125          GVSU                Grand Valley State Lakers
#> 33     cfb        125974          HLBT                            Hilbert Hawks
#> 34     cfb           126          KALC                        Kalamazoo Hornets
#> 35     cfb        126086          POST                              Post Eagles
#> 36     cfb           127           MSU                  Michigan State Spartans
#> 37     cfb        127954            EU                           Eastern Eagles
#> 38     cfb           128           NMI               Northern Michigan Wildcats
#> 39     cfb           129          SVSU           Saginaw Valley State Cardinals
#> 40     cfb        129469          ANSC                    Anderson (SC) Trojans
#> 41     cfb        129738          CALU                           Calvin Knights
#> 42     cfb            13            CP                        Cal Poly Mustangs
#> 43     cfb           130          MICH                      Michigan Wolverines
#> 44     cfb           131          WSMI                Wayne State (MI) Warriors
#> 45     cfb           132           BST                    Bemidji State Beavers
#> 46     cfb           133          OLAF                            St. Olaf Oles
#> 47     cfb           134           UMD                Minnesota Duluth Bulldogs
#> 48     cfb           135          MINN                 Minnesota Golden Gophers
#> 49     cfb           137          MOWE                Missouri Western Griffons
#> 50     cfb           138          MWMO        Northwest Missouri State Bearcats
#> 51     cfb           142           MIZ                          Missouri Tigers
#> 52     cfb           143          WUMO               Washington St. Louis Bears
#> 53     cfb           145          MISS                          Ole Miss Rebels
#> 54     cfb           146           GRO                    Grove City Wolverines
#> 55     cfb           147          MTST                    Montana State Bobcats
#> 56     cfb           149          MONT                        Montana Grizzlies
#> 57     cfb           150          DUKE                         Duke Blue Devils
#> 58     cfb           151           ECU                    East Carolina Pirates
#> 59     cfb           152          NCSU                        NC State Wolfpack
#> 60     cfb           153           UNC                 North Carolina Tar Heels
#> 61     cfb           154          WAKE                Wake Forest Demon Deacons
#> 62     cfb           155           UND              North Dakota Fighting Hawks
#> 63     cfb           158           NEB                     Nebraska Cornhuskers
#> 64     cfb           159          DART                      Dartmouth Big Green
#> 65     cfb            16           SAC                 Sacramento State Hornets
#> 66     cfb           160           UNH                   New Hampshire Wildcats
#> 67     cfb           162          HMLN                           Hamline Pipers
#> 68     cfb           163          PRIN                         Princeton Tigers
#> 69     cfb           164          RUTG                  Rutgers Scarlet Knights
#> 70     cfb           166          NMSU                  New Mexico State Aggies
#> 71     cfb           167           UNM                         New Mexico Lobos
#> 72     cfb            17           CMS             Claremont Mudd Scripps Stags
#> 73     cfb           171          COLU                           Columbia Lions
#> 74     cfb           172           COR                          Cornell Big Red
#> 75     cfb           173          HRTW                           Hartwick Hawks
#> 76     cfb           174          HBRT                         Hobart Statesmen
#> 77     cfb           175           ITH                           Ithaca Bombers
#> 78     cfb            18          BRIS                  Bridgewater State Bears
#> 79     cfb           183           SYR                          Syracuse Orange
#> 80     cfb           184          URNY            Rochester (NY) Yellow Jackets
#> 81     cfb           188            BW           Baldwin Wallace Yellow Jackets
#> 82     cfb           189          BGSU                    Bowling Green Falcons
#> 83     cfb           190           DEF          Defiance College Yellow Jackets
#> 84     cfb           191          HDBG               Heidelberg Student Princes
#> 85     cfb           193          M-OH                      Miami (OH) RedHawks
#> 86     cfb           194           OSU                      Ohio State Buckeyes
#> 87     cfb           195          OHIO                             Ohio Bobcats
#> 88     cfb           196          NESU            Northeastern State RiverHawks
#> 89     cfb           197          OKST                   Oklahoma State Cowboys
#> 90     cfb           199          SEOK Southeastern Oklahoma State Savage Storm
#> 91     cfb             2           AUB                            Auburn Tigers
#> 92     cfb           200           SNU          Southern Nazarene Crimson Storm
#> 93     cfb          2000           ACU               Abilene Christian Wildcats
#> 94     cfb          2001          ADSU                    Adams State Grizzlies
#> 95     cfb          2003           ADR                          Adrian Bulldogs
#> 96     cfb          2005            AF                        Air Force Falcons
#> 97     cfb          2006           AKR                               Akron Zips
#> 98     cfb           201            OU                         Oklahoma Sooners
#> 99     cfb          2010          AAMU                     Alabama A&M Bulldogs
#> 100    cfb          2011          ALST                    Alabama State Hornets
#> 101    cfb          2013          ABSU                 Albany State Golden Rams
#> 102    cfb          2015          ALBR                           Albright Lions
#> 103    cfb          2016          ALCN                      Alcorn State Braves
#> 104    cfb          2018          ALLG                         Allegheny Gators
#> 105    cfb          2019          ALNU                     Allen Yellow Jackets
#> 106    cfb           202          TLSA                   Tulsa Golden Hurricane
#> 107    cfb          2022           AIC    American International Yellow Jackets
#> 108    cfb          2023          ANIN                     Anderson (IN) Ravens
#> 109    cfb          2025          AGSU                        Angelo State Rams
#> 110    cfb          2026           APP                   App State Mountaineers
#> 111    cfb          2028           UAM         Arkansas Monticello Boll Weevils
#> 112    cfb          2029          UAPB         Arkansas-Pine Bluff Golden Lions
#> 113    cfb           203          LINF                        Linfield Wildcats
#> 114    cfb          2032          ARST                Arkansas State Red Wolves
#> 115    cfb          2033          ARTE                Arkansas Tech Wonder Boys
#> 116    cfb          2038           ASP                    Assumption Greyhounds
#> 117    cfb           204          ORST                     Oregon State Beavers
#> 118    cfb          2042          AUGC                   Augustana (IL) Vikings
#> 119    cfb          2043          AUSD                   Augustana (SD) Vikings
#> 120    cfb          2044           AUR                          Aurora Spartans
#> 121    cfb          2045           AUS                             Austin 'Roos
#> 122    cfb          2046          APSU                    Austin Peay Governors
#> 123    cfb          2047          AVER                          Averett Cougars
#> 124    cfb          2049           APU                    Azusa Pacific Cougars
#> 125    cfb           205          PCOR                      Pacific (OR) Boxers
#> 126    cfb          2050          BALL                     Ball State Cardinals
#> 127    cfb          2056          BELH                         Belhaven Blazers
#> 128    cfb          2060          BENT                          Bentley Falcons
#> 129    cfb          2062          BCWV                       Bethany (WV) Bison
#> 130    cfb          2064          BTTN                     Bethel (TN) Wildcats
#> 131    cfb          2065           BCU                 Bethune-Cookman Wildcats
#> 132    cfb          2069          BHSU         Black Hills State Yellow Jackets
#> 133    cfb          2071           BBU                       Bloomsburg Huskies
#> 134    cfb          2074           BLF                         Bluffton Beavers
#> 135    cfb          2075          BOWE                     Bowie State Bulldogs
#> 136    cfb          2079           BRI                       Bridgewater Eagles
#> 137    cfb          2083          BUCK                           Bucknell Bison
#> 138    cfb          2084           BUF                            Buffalo Bulls
#> 139    cfb          2085           BSU                    Buffalo State Bengals
#> 140    cfb          2086          BTLR                          Butler Bulldogs
#> 141    cfb           209           LHU                   Lock Haven Bald Eagles
#> 142    cfb          2094           CLU                    Cal Lutheran Kingsmen
#> 143    cfb          2097           CAM                 Campbell Fighting Camels
#> 144    cfb            21          SDSU                   San Diego State Aztecs
#> 145    cfb           210          MILL                   Millersville Marauders
#> 146    cfb          2101           CAR                         Carleton Knights
#> 147    cfb          2102          CGMU                  Carnegie Mellon Tartans
#> 148    cfb          2105            CN                     Carson Newman Eagles
#> 149    cfb          2106           CCW                       Carthage Firebirds
#> 150    cfb          2107           CAT                          Catawba Indians
#> 151    cfb          2108          CATH                       Catholic Cardinals
#> 152    cfb          2110          CARK                   Central Arkansas Bears
#> 153    cfb          2115          CCSU          Central Connecticut Blue Devils
#> 154    cfb          2116           UCF                              UCF Knights
#> 155    cfb          2117           CMU               Central Michigan Chippewas
#> 156    cfb          2118           UCM                   Central Missouri Mules
#> 157    cfb          2119          CNSU                  Central State Marauders
#> 158    cfb          2120          CWAU              Central Washington Wildcats
#> 159    cfb          2121           CCO                          Centre Colonels
#> 160    cfb          2122           UCO                Central Oklahoma Bronchos
#> 161    cfb          2123          CHAD                     Chadron State Eagles
#> 162    cfb          2127          CHSO           Charleston Southern Buccaneers
#> 163    cfb          2128          UCWV            Charleston (WV) Golden Eagles
#> 164    cfb           213           PSU                 Penn State Nittany Lions
#> 165    cfb          2130          CHST                    Chicago State Cougars
#> 166    cfb          2132           CIN                      Cincinnati Bearcats
#> 167    cfb          2134          CLRN                    Clarion Golden Eagles
#> 168    cfb          2141           COE                              Coe Kohawks
#> 169    cfb          2142          COLG                          Colgate Raiders
#> 170    cfb          2146          CMIN      Colorado School of Mines Orediggers
#> 171    cfb          2148          CONC                   Concord Mountain Lions
#> 172    cfb           215           SRU                   Slippery Rock The Rock
#> 173    cfb          2151           CUC                Concordia Chicago Cougars
#> 174    cfb          2152          CCMN                   Concordia (MN) Cobbers
#> 175    cfb          2155          CNIA                        Cornell (IA) Rams
#> 176    cfb           216          SUSQ                  Susquehanna River Hawks
#> 177    cfb          2166           DAV                        Davidson Wildcats
#> 178    cfb          2168           DAY                            Dayton Flyers
#> 179    cfb          2169           DSU                   Delaware State Hornets
#> 180    cfb          2170          DLST                    Delta State Statesmen
#> 181    cfb          2171           DSN                          Denison Big Red
#> 182    cfb          2175          DKSN                     Dickinson Red Devils
#> 183    cfb           218           TEM                              Temple Owls
#> 184    cfb          2181          DRKE                           Drake Bulldogs
#> 185    cfb          2184           DUQ                           Duquesne Dukes
#> 186    cfb          2188           ESU                East Stroudsburg Warriors
#> 187    cfb           219          PENN                     Pennsylvania Quakers
#> 188    cfb          2191          ECNU                      East Central Tigers
#> 189    cfb          2193          ETSU          East Tennessee State Buccaneers
#> 190    cfb          2194          ETBU                East Texas Baptist Tigers
#> 191    cfb          2197           EIU                Eastern Illinois Panthers
#> 192    cfb          2198           EKU                Eastern Kentucky Colonels
#> 193    cfb          2199           EMU                  Eastern Michigan Eagles
#> 194    cfb          2201          ENMU            Eastern New Mexico Greyhounds
#> 195    cfb          2202          EORE                           Eastern Oregon
#> 196    cfb          2205          EDBR                  Edinboro Fighting Scots
#> 197    cfb          2206           EDW                     Edward Waters Tigers
#> 198    cfb          2207          ECSU             Elizabeth City State Vikings
#> 199    cfb           221          PITT                      Pittsburgh Panthers
#> 200    cfb          2210          ELON                             Elon Phoenix
#> 201    cfb          2213           EHC                      Emory & Henry Wasps
#> 202    cfb          2214          EMSU                    Emporia State Hornets
#> 203    cfb           222          VILL                       Villanova Wildcats
#> 204    cfb          2220          FAYU               Fayetteville State Broncos
#> 205    cfb          2221          FDUF                       FDU Florham Devils
#> 206    cfb          2222          FRST                    Ferris State Bulldogs
#> 207    cfb          2224            UF                           Findlay Oilers
#> 208    cfb          2226           FAU                    Florida Atlantic Owls
#> 209    cfb          2229           FIU           Florida International Panthers
#> 210    cfb           223          WCHT                 West Chester Golden Rams
#> 211    cfb          2230           FOR                             Fordham Rams
#> 212    cfb          2231          FHSU                         Fort Hays Tigers
#> 213    cfb          2232          FVSU               Fort Valley State Wildcats
#> 214    cfb          2233          FRKL                       Franklin Grizzlies
#> 215    cfb          2234           FMC            Franklin & Marshall Diplomats
#> 216    cfb          2237          FLWC                      Fort Lewis Skyhawks
#> 217    cfb          2241          GWEB            Gardner-Webb Runnin' Bulldogs
#> 218    cfb          2242           GEN                  Geneva Golden Tornadoes
#> 219    cfb          2244           GMU         George Mason University Patriots
#> 220    cfb          2245          GTKY                   Georgetown (KY) Tigers
#> 221    cfb          2247          GAST                   Georgia State Panthers
#> 222    cfb          2248          GTYB                       Gettysburg Bullets
#> 223    cfb          2249          GVLS                 Glenville State Pioneers
#> 224    cfb           225          BRWN                              Brown Bears
#> 225    cfb          2254     GRANDVIEW                       Des Moines Vikings
#> 226    cfb          2256          GRNB                         Greensboro Pride
#> 227    cfb          2257          GRNV                      Greenville Panthers
#> 228    cfb          2258          GLFD                         Guilford Quakers
#> 229    cfb          2261          HAMP                          Hampton Pirates
#> 230    cfb          2262          HNVR                         Hanover Panthers
#> 231    cfb          2264          HARD                           Harding Bisons
#> 232    cfb           227           URI                        Rhode Island Rams
#> 233    cfb          2271          HSTU                  Henderson State Reddies
#> 234    cfb          2273          HLDL                       Hillsdale Chargers
#> 235    cfb          2274          HIRM                           Hiram Terriers
#> 236    cfb          2277           HCU                Houston Christian Huskies
#> 237    cfb           228          CLEM                           Clemson Tigers
#> 238    cfb          2280          HUSS                            Husson Eagles
#> 239    cfb          2283          BNIL                  Benedictine (IL) Eagles
#> 240    cfb          2286          ILLC                Illinois College Blueboys
#> 241    cfb          2287          ILST                  Illinois State Redbirds
#> 242    cfb          2291           IUP            IU Pennsylvania Crimson Hawks
#> 243    cfb          2292          INDY                  Indianapolis Greyhounds
#> 244    cfb          2294          IOWA                            Iowa Hawkeyes
#> 245    cfb          2296          JKST                     Jackson State Tigers
#> 246    cfb            23          SJSU                  San José State Spartans
#> 247    cfb          2302           JCU                John Carroll Blue Streaks
#> 248    cfb          2304          JCSU            Johnson C. Smith Golden Bulls
#> 249    cfb          2305            KU                          Kansas Jayhawks
#> 250    cfb          2306           KSU                    Kansas State Wildcats
#> 251    cfb          2309          KENT                Kent State Golden Flashes
#> 252    cfb           231           FUR                          Furman Paladins
#> 253    cfb          2310          KYSU                Kentucky State Thorobreds
#> 254    cfb          2315          KUTZ                    Kutztown Golden Bears
#> 255    cfb          2316           KWC               Kentucky Wesleyan Panthers
#> 256    cfb          2318           ULV                        La Verne Leopards
#> 257    cfb          2320           LAM                          Lamar Cardinals
#> 258    cfb          2323          LANE                     Lane College Dragons
#> 259    cfb          2324          LNGT                           Langston Lions
#> 260    cfb          2329           LEH                    Lehigh Mountain Hawks
#> 261    cfb           233          SDAK                     South Dakota Coyotes
#> 262    cfb          2331          LENR                       Lenoir Rhyne Bears
#> 263    cfb          2333            LC               Lewis & Clark River Otters
#> 264    cfb          2335           LIB                           Liberty Flames
#> 265    cfb          2339          LNPA                       Lincoln (PA) Lions
#> 266    cfb          2341           LIU            Long Island University Sharks
#> 267    cfb          2348            LT                  Louisiana Tech Bulldogs
#> 268    cfb           235           MEM                           Memphis Tigers
#> 269    cfb          2354          LYCO                        Lycoming Warriors
#> 270    cfb          2359           MAC                         Macalester Scots
#> 271    cfb           236           UTC                         Chattanooga Mocs
#> 272    cfb          2362          MNCH                      Manchester Spartans
#> 273    cfb          2364          MNST                Minnesota State Mavericks
#> 274    cfb          2365          MNFD                   Mansfield Mountaineers
#> 275    cfb          2368          MRST                         Marist Red Foxes
#> 276    cfb          2369           MHU                          Mars Hill Lions
#> 277    cfb           237          UNNY                    Union Garnet Chargers
#> 278    cfb          2371           MHB             Mary Hardin Baylor Crusaders
#> 279    cfb          2373          MCTN                     Maryville (TN) Scots
#> 280    cfb          2377           MCN                          McNeese Cowboys
#> 281    cfb           238           VAN                    Vanderbilt Commodores
#> 282    cfb          2382           MER                             Mercer Bears
#> 283    cfb          2383           MMA                 Merchant Marine Mariners
#> 284    cfb          2385          MERC                        Mercyhurst Lakers
#> 285    cfb           239           BAY                             Baylor Bears
#> 286    cfb          2390           MIA                         Miami Hurricanes
#> 287    cfb          2392           MTU                    Michigan Tech Huskies
#> 288    cfb          2393          MTSU            Middle Tennessee Blue Raiders
#> 289    cfb          2394          MIDB                      Middlebury Panthers
#> 290    cfb          2396          MILE                       Miles Golden Bears
#> 291    cfb          2398          MLSP                          Millsaps Majors
#> 292    cfb          2399          MNMO                 Minnesota Morris Cougars
#> 293    cfb            24          STAN                        Stanford Cardinal
#> 294    cfb          2400          MVSU    Mississippi Valley State Delta Devils
#> 295    cfb          2402          MS&T                      Missouri S&T Miners
#> 296    cfb          2403          MSSU            Missouri Southern State Lions
#> 297    cfb          2405          MONM                           Monmouth Hawks
#> 298    cfb           241           MCM                        McMurry War Hawks
#> 299    cfb          2413          MORE                    Morehead State Eagles
#> 300    cfb          2415          MORG                       Morgan State Bears
#> 301    cfb          2416          MNGS                       Morningside Chiefs
#> 302    cfb          2419           MSJ                    Mount St Joseph Lions
#> 303    cfb           242          RICE                                Rice Owls
#> 304    cfb          2422          MUHL                         Muhlenberg Mules
#> 305    cfb          2424          NMHU             New Mexico Highlands Cowboys
#> 306    cfb          2426          NAVY                          Navy Midshipmen
#> 307    cfb          2428          NCCU            North Carolina Central Eagles
#> 308    cfb          2429           CLT                          Charlotte 49ers
#> 309    cfb          2433           ULM                       UL Monroe Warhawks
#> 310    cfb          2438          NEBK                  Nebraska Kearney Lopers
#> 311    cfb          2439          UNLV                              UNLV Rebels
#> 312    cfb          2440           NEV                         Nevada Wolf Pack
#> 313    cfb          2441          NHVN                       New Haven Chargers
#> 314    cfb          2442          TCNJ          The College of New Jersey Lions
#> 315    cfb          2444          NBRY                          Newberry Wolves
#> 316    cfb          2447          NICH                        Nicholls Colonels
#> 317    cfb          2448          NCAT                North Carolina A&T Aggies
#> 318    cfb          2449          NDSU                 North Dakota State Bison
#> 319    cfb           245          TA&M                         Texas A&M Aggies
#> 320    cfb          2450          NORF                   Norfolk State Spartans
#> 321    cfb          2453           UNA                      North Alabama Lions
#> 322    cfb          2458          UNCO                  Northern Colorado Bears
#> 323    cfb          2459           NIU                Northern Illinois Huskies
#> 324    cfb           246           JUN                           Juniata Eagles
#> 325    cfb          2460           UNI                   Northern Iowa Panthers
#> 326    cfb          2464           NAU             Northern Arizona Lumberjacks
#> 327    cfb          2466          NWST                Northwestern State Demons
#> 328    cfb          2467          NWCH                           Norwich Cadets
#> 329    cfb           247          KNGS                          King's Monarchs
#> 330    cfb          2477          OHDU                  Ohio Dominican Panthers
#> 331    cfb           248           HOU                          Houston Cougars
#> 332    cfb          2483           ORE                             Oregon Ducks
#> 333    cfb          2486          PCLT                   Pacific Lutheran Lutes
#> 334    cfb          2487          PACE                             Pace Setters
#> 335    cfb           249           UNT                   North Texas Mean Green
#> 336    cfb            25           CAL                  California Golden Bears
#> 337    cfb          2502          PRST                   Portland State Vikings
#> 338    cfb          2504            PV                Prairie View A&M Panthers
#> 339    cfb          2506          PRES                   Presbyterian Blue Hose
#> 340    cfb          2508           PUG                      Puget Sound Loggers
#> 341    cfb          2509           PUR                      Purdue Boilermakers
#> 342    cfb           251           TEX                          Texas Longhorns
#> 343    cfb          2516           RMC            Randolph Macon Yellow Jackets
#> 344    cfb          2519          RHDS                              Rhodes Lynx
#> 345    cfb           252           BYU                              BYU Cougars
#> 346    cfb          2523           RMU                  Robert Morris Colonials
#> 347    cfb          2524           RFU                         Rockford Regents
#> 348    cfb          2528           RPI                     Rensselaer Engineers
#> 349    cfb          2529           SHU                    Sacred Heart Pioneers
#> 350    cfb           253           SUU               Southern Utah Thunderbirds
#> 351    cfb          2532           SAL                      Salisbury Sea Gulls
#> 352    cfb          2534          SHSU                     Sam Houston Bearkats
#> 353    cfb          2535           SAM                         Samford Bulldogs
#> 354    cfb           254          UTAH                                Utah Utes
#> 355    cfb          2542           SAV                    Savannah State Tigers
#> 356    cfb          2545          SELA                       SE Louisiana Lions
#> 357    cfb          2546          SEMO        Southeast Missouri State Redhawks
#> 358    cfb           255          KNOX                        Knox Prairie Fire
#> 359    cfb          2551          SHAW                               Shaw Bears
#> 360    cfb          2553          SEWA                           Sewanee Tigers
#> 361    cfb          2557          USCG                        Coast Guard Bears
#> 362    cfb          2559          SHIP                     Shippensburg Raiders
#> 363    cfb           256           JMU                      James Madison Dukes
#> 364    cfb          2560          SHOU                            Shorter Hawks
#> 365    cfb          2564          SCIA                       Simpson (IA) Storm
#> 366    cfb          2567           SMU                             SMU Mustangs
#> 367    cfb          2568           SAR             Southern Arkansas Muleriders
#> 368    cfb          2569          SCST            South Carolina State Bulldogs
#> 369    cfb           257          RICH                         Richmond Spiders
#> 370    cfb          2570          CSUP                 CSU Pueblo ThunderWolves
#> 371    cfb          2571          SDST           South Dakota State Jackrabbits
#> 372    cfb          2572           USM              Southern Miss Golden Eagles
#> 373    cfb          2579            SC                 South Carolina Gamecocks
#> 374    cfb           258           UVA                       Virginia Cavaliers
#> 375    cfb          2582           SOU                         Southern Jaguars
#> 376    cfb          2583          SCTS          Southern Connecticut State Owls
#> 377    cfb          2584           SOR                  Southern Oregon Raiders
#> 378    cfb          2586          SWBU               Southwest Baptist Bearcats
#> 379    cfb          2587          SWMS       Southwest Minnesota State Mustangs
#> 380    cfb          2588           SWU                   Southwestern U Pirates
#> 381    cfb           259            VT                     Virginia Tech Hokies
#> 382    cfb          2591          STAM                St. Ambrose Fighting Bees
#> 383    cfb          2595          SFIL         St. Francis (IL) Fighting Saints
#> 384    cfb          2598          SFPA                  Saint Francis Red Flash
#> 385    cfb            26          UCLA                              UCLA Bruins
#> 386    cfb          2600          STJM               Saint John's (MN) Johnnies
#> 387    cfb          2614           SVC                   Saint Vincent Bearcats
#> 388    cfb          2617           SFA            Stephen F. Austin Lumberjacks
#> 389    cfb          2619          STBK                    Stony Brook Seawolves
#> 390    cfb           262           LFC                    Lake Forest Foresters
#> 391    cfb          2623          MOST                     Missouri State Bears
#> 392    cfb          2627           TAR                    Tarleton State Texans
#> 393    cfb          2628           TCU                         TCU Horned Frogs
#> 394    cfb           263           LOR                            Loras Duhawks
#> 395    cfb          2630           UTM                       UT Martin Skyhawks
#> 396    cfb          2633          TENN                     Tennessee Volunteers
#> 397    cfb          2634          TNST                   Tennessee State Tigers
#> 398    cfb          2635          TNTC             Tennessee Tech Golden Eagles
#> 399    cfb          2636          UTSA                         UTSA Roadrunners
#> 400    cfb          2637          TXCL                     Texas College Steers
#> 401    cfb          2638          UTEP                              UTEP Miners
#> 402    cfb          2639          TXLU                  Texas Lutheran Bulldogs
#> 403    cfb           264          WASH                       Washington Huskies
#> 404    cfb          2640          TXSO                    Texas Southern Tigers
#> 405    cfb          2641           TTU                   Texas Tech Red Raiders
#> 406    cfb          2643           CIT                     The Citadel Bulldogs
#> 407    cfb          2644           THI                            Thiel Tomcats
#> 408    cfb          2646          TMOR                       Thomas More Saints
#> 409    cfb          2649           TOL                           Toledo Rockets
#> 410    cfb           265           WSU                 Washington State Cougars
#> 411    cfb          2651          TRNE                            Trine Thunder
#> 412    cfb          2653          TROY                             Troy Trojans
#> 413    cfb          2654          TRST                    Truman State Bulldogs
#> 414    cfb          2655          TULN                        Tulane Green Wave
#> 415    cfb          2657          TUSK                   Tuskegee Golden Tigers
#> 416    cfb          2658          TAMK           Texas A&M-Kingsville Javelinas
#> 417    cfb           266          BELO                        Beloit Buccaneers
#> 418    cfb          2667          URSN                            Ursinus Bears
#> 419    cfb          2673          VALD                   Valdosta State Blazers
#> 420    cfb          2674           VAL                       Valparaiso Beacons
#> 421    cfb          2676           VUU                  Virginia Union Panthers
#> 422    cfb          2678           VMI                              VMI Keydets
#> 423    cfb           268           LAW                         Lawrence Vikings
#> 424    cfb          2681           WAG                          Wagner Seahawks
#> 425    cfb          2682          WLSH                          Walsh Cavaliers
#> 426    cfb          2685          WTBG                         Wartburg Knights
#> 427    cfb          2686           W&J        Washington & Jefferson Presidents
#> 428    cfb          2687          WSBN                        Washburn Ichabods
#> 429    cfb          2688           W&L              Washington and Lee Generals
#> 430    cfb          2692           WEB                     Weber State Wildcats
#> 431    cfb          2695           UWA                      West Alabama Tigers
#> 432    cfb          2698           WGA                      West Georgia Wolves
#> 433    cfb          2699           WLU                 West Liberty Hilltoppers
#> 434    cfb          2700           MCD                    McDaniel Green Terror
#> 435    cfb          2701           UMW                 Montana Western Bulldogs
#> 436    cfb          2702           WNE         Western New England Golden Bears
#> 437    cfb          2703          WNMU              Western New Mexico Mustangs
#> 438    cfb          2704          WTAM                     West Texas Buffaloes
#> 439    cfb          2706          WVUT                    WVU Tech Golden Bears
#> 440    cfb          2707          WVSU       West Virginia State Yellow Jackets
#> 441    cfb           271           UWO                 Wisconsin Oshkosh Titans
#> 442    cfb          2710           WIU            Western Illinois Leathernecks
#> 443    cfb          2711           WMU                 Western Michigan Broncos
#> 444    cfb          2714          WCOL            Western Colorado Mountaineers
#> 445    cfb          2717           WCU              Western Carolina Catamounts
#> 446    cfb           272           UWP           Wisconsin Platteville Pioneers
#> 447    cfb          2721          WHIW                        Whitworth Pirates
#> 448    cfb          2723          UWRF            Wisconsin River Falls Falcons
#> 449    cfb          2725          WIDE                            Widener Pride
#> 450    cfb          2729           W&M                     William & Mary Tribe
#> 451    cfb          2731           WLM                            Williams Ephs
#> 452    cfb          2733          WCOH         Wilmington (OH) Fightin' Quakers
#> 453    cfb          2736          WSSU                 Winston-Salem State Rams
#> 454    cfb          2738          UWEC            Wisconsin Eau Claire Blugolds
#> 455    cfb           274          UMMA                  Maine Maritime Mariners
#> 456    cfb          2740           UWL               Wisconsin La Crosse Eagles
#> 457    cfb          2741           WLC              Wisconsin Lutheran Warriors
#> 458    cfb          2743          UWSP         Wisconsin Stevens Point Pointers
#> 459    cfb          2744          UWST              Wisconsin Stout Blue Devils
#> 460    cfb          2745           UWW            Wisconsin Whitewater Warhawks
#> 461    cfb          2746          WITT                        Wittenberg Tigers
#> 462    cfb          2747           WOF                         Wofford Terriers
#> 463    cfb          2748           WOO                   Wooster Fighting Scots
#> 464    cfb          2749           WPI                            WPI Engineers
#> 465    cfb           275           WIS                        Wisconsin Badgers
#> 466    cfb          2751           WYO                          Wyoming Cowboys
#> 467    cfb          2754           YSU                Youngstown State Penguins
#> 468    cfb          2755          GRAM                         Grambling Tigers
#> 469    cfb          2757          BERR                            Berry Vikings
#> 470    cfb          2758          HWPU              Howard Payne Yellow Jackets
#> 471    cfb           276          MRSH                 Marshall Thundering Herd
#> 472    cfb           277           WVU               West Virginia Mountaineers
#> 473    cfb          2771          MRMK                       Merrimack Warriors
#> 474    cfb          2776          SALV                    Salve Regina Seahawks
#> 475    cfb          2779           USL                      St. Lawrence Saints
#> 476    cfb           278          FRES                    Fresno State Bulldogs
#> 477    cfb          2781           BRO                  Brockport Golden Eagles
#> 478    cfb          2782          NYCL                SUNY Cortland Red Dragons
#> 479    cfb          2790          ALBI                           Albion Britons
#> 480    cfb          2800          ALMA                               Alma Scots
#> 481    cfb          2802          BUMN                       Bethel (MN) Royals
#> 482    cfb          2803           BRY                          Bryant Bulldogs
#> 483    cfb          2804          CWAN                             Chowan Hawks
#> 484    cfb          2805          CKGA                   Clark Atlanta Panthers
#> 485    cfb          2808           DVU                   Delaware Valley Aggies
#> 486    cfb          2810           HSU                   Hardin Simmons Cowboys
#> 487    cfb          2812          HOPE                     Hope Flying Dutchmen
#> 488    cfb          2815           LIN                         Lindenwood Lions
#> 489    cfb          2816           MCK                       McKendree Bearcats
#> 490    cfb          2817          MSUM            Minnesota St Moorhead Dragons
#> 491    cfb          2818          MCST                Montclair State Red Hawks
#> 492    cfb           282          INST                  Indiana State Sycamores
#> 493    cfb          2822           NGU            North Greenville Trailblazers
#> 494    cfb          2823          NWOK                Northwestern (OK) Rangers
#> 495    cfb          2824          OPSU                Oklahoma Panhandle Aggies
#> 496    cfb          2825           QUI                             Quincy Hawks
#> 497    cfb          2827           ROW                              Rowan Profs
#> 498    cfb          2828          SHEN                       Shenandoah Hornets
#> 499    cfb          2830          SANS                       Saint Anselm Hawks
#> 500    cfb          2832          STNC                St. Norbert Green Knights
#> 501    cfb          2834          SRST                     Sul Ross State Lobos
#> 502    cfb          2837          ETAM                     East Texas A&M Lions
#> 503    cfb          2838          TIFF                           Tiffin Dragons
#> 504    cfb          2839          TUSC                        Tusculum Pioneers
#> 505    cfb           284           STO                       Stonehill Skyhawks
#> 506    cfb          2842          UVAW                       UVA Wise Cavaliers
#> 507    cfb          2843          WCSU         Western Connecticut State Wolves
#> 508    cfb          2844          WSNE                Wayne State (NE) Wildcats
#> 509    cfb          2845          WAYN                Waynesburg Yellow Jackets
#> 510    cfb          2848          WORU                    Western Oregon Wolves
#> 511    cfb          2849          WCPA                  Westminster (PA) Titans
#> 512    cfb          2850          WHTR                           Whittier Poets
#> 513    cfb          2851          WNST                    Winona State Warriors
#> 514    cfb          2858          CAPA                  California (PA) Vulcans
#> 515    cfb           286           NCW North Carolina Wesleyan Battling Bishops
#> 516    cfb          2871          KEAN                             Kean Cougars
#> 517    cfb          2876          LNMO                 Lincoln (MO) Blue Tigers
#> 518    cfb          2880          MOBU                Missouri Baptist Spartans
#> 519    cfb          2882          UNCP                      UNC Pembroke Braves
#> 520    cfb          2884          NICC                            Nichols Bison
#> 521    cfb          2886           NWD                   Northwood Timberwolves
#> 522    cfb          2888           OBU                  Ouachita Baptist Tigers
#> 523    cfb          2891           RIP                          Ripon Red Hawks
#> 524    cfb          2894           SFU                      Sioux Falls Cougars
#> 525    cfb          2896          SOVA                Southern Virginia Knights
#> 526    cfb            29          REDL                        Redlands Bulldogs
#> 527    cfb           290          GASO                  Georgia Southern Eagles
#> 528    cfb          2900          STMN                       St. Thomas Tommies
#> 529    cfb          2909          WFST                     Westfield State Owls
#> 530    cfb           291            MU                       Methodist Monarchs
#> 531    cfb          2911           WJC                 William Jewell Cardinals
#> 532    cfb          2912          WPEN                   William Penn Statesmen
#> 533    cfb          2913           BRE                         Brevard Tornados
#> 534    cfb          2916           UIW                 Incarnate Word Cardinals
#> 535    cfb          2919          MNIL             Monmouth (IL) Fighting Scots
#> 536    cfb           292           RGV            UT Rio Grande Valley Vaqueros
#> 537    cfb          2923          POPI                   Pomona Pitzer Sagehens
#> 538    cfb          2927          SOSU     Southwestern Oklahoma State Bulldogs
#> 539    cfb           293          VTSC         Vermont State Castleton Spartans
#> 540    cfb          2930          WLMT                      Willamette Bearcats
#> 541    cfb          2938          HNTC                         Huntingdon Hawks
#> 542    cfb          2940           LIV                   Livingstone Blue Bears
#> 543    cfb           295           ODU                    Old Dominion Monarchs
#> 544    cfb          2951          NYMT                 SUNY Maritime Privateers
#> 545    cfb          2963          CWRU            Case Western Reserve Spartans
#> 546    cfb          2964          CNTC                    Central College Dutch
#> 547    cfb          2967          FRSU                    Framingham State Rams
#> 548    cfb          2968           GAC         Gustavus Adolphus Golden Gusties
#> 549    cfb          2969          MISE                     Misericordia Cougars
#> 550    cfb           297           HSC                    Hampden Sydney Tigers
#> 551    cfb          2970           WPU                William Paterson Pioneers
#> 552    cfb          2972          PLYM                  Plymouth State Panthers
#> 553    cfb          2974          SHEP                            Shepherd Rams
#> 554    cfb          2977          TCCT                     Trinity (CT) Bantams
#> 555    cfb          2980           OWU           Ohio Wesleyan Battling Bishops
#> 556    cfb          2986          FMSU                   Fairmont State Falcons
#> 557    cfb            30           USC                              USC Trojans
#> 558    cfb           301           USD                        San Diego Toreros
#> 559    cfb           302           UCD                          UC Davis Aggies
#> 560    cfb           304          IDST                      Idaho State Bengals
#> 561    cfb           306          ILWU                 Illinois Wesleyan Titans
#> 562    cfb          3066           CSP          Concordia St. Paul Golden Bears
#> 563    cfb          3071           NCC          North Central College Cardinals
#> 564    cfb           308           ASH                           Ashland Eagles
#> 565    cfb           309            UL                  Louisiana Ragin' Cajuns
#> 566    cfb          3101           UTU                   Utah Tech Trailblazers
#> 567    cfb           311            ME                        Maine Black Bears
#> 568    cfb          3110          NYMS                SUNY Morrisville Mustangs
#> 569    cfb          3112           CNU             Christopher Newport Captains
#> 570    cfb          3162          AFST                    Alfred State Pioneers
#> 571    cfb           317          MRTT                        Marietta Pioneers
#> 572    cfb           319          OKBU                   Oklahoma Baptist Bison
#> 573    cfb            32           CRU                    Carroll (WI) Pioneers
#> 574    cfb           322           LAF                       Lafayette Leopards
#> 575    cfb           323           MOR                      Moravian Greyhounds
#> 576    cfb          3237          HVCC                             Troy Vikings
#> 577    cfb           324           CCU            Coastal Carolina Chanticleers
#> 578    cfb          3253         COLLE                         Charlotte Saints
#> 579    cfb           326          TXST                      Texas State Bobcats
#> 580    cfb           328           USU                        Utah State Aggies
#> 581    cfb            33          CLBY                        Colby White Mules
#> 582    cfb           330           VSU                   Virginia State Trojans
#> 583    cfb           331           EWU                Eastern Washington Eagles
#> 584    cfb           332           MSK               Muskingum Fighting Muskies
#> 585    cfb           333           ALA                     Alabama Crimson Tide
#> 586    cfb           336          WSCT                  Wesleyan (CT) Cardinals
#> 587    cfb           338          KENN                      Kennesaw State Owls
#> 588    cfb           340           BOW                      Bowdoin Polar Bears
#> 589    cfb           341          FSTU                  Frostburg State Bobcats
#> 590    cfb           344          MSST               Mississippi State Bulldogs
#> 591    cfb           348           HAM                    Hamilton Continentals
#> 592    cfb           349          ARMY                       Army Black Knights
#> 593    cfb           351          WINU                         Wingate Bulldogs
#> 594    cfb           352           KNY                              Kenyon Owls
#> 595    cfb           354           UOO                            Olivet Comets
#> 596    cfb           356           ILL                 Illinois Fighting Illini
#> 597    cfb           359          OTTB                      Otterbein Cardinals
#> 598    cfb            36           CSU                      Colorado State Rams
#> 599    cfb           365          ALFR                            Alfred Saxons
#> 600    cfb           366            FC                          Ferrum Panthers
#> 601    cfb           367          GANN                    Gannon Golden Knights
#> 602    cfb           374          STJF                St. John Fisher Cardinals
#> 603    cfb           375           CSS                   St. Scholastica Saints
#> 604    cfb           379          MDAR                 UMass Dartmouth Corsairs
#> 605    cfb            38          COLO                       Colorado Buffaloes
#> 606    cfb           386          TUTX                      Trinity (TX) Tigers
#> 607    cfb           388           LVC           Lebanon Valley Flying Dutchmen
#> 608    cfb           389           UIU                      Upper Iowa Peacocks
#> 609    cfb           390          UTIC                           Utica Pioneers
#> 610    cfb           391           OBE                           Oberlin Yeomen
#> 611    cfb           396          WCIL                     Wheaton (IL) Thunder
#> 612    cfb           398          WILK                          Wilkes Colonels
#> 613    cfb           399          UALB                      UAlbany Great Danes
#> 614    cfb            40            CC                           Curry Colonels
#> 615    cfb           402          WORC                  Worcester State Lancers
#> 616    cfb           409           CUW                   Concordia (WI) Falcons
#> 617    cfb            41          CONN                            UConn Huskies
#> 618    cfb           411          CHAP                         Chapman Panthers
#> 619    cfb           415           GFU                        George Fox Bruins
#> 620    cfb           417          GLDT                          Gallaudet Bison
#> 621    cfb           418           HDX                         Hendrix Warriors
#> 622    cfb           424          CAPU                           Capital Comets
#> 623    cfb           425           NSU                    Northern State Wolves
#> 624    cfb           426           UMU               Mount Union Purple Raiders
#> 625    cfb           427          OHNU                Ohio Northern Polar Bears
#> 626    cfb            43          YALE                            Yale Bulldogs
#> 627    cfb           433          WCMO               Westminster (MO) Blue Jays
#> 628    cfb           437          LKER                          Lake Erie Storm
#> 629    cfb           446           MLC                    Martin Luther Knights
#> 630    cfb           452          ENDC                           Endicott Gulls
#> 631    cfb           455          WVWC           West Virginia Wesleyan Bobcats
#> 632    cfb            46          GTWN                         Georgetown Hoyas
#> 633    cfb            47           HOW                             Howard Bison
#> 634    cfb           471          STVS                       Stevenson Mustangs
#> 635    cfb            48           DEL                       Delaware Blue Hens
#> 636    cfb            49           DBQ                         Dubuque Spartans
#> 637    cfb           490           BEN                          Benedict Tigers
#> 638    cfb             5           UAB                              UAB Blazers
#> 639    cfb            50          FAMU                     Florida A&M Rattlers
#> 640    cfb           509          CRWN                             Crown Polars
#> 641    cfb           512         DAKOT          Dakota State University Trojans
#> 642    cfb            52           FSU                  Florida State Seminoles
#> 643    cfb           530           GRC           Graceland University Graceland
#> 644    cfb           548           LGC                        LaGrange Panthers
#> 645    cfb            55          JXST             Jacksonville State Gamecocks
#> 646    cfb           559          MARY             University of Mary Marauders
#> 647    cfb            56          STET                          Stetson Hatters
#> 648    cfb           568          MINS                      Minot State Beavers
#> 649    cfb            57           FLA                           Florida Gators
#> 650    cfb            58           USF                      South Florida Bulls
#> 651    cfb           583           UNW                 Northwestern (MN) Eagles
#> 652    cfb            59            GT              Georgia Tech Yellow Jackets
#> 653    cfb             6           USA                    South Alabama Jaguars
#> 654    cfb            60          MRHO                  Morehouse Maroon Tigers
#> 655    cfb            61           UGA                         Georgia Bulldogs
#> 656    cfb           611          SEHI                      Seton Hill Griffins
#> 657    cfb           613          SDMT           South Dakota Mines Hardrockers
#> 658    cfb            62           HAW                 Hawai'i Rainbow Warriors
#> 659    cfb            63           BVU                      Buena Vista Beavers
#> 660    cfb          6353          LKLD                         Lakeland Muskies
#> 661    cfb            65          GRNL                        Grinnell Pioneers
#> 662    cfb            66           ISU                      Iowa State Cyclones
#> 663    cfb            67          LUTH                             Luther Norse
#> 664    cfb            68          BOIS                      Boise State Broncos
#> 665    cfb          6845           NWU         Nebraska Wesleyan Prairie Wolves
#> 666    cfb             7           AMH                         Amherst Mammoths
#> 667    cfb            70          IDHO                            Idaho Vandals
#> 668    cfb            72          ELMH                        Elmhurst Bluejays
#> 669    cfb            74          MILK                        Millikin Big Blue
#> 670    cfb            75           NPU                       North Park Vikings
#> 671    cfb            77            NU                    Northwestern Wildcats
#> 672    cfb            79           SIU                Southern Illinois Salukis
#> 673    cfb             8           ARK                      Arkansas Razorbacks
#> 674    cfb            80           CHI                          Chicago Maroons
#> 675    cfb            81           SPR                        Springfield Pride
#> 676    cfb            83           DPU                            DePauw Tigers
#> 677    cfb            84            IU                         Indiana Hoosiers
#> 678    cfb            86          RHIT           Rose Hulman Fightin' Engineers
#> 679    cfb            87            ND                Notre Dame Fighting Irish
#> 680    cfb            89           WAB                     Wabash Little Giants
#> 681    cfb             9           ASU                 Arizona State Sun Devils
#> 682    cfb            90          PTSU                 Pittsburg State Gorillas
#> 683    cfb            93           MUR                      Murray State Racers
#> 684    cfb            96            UK                        Kentucky Wildcats
#> 685    cfb            97           LOU                     Louisville Cardinals
#> 686    cfb            98           WKU             Western Kentucky Hilltoppers
#> 687    cfb            99           LSU                               LSU Tigers
#> 688    cfb           AAC           AAC                      American Conference
#> 689    cfb           ACC           ACC                Atlantic Coast Conference
#> 690    cfb        Big 12        Big 12                        Big 12 Conference
#> 691    cfb       Big Sky       Big Sky                       Big Sky Conference
#> 692    cfb       Big Ten       Big Ten                       Big Ten Conference
#> 693    cfb           CAA           CAA             Coastal Athletic Association
#> 694    cfb          CUSA          CUSA                           Conference USA
#> 695    cfb    FBS Indep.    FBS Indep.                         FBS Independents
#> 696    cfb    FCS Indep.    FCS Indep.                         FCS Independents
#> 697    cfb           Ivy           Ivy                               Ivy League
#> 698    cfb           MAC           MAC                  Mid-American Conference
#> 699    cfb          MEAC          MEAC          Mid-Eastern Athletic Conference
#> 700    cfb          MVFC          MVFC      Missouri Valley Football Conference
#> 701    cfb Mountain West Mountain West                 Mountain West Conference
#> 702    cfb           NEC           NEC                     Northeast Conference
#> 703    cfb           OVC           OVC                   Ohio Valley Conference
#> 704    cfb        Pac-12        Pac-12                        Pac-12 Conference
#> 705    cfb       Patriot       Patriot                           Patriot League
#> 706    cfb       Pioneer       Pioneer                  Pioneer Football League
#> 707    cfb           SEC           SEC                  Southeastern Conference
#> 708    cfb          SWAC          SWAC         Southwestern Athletic Conference
#> 709    cfb         SoCon         SoCon                      Southern Conference
#> 710    cfb     Southland     Southland                     Southland Conference
#> 711    cfb      Sun Belt      Sun Belt                      Sun Belt Conference
#> 712    cfb           WAC           WAC              Western Athletic Conference
#>           short_name                    location    program
#> 1             Eureka                      Eureka   football
#> 2     Centenary (LA)              Centenary (LA)   football
#> 3            Erskine                     Erskine   football
#> 4     Boston College              Boston College   football
#> 5         Holy Cross                  Holy Cross   football
#> 6            Harvard                     Harvard   football
#> 7                MIT                         MIT   football
#> 8      Colorado Mesa               Colorado Mesa   football
#> 9      Mass Maritime               Mass Maritime   football
#> 10      West Florida                West Florida   football
#> 11    UT Prmian Basn            UT Permian Basin   football
#> 12              Dean                        Dean   football
#> 13        St Andrews                 St. Andrews   football
#> 14          Alvernia                    Alvernia   football
#> 15       New England                 New England   football
#> 16             Tufts                       Tufts   football
#> 17   Franklin Pierce             Franklin Pierce   football
#> 18          Wheeling                    Wheeling   football
#> 19             UMass               Massachusetts   football
#> 20      Fitchburg St             Fitchburg State   football
#> 21     Johns Hopkins               Johns Hopkins   football
#> 22            Towson                      Towson   football
#> 23           Arizona                     Arizona   football
#> 24          Maryland                    Maryland   football
#> 25             Bates                       Bates   football
#> 26            Barton                      Barton   football
#> 27          Keystone                    Keystone   football
#> 28        N American              North American   football
#> 29          Augsburg                    Augsburg   football
#> 30      Lincoln (CA)                Lincoln (CA)   football
#> 31      Bluefield St             Bluefield State   football
#> 32      Grand Val St          Grand Valley State   football
#> 33           Hilbert                     Hilbert   football
#> 34         Kalamazoo                   Kalamazoo   football
#> 35              Post                        Post   football
#> 36       Michigan St              Michigan State   football
#> 37           Eastern                     Eastern   football
#> 38        N Michigan           Northern Michigan   football
#> 39    Saginaw Valley        Saginaw Valley State   football
#> 40     Anderson (SC)               Anderson (SC)   football
#> 41            Calvin                      Calvin   football
#> 42          Cal Poly                    Cal Poly   football
#> 43          Michigan                    Michigan   football
#> 44     Wayne St (MI)            Wayne State (MI)   football
#> 45        Bemidji St               Bemidji State   football
#> 46           St Olaf                    St. Olaf   football
#> 47       Minn Duluth            Minnesota Duluth   football
#> 48         Minnesota                   Minnesota   football
#> 49        MO Western            Missouri Western   football
#> 50    NW Missouri St    Northwest Missouri State   football
#> 51          Missouri                    Missouri   football
#> 52     Wash St Louis        Washington St. Louis   football
#> 53          Ole Miss                    Ole Miss   football
#> 54        Grove City                  Grove City   football
#> 55        Montana St               Montana State   football
#> 56           Montana                     Montana   football
#> 57              Duke                        Duke   football
#> 58     East Carolina               East Carolina   football
#> 59          NC State                    NC State   football
#> 60    North Carolina              North Carolina   football
#> 61       Wake Forest                 Wake Forest   football
#> 62      North Dakota                North Dakota   football
#> 63          Nebraska                    Nebraska   football
#> 64         Dartmouth                   Dartmouth   football
#> 65     Sacramento St            Sacramento State   football
#> 66     New Hampshire               New Hampshire   football
#> 67           Hamline                     Hamline   football
#> 68         Princeton                   Princeton   football
#> 69           Rutgers                     Rutgers   football
#> 70     New Mexico St            New Mexico State   football
#> 71        New Mexico                  New Mexico   football
#> 72     Claremont-M-S      Claremont Mudd Scripps   football
#> 73          Columbia                    Columbia   football
#> 74           Cornell                     Cornell   football
#> 75          Hartwick                    Hartwick   football
#> 76            Hobart                      Hobart   football
#> 77            Ithaca                      Ithaca   football
#> 78    Bridgewater St           Bridgewater State   football
#> 79          Syracuse                    Syracuse   football
#> 80    Rochester (NY)              Rochester (NY)   football
#> 81      Baldwin Wall             Baldwin Wallace   football
#> 82     Bowling Green               Bowling Green   football
#> 83          Defiance            Defiance College   football
#> 84        Heidelberg                  Heidelberg   football
#> 85          Miami OH                  Miami (OH)   football
#> 86        Ohio State                  Ohio State   football
#> 87              Ohio                        Ohio   football
#> 88          NE State          Northeastern State   football
#> 89       Oklahoma St              Oklahoma State   football
#> 90    SE Oklahoma St Southeastern Oklahoma State   football
#> 91            Auburn                      Auburn   football
#> 92        S Nazarene           Southern Nazarene   football
#> 93    Abilene Chrstn           Abilene Christian   football
#> 94          Adams St                 Adams State   football
#> 95            Adrian                      Adrian   football
#> 96         Air Force                   Air Force   football
#> 97             Akron                       Akron   football
#> 98          Oklahoma                    Oklahoma   football
#> 99       Alabama A&M                 Alabama A&M   football
#> 100       Alabama St               Alabama State   football
#> 101        Albany St                Albany State   football
#> 102         Albright                    Albright   football
#> 103        Alcorn St                Alcorn State   football
#> 104        Allegheny                   Allegheny   football
#> 105            Allen                       Allen   football
#> 106            Tulsa                       Tulsa   football
#> 107   American Int'l      American International   football
#> 108    Anderson (IN)               Anderson (IN)   football
#> 109        Angelo St                Angelo State   football
#> 110        App State                   App State   football
#> 111    UA Monticello         Arkansas Monticello   football
#> 112    AR-Pine Bluff         Arkansas-Pine Bluff   football
#> 113         Linfield                    Linfield   football
#> 114      Arkansas St              Arkansas State   football
#> 115    Arkansas Tech               Arkansas Tech   football
#> 116       Assumption                  Assumption   football
#> 117        Oregon St                Oregon State   football
#> 118   Augustana (IL)              Augustana (IL)   football
#> 119   Augustana (SD)              Augustana (SD)   football
#> 120           Aurora                      Aurora   football
#> 121           Austin                      Austin   football
#> 122      Austin Peay                 Austin Peay   football
#> 123          Averett                     Averett   football
#> 124    Azusa Pacific               Azusa Pacific   football
#> 125     Pacific (OR)                Pacific (OR)   football
#> 126       Ball State                  Ball State   football
#> 127         Belhaven                    Belhaven   football
#> 128          Bentley                     Bentley   football
#> 129     Bethany (WV)                Bethany (WV)   football
#> 130      Bethel (TN)                 Bethel (TN)   football
#> 131          Bethune             Bethune-Cookman   football
#> 132   Black Hills St           Black Hills State   football
#> 133       Bloomsburg                  Bloomsburg   football
#> 134         Bluffton                    Bluffton   football
#> 135         Bowie St                 Bowie State   football
#> 136      Bridgewater                 Bridgewater   football
#> 137         Bucknell                    Bucknell   football
#> 138          Buffalo                     Buffalo   football
#> 139       Buffalo St               Buffalo State   football
#> 140           Butler                      Butler   football
#> 141       Lock Haven                  Lock Haven   football
#> 142     Cal Lutheran                Cal Lutheran   football
#> 143         Campbell                    Campbell   football
#> 144     San Diego St             San Diego State   football
#> 145     Millersville                Millersville   football
#> 146         Carleton                    Carleton   football
#> 147      Carn Mellon             Carnegie Mellon   football
#> 148    Carson Newman               Carson Newman   football
#> 149         Carthage                    Carthage   football
#> 150          Catawba                     Catawba   football
#> 151         Catholic                    Catholic   football
#> 152       C Arkansas            Central Arkansas   football
#> 153    C Connecticut         Central Connecticut   football
#> 154              UCF                         UCF   football
#> 155       C Michigan            Central Michigan   football
#> 156       C Missouri            Central Missouri   football
#> 157       Central St               Central State   football
#> 158     C Washington          Central Washington   football
#> 159           Centre                      Centre   football
#> 160       C Oklahoma            Central Oklahoma   football
#> 161       Chadron St               Chadron State   football
#> 162    Charleston So         Charleston Southern   football
#> 163    Charleston WV             Charleston (WV)   football
#> 164       Penn State                  Penn State   football
#> 165       Chicago St               Chicago State   football
#> 166       Cincinnati                  Cincinnati   football
#> 167          Clarion                     Clarion   football
#> 168              Coe                         Coe   football
#> 169          Colgate                     Colgate   football
#> 170   Colorado Mines    Colorado School of Mines   football
#> 171          Concord                     Concord   football
#> 172    Slippery Rock               Slippery Rock   football
#> 173    Concordia Chi           Concordia Chicago   football
#> 174   Concordia (MN)              Concordia (MN)   football
#> 175     Cornell (IA)                Cornell (IA)   football
#> 176      Susquehanna                 Susquehanna   football
#> 177         Davidson                    Davidson   football
#> 178           Dayton                      Dayton   football
#> 179      Delaware St              Delaware State   football
#> 180         Delta St                 Delta State   football
#> 181          Denison                     Denison   football
#> 182        Dickinson                   Dickinson   football
#> 183           Temple                      Temple   football
#> 184            Drake                       Drake   football
#> 185         Duquesne                    Duquesne   football
#> 186    E Stroudsburg            East Stroudsburg   football
#> 187             Penn                Pennsylvania   football
#> 188     East Central                East Central   football
#> 189             ETSU        East Tennessee State   football
#> 190     E TX Baptist          East Texas Baptist   football
#> 191       E Illinois            Eastern Illinois   football
#> 192       E Kentucky            Eastern Kentucky   football
#> 193       E Michigan            Eastern Michigan   football
#> 194       Eastern NM          Eastern New Mexico   football
#> 195         E Oregon              Eastern Oregon   football
#> 196         Edinboro                    Edinboro   football
#> 197    Edward Waters               Edward Waters   football
#> 198   Elizabeth City        Elizabeth City State   football
#> 199             Pitt                  Pittsburgh   football
#> 200             Elon                        Elon   football
#> 201    Emory & Henry               Emory & Henry   football
#> 202       Emporia St               Emporia State   football
#> 203        Villanova                   Villanova   football
#> 204     Fay'ville St          Fayetteville State   football
#> 205      FDU Florham                 FDU Florham   football
#> 206        Ferris St                Ferris State   football
#> 207          Findlay                     Findlay   football
#> 208              FAU            Florida Atlantic   football
#> 209              FIU       Florida International   football
#> 210     West Chester                West Chester   football
#> 211          Fordham                     Fordham   football
#> 212        Fort Hays                   Fort Hays   football
#> 213   Fort Valley St           Fort Valley State   football
#> 214         Franklin                    Franklin   football
#> 215   Franklin Marsh         Franklin & Marshall   football
#> 216       Fort Lewis                  Fort Lewis   football
#> 217     Gardner-Webb                Gardner-Webb   football
#> 218           Geneva                      Geneva   football
#> 219     George Mason     George Mason University   football
#> 220    Georgetown KY             Georgetown (KY)   football
#> 221       Georgia St               Georgia State   football
#> 222       Gettysburg                  Gettysburg   football
#> 223     Glenville St             Glenville State   football
#> 224            Brown                       Brown   football
#> 225       Grand View                  Des Moines   football
#> 226       Greensboro                  Greensboro   football
#> 227       Greenville                  Greenville   football
#> 228         Guilford                    Guilford   football
#> 229          Hampton                     Hampton   football
#> 230          Hanover                     Hanover   football
#> 231          Harding                     Harding   football
#> 232     Rhode Island                Rhode Island   football
#> 233     Henderson St             Henderson State   football
#> 234        Hillsdale                   Hillsdale   football
#> 235            Hiram                       Hiram   football
#> 236    Hou Christian           Houston Christian   football
#> 237          Clemson                     Clemson   football
#> 238           Husson                      Husson   football
#> 239   Benedictine IL            Benedictine (IL)   football
#> 240     Illinois Col            Illinois College   football
#> 241      Illinois St              Illinois State   football
#> 242          IU Penn             IU Pennsylvania   football
#> 243     Indianapolis                Indianapolis   football
#> 244             Iowa                        Iowa   football
#> 245       Jackson St               Jackson State   football
#> 246      San José St              San José State   football
#> 247     John Carroll                John Carroll   football
#> 248   Johnson C Smth            Johnson C. Smith   football
#> 249           Kansas                      Kansas   football
#> 250        Kansas St                Kansas State   football
#> 251       Kent State                  Kent State   football
#> 252           Furman                      Furman   football
#> 253      Kentucky St              Kentucky State   football
#> 254         Kutztown                    Kutztown   football
#> 255      KY Wesleyan           Kentucky Wesleyan   football
#> 256         La Verne                    La Verne   football
#> 257            Lamar                       Lamar   football
#> 258     Lane College                Lane College   football
#> 259         Langston                    Langston   football
#> 260           Lehigh                      Lehigh   football
#> 261     South Dakota                South Dakota   football
#> 262     Lenoir Rhyne                Lenoir Rhyne   football
#> 263    Lewis & Clark               Lewis & Clark   football
#> 264          Liberty                     Liberty   football
#> 265     Lincoln (PA)                Lincoln (PA)   football
#> 266      Long Island      Long Island University   football
#> 267   Louisiana Tech              Louisiana Tech   football
#> 268          Memphis                     Memphis   football
#> 269         Lycoming                    Lycoming   football
#> 270       Macalester                  Macalester   football
#> 271      Chattanooga                 Chattanooga   football
#> 272       Manchester                  Manchester   football
#> 273     Minnesota St             Minnesota State   football
#> 274        Mansfield                   Mansfield   football
#> 275           Marist                      Marist   football
#> 276        Mars Hill                   Mars Hill   football
#> 277            Union                       Union   football
#> 278      Mary Hardin          Mary Hardin Baylor   football
#> 279   Maryville (TN)              Maryville (TN)   football
#> 280          McNeese                     McNeese   football
#> 281       Vanderbilt                  Vanderbilt   football
#> 282           Mercer                      Mercer   football
#> 283     Merch Marine             Merchant Marine   football
#> 284       Mercyhurst                  Mercyhurst   football
#> 285           Baylor                      Baylor   football
#> 286            Miami                       Miami   football
#> 287    Michigan Tech               Michigan Tech   football
#> 288             MTSU            Middle Tennessee   football
#> 289       Middlebury                  Middlebury   football
#> 290            Miles                       Miles   football
#> 291         Millsaps                    Millsaps   football
#> 292      Minn Morris            Minnesota Morris   football
#> 293         Stanford                    Stanford   football
#> 294   Miss Valley St    Mississippi Valley State   football
#> 295     Missouri S&T                Missouri S&T   football
#> 296   Missouri So St     Missouri Southern State   football
#> 297         Monmouth                    Monmouth   football
#> 298          McMurry                     McMurry   football
#> 299      Morehead St              Morehead State   football
#> 300        Morgan St                Morgan State   football
#> 301      Morningside                 Morningside   football
#> 302     Mt St Joseph             Mount St Joseph   football
#> 303             Rice                        Rice   football
#> 304       Muhlenberg                  Muhlenberg   football
#> 305     NM Highlands        New Mexico Highlands   football
#> 306             Navy                        Navy   football
#> 307       NC Central      North Carolina Central   football
#> 308        Charlotte                   Charlotte   football
#> 309        UL Monroe                   UL Monroe   football
#> 310       NE Kearney            Nebraska Kearney   football
#> 311             UNLV                        UNLV   football
#> 312           Nevada                      Nevada   football
#> 313        New Haven                   New Haven   football
#> 314    College of NJ   The College of New Jersey   football
#> 315         Newberry                    Newberry   football
#> 316         Nicholls                    Nicholls   football
#> 317           NC A&T          North Carolina A&T   football
#> 318      N Dakota St          North Dakota State   football
#> 319        Texas A&M                   Texas A&M   football
#> 320       Norfolk St               Norfolk State   football
#> 321    North Alabama               North Alabama   football
#> 322       N Colorado           Northern Colorado   football
#> 323       N Illinois           Northern Illinois   football
#> 324          Juniata                     Juniata   football
#> 325    Northern Iowa               Northern Iowa   football
#> 326        N Arizona            Northern Arizona   football
#> 327     N'Western St          Northwestern State   football
#> 328          Norwich                     Norwich   football
#> 329           King's                      King's   football
#> 330   Ohio Dominican              Ohio Dominican   football
#> 331          Houston                     Houston   football
#> 332           Oregon                      Oregon   football
#> 333     Pac Lutheran            Pacific Lutheran   football
#> 334             Pace                        Pace   football
#> 335      North Texas                 North Texas   football
#> 336       California                  California   football
#> 337      Portland St              Portland State   football
#> 338     Prairie View            Prairie View A&M   football
#> 339     Presbyterian                Presbyterian   football
#> 340      Puget Sound                 Puget Sound   football
#> 341           Purdue                      Purdue   football
#> 342            Texas                       Texas   football
#> 343   Randolph Macon              Randolph Macon   football
#> 344           Rhodes                      Rhodes   football
#> 345              BYU                         BYU   football
#> 346    Robert Morris               Robert Morris   football
#> 347         Rockford                    Rockford   football
#> 348       Rensselaer                  Rensselaer   football
#> 349     Sacred Heart                Sacred Heart   football
#> 350    Southern Utah               Southern Utah   football
#> 351        Salisbury                   Salisbury   football
#> 352      Sam Houston                 Sam Houston   football
#> 353          Samford                     Samford   football
#> 354             Utah                        Utah   football
#> 355      Savannah St              Savannah State   football
#> 356     SE Louisiana                SE Louisiana   football
#> 357      SE Missouri    Southeast Missouri State   football
#> 358             Knox                        Knox   football
#> 359             Shaw                        Shaw   football
#> 360          Sewanee                     Sewanee   football
#> 361      Coast Guard                 Coast Guard   football
#> 362     Shippensburg                Shippensburg   football
#> 363    James Madison               James Madison   football
#> 364          Shorter                     Shorter   football
#> 365     Simpson (IA)                Simpson (IA)   football
#> 366              SMU                         SMU   football
#> 367       S Arkansas           Southern Arkansas   football
#> 368         SC State        South Carolina State   football
#> 369         Richmond                    Richmond   football
#> 370       CSU Pueblo                  CSU Pueblo   football
#> 371      S Dakota St          South Dakota State   football
#> 372    Southern Miss               Southern Miss   football
#> 373   South Carolina              South Carolina   football
#> 374         Virginia                    Virginia   football
#> 375         Southern                    Southern   football
#> 376        S Conn St  Southern Connecticut State   football
#> 377         S Oregon             Southern Oregon   football
#> 378       SW Baptist           Southwest Baptist   football
#> 379       SW Minn St   Southwest Minnesota State   football
#> 380     Southwestern              Southwestern U   football
#> 381    Virginia Tech               Virginia Tech   football
#> 382       St Ambrose                 St. Ambrose   football
#> 383    St Francis IL            St. Francis (IL)   football
#> 384    Saint Francis               Saint Francis   football
#> 385             UCLA                        UCLA   football
#> 386    St Johns (MN)           Saint John's (MN)   football
#> 387    Saint Vincent               Saint Vincent   football
#> 388        SF Austin           Stephen F. Austin   football
#> 389      Stony Brook                 Stony Brook   football
#> 390      Lake Forest                 Lake Forest   football
#> 391      Missouri St              Missouri State   football
#> 392      Tarleton St              Tarleton State   football
#> 393              TCU                         TCU   football
#> 394            Loras                       Loras   football
#> 395        UT Martin                   UT Martin   football
#> 396        Tennessee                   Tennessee   football
#> 397     Tennessee St             Tennessee State   football
#> 398   Tennessee Tech              Tennessee Tech   football
#> 399             UTSA                        UTSA   football
#> 400    Texas College               Texas College   football
#> 401             UTEP                        UTEP   football
#> 402   Texas Lutheran              Texas Lutheran   football
#> 403       Washington                  Washington   football
#> 404   Texas Southern              Texas Southern   football
#> 405       Texas Tech                  Texas Tech   football
#> 406      The Citadel                 The Citadel   football
#> 407            Thiel                       Thiel   football
#> 408      Thomas More                 Thomas More   football
#> 409           Toledo                      Toledo   football
#> 410    Washington St            Washington State   football
#> 411            Trine                       Trine   football
#> 412             Troy                        Troy   football
#> 413        Truman St                Truman State   football
#> 414           Tulane                      Tulane   football
#> 415         Tuskegee                    Tuskegee   football
#> 416   TAMU-Kingsvlle        Texas A&M-Kingsville   football
#> 417           Beloit                      Beloit   football
#> 418          Ursinus                     Ursinus   football
#> 419      Valdosta St              Valdosta State   football
#> 420       Valparaiso                  Valparaiso   football
#> 421   Virginia Union              Virginia Union   football
#> 422              VMI                         VMI   football
#> 423         Lawrence                    Lawrence   football
#> 424           Wagner                      Wagner   football
#> 425            Walsh                       Walsh   football
#> 426         Wartburg                    Wartburg   football
#> 427      Wash & Jeff      Washington & Jefferson   football
#> 428         Washburn                    Washburn   football
#> 429     Wash and Lee          Washington and Lee   football
#> 430         Weber St                 Weber State   football
#> 431     West Alabama                West Alabama   football
#> 432     West Georgia                West Georgia   football
#> 433     West Liberty                West Liberty   football
#> 434         McDaniel                    McDaniel   football
#> 435       MT Western             Montana Western   football
#> 436    W New England         Western New England   football
#> 437       Western NM          Western New Mexico   football
#> 438       West Texas                  West Texas   football
#> 439         WVU Tech                    WVU Tech   football
#> 440    W Virginia St         West Virginia State   football
#> 441       UW-Oshkosh           Wisconsin Oshkosh   football
#> 442       W Illinois            Western Illinois   football
#> 443       W Michigan            Western Michigan   football
#> 444       W Colorado            Western Colorado   football
#> 445       W Carolina            Western Carolina   football
#> 446   UW-Platteville       Wisconsin Platteville   football
#> 447        Whitworth                   Whitworth   football
#> 448   UW-River Falls       Wisconsin River Falls   football
#> 449          Widener                     Widener   football
#> 450   William & Mary              William & Mary   football
#> 451         Williams                    Williams   football
#> 452    Wilmington OH             Wilmington (OH)   football
#> 453    Winston-Salem         Winston-Salem State   football
#> 454    UW-Eau Claire        Wisconsin Eau Claire   football
#> 455   Maine Maritime              Maine Maritime   football
#> 456     UW-La Crosse         Wisconsin La Crosse   football
#> 457    Wisc Lutheran          Wisconsin Lutheran   football
#> 458    UW-Stevens Pt     Wisconsin Stevens Point   football
#> 459         UW-Stout             Wisconsin Stout   football
#> 460    UW-Whitewater        Wisconsin Whitewater   football
#> 461       Wittenberg                  Wittenberg   football
#> 462          Wofford                     Wofford   football
#> 463          Wooster                     Wooster   football
#> 464              WPI                         WPI   football
#> 465        Wisconsin                   Wisconsin   football
#> 466          Wyoming                     Wyoming   football
#> 467    Youngstown St            Youngstown State   football
#> 468        Grambling                   Grambling   football
#> 469            Berry                       Berry   football
#> 470     Howard Payne                Howard Payne   football
#> 471         Marshall                    Marshall   football
#> 472    West Virginia               West Virginia   football
#> 473        Merrimack                   Merrimack   football
#> 474     Salve Regina                Salve Regina   football
#> 475      St Lawrence                St. Lawrence   football
#> 476        Fresno St                Fresno State   football
#> 477        Brockport                   Brockport   football
#> 478    SUNY Cortland               SUNY Cortland   football
#> 479           Albion                      Albion   football
#> 480             Alma                        Alma   football
#> 481      Bethel (MN)                 Bethel (MN)   football
#> 482           Bryant                      Bryant   football
#> 483           Chowan                      Chowan   football
#> 484       Clark (GA)               Clark Atlanta   football
#> 485          Del Val             Delaware Valley   football
#> 486   Hardin Simmons              Hardin Simmons   football
#> 487             Hope                        Hope   football
#> 488       Lindenwood                  Lindenwood   football
#> 489        McKendree                   McKendree   football
#> 490    Minn Moorhead       Minnesota St Moorhead   football
#> 491        Montclair             Montclair State   football
#> 492       Indiana St               Indiana State   football
#> 493     N Greenville            North Greenville   football
#> 494   N'Western (OK)           Northwestern (OK)   football
#> 495     OK Panhandle          Oklahoma Panhandle   football
#> 496           Quincy                      Quincy   football
#> 497            Rowan                       Rowan   football
#> 498       Shenandoah                  Shenandoah   football
#> 499     Saint Anselm                Saint Anselm   football
#> 500       St Norbert                 St. Norbert   football
#> 501      Sul Ross St              Sul Ross State   football
#> 502   East Texas A&M              East Texas A&M   football
#> 503           Tiffin                      Tiffin   football
#> 504         Tusculum                    Tusculum   football
#> 505        Stonehill                   Stonehill   football
#> 506         UVA Wise                    UVA Wise   football
#> 507         WestConn   Western Connecticut State   football
#> 508    Wayne St (NE)            Wayne State (NE)   football
#> 509       Waynesburg                  Waynesburg   football
#> 510      West Oregon              Western Oregon   football
#> 511   Westminster PA            Westminster (PA)   football
#> 512         Whittier                    Whittier   football
#> 513        Winona St                Winona State   football
#> 514         Cal (PA)             California (PA)   football
#> 515      NC Wesleyan     North Carolina Wesleyan   football
#> 516             Kean                        Kean   football
#> 517     Lincoln (MO)                Lincoln (MO)   football
#> 518    Missouri Bapt            Missouri Baptist   football
#> 519     UNC Pembroke                UNC Pembroke   football
#> 520          Nichols                     Nichols   football
#> 521        Northwood                   Northwood   football
#> 522    Ouachita Bapt            Ouachita Baptist   football
#> 523            Ripon                       Ripon   football
#> 524      Sioux Falls                 Sioux Falls   football
#> 525       S Virginia           Southern Virginia   football
#> 526         Redlands                    Redlands   football
#> 527      GA Southern            Georgia Southern   football
#> 528        St Thomas                  St. Thomas   football
#> 529     Westfield St             Westfield State   football
#> 530        Methodist                   Methodist   football
#> 531   William Jewell              William Jewell   football
#> 532     William Penn                William Penn   football
#> 533          Brevard                     Brevard   football
#> 534   Incarnate Word              Incarnate Word   football
#> 535    Monmouth (IL)               Monmouth (IL)   football
#> 536             <NA>                        <NA>   football
#> 537    Pomona Pitzer               Pomona Pitzer   football
#> 538   SW Oklahoma St Southwestern Oklahoma State   football
#> 539   VTSU Castleton     Vermont State Castleton   football
#> 540       Willamette                  Willamette   football
#> 541       Huntingdon                  Huntingdon   football
#> 542      Livingstone                 Livingstone   football
#> 543     Old Dominion                Old Dominion   football
#> 544    SUNY Maritime               SUNY Maritime   football
#> 545     Case Western        Case Western Reserve   football
#> 546      Central Col             Central College   football
#> 547    Framingham St            Framingham State   football
#> 548         Gustavus           Gustavus Adolphus   football
#> 549     Misericordia                Misericordia   football
#> 550   Hampden Sydney              Hampden Sydney   football
#> 551      Wm Paterson            William Paterson   football
#> 552      Plymouth St              Plymouth State   football
#> 553         Shepherd                    Shepherd   football
#> 554     Trinity (CT)                Trinity (CT)   football
#> 555    Ohio Wesleyan               Ohio Wesleyan   football
#> 556      Fairmont St              Fairmont State   football
#> 557              USC                         USC   football
#> 558        San Diego                   San Diego   football
#> 559         UC Davis                    UC Davis   football
#> 560         Idaho St                 Idaho State   football
#> 561      IL Wesleyan           Illinois Wesleyan   football
#> 562   Concordia St P          Concordia St. Paul   football
#> 563   N Central (IL)       North Central College   football
#> 564          Ashland                     Ashland   football
#> 565        Louisiana                   Louisiana   football
#> 566        Utah Tech                   Utah Tech   football
#> 567            Maine                       Maine   football
#> 568   SUNY Morrisvle            SUNY Morrisville   football
#> 569    Chris Newport         Christopher Newport   football
#> 570        Alfred St                Alfred State   football
#> 571         Marietta                    Marietta   football
#> 572       OK Baptist            Oklahoma Baptist   football
#> 573     Carroll (WI)                Carroll (WI)   football
#> 574        Lafayette                   Lafayette   football
#> 575         Moravian                    Moravian   football
#> 576           Hudson                        Troy   football
#> 577          Coastal            Coastal Carolina   football
#> 578         Faith NC                   Charlotte   football
#> 579         Texas St                 Texas State   football
#> 580       Utah State                  Utah State   football
#> 581            Colby                       Colby   football
#> 582      Virginia St              Virginia State   football
#> 583     E Washington          Eastern Washington   football
#> 584        Muskingum                   Muskingum   football
#> 585          Alabama                     Alabama   football
#> 586    Wesleyan (CT)               Wesleyan (CT)   football
#> 587      Kennesaw St              Kennesaw State   football
#> 588          Bowdoin                     Bowdoin   football
#> 589     Frostburg St             Frostburg State   football
#> 590   Mississippi St           Mississippi State   football
#> 591         Hamilton                    Hamilton   football
#> 592             Army                        Army   football
#> 593          Wingate                     Wingate   football
#> 594           Kenyon                      Kenyon   football
#> 595           Olivet                      Olivet   football
#> 596         Illinois                    Illinois   football
#> 597        Otterbein                   Otterbein   football
#> 598      Colorado St              Colorado State   football
#> 599           Alfred                      Alfred   football
#> 600           Ferrum                      Ferrum   football
#> 601           Gannon                      Gannon   football
#> 602   St John Fisher             St. John Fisher   football
#> 603   St Scholastica             St. Scholastica   football
#> 604    UMass Dartmth             UMass Dartmouth   football
#> 605         Colorado                    Colorado   football
#> 606     Trinity (TX)                Trinity (TX)   football
#> 607   Lebanon Valley              Lebanon Valley   football
#> 608       Upper Iowa                  Upper Iowa   football
#> 609            Utica                       Utica   football
#> 610          Oberlin                     Oberlin   football
#> 611     Wheaton (IL)                Wheaton (IL)   football
#> 612           Wilkes                      Wilkes   football
#> 613          UAlbany                     UAlbany   football
#> 614            Curry                       Curry   football
#> 615     Worcester St             Worcester State   football
#> 616   Concordia (WI)              Concordia (WI)   football
#> 617            UConn                       UConn   football
#> 618          Chapman                     Chapman   football
#> 619       George Fox                  George Fox   football
#> 620        Gallaudet                   Gallaudet   football
#> 621          Hendrix                     Hendrix   football
#> 622          Capital                     Capital   football
#> 623      Northern St              Northern State   football
#> 624         Mt Union                 Mount Union   football
#> 625    Ohio Northern               Ohio Northern   football
#> 626             Yale                        Yale   football
#> 627   Westminster MO            Westminster (MO)   football
#> 628        Lake Erie                   Lake Erie   football
#> 629    Martin Luther               Martin Luther   football
#> 630         Endicott                    Endicott   football
#> 631      WV Wesleyan      West Virginia Wesleyan   football
#> 632       Georgetown                  Georgetown   football
#> 633           Howard                      Howard   football
#> 634        Stevenson                   Stevenson   football
#> 635         Delaware                    Delaware   football
#> 636          Dubuque                     Dubuque   football
#> 637         Benedict                    Benedict   football
#> 638              UAB                         UAB   football
#> 639      Florida A&M                 Florida A&M   football
#> 640            Crown                       Crown   football
#> 641        Dakota St     Dakota State University   football
#> 642       Florida St               Florida State   football
#> 643        Graceland        Graceland University   football
#> 644         LaGrange                    LaGrange   football
#> 645        Jax State          Jacksonville State   football
#> 646            UMary          University of Mary   football
#> 647          Stetson                     Stetson   football
#> 648         Minot St                 Minot State   football
#> 649          Florida                     Florida   football
#> 650    South Florida               South Florida   football
#> 651   N'Western (MN)           Northwestern (MN)   football
#> 652     Georgia Tech                Georgia Tech   football
#> 653    South Alabama               South Alabama   football
#> 654        Morehouse                   Morehouse   football
#> 655          Georgia                     Georgia   football
#> 656       Seton Hill                  Seton Hill   football
#> 657         SD Mines          South Dakota Mines   football
#> 658          Hawai'i                     Hawai'i   football
#> 659      Buena Vista                 Buena Vista   football
#> 660         Lakeland                    Lakeland   football
#> 661         Grinnell                    Grinnell   football
#> 662       Iowa State                  Iowa State   football
#> 663           Luther                      Luther   football
#> 664         Boise St                 Boise State   football
#> 665      NE Wesleyan           Nebraska Wesleyan   football
#> 666          Amherst                     Amherst   football
#> 667            Idaho                       Idaho   football
#> 668         Elmhurst                    Elmhurst   football
#> 669         Millikin                    Millikin   football
#> 670       North Park                  North Park   football
#> 671     Northwestern                Northwestern   football
#> 672       S Illinois           Southern Illinois   football
#> 673         Arkansas                    Arkansas   football
#> 674          Chicago                     Chicago   football
#> 675      Springfield                 Springfield   football
#> 676           DePauw                      DePauw   football
#> 677          Indiana                     Indiana   football
#> 678      Rose Hulman                 Rose Hulman   football
#> 679       Notre Dame                  Notre Dame   football
#> 680           Wabash                      Wabash   football
#> 681       Arizona St               Arizona State   football
#> 682     Pittsburg St             Pittsburg State   football
#> 683        Murray St                Murray State   football
#> 684         Kentucky                    Kentucky   football
#> 685       Louisville                  Louisville   football
#> 686       Western KY            Western Kentucky   football
#> 687              LSU                         LSU   football
#> 688         American                        <NA> conference
#> 689              ACC                        <NA> conference
#> 690           Big 12                        <NA> conference
#> 691          Big Sky                        <NA> conference
#> 692          Big Ten                        <NA> conference
#> 693              CAA                        <NA> conference
#> 694   Conference USA                        <NA> conference
#> 695 FBS Independents                        <NA> conference
#> 696 FCS Independents                        <NA> conference
#> 697              Ivy                        <NA> conference
#> 698     Mid-American                        <NA> conference
#> 699             MEAC                        <NA> conference
#> 700  Missouri Valley                        <NA> conference
#> 701    Mountain West                        <NA> conference
#> 702        Northeast                        <NA> conference
#> 703              OVC                        <NA> conference
#> 704           Pac-12                        <NA> conference
#> 705   Patriot League                        <NA> conference
#> 706          Pioneer                        <NA> conference
#> 707              SEC                        <NA> conference
#> 708             SWAC                        <NA> conference
#> 709         Southern                        <NA> conference
#> 710        Southland                        <NA> conference
#> 711         Sun Belt                        <NA> conference
#> 712              WAC                        <NA> conference
#>                        conference_id
#> 1                           cfb:nacc
#> 2   cfb:southern-collegiate-athletic
#> 3                      cfb:carolinas
#> 4                            cfb:acc
#> 5                        cfb:patriot
#> 6                            cfb:ivy
#> 7                         cfb:newmac
#> 8                 cfb:rocky-mountain
#> 9                          cfb:mscac
#> 10                           cfb:uac
#> 11                     cfb:lone-star
#> 12                         cfb:mscac
#> 13                              <NA>
#> 14                  cfb:mid-atlantic
#> 15            cfb:commonwealth-coast
#> 16                        cfb:nescac
#> 17                  cfb:northeast-10
#> 18                 cfb:mountain-east
#> 19                           cfb:mac
#> 20                         cfb:mscac
#> 21                    cfb:centennial
#> 22                           cfb:caa
#> 23                        cfb:big-12
#> 24                       cfb:big-ten
#> 25                        cfb:nescac
#> 26                     cfb:carolinas
#> 27               cfb:d3-independents
#> 28                              <NA>
#> 29                     cfb:minnesota
#> 30               cfb:d2-independents
#> 31                          cfb:ciaa
#> 32                         cfb:gliac
#> 33                      cfb:empire-8
#> 34                      cfb:michigan
#> 35                  cfb:northeast-10
#> 36                       cfb:big-ten
#> 37                  cfb:mid-atlantic
#> 38                         cfb:gliac
#> 39                         cfb:gliac
#> 40                cfb:south-atlantic
#> 41                      cfb:michigan
#> 42                       cfb:big-sky
#> 43                       cfb:big-ten
#> 44                         cfb:gliac
#> 45                  cfb:northern-sun
#> 46                     cfb:minnesota
#> 47                  cfb:northern-sun
#> 48                       cfb:big-ten
#> 49                   cfb:mid-america
#> 50                   cfb:mid-america
#> 51                           cfb:sec
#> 52                   cfb:north-coast
#> 53                           cfb:sec
#> 54                    cfb:presidents
#> 55                       cfb:big-sky
#> 56                       cfb:big-sky
#> 57                           cfb:acc
#> 58                      cfb:american
#> 59                           cfb:acc
#> 60                           cfb:acc
#> 61                           cfb:acc
#> 62                          cfb:mvfc
#> 63                       cfb:big-ten
#> 64                           cfb:ivy
#> 65                           cfb:mac
#> 66                           cfb:caa
#> 67                     cfb:minnesota
#> 68                           cfb:ivy
#> 69                       cfb:big-ten
#> 70                          cfb:cusa
#> 71                 cfb:mountain-west
#> 72                         cfb:sciac
#> 73                           cfb:ivy
#> 74                           cfb:ivy
#> 75                      cfb:empire-8
#> 76                cfb:liberty-league
#> 77                cfb:liberty-league
#> 78                         cfb:mscac
#> 79                           cfb:acc
#> 80                cfb:liberty-league
#> 81                          cfb:ohio
#> 82                           cfb:mac
#> 83                     cfb:heartland
#> 84                          cfb:ohio
#> 85                           cfb:mac
#> 86                       cfb:big-ten
#> 87                           cfb:mac
#> 88               cfb:d2-independents
#> 89                        cfb:big-12
#> 90                cfb:great-american
#> 91                           cfb:sec
#> 92                cfb:great-american
#> 93                           cfb:uac
#> 94                cfb:rocky-mountain
#> 95                      cfb:michigan
#> 96                 cfb:mountain-west
#> 97                           cfb:mac
#> 98                           cfb:sec
#> 99                          cfb:swac
#> 100                         cfb:swac
#> 101                         cfb:siac
#> 102                 cfb:mid-atlantic
#> 103                         cfb:swac
#> 104                   cfb:presidents
#> 105                         cfb:siac
#> 106                     cfb:american
#> 107                 cfb:northeast-10
#> 108                    cfb:heartland
#> 109                    cfb:lone-star
#> 110                     cfb:sun-belt
#> 111               cfb:great-american
#> 112                         cfb:swac
#> 113                    cfb:northwest
#> 114                     cfb:sun-belt
#> 115               cfb:great-american
#> 116                 cfb:northeast-10
#> 117                       cfb:pac-12
#> 118                         cfb:cciw
#> 119                 cfb:northern-sun
#> 120                         cfb:nacc
#> 121 cfb:southern-collegiate-athletic
#> 122                          cfb:uac
#> 123                 cfb:old-dominion
#> 124                        cfb:sciac
#> 125                    cfb:northwest
#> 126                          cfb:mac
#> 127                    cfb:usa-south
#> 128                 cfb:northeast-10
#> 129                   cfb:presidents
#> 130                             <NA>
#> 131                         cfb:swac
#> 132               cfb:rocky-mountain
#> 133  cfb:pennsylvania-state-athletic
#> 134                    cfb:heartland
#> 135                         cfb:ciaa
#> 136                 cfb:old-dominion
#> 137                      cfb:patriot
#> 138                          cfb:mac
#> 139               cfb:liberty-league
#> 140                      cfb:pioneer
#> 141  cfb:pennsylvania-state-athletic
#> 142                        cfb:sciac
#> 143                          cfb:caa
#> 144                       cfb:pac-12
#> 145  cfb:pennsylvania-state-athletic
#> 146                    cfb:minnesota
#> 147                   cfb:presidents
#> 148               cfb:south-atlantic
#> 149                         cfb:cciw
#> 150               cfb:south-atlantic
#> 151          cfb:landmark-conference
#> 152                          cfb:uac
#> 153                          cfb:nec
#> 154                       cfb:big-12
#> 155                          cfb:mac
#> 156                  cfb:mid-america
#> 157                         cfb:siac
#> 158                    cfb:lone-star
#> 159            cfb:southern-athletic
#> 160                  cfb:mid-america
#> 161               cfb:rocky-mountain
#> 162                          cfb:ovc
#> 163                cfb:mountain-east
#> 164                      cfb:big-ten
#> 165             cfb:fcs-independents
#> 166                       cfb:big-12
#> 167  cfb:pennsylvania-state-athletic
#> 168              cfb:american-rivers
#> 169                      cfb:patriot
#> 170               cfb:rocky-mountain
#> 171                cfb:mountain-east
#> 172  cfb:pennsylvania-state-athletic
#> 173                         cfb:nacc
#> 174                    cfb:minnesota
#> 175                      cfb:midwest
#> 176          cfb:landmark-conference
#> 177                      cfb:pioneer
#> 178                      cfb:pioneer
#> 179                         cfb:meac
#> 180                   cfb:gulf-south
#> 181                  cfb:north-coast
#> 182                   cfb:centennial
#> 183                     cfb:american
#> 184                      cfb:pioneer
#> 185                          cfb:nec
#> 186  cfb:pennsylvania-state-athletic
#> 187                          cfb:ivy
#> 188               cfb:great-american
#> 189                     cfb:southern
#> 190           cfb:american-southwest
#> 191                          cfb:ovc
#> 192                          cfb:uac
#> 193                          cfb:mac
#> 194                    cfb:lone-star
#> 195                             <NA>
#> 196  cfb:pennsylvania-state-athletic
#> 197                         cfb:siac
#> 198                         cfb:ciaa
#> 199                          cfb:acc
#> 200                          cfb:caa
#> 201               cfb:south-atlantic
#> 202                  cfb:mid-america
#> 203                      cfb:patriot
#> 204                         cfb:ciaa
#> 205                 cfb:mid-atlantic
#> 206                        cfb:gliac
#> 207       cfb:great-midwest-athletic
#> 208                     cfb:american
#> 209                         cfb:cusa
#> 210  cfb:pennsylvania-state-athletic
#> 211                      cfb:patriot
#> 212                  cfb:mid-america
#> 213                         cfb:siac
#> 214                    cfb:heartland
#> 215                   cfb:centennial
#> 216               cfb:rocky-mountain
#> 217                          cfb:ovc
#> 218                   cfb:presidents
#> 219                             <NA>
#> 220                             <NA>
#> 221                     cfb:sun-belt
#> 222                   cfb:centennial
#> 223                cfb:mountain-east
#> 224                          cfb:ivy
#> 225                             <NA>
#> 226                    cfb:usa-south
#> 227                cfb:upper-midwest
#> 228                 cfb:old-dominion
#> 229                          cfb:caa
#> 230                    cfb:heartland
#> 231               cfb:great-american
#> 232                          cfb:caa
#> 233               cfb:great-american
#> 234       cfb:great-midwest-athletic
#> 235                   cfb:presidents
#> 236                    cfb:southland
#> 237                          cfb:acc
#> 238           cfb:commonwealth-coast
#> 239                         cfb:nacc
#> 240                      cfb:midwest
#> 241                         cfb:mvfc
#> 242  cfb:pennsylvania-state-athletic
#> 243                  cfb:great-lakes
#> 244                      cfb:big-ten
#> 245                         cfb:swac
#> 246                cfb:mountain-west
#> 247                         cfb:ohio
#> 248                         cfb:ciaa
#> 249                       cfb:big-12
#> 250                       cfb:big-12
#> 251                          cfb:mac
#> 252                     cfb:southern
#> 253                         cfb:siac
#> 254  cfb:pennsylvania-state-athletic
#> 255       cfb:great-midwest-athletic
#> 256                        cfb:sciac
#> 257                    cfb:southland
#> 258                         cfb:siac
#> 259                             <NA>
#> 260                      cfb:patriot
#> 261                         cfb:mvfc
#> 262               cfb:south-atlantic
#> 263                    cfb:northwest
#> 264                         cfb:cusa
#> 265                         cfb:ciaa
#> 266                          cfb:nec
#> 267                     cfb:sun-belt
#> 268                     cfb:american
#> 269          cfb:landmark-conference
#> 270                    cfb:minnesota
#> 271                     cfb:southern
#> 272                    cfb:heartland
#> 273                 cfb:northern-sun
#> 274                             <NA>
#> 275                      cfb:pioneer
#> 276               cfb:south-atlantic
#> 277               cfb:liberty-league
#> 278           cfb:american-southwest
#> 279                    cfb:usa-south
#> 280                    cfb:southland
#> 281                          cfb:sec
#> 282                     cfb:southern
#> 283                       cfb:newmac
#> 284                          cfb:nec
#> 285                       cfb:big-12
#> 286                          cfb:acc
#> 287                        cfb:gliac
#> 288                         cfb:cusa
#> 289                       cfb:nescac
#> 290                         cfb:siac
#> 291            cfb:southern-athletic
#> 292                cfb:upper-midwest
#> 293                          cfb:acc
#> 294                         cfb:swac
#> 295                  cfb:great-lakes
#> 296                  cfb:mid-america
#> 297                          cfb:caa
#> 298           cfb:american-southwest
#> 299                      cfb:pioneer
#> 300                         cfb:meac
#> 301                             <NA>
#> 302                    cfb:heartland
#> 303                     cfb:american
#> 304                   cfb:centennial
#> 305               cfb:rocky-mountain
#> 306                     cfb:american
#> 307                         cfb:meac
#> 308                     cfb:american
#> 309                     cfb:sun-belt
#> 310                  cfb:mid-america
#> 311                cfb:mountain-west
#> 312                cfb:mountain-west
#> 313                          cfb:nec
#> 314                   cfb:new-jersey
#> 315               cfb:south-atlantic
#> 316                    cfb:southland
#> 317                          cfb:caa
#> 318                cfb:mountain-west
#> 319                          cfb:sec
#> 320                         cfb:meac
#> 321                          cfb:uac
#> 322                      cfb:big-sky
#> 323                cfb:mountain-west
#> 324          cfb:landmark-conference
#> 325                         cfb:mvfc
#> 326                      cfb:big-sky
#> 327                    cfb:southland
#> 328                       cfb:newmac
#> 329                 cfb:mid-atlantic
#> 330       cfb:great-midwest-athletic
#> 331                       cfb:big-12
#> 332                      cfb:big-ten
#> 333                    cfb:northwest
#> 334                 cfb:northeast-10
#> 335                     cfb:american
#> 336                          cfb:acc
#> 337                      cfb:big-sky
#> 338                         cfb:swac
#> 339                      cfb:pioneer
#> 340                    cfb:northwest
#> 341                      cfb:big-ten
#> 342                          cfb:sec
#> 343                 cfb:old-dominion
#> 344            cfb:southern-athletic
#> 345                       cfb:big-12
#> 346                          cfb:nec
#> 347                         cfb:nacc
#> 348               cfb:liberty-league
#> 349                          cfb:caa
#> 350                      cfb:big-sky
#> 351                   cfb:new-jersey
#> 352                         cfb:cusa
#> 353                     cfb:southern
#> 354                       cfb:big-12
#> 355                         cfb:siac
#> 356                    cfb:southland
#> 357                          cfb:ovc
#> 358                      cfb:midwest
#> 359                         cfb:ciaa
#> 360            cfb:southern-athletic
#> 361                       cfb:newmac
#> 362  cfb:pennsylvania-state-athletic
#> 363                     cfb:sun-belt
#> 364                    cfb:carolinas
#> 365              cfb:american-rivers
#> 366                          cfb:acc
#> 367               cfb:great-american
#> 368                         cfb:meac
#> 369                      cfb:patriot
#> 370               cfb:rocky-mountain
#> 371                         cfb:mvfc
#> 372                     cfb:sun-belt
#> 373                          cfb:sec
#> 374                          cfb:acc
#> 375                         cfb:swac
#> 376                 cfb:northeast-10
#> 377                             <NA>
#> 378                  cfb:great-lakes
#> 379                 cfb:northern-sun
#> 380            cfb:southern-athletic
#> 381                          cfb:acc
#> 382                             <NA>
#> 383                             <NA>
#> 384                   cfb:presidents
#> 385                      cfb:big-ten
#> 386                    cfb:minnesota
#> 387                   cfb:presidents
#> 388                    cfb:southland
#> 389                          cfb:caa
#> 390                      cfb:midwest
#> 391                         cfb:cusa
#> 392                          cfb:uac
#> 393                       cfb:big-12
#> 394              cfb:american-rivers
#> 395                          cfb:ovc
#> 396                          cfb:sec
#> 397                          cfb:ovc
#> 398                     cfb:southern
#> 399                     cfb:american
#> 400                             <NA>
#> 401                cfb:mountain-west
#> 402 cfb:southern-collegiate-athletic
#> 403                      cfb:big-ten
#> 404                         cfb:swac
#> 405                       cfb:big-12
#> 406                     cfb:southern
#> 407                   cfb:presidents
#> 408       cfb:great-midwest-athletic
#> 409                          cfb:mac
#> 410                       cfb:pac-12
#> 411                     cfb:michigan
#> 412                     cfb:sun-belt
#> 413                  cfb:great-lakes
#> 414                     cfb:american
#> 415                         cfb:siac
#> 416                    cfb:lone-star
#> 417                      cfb:midwest
#> 418                   cfb:centennial
#> 419                   cfb:gulf-south
#> 420                      cfb:pioneer
#> 421                         cfb:ciaa
#> 422                     cfb:southern
#> 423                      cfb:midwest
#> 424                          cfb:nec
#> 425       cfb:great-midwest-athletic
#> 426              cfb:american-rivers
#> 427                   cfb:presidents
#> 428                  cfb:mid-america
#> 429                 cfb:old-dominion
#> 430                      cfb:big-sky
#> 431                   cfb:gulf-south
#> 432                          cfb:uac
#> 433                cfb:mountain-east
#> 434                   cfb:centennial
#> 435                             <NA>
#> 436           cfb:commonwealth-coast
#> 437                    cfb:lone-star
#> 438                    cfb:lone-star
#> 439                             <NA>
#> 440                cfb:mountain-east
#> 441                    cfb:wisconsin
#> 442                          cfb:ovc
#> 443                          cfb:mac
#> 444               cfb:rocky-mountain
#> 445                     cfb:southern
#> 446                    cfb:wisconsin
#> 447                    cfb:northwest
#> 448                    cfb:wisconsin
#> 449                 cfb:mid-atlantic
#> 450                      cfb:patriot
#> 451                       cfb:nescac
#> 452                         cfb:ohio
#> 453                         cfb:ciaa
#> 454                    cfb:wisconsin
#> 455           cfb:commonwealth-coast
#> 456                    cfb:wisconsin
#> 457                         cfb:nacc
#> 458                    cfb:wisconsin
#> 459                    cfb:wisconsin
#> 460                    cfb:wisconsin
#> 461                  cfb:north-coast
#> 462                     cfb:southern
#> 463                  cfb:north-coast
#> 464                       cfb:newmac
#> 465                      cfb:big-ten
#> 466                cfb:mountain-west
#> 467                         cfb:mvfc
#> 468                         cfb:swac
#> 469            cfb:southern-athletic
#> 470           cfb:american-southwest
#> 471                     cfb:sun-belt
#> 472                       cfb:big-12
#> 473             cfb:fcs-independents
#> 474                       cfb:newmac
#> 475               cfb:liberty-league
#> 476                       cfb:pac-12
#> 477                     cfb:empire-8
#> 478                     cfb:empire-8
#> 479                     cfb:michigan
#> 480                     cfb:michigan
#> 481                    cfb:minnesota
#> 482                          cfb:caa
#> 483                    cfb:carolinas
#> 484                         cfb:siac
#> 485                 cfb:mid-atlantic
#> 486           cfb:american-southwest
#> 487                     cfb:michigan
#> 488                          cfb:ovc
#> 489                  cfb:great-lakes
#> 490                 cfb:northern-sun
#> 491                   cfb:new-jersey
#> 492                         cfb:mvfc
#> 493                    cfb:carolinas
#> 494               cfb:great-american
#> 495              cfb:d2-independents
#> 496                  cfb:great-lakes
#> 497                   cfb:new-jersey
#> 498                 cfb:old-dominion
#> 499                 cfb:northeast-10
#> 500                         cfb:nacc
#> 501                    cfb:lone-star
#> 502                    cfb:southland
#> 503       cfb:great-midwest-athletic
#> 504               cfb:south-atlantic
#> 505                          cfb:nec
#> 506               cfb:south-atlantic
#> 507          cfb:landmark-conference
#> 508                 cfb:northern-sun
#> 509                   cfb:presidents
#> 510                    cfb:lone-star
#> 511                   cfb:presidents
#> 512                        cfb:sciac
#> 513                 cfb:northern-sun
#> 514  cfb:pennsylvania-state-athletic
#> 515                    cfb:usa-south
#> 516                   cfb:new-jersey
#> 517                  cfb:great-lakes
#> 518                             <NA>
#> 519                    cfb:carolinas
#> 520           cfb:commonwealth-coast
#> 521       cfb:great-midwest-athletic
#> 522               cfb:great-american
#> 523                      cfb:midwest
#> 524                 cfb:northern-sun
#> 525                    cfb:usa-south
#> 526                        cfb:sciac
#> 527                     cfb:sun-belt
#> 528                      cfb:pioneer
#> 529                        cfb:mscac
#> 530                    cfb:usa-south
#> 531                  cfb:great-lakes
#> 532                             <NA>
#> 533                    cfb:usa-south
#> 534                    cfb:southland
#> 535                      cfb:midwest
#> 536                    cfb:southland
#> 537                        cfb:sciac
#> 538               cfb:great-american
#> 539                   cfb:new-jersey
#> 540                    cfb:northwest
#> 541                    cfb:usa-south
#> 542                         cfb:ciaa
#> 543                     cfb:sun-belt
#> 544                       cfb:newmac
#> 545                   cfb:presidents
#> 546              cfb:american-rivers
#> 547                        cfb:mscac
#> 548                    cfb:minnesota
#> 549                 cfb:mid-atlantic
#> 550                 cfb:old-dominion
#> 551                   cfb:new-jersey
#> 552                        cfb:mscac
#> 553  cfb:pennsylvania-state-athletic
#> 554                       cfb:nescac
#> 555                  cfb:north-coast
#> 556                cfb:mountain-east
#> 557                      cfb:big-ten
#> 558                      cfb:pioneer
#> 559                      cfb:big-sky
#> 560                      cfb:big-sky
#> 561                         cfb:cciw
#> 562                 cfb:northern-sun
#> 563                         cfb:cciw
#> 564       cfb:great-midwest-athletic
#> 565                     cfb:sun-belt
#> 566                      cfb:big-sky
#> 567                          cfb:caa
#> 568                     cfb:empire-8
#> 569                   cfb:new-jersey
#> 570                     cfb:empire-8
#> 571                         cfb:ohio
#> 572               cfb:great-american
#> 573                         cfb:cciw
#> 574                      cfb:patriot
#> 575          cfb:landmark-conference
#> 576                             <NA>
#> 577                     cfb:sun-belt
#> 578                             <NA>
#> 579                       cfb:pac-12
#> 580                       cfb:pac-12
#> 581                       cfb:nescac
#> 582                         cfb:ciaa
#> 583                      cfb:big-sky
#> 584                         cfb:ohio
#> 585                          cfb:sec
#> 586                       cfb:nescac
#> 587                         cfb:cusa
#> 588                       cfb:nescac
#> 589                cfb:mountain-east
#> 590                          cfb:sec
#> 591                       cfb:nescac
#> 592                     cfb:american
#> 593               cfb:south-atlantic
#> 594                  cfb:north-coast
#> 595                     cfb:michigan
#> 596                      cfb:big-ten
#> 597                         cfb:ohio
#> 598                       cfb:pac-12
#> 599                     cfb:empire-8
#> 600                    cfb:carolinas
#> 601  cfb:pennsylvania-state-athletic
#> 602                     cfb:empire-8
#> 603                    cfb:minnesota
#> 604                        cfb:mscac
#> 605                       cfb:big-12
#> 606            cfb:southern-athletic
#> 607                 cfb:mid-atlantic
#> 608                  cfb:great-lakes
#> 609                     cfb:empire-8
#> 610                  cfb:north-coast
#> 611                         cfb:cciw
#> 612          cfb:landmark-conference
#> 613                          cfb:caa
#> 614           cfb:commonwealth-coast
#> 615                        cfb:mscac
#> 616                         cfb:nacc
#> 617             cfb:fbs-independents
#> 618                        cfb:sciac
#> 619                    cfb:northwest
#> 620 cfb:southern-collegiate-athletic
#> 621            cfb:southern-athletic
#> 622                         cfb:ohio
#> 623                 cfb:northern-sun
#> 624                         cfb:ohio
#> 625                         cfb:ohio
#> 626                          cfb:ivy
#> 627                cfb:upper-midwest
#> 628       cfb:great-midwest-athletic
#> 629                cfb:upper-midwest
#> 630           cfb:commonwealth-coast
#> 631                cfb:mountain-east
#> 632                      cfb:patriot
#> 633                         cfb:meac
#> 634                 cfb:mid-atlantic
#> 635                         cfb:cusa
#> 636              cfb:american-rivers
#> 637                         cfb:siac
#> 638                     cfb:american
#> 639                         cfb:swac
#> 640                cfb:upper-midwest
#> 641                             <NA>
#> 642                          cfb:acc
#> 643                             <NA>
#> 644                    cfb:usa-south
#> 645                         cfb:cusa
#> 646                 cfb:northern-sun
#> 647                      cfb:pioneer
#> 648                 cfb:northern-sun
#> 649                          cfb:sec
#> 650                     cfb:american
#> 651                cfb:upper-midwest
#> 652                          cfb:acc
#> 653                     cfb:sun-belt
#> 654                         cfb:siac
#> 655                          cfb:sec
#> 656  cfb:pennsylvania-state-athletic
#> 657               cfb:rocky-mountain
#> 658                cfb:mountain-west
#> 659              cfb:american-rivers
#> 660                         cfb:nacc
#> 661                      cfb:midwest
#> 662                       cfb:big-12
#> 663                      cfb:midwest
#> 664                       cfb:pac-12
#> 665              cfb:american-rivers
#> 666                       cfb:nescac
#> 667                      cfb:big-sky
#> 668                         cfb:cciw
#> 669                         cfb:cciw
#> 670                         cfb:cciw
#> 671                      cfb:big-ten
#> 672                         cfb:mvfc
#> 673                          cfb:sec
#> 674                      cfb:midwest
#> 675                       cfb:newmac
#> 676                  cfb:north-coast
#> 677                      cfb:big-ten
#> 678                    cfb:heartland
#> 679             cfb:fbs-independents
#> 680                  cfb:north-coast
#> 681                       cfb:big-12
#> 682                  cfb:mid-america
#> 683                         cfb:mvfc
#> 684                          cfb:sec
#> 685                          cfb:acc
#> 686                         cfb:cusa
#> 687                          cfb:sec
#> 688                     cfb:american
#> 689                          cfb:acc
#> 690                       cfb:big-12
#> 691                      cfb:big-sky
#> 692                      cfb:big-ten
#> 693                          cfb:caa
#> 694                         cfb:cusa
#> 695             cfb:fbs-independents
#> 696             cfb:fcs-independents
#> 697                          cfb:ivy
#> 698                          cfb:mac
#> 699                         cfb:meac
#> 700                         cfb:mvfc
#> 701                cfb:mountain-west
#> 702                          cfb:nec
#> 703                          cfb:ovc
#> 704                       cfb:pac-12
#> 705                      cfb:patriot
#> 706                      cfb:pioneer
#> 707                          cfb:sec
#> 708                         cfb:swac
#> 709                     cfb:southern
#> 710                    cfb:southland
#> 711                     cfb:sun-belt
#> 712                             <NA>
#>                                             conference color_primary
#> 1             Northern Athletics Collegiate Conference       #960a2c
#> 2              Southern Collegiate Athletic Conference       #8a2432
#> 3                                 Conference Carolinas       #701931
#> 4                            Atlantic Coast Conference       #8c2232
#> 5                                       Patriot League       #582c83
#> 6                                           Ivy League       #990000
#> 7    New England Women's and Men's Athletic Conference       #b20838
#> 8                                       Rocky Mountain       #860038
#> 9   Massachusetts State Collegiate Athletic Conference       #212c62
#> 10                          United Athletic Conference       #087dc2
#> 11                                           Lone Star       #e35205
#> 12  Massachusetts State Collegiate Athletic Conference       #43252a
#> 13                                                <NA>       #001681
#> 14                          Middle Atlantic Conference       #9e053b
#> 15                       Commonwealth Coast Conference       #0079c2
#> 16                                              NESCAC       #3e8ede
#> 17                                        Northeast 10       #701931
#> 18                            Mountain East Conference       #e31937
#> 19                             Mid-American Conference       #881c1c
#> 20  Massachusetts State Collegiate Athletic Conference       #024d36
#> 21                                          Centennial       #68aee0
#> 22                        Coastal Athletic Association       #ffc229
#> 23                                   Big 12 Conference       #cc0033
#> 24                                  Big Ten Conference       #ce1126
#> 25                                              NESCAC       #a51e36
#> 26                                Conference Carolinas       #004684
#> 27                                    Independent DIII       #001e4e
#> 28                                                <NA>       #2a388c
#> 29                                           Minnesota       #74233d
#> 30                                     Independent DII       #a61d2f
#> 31                                                CIAA       #0f1f43
#> 32                                               GLIAC       #0f298f
#> 33                                            Empire 8       #233f94
#> 34                                            Michigan       #ec6820
#> 35                                        Northeast 10       #632d4f
#> 36                                  Big Ten Conference       #173f35
#> 37                          Middle Atlantic Conference       #6a1f32
#> 38                                               GLIAC       #0f553a
#> 39                                               GLIAC       #c41230
#> 40                                      South Atlantic       #bca271
#> 41                                            Michigan       #891b2f
#> 42                                  Big Sky Conference       #1e4d2b
#> 43                                  Big Ten Conference       #00274c
#> 44                                               GLIAC       #4a8075
#> 45                                        Northern Sun       #d3af7e
#> 46                                           Minnesota       #000000
#> 47                                        Northern Sun       #fec050
#> 48                                  Big Ten Conference       #5e0a2f
#> 49                                         Mid America       #fab615
#> 50                                         Mid America       #006e51
#> 51                             Southeastern Conference       #f1b82d
#> 52                                         North Coast       #007360
#> 53                             Southeastern Conference       #13294b
#> 54                                         Presidents'       #eb1f25
#> 55                                  Big Sky Conference       #00205c
#> 56                                  Big Sky Conference       #751d4a
#> 57                           Atlantic Coast Conference       #00539b
#> 58                                 American Conference       #582c83
#> 59                           Atlantic Coast Conference       #cc0000
#> 60                           Atlantic Coast Conference       #7bafd4
#> 61                           Atlantic Coast Conference       #ceb888
#> 62                 Missouri Valley Football Conference       #00a26b
#> 63                                  Big Ten Conference       #e31937
#> 64                                          Ivy League       #005730
#> 65                             Mid-American Conference       #00573c
#> 66                        Coastal Athletic Association       #004990
#> 67                                           Minnesota       #98012e
#> 68                                          Ivy League       #000000
#> 69                                  Big Ten Conference       #ce0e2d
#> 70                                      Conference USA       #7e141b
#> 71                            Mountain West Conference       #ba0c2f
#> 72                                            So. Cal.       #981a31
#> 73                                          Ivy League       #7ba4db
#> 74                                          Ivy League       #b31b1b
#> 75                                            Empire 8       #0058a9
#> 76                                      Liberty League       #4f1079
#> 77                                      Liberty League       #000000
#> 78  Massachusetts State Collegiate Athletic Conference       #bf2f38
#> 79                           Atlantic Coast Conference       #000e54
#> 80                                      Liberty League       #f8d000
#> 81                                                Ohio       #f6c406
#> 82                             Mid-American Conference       #fd5000
#> 83                                           Heartland       #4e2d8a
#> 84                                                Ohio       #d55929
#> 85                             Mid-American Conference       #c41230
#> 86                                  Big Ten Conference       #ba0c2f
#> 87                             Mid-American Conference       #154734
#> 88                                     Independent DII       #008265
#> 89                                   Big 12 Conference       #fe5c00
#> 90                           Great American Conference       #00498e
#> 91                             Southeastern Conference       #002b5c
#> 92                           Great American Conference       #841617
#> 93                          United Athletic Conference       #592d82
#> 94                                      Rocky Mountain       #007954
#> 95                                            Michigan       #ffc423
#> 96                            Mountain West Conference       #003594
#> 97                             Mid-American Conference       #041e42
#> 98                             Southeastern Conference       #990000
#> 99                    Southwestern Athletic Conference       #790000
#> 100                   Southwestern Athletic Conference       #e9a900
#> 101                                               SIAC       #eaab00
#> 102                         Middle Atlantic Conference       #c82e48
#> 103                   Southwestern Athletic Conference       #4b0058
#> 104                                        Presidents'       #0b2340
#> 105                                               SIAC       #025399
#> 106                                American Conference       #003595
#> 107                                       Northeast 10       #ffbc15
#> 108                                          Heartland       #f78f1e
#> 109                                          Lone Star       #245397
#> 110                                Sun Belt Conference       #000000
#> 111                          Great American Conference       #28825a
#> 112                   Southwestern Athletic Conference       #e0aa0f
#> 113                                          Northwest       #46256a
#> 114                                Sun Belt Conference       #cc092f
#> 115                          Great American Conference       #ffd20a
#> 116                                       Northeast 10       #004b87
#> 117                                  Pac-12 Conference       #dc4405
#> 118                                               CCIW       #00437c
#> 119                                       Northern Sun       #002d62
#> 120           Northern Athletics Collegiate Conference       #00549f
#> 121            Southern Collegiate Athletic Conference       #b20838
#> 122                         United Athletic Conference       #8e0b0b
#> 123                                       Old Dominion       #012853
#> 124                                           So. Cal.       #ffffff
#> 125                                          Northwest       #b4183a
#> 126                            Mid-American Conference       #ba0c2f
#> 127                                          USA South       #215732
#> 128                                       Northeast 10       #86a7bb
#> 129                                        Presidents'       #00583d
#> 130                                               <NA>       #613394
#> 131                   Southwestern Athletic Conference       #7b1831
#> 132                                     Rocky Mountain       #f5bc21
#> 133             Pennsylvania State Athletic Conference       #7a001f
#> 134                                          Heartland       #46166a
#> 135                                               CIAA       #ffec9f
#> 136                                       Old Dominion       #990022
#> 137                                     Patriot League       #000060
#> 138                            Mid-American Conference       #005bbb
#> 139                                     Liberty League       #e77324
#> 140                            Pioneer Football League       #0d1361
#> 141             Pennsylvania State Athletic Conference       #922135
#> 142                                           So. Cal.       #3b2361
#> 143                       Coastal Athletic Association       #ff4713
#> 144                                  Pac-12 Conference       #a6192e
#> 145             Pennsylvania State Athletic Conference       #dda10e
#> 146                                          Minnesota       #173a79
#> 147                                        Presidents'       #c71230
#> 148                                     South Atlantic       #f2682a
#> 149                                               CCIW       #ce0e2d
#> 150                                     South Atlantic       #0c233f
#> 151                                Landmark Conference       #bf2e1a
#> 152                         United Athletic Conference       #a7a9ac
#> 153                               Northeast Conference       #1b49a2
#> 154                                  Big 12 Conference       #000000
#> 155                            Mid-American Conference       #4c0027
#> 156                                        Mid America       #d31145
#> 157                                               SIAC       #770022
#> 158                                          Lone Star       #ad1d37
#> 159                      Southern Athletic Association       #f5d116
#> 160                                        Mid America       #002d62
#> 161                                     Rocky Mountain       #650934
#> 162                             Ohio Valley Conference       #2e3192
#> 163                           Mountain East Conference       #651d32
#> 164                                 Big Ten Conference       #061440
#> 165                                   FCS Independents       #006700
#> 166                                  Big 12 Conference       #000000
#> 167             Pennsylvania State Athletic Conference       #133880
#> 168                         American Rivers Conference       #881922
#> 169                                     Patriot League       #821019
#> 170                                     Rocky Mountain       #011e47
#> 171                           Mountain East Conference       #74043a
#> 172             Pennsylvania State Athletic Conference       #016f54
#> 173           Northern Athletics Collegiate Conference       #572a31
#> 174                                          Minnesota       #701d45
#> 175                                            Midwest       #533379
#> 176                                Landmark Conference       #6b1a31
#> 177                            Pioneer Football League       #000000
#> 178                            Pioneer Football League       #004b8d
#> 179                    Mid-Eastern Athletic Conference       #009cdb
#> 180                                         Gulf South       #00753e
#> 181                                        North Coast       #c8032b
#> 182                                         Centennial       #ed192d
#> 183                                American Conference       #a41e35
#> 184                            Pioneer Football League       #005596
#> 185                               Northeast Conference       #002d62
#> 186             Pennsylvania State Athletic Conference       #dd0632
#> 187                                         Ivy League       #082a74
#> 188                          Great American Conference       #f05423
#> 189                                Southern Conference       #002d61
#> 190                                 American Southwest       #002b44
#> 191                             Ohio Valley Conference       #000000
#> 192                         United Athletic Conference       #660819
#> 193                            Mid-American Conference       #006938
#> 194                                          Lone Star       #006430
#> 195                                               <NA>       #434445
#> 196             Pennsylvania State Athletic Conference       #bb131a
#> 197                                               SIAC       #f68428
#> 198                                               CIAA       #1235c5
#> 199                          Atlantic Coast Conference       #003594
#> 200                       Coastal Athletic Association       #020303
#> 201                                     South Atlantic       #1e376d
#> 202                                        Mid America       #c29209
#> 203                                     Patriot League       #00205b
#> 204                                               CIAA       #1468b2
#> 205                         Middle Atlantic Conference       #003f87
#> 206                                              GLIAC       #ffc423
#> 207                  Great Midwest Athletic Conference       #ff8300
#> 208                                American Conference       #003366
#> 209                                     Conference USA       #091f3f
#> 210             Pennsylvania State Athletic Conference       #fec526
#> 211                                     Patriot League       #830032
#> 212                                        Mid America       #a69671
#> 213                                               SIAC       #f9bd0a
#> 214                                          Heartland       #1b295b
#> 215                                         Centennial       #25377d
#> 216                                     Rocky Mountain       #004785
#> 217                             Ohio Valley Conference       #c12535
#> 218                                        Presidents'       #8b732f
#> 219                                               <NA>       #016600
#> 220                                               <NA>       #fc671a
#> 221                                Sun Belt Conference       #0039a6
#> 222                                         Centennial       #f4711f
#> 223                           Mountain East Conference       #004f93
#> 224                                         Ivy League       #411e09
#> 225                                               <NA>       #d01b35
#> 226                                          USA South       #007853
#> 227                                      Upper Midwest       #f36917
#> 228                                       Old Dominion       #910028
#> 229                       Coastal Athletic Association       #0067ac
#> 230                                          Heartland       #0b486d
#> 231                          Great American Conference       #a48544
#> 232                       Coastal Athletic Association       #091f3f
#> 233                          Great American Conference       #7a0026
#> 234                  Great Midwest Athletic Conference       #0d1d41
#> 235                                        Presidents'       #1c4077
#> 236                               Southland Conference       #00539c
#> 237                          Atlantic Coast Conference       #f56600
#> 238                      Commonwealth Coast Conference       #004b44
#> 239           Northern Athletics Collegiate Conference       #ba0c2f
#> 240                                            Midwest       #014a91
#> 241                Missouri Valley Football Conference       #ce1126
#> 242             Pennsylvania State Athletic Conference       #aa0632
#> 243                                        Great Lakes       #880c2c
#> 244                                 Big Ten Conference       #231f20
#> 245                   Southwestern Athletic Conference       #123297
#> 246                           Mountain West Conference       #0038a8
#> 247                                               Ohio       #28334a
#> 248                                               CIAA       #002d56
#> 249                                  Big 12 Conference       #0051ba
#> 250                                  Big 12 Conference       #330a57
#> 251                            Mid-American Conference       #002664
#> 252                                Southern Conference       #582c83
#> 253                                               SIAC       #ffcf06
#> 254             Pennsylvania State Athletic Conference       #c6b884
#> 255                  Great Midwest Athletic Conference       #3b2e81
#> 256                                           So. Cal.       #004812
#> 257                               Southland Conference       #000000
#> 258                                               SIAC       #083254
#> 259                                               <NA>       #1b3667
#> 260                                     Patriot League       #6c2b2a
#> 261                Missouri Valley Football Conference       #cd1241
#> 262                                     South Atlantic       #000000
#> 263                                          Northwest       #f37737
#> 264                                     Conference USA       #0a254e
#> 265                                               CIAA       #fc6c0f
#> 266                               Northeast Conference       #50c9f7
#> 267                                Sun Belt Conference       #003087
#> 268                                American Conference       #004991
#> 269                                Landmark Conference       #15283f
#> 270                                          Minnesota       #09426a
#> 271                                Southern Conference       #00386b
#> 272                                          Heartland       #ddac14
#> 273                                       Northern Sun       #480059
#> 274                                               <NA>       #ad162c
#> 275                            Pioneer Football League       #e53730
#> 276                                     South Atlantic       #004b8d
#> 277                                     Liberty League       #762334
#> 278                                 American Southwest       #492f92
#> 279                                          USA South       #5f0014
#> 280                               Southland Conference       #00529c
#> 281                            Southeastern Conference       #000000
#> 282                                Southern Conference       #ff7f29
#> 283  New England Women's and Men's Athletic Conference       #244788
#> 284                               Northeast Conference       #036857
#> 285                                  Big 12 Conference       #154734
#> 286                          Atlantic Coast Conference       #f47423
#> 287                                              GLIAC       #facd03
#> 288                                     Conference USA       #036eb7
#> 289                                             NESCAC       #365a8a
#> 290                                               SIAC       #580d69
#> 291                      Southern Athletic Association       #20145f
#> 292                                      Upper Midwest       #8d191b
#> 293                          Atlantic Coast Conference       #8c1515
#> 294                   Southwestern Athletic Conference       #005328
#> 295                                        Great Lakes       #f0dbaa
#> 296                                        Mid America       #f6cf3c
#> 297                       Coastal Athletic Association       #051844
#> 298                                 American Southwest       #98002e
#> 299                            Pioneer Football League       #094fa3
#> 300                    Mid-Eastern Athletic Conference       #014786
#> 301                                               <NA>       #0d0c0c
#> 302                                          Heartland       #002d5d
#> 303                                American Conference       #00205b
#> 304                                         Centennial       #a51e36
#> 305                                     Rocky Mountain       #4e2683
#> 306                                American Conference       #00225b
#> 307                    Mid-Eastern Athletic Conference       #880023
#> 308                                American Conference       #005035
#> 309                                Sun Belt Conference       #840029
#> 310                                        Mid America       #004d86
#> 311                           Mountain West Conference       #cf0a2c
#> 312                           Mountain West Conference       #041e42
#> 313                               Northeast Conference       #041e42
#> 314                                         New Jersey       #154c7d
#> 315                                     South Atlantic       #d02030
#> 316                               Southland Conference       #c41230
#> 317                       Coastal Athletic Association       #0505aa
#> 318                           Mountain West Conference       #01402a
#> 319                            Southeastern Conference       #500000
#> 320                    Mid-Eastern Athletic Conference       #0c8968
#> 321                         United Athletic Conference       #663399
#> 322                                 Big Sky Conference       #13558d
#> 323                           Mountain West Conference       #c8102e
#> 324                                Landmark Conference       #031832
#> 325                Missouri Valley Football Conference       #473282
#> 326                                 Big Sky Conference       #003976
#> 327                               Southland Conference       #492f91
#> 328  New England Women's and Men's Athletic Conference       #822130
#> 329                         Middle Atlantic Conference       #c41230
#> 330                  Great Midwest Athletic Conference       #ffcf28
#> 331                                  Big 12 Conference       #c8102e
#> 332                                 Big Ten Conference       #00934b
#> 333                                          Northwest       #ffc423
#> 334                                       Northeast 10       #fedc1e
#> 335                                American Conference       #068f33
#> 336                          Atlantic Coast Conference       #041e42
#> 337                                 Big Sky Conference       #00311e
#> 338                   Southwestern Athletic Conference       #582c83
#> 339                            Pioneer Football League       #194896
#> 340                                          Northwest       #680001
#> 341                                 Big Ten Conference       #ceb888
#> 342                            Southeastern Conference       #af5c37
#> 343                                       Old Dominion       #fcdf12
#> 344                      Southern Athletic Association       #cf152d
#> 345                                  Big 12 Conference       #0047ba
#> 346                               Northeast Conference       #00214d
#> 347           Northern Athletics Collegiate Conference       #5a3f99
#> 348                                     Liberty League       #ed3023
#> 349                       Coastal Athletic Association       #a40012
#> 350                                 Big Sky Conference       #c72026
#> 351                                         New Jersey       #8b0e04
#> 352                                     Conference USA       #f56423
#> 353                                Southern Conference       #005485
#> 354                                  Big 12 Conference       #be0000
#> 355                                               SIAC       #280298
#> 356                               Southland Conference       #215732
#> 357                             Ohio Valley Conference       #c8102e
#> 358                                            Midwest       #5b2b82
#> 359                                               CIAA       #6a1432
#> 360                      Southern Athletic Association       #d0b786
#> 361  New England Women's and Men's Athletic Conference       #f26722
#> 362             Pennsylvania State Athletic Conference       #0b2240
#> 363                                Sun Belt Conference       #450084
#> 364                               Conference Carolinas       #0068b3
#> 365                         American Rivers Conference       #b20838
#> 366                          Atlantic Coast Conference       #a80000
#> 367                          Great American Conference       #003da5
#> 368                    Mid-Eastern Athletic Conference       #7d1315
#> 369                                     Patriot League       #9e0712
#> 370                                     Rocky Mountain       #162856
#> 371                Missouri Valley Football Conference       #0033a0
#> 372                                Sun Belt Conference       #ffc72c
#> 373                            Southeastern Conference       #73000a
#> 374                          Atlantic Coast Conference       #232d4b
#> 375                   Southwestern Athletic Conference       #004b97
#> 376                                       Northeast 10       #071689
#> 377                                               <NA>       #e51d3a
#> 378                                        Great Lakes       #502583
#> 379                                       Northern Sun       #3a1707
#> 380                      Southern Athletic Association       #000000
#> 381                          Atlantic Coast Conference       #6a2c3e
#> 382                                               <NA>       #00529b
#> 383                                               <NA>       #434445
#> 384                                        Presidents'       #a20012
#> 385                                 Big Ten Conference       #2774ae
#> 386                                          Minnesota       #ce153e
#> 387                                        Presidents'       #daad27
#> 388                               Southland Conference       #393996
#> 389                       Coastal Athletic Association       #990000
#> 390                                            Midwest       #e12a3d
#> 391                                     Conference USA       #5e0009
#> 392                         United Athletic Conference       #592b82
#> 393                                  Big 12 Conference       #4d1979
#> 394                         American Rivers Conference       #452d7d
#> 395                             Ohio Valley Conference       #ff6700
#> 396                            Southeastern Conference       #ff8200
#> 397                             Ohio Valley Conference       #171796
#> 398                                Southern Conference       #5a4099
#> 399                                American Conference       #0c2340
#> 400                                               <NA>       #e05e15
#> 401                           Mountain West Conference       #ff8200
#> 402            Southern Collegiate Athletic Conference       #fdbe10
#> 403                                 Big Ten Conference       #33006f
#> 404                   Southwestern Athletic Conference       #860038
#> 405                                  Big 12 Conference       #da291c
#> 406                                Southern Conference       #7badd3
#> 407                                        Presidents'       #b6964b
#> 408                  Great Midwest Athletic Conference       #004f9d
#> 409                            Mid-American Conference       #0b2240
#> 410                                  Pac-12 Conference       #a60f2d
#> 411                                           Michigan       #0b335e
#> 412                                Sun Belt Conference       #862633
#> 413                                        Great Lakes       #510c76
#> 414                                American Conference       #006747
#> 415                                               SIAC       #a32035
#> 416                                          Lone Star       #005daa
#> 417                                            Midwest       #003865
#> 418                                         Centennial       #98012e
#> 419                                         Gulf South       #dd1a32
#> 420                            Pioneer Football League       #794500
#> 421                                               CIAA       #72171a
#> 422                                Southern Conference       #ae122a
#> 423                                            Midwest       #062336
#> 424                               Northeast Conference       #00483a
#> 425                  Great Midwest Athletic Conference       #6e0022
#> 426                         American Rivers Conference       #f5822b
#> 427                                        Presidents'       #a93339
#> 428                                        Mid America       #003876
#> 429                                       Old Dominion       #000399
#> 430                                 Big Sky Conference       #18005a
#> 431                                         Gulf South       #d31d33
#> 432                         United Athletic Conference       #0033a1
#> 433                           Mountain East Conference       #ffcd32
#> 434                                         Centennial       #00674d
#> 435                                               <NA>       #b5121b
#> 436                      Commonwealth Coast Conference       #feb610
#> 437                                          Lone Star       #42196e
#> 438                                          Lone Star       #6a1831
#> 439                                               <NA>       #005dab
#> 440                           Mountain East Conference       #d2ac2a
#> 441                                          Wisconsin       #b38707
#> 442                             Ohio Valley Conference       #4e1e8a
#> 443                            Mid-American Conference       #532e1f
#> 444                                     Rocky Mountain       #c61230
#> 445                                Southern Conference       #492f91
#> 446                                          Wisconsin       #0068b5
#> 447                                          Northwest       #930036
#> 448                                          Wisconsin       #cd1041
#> 449                         Middle Atlantic Conference       #0056ba
#> 450                                     Patriot League       #115740
#> 451                                             NESCAC       #500082
#> 452                                               Ohio       #92c648
#> 453                                               CIAA       #bb0100
#> 454                                          Wisconsin       #023576
#> 455                      Commonwealth Coast Conference       #1a64b7
#> 456                                          Wisconsin       #850129
#> 457           Northern Athletics Collegiate Conference       #006241
#> 458                                          Wisconsin       #492f91
#> 459                                          Wisconsin       #0c233f
#> 460                                          Wisconsin       #5b3085
#> 461                                        North Coast       #d31145
#> 462                                Southern Conference       #533b23
#> 463                                        North Coast       #f7be00
#> 464  New England Women's and Men's Athletic Conference       #c41230
#> 465                                 Big Ten Conference       #a00000
#> 466                           Mountain West Conference       #492f24
#> 467                Missouri Valley Football Conference       #e51936
#> 468                   Southwestern Athletic Conference       #ee8601
#> 469                      Southern Athletic Association       #00205b
#> 470                                 American Southwest       #02215b
#> 471                                Sun Belt Conference       #00b140
#> 472                                  Big 12 Conference       #eaaa00
#> 473                                   FCS Independents       #2f4f93
#> 474  New England Women's and Men's Athletic Conference       #005588
#> 475                                     Liberty League       #663a2b
#> 476                                  Pac-12 Conference       #b1102b
#> 477                                           Empire 8       #00462d
#> 478                                           Empire 8       #c00c26
#> 479                                           Michigan       #efb30f
#> 480                                           Michigan       #421d2f
#> 481                                          Minnesota       #002d62
#> 482                       Coastal Athletic Association       #000000
#> 483                               Conference Carolinas       #00529b
#> 484                                               SIAC       #ad141a
#> 485                         Middle Atlantic Conference       #004c23
#> 486                                 American Southwest       #5b2d83
#> 487                                           Michigan       #f36b23
#> 488                             Ohio Valley Conference       #b3a068
#> 489                                        Great Lakes       #54237f
#> 490                                       Northern Sun       #c8102e
#> 491                                         New Jersey       #c20f2f
#> 492                Missouri Valley Football Conference       #00669a
#> 493                               Conference Carolinas       #d91e39
#> 494                          Great American Conference       #d02030
#> 495                                    Independent DII       #ce0e2d
#> 496                                        Great Lakes       #947e1b
#> 497                                         New Jersey       #571b04
#> 498                                       Old Dominion       #b80835
#> 499                                       Northeast 10       #0c233f
#> 500           Northern Athletics Collegiate Conference       #004712
#> 501                                          Lone Star       #eb0626
#> 502                               Southland Conference       #ffc333
#> 503                  Great Midwest Athletic Conference       #00401f
#> 504                                     South Atlantic       #f2682a
#> 505                               Northeast Conference       #300a48
#> 506                                     South Atlantic       #e30000
#> 507                                Landmark Conference       #002857
#> 508                                       Northern Sun       #ffd02e
#> 509                                        Presidents'       #9a5627
#> 510                                          Lone Star       #e2383f
#> 511                                        Presidents'       #00355f
#> 512                                           So. Cal.       #4a217b
#> 513                                       Northern Sun       #4b09a2
#> 514             Pennsylvania State Athletic Conference       #b42622
#> 515                                          USA South       #005288
#> 516                                         New Jersey       #092f56
#> 517                                        Great Lakes       #112845
#> 518                                               <NA>       #082443
#> 519                               Conference Carolinas       #8d754f
#> 520                      Commonwealth Coast Conference       #007b5f
#> 521                  Great Midwest Athletic Conference       #7fb0d6
#> 522                          Great American Conference       #542989
#> 523                                            Midwest       #c10e3f
#> 524                                       Northern Sun       #492f91
#> 525                                          USA South       #9b2036
#> 526                                           So. Cal.       #751708
#> 527                                Sun Belt Conference       #041e42
#> 528                            Pioneer Football League       #512873
#> 529 Massachusetts State Collegiate Athletic Conference       #1b509e
#> 530                                          USA South       #fec325
#> 531                                        Great Lakes       #ea1c2d
#> 532                                               <NA>       #00457c
#> 533                                          USA South       #003c78
#> 534                               Southland Conference       #000000
#> 535                                            Midwest       #d4282f
#> 536                               Southland Conference       #dc6000
#> 537                                           So. Cal.       #00549a
#> 538                          Great American Conference       #2e3d50
#> 539                                         New Jersey       #01573c
#> 540                                          Northwest       #960a2c
#> 541                                          USA South       #d21f36
#> 542                                               CIAA       #86b0c6
#> 543                                Sun Belt Conference       #003768
#> 544  New England Women's and Men's Athletic Conference       #790032
#> 545                                        Presidents'       #083150
#> 546                         American Rivers Conference       #ea0029
#> 547 Massachusetts State Collegiate Athletic Conference       #edb317
#> 548                                          Minnesota       #000000
#> 549                         Middle Atlantic Conference       #ffe315
#> 550                                       Old Dominion       #900028
#> 551                                         New Jersey       #000000
#> 552 Massachusetts State Collegiate Athletic Conference       #054e39
#> 553             Pennsylvania State Athletic Conference       #c0b45f
#> 554                                             NESCAC       #032d58
#> 555                                        North Coast       #e82524
#> 556                           Mountain East Conference       #75243e
#> 557                                 Big Ten Conference       #9d2235
#> 558                            Pioneer Football League       #2f99d4
#> 559                                 Big Sky Conference       #002855
#> 560                                 Big Sky Conference       #ef8c00
#> 561                                               CCIW       #006f51
#> 562                                       Northern Sun       #d8ab27
#> 563                                               CCIW       #b20838
#> 564                  Great Midwest Athletic Conference       #513093
#> 565                                Sun Belt Conference       #ce181e
#> 566                                 Big Sky Conference       #ba1c21
#> 567                       Coastal Athletic Association       #127dbe
#> 568                                           Empire 8       #00502f
#> 569                                         New Jersey       #005394
#> 570                                           Empire 8       #00467f
#> 571                                               Ohio       #00275c
#> 572                          Great American Conference       #255f2b
#> 573                                               CCIW       #f16723
#> 574                                     Patriot League       #790000
#> 575                                Landmark Conference       #1f3361
#> 576                                               <NA>       #871c30
#> 577                                Sun Belt Conference       #006f71
#> 578                                               <NA>       #124d39
#> 579                                  Pac-12 Conference       #501214
#> 580                                  Pac-12 Conference       #0f2439
#> 581                                             NESCAC       #012778
#> 582                                               CIAA       #a9712c
#> 583                                 Big Sky Conference       #a10022
#> 584                                               Ohio       #bf2037
#> 585                            Southeastern Conference       #9e1b32
#> 586                                             NESCAC       #d72121
#> 587                                     Conference USA       #fdbb30
#> 588                                             NESCAC       #ffffff
#> 589                           Mountain East Conference       #d31145
#> 590                            Southeastern Conference       #5d1725
#> 591                                             NESCAC       #062f87
#> 592                                American Conference       #000000
#> 593                                     South Atlantic       #182441
#> 594                                        North Coast       #613394
#> 595                                           Michigan       #e72623
#> 596                                 Big Ten Conference       #ff5f05
#> 597                                               Ohio       #cca05b
#> 598                                  Pac-12 Conference       #004c23
#> 599                                           Empire 8       #633394
#> 600                               Conference Carolinas       #000000
#> 601             Pennsylvania State Athletic Conference       #fcb040
#> 602                                           Empire 8       #c02f39
#> 603                                          Minnesota       #00447c
#> 604 Massachusetts State Collegiate Athletic Conference       #0f223f
#> 605                                  Big 12 Conference       #cfb87c
#> 606                      Southern Athletic Association       #8c2129
#> 607                         Middle Atlantic Conference       #003767
#> 608                                        Great Lakes       #1a2d5d
#> 609                                           Empire 8       #0b2240
#> 610                                        North Coast       #ad0935
#> 611                                               CCIW       #002857
#> 612                                Landmark Conference       #002856
#> 613                       Coastal Athletic Association       #3d2777
#> 614                      Commonwealth Coast Conference       #65448b
#> 615 Massachusetts State Collegiate Athletic Conference       #004b8e
#> 616           Northern Athletics Collegiate Conference       #245699
#> 617                                   FBS Independents       #0c2340
#> 618                                           So. Cal.       #ab1d38
#> 619                                          Northwest       #002d62
#> 620            Southern Collegiate Athletic Conference       #d1ac54
#> 621                      Southern Athletic Association       #f58023
#> 622                                               Ohio       #35236a
#> 623                                       Northern Sun       #8e0a26
#> 624                                               Ohio       #291f2e
#> 625                                               Ohio       #ff5324
#> 626                                         Ivy League       #004a81
#> 627                                      Upper Midwest       #06496f
#> 628                  Great Midwest Athletic Conference       #113d2a
#> 629                                      Upper Midwest       #de1b22
#> 630                      Commonwealth Coast Conference       #008265
#> 631                           Mountain East Conference       #ff4c00
#> 632                                     Patriot League       #110e42
#> 633                    Mid-Eastern Athletic Conference       #003a63
#> 634                         Middle Atlantic Conference       #005747
#> 635                                     Conference USA       #00539f
#> 636                         American Rivers Conference       #1c3c75
#> 637                                               SIAC       #fcd309
#> 638                                American Conference       #1a5632
#> 639                   Southwestern Athletic Conference       #f89728
#> 640                                      Upper Midwest       #5c2f92
#> 641                                               <NA>       #fff200
#> 642                          Atlantic Coast Conference       #782f40
#> 643                                               <NA>       #f0b310
#> 644                                          USA South       #df1c2b
#> 645                                     Conference USA       #cc0000
#> 646                                       Northern Sun       #0a2e6e
#> 647                            Pioneer Football League       #0a5640
#> 648                                       Northern Sun       #ce0e2d
#> 649                            Southeastern Conference       #0021a5
#> 650                                American Conference       #006747
#> 651                                      Upper Midwest       #291d40
#> 652                          Atlantic Coast Conference       #b3a369
#> 653                                Sun Belt Conference       #00205b
#> 654                                               SIAC       #840028
#> 655                            Southeastern Conference       #ba0c2f
#> 656             Pennsylvania State Athletic Conference       #d11042
#> 657                                     Rocky Mountain       #131f48
#> 658                           Mountain West Conference       #005737
#> 659                         American Rivers Conference       #feba12
#> 660           Northern Athletics Collegiate Conference       #fec425
#> 661                                            Midwest       #ee3124
#> 662                                  Big 12 Conference       #ae192d
#> 663                                            Midwest       #015a9c
#> 664                                  Pac-12 Conference       #0033a0
#> 665                         American Rivers Conference       #aa985d
#> 666                                             NESCAC       #3f1f69
#> 667                                 Big Sky Conference       #000000
#> 668                                               CCIW       #00a2e0
#> 669                                               CCIW       #014576
#> 670                                               CCIW       #0057a8
#> 671                                 Big Ten Conference       #492f92
#> 672                Missouri Valley Football Conference       #85283d
#> 673                            Southeastern Conference       #a32136
#> 674                                            Midwest       #8b0021
#> 675  New England Women's and Men's Athletic Conference       #862633
#> 676                                        North Coast       #ffce34
#> 677                                 Big Ten Conference       #970310
#> 678                                          Heartland       #800000
#> 679                                   FBS Independents       #062340
#> 680                                        North Coast       #ce0e19
#> 681                                  Big 12 Conference       #ffc627
#> 682                                        Mid America       #e51837
#> 683                Missouri Valley Football Conference       #002148
#> 684                            Southeastern Conference       #0033a0
#> 685                          Atlantic Coast Conference       #c9001f
#> 686                                     Conference USA       #e13a3e
#> 687                            Southeastern Conference       #461d76
#> 688                                American Conference       #0e1d41
#> 689                          Atlantic Coast Conference       #003ca6
#> 690                                  Big 12 Conference       #fa4238
#> 691                                 Big Sky Conference       #0133a0
#> 692                                 Big Ten Conference       #0082cb
#> 693                       Coastal Athletic Association       #002648
#> 694                                     Conference USA       #002638
#> 695                                   FBS Independents       #76b7b2
#> 696                                   FCS Independents       #9c755f
#> 697                                         Ivy League       #18563f
#> 698                            Mid-American Conference       #009844
#> 699                    Mid-Eastern Athletic Conference       #582c82
#> 700                Missouri Valley Football Conference       #9c755f
#> 701                           Mountain West Conference       #4e2d7f
#> 702                               Northeast Conference       #035f9b
#> 703                             Ohio Valley Conference       #a51844
#> 704                                  Pac-12 Conference       #001a6f
#> 705                                     Patriot League       #00205a
#> 706                            Pioneer Football League       #ff9da7
#> 707                            Southeastern Conference       #012d74
#> 708                   Southwestern Athletic Conference       #e2201b
#> 709                                Southern Conference       #001588
#> 710                               Southland Conference       #c1a552
#> 711                                Sun Belt Conference       #0c2140
#> 712                        Western Athletic Conference       #8a2432
#>     color_secondary color_source
#> 1           #c09a05         espn
#> 2           #300e12         logo
#> 3           #010101         logo
#> 4           #dbcca6         espn
#> 5           #ffffff         espn
#> 6           #dbdbdb         espn
#> 7           #231f20         logo
#> 8           #face06         logo
#> 9           #fed523         espn
#> 10          #03b186         espn
#> 11          #000000         logo
#> 12          #bababa         logo
#> 13          #231f20         logo
#> 14          #dfa576         logo
#> 15          #292f35         logo
#> 16          #c6beb6         espn
#> 17          #232021         logo
#> 18          #e2735c         logo
#> 19          #ffffff         espn
#> 20          #fbbf16         espn
#> 21          #64747f         logo
#> 22             <NA>         espn
#> 23          #003366         espn
#> 24          #ffffff         espn
#> 25          #b2b3b2         espn
#> 26          #1e2f40         logo
#> 27          #804444         logo
#> 28          #707499         logo
#> 29          #a9a9aa         espn
#> 30          #fcb71c         logo
#> 31          #c5ad84         logo
#> 32          #686d86         logo
#> 33          #828995         logo
#> 34          #41312a         logo
#> 35          #fd8404         logo
#> 36          #ffffff         espn
#> 37          #825a65         logo
#> 38          #ffc423         logo
#> 39          #d0a360         logo
#> 40          #231f20         logo
#> 41          #eecc0a         logo
#> 42          #eed897         espn
#> 43          #ffcb05         espn
#> 44          #0f594e         logo
#> 45          #005745         logo
#> 46          #d18c29         espn
#> 47          #7e683c         logo
#> 48          #fab41c         espn
#> 49          #4c3c1e         logo
#> 50          #589784         logo
#> 51          #000000         espn
#> 52          #bc0940         logo
#> 53          #cf142b         espn
#> 54          #f7a7a9         logo
#> 55          #bc955c         espn
#> 56          #666666         espn
#> 57          #ffffff         espn
#> 58          #ffc72c         espn
#> 59          #ffffff         espn
#> 60          #13294b         espn
#> 61          #2c2a29         espn
#> 62          #c2c3c0         espn
#> 63          #ffffff         espn
#> 64          #000000         espn
#> 65          #cdb97d         espn
#> 66          #c3c4c6         espn
#> 67          #ffffff         espn
#> 68          #ff6000         espn
#> 69          #ffffff         espn
#> 70          #231f20         espn
#> 71          #a7a8aa         espn
#> 72          #feba15         espn
#> 73          #183863         espn
#> 74          #ffffff         espn
#> 75          #45515d         logo
#> 76          #fe6317         logo
#> 77             <NA>         logo
#> 78          #000000         espn
#> 79          #ff431b         espn
#> 80          #093c71         logo
#> 81          #41250d         logo
#> 82          #4f2c1d         espn
#> 83          #ded27c         espn
#> 84          #4b3c37         logo
#> 85          #ffffff         espn
#> 86          #a8adb4         espn
#> 87          #ffffff         espn
#> 88          #231f20         logo
#> 89          #000000         espn
#> 90          #ffda01         logo
#> 91          #f26522         espn
#> 92          #8f5a5a         logo
#> 93          #b1b3b3         espn
#> 94          #11352a         logo
#> 95          #bca77d         logo
#> 96          #ffffff         espn
#> 97          #c5b783         espn
#> 98          #ffffff         espn
#> 99          #ffffff         espn
#> 100         #0a0a0a         espn
#> 101         #35538f         logo
#> 102         #000000         espn
#> 103         #46166a         espn
#> 104            <NA>         logo
#> 105         #e6e3a9         logo
#> 106         #d0b787         espn
#> 107         #f7da8d         logo
#> 108         #5f4120         logo
#> 109         #f0c33b         logo
#> 110         #ffcd00         espn
#> 111         #110f0e         logo
#> 112         #eaaa00         espn
#> 113         #d41e47         espn
#> 114         #000000         espn
#> 115         #02634e         logo
#> 116         #b7c0c6         logo
#> 117         #000000         espn
#> 118         #ffe100         logo
#> 119         #f7e23e         logo
#> 120         #000000         espn
#> 121         #fdb913         logo
#> 122            <NA>         espn
#> 123         #fdbb30         espn
#> 124            <NA>         logo
#> 125         #ffffff         espn
#> 126         #ffffff         espn
#> 127         #f2a900         espn
#> 128         #0074c1         logo
#> 129         #6e9061         logo
#> 130            <NA>         logo
#> 131         #e9aa12         espn
#> 132         #445540         logo
#> 133         #36282a         logo
#> 134         #ffffff         espn
#> 135         #7b614e         logo
#> 136         #8d724b         espn
#> 137         #00316e         espn
#> 138         #ffffff         espn
#> 139         #4e4038         logo
#> 140         #00a3e0         espn
#> 141         #3e2728         logo
#> 142         #fec223         espn
#> 143         #2e1811         logo
#> 144         #000000         espn
#> 145         #6a5322         logo
#> 146         #edac09         espn
#> 147         #916b71         logo
#> 148         #0c233f         espn
#> 149         #000000         logo
#> 150         #cb152f         espn
#> 151         #cf9b63         logo
#> 152         #8e959a         espn
#> 153         #d1d5d8         espn
#> 154         #b4a169         espn
#> 155         #fbab18         espn
#> 156         #6f0924         logo
#> 157         #ffd600         logo
#> 158         #482e30         logo
#> 159         #f5ebb6         logo
#> 160         #ffdc00         logo
#> 161         #231f20         logo
#> 162         #ded090         espn
#> 163         #f2bb39         logo
#> 164         #ffffff         espn
#> 165            <NA>         espn
#> 166         #e00122         espn
#> 167         #97824a         logo
#> 168         #c8934a         espn
#> 169         #ffffff         espn
#> 170         #3f5572         logo
#> 171         #8694a0         logo
#> 172         #519682         logo
#> 173         #ffc72e         espn
#> 174         #ffffff         espn
#> 175         #232020         logo
#> 176         #fd6b0d         espn
#> 177         #e51837         espn
#> 178         #ffffff         espn
#> 179         #d51c28         espn
#> 180         #000000         espn
#> 181         #000000         logo
#> 182         #000000         espn
#> 183         #ffffff         espn
#> 184         #bec0c2         espn
#> 185         #b90b2e         espn
#> 186         #5e1725         logo
#> 187         #a6163d         espn
#> 188         #461d12         logo
#> 189         #ffc423         espn
#> 190         #e0ad13         espn
#> 191         #bebab9         espn
#> 192         #f0f0f0         espn
#> 193         #ffffff         espn
#> 194         #508f6b         logo
#> 195            <NA>         logo
#> 196         #b27f82         logo
#> 197         #6c207f         logo
#> 198         #7888ce         logo
#> 199         #ffb81c         espn
#> 200         #b59a57         espn
#> 201         #daad27         espn
#> 202         #7f6213         logo
#> 203         #13b5ea         espn
#> 204            <NA>         logo
#> 205         #a32638         espn
#> 206         #2d2521         logo
#> 207         #402301         logo
#> 208         #cc0000         espn
#> 209         #c3993f         espn
#> 210         #522d6e         logo
#> 211         #909090         espn
#> 212         #ecc86e         logo
#> 213         #2a307f         espn
#> 214         #fdd106         espn
#> 215         #6cb3e9         espn
#> 216         #fdbf57         logo
#> 217         #909090         espn
#> 218         #493a1a         logo
#> 219         #ecb010         espn
#> 220         #553628         logo
#> 221         #ffffff         espn
#> 222         #15569b         logo
#> 223         #4c7caf         logo
#> 224         #949300         espn
#> 225         #99757b         logo
#> 226         #d9dcdd         logo
#> 227         #000000         espn
#> 228         #dcddde         espn
#> 229            <NA>         espn
#> 230         #990000         espn
#> 231         #000000         logo
#> 232         #5ab3e8         espn
#> 233         #4a2a31         logo
#> 234         #bbbbbb         logo
#> 235         #382940         logo
#> 236            <NA>         espn
#> 237         #ffffff         espn
#> 238         #b09a5f         espn
#> 239         #c83f5a         logo
#> 240            <NA>         logo
#> 241         #ffe716         espn
#> 242         #8b6b74         logo
#> 243         #6e4b54         logo
#> 244         #fcd116         espn
#> 245         #b5b7ba         espn
#> 246         #ffb81a         espn
#> 247         #cabba8         logo
#> 248         #fed205         logo
#> 249         #e8000d         espn
#> 250         #e2e3e4         espn
#> 251         #eaab00         espn
#> 252         #ffffff         espn
#> 253         #006838         logo
#> 254         #473333         logo
#> 255         #a8a8aa         logo
#> 256         #f89828         espn
#> 257         #ebebeb         espn
#> 258            <NA>         logo
#> 259         #f1682a         logo
#> 260         #b69e70         espn
#> 261         #f0f0f0         espn
#> 262         #ffffff         espn
#> 263         #000000         espn
#> 264         #b72025         espn
#> 265         #05176f         logo
#> 266         #ffbf00         espn
#> 267         #cb333b         espn
#> 268         #8e908f         espn
#> 269         #eaa22e         espn
#> 270            <NA>         logo
#> 271         #dca71d         espn
#> 272         #000000         espn
#> 273         #fbea00         logo
#> 274         #231f20         logo
#> 275         #f0f0f0         espn
#> 276         #efc814         espn
#> 277         #000000         espn
#> 278         #fece1c         espn
#> 279         #c85e22         logo
#> 280            <NA>         espn
#> 281         #cfae70         espn
#> 282         #080808         espn
#> 283         #967d66         logo
#> 284         #66979b         logo
#> 285         #ffb81c         espn
#> 286         #035131         espn
#> 287         #453f32         logo
#> 288         #ffffff         espn
#> 289         #ffffff         espn
#> 290         #e3d100         logo
#> 291         #6e6697         logo
#> 292         #e19c25         espn
#> 293         #ffffff         espn
#> 294         #cf2d34         espn
#> 295         #005030         logo
#> 296         #0d6937         logo
#> 297            <NA>         espn
#> 298         #000000         espn
#> 299         #fed91a         espn
#> 300         #f47937         espn
#> 301            <NA>         logo
#> 302         #f5ce3e         espn
#> 303         #c1c6c8         espn
#> 304            <NA>         logo
#> 305            <NA>         logo
#> 306         #b5a67c         espn
#> 307         #c2c3c0         espn
#> 308         #a49665         espn
#> 309         #fdb913         espn
#> 310         #b4cbdb         logo
#> 311         #cac8c8         espn
#> 312         #8a8d8f         espn
#> 313         #ffc425         espn
#> 314         #fbbc20         espn
#> 315         #8a8c8f         espn
#> 316         #f0f0f0         espn
#> 317         #004684         espn
#> 318         #ffffff         espn
#> 319         #ffffff         espn
#> 320         #fdb813         espn
#> 321            <NA>         espn
#> 322         #ffc533         espn
#> 323         #000000         espn
#> 324         #ac9c66         espn
#> 325         #ffffff         espn
#> 326         #1b3069         espn
#> 327         #ed6118         espn
#> 328         #cdab6a         logo
#> 329         #000000         espn
#> 330         #826817         logo
#> 331         #ffffff         espn
#> 332         #fff41b         espn
#> 333         #000000         espn
#> 334         #002762         logo
#> 335         #ffffff         espn
#> 336         #ffc72c         espn
#> 337         #ebebeb         espn
#> 338         #eaaa00         espn
#> 339         #990134         espn
#> 340         #ffffff         espn
#> 341         #000000         espn
#> 342         #ffffff         espn
#> 343         #000000         espn
#> 344         #462d30         logo
#> 345         #002e5d         espn
#> 346         #a21d2b         espn
#> 347         #c4c6c8         espn
#> 348         #330a08         logo
#> 349         #c29472         espn
#> 350         #000000         espn
#> 351         #fdb913         espn
#> 352         #ffffff         espn
#> 353         #bc0023         espn
#> 354         #ffffff         espn
#> 355         #f78f1e         espn
#> 356         #ffc72c         espn
#> 357         #000000         espn
#> 358         #eca413         logo
#> 359         #a4753e         logo
#> 360         #5c3285         logo
#> 361         #163d6f         logo
#> 362         #ee3a43         logo
#> 363         #cbb677         espn
#> 364         #244a68         logo
#> 365         #f0b310         espn
#> 366         #0033a1         espn
#> 367         #ffd100         logo
#> 368         #104897         espn
#> 369         #b90b2e         espn
#> 370         #76819c         logo
#> 371         #ffd100         espn
#> 372         #231f20         espn
#> 373         #000000         espn
#> 374         #f84c1e         espn
#> 375         #ffc82d         espn
#> 376         #5f67a0         logo
#> 377         #231f20         logo
#> 378         #917aae         logo
#> 379         #beaa70         logo
#> 380         #ffcd00         espn
#> 381         #cf4520         espn
#> 382         #80a9cd         logo
#> 383            <NA>         logo
#> 384            <NA>         espn
#> 385         #f2a900         espn
#> 386         #7baed5         espn
#> 387         #195632         logo
#> 388         #bec0c2         espn
#> 389            <NA>         espn
#> 390         #ee7b87         logo
#> 391         #ffffff         espn
#> 392         #9578af         logo
#> 393         #ffffff         espn
#> 394         #d2b888         espn
#> 395         #102a5c         espn
#> 396         #ffffff         espn
#> 397         #f0f0f0         espn
#> 398         #ffde00         espn
#> 399         #f15a22         espn
#> 400            <NA>         logo
#> 401         #041e42         espn
#> 402         #000000         espn
#> 403         #e8d3a2         espn
#> 404         #ffffff         espn
#> 405         #000000         espn
#> 406         #002856         espn
#> 407         #00183e         logo
#> 408         #7b868c         logo
#> 409         #ffcd00         espn
#> 410         #4d4d4d         espn
#> 411            <NA>         logo
#> 412         #b1b1b1         espn
#> 413         #c4b6d4         logo
#> 414         #418fde         espn
#> 415         #efad00         logo
#> 416            <NA>         logo
#> 417         #39524f         logo
#> 418         #fcb034         espn
#> 419         #000000         espn
#> 420            <NA>         espn
#> 421         #261e1f         logo
#> 422         #000000         espn
#> 423         #215379         logo
#> 424         #ffffff         espn
#> 425         #b7986b         logo
#> 426         #000000         espn
#> 427         #231f20         logo
#> 428         #6a8bb0         logo
#> 429         #d8d8d8         espn
#> 430         #ebebeb         espn
#> 431         #ffffff         espn
#> 432         #db1a21         espn
#> 433         #050707         logo
#> 434         #f5cc2e         espn
#> 435         #a87477         logo
#> 436         #3a231c         logo
#> 437         #d9b962         logo
#> 438            <NA>         logo
#> 439         #f0b310         logo
#> 440         #7d7149         logo
#> 441         #febc28         logo
#> 442         #ffc90a         espn
#> 443         #f1c500         espn
#> 444         #5f6062         logo
#> 445         #bf9e70         espn
#> 446         #8cbbdd         logo
#> 447         #000000         espn
#> 448         #936c74         logo
#> 449         #fdc743         espn
#> 450         #f0b323         espn
#> 451         #ffbe0a         espn
#> 452         #015f52         logo
#> 453            <NA>         espn
#> 454         #f2b310         logo
#> 455         #fde133         logo
#> 456            <NA>         logo
#> 457         #000000         espn
#> 458         #ffde00         logo
#> 459         #bdbec0         logo
#> 460         #a2a9ad         logo
#> 461            <NA>         logo
#> 462         #f0f0f0         espn
#> 463         #5e2921         logo
#> 464         #db8b99         logo
#> 465         #ffffff         espn
#> 466         #ffc425         espn
#> 467         #690717         espn
#> 468         #ffd10a         espn
#> 469         #a2aaad         espn
#> 470         #b5985b         espn
#> 471         #000000         espn
#> 472         #002855         espn
#> 473         #e8c535         espn
#> 474         #aa8800         logo
#> 475         #ac1f2d         logo
#> 476         #13284c         espn
#> 477         #fbcd20         logo
#> 478         #38050a         logo
#> 479         #472766         logo
#> 480         #80143e         logo
#> 481         #b59859         espn
#> 482         #9f8343         espn
#> 483         #012e64         logo
#> 484         #8e4f53         logo
#> 485         #e6b71b         espn
#> 486         #fec52f         espn
#> 487         #0a2343         logo
#> 488         #6c6146         logo
#> 489         #cfb97a         logo
#> 490         #000000         logo
#> 491         #53585a         espn
#> 492         #f0f0f0         espn
#> 493         #000000         espn
#> 494         #8d1d25         logo
#> 495         #00205c         logo
#> 496         #432014         logo
#> 497         #ffcf06         espn
#> 498         #003679         logo
#> 499         #5b6a78         logo
#> 500         #fdbd54         logo
#> 501         #d7a0a5         logo
#> 502         #00386c         logo
#> 503         #bca233         logo
#> 504         #000000         espn
#> 505            <NA>         espn
#> 506         #000000         espn
#> 507         #ffffff         espn
#> 508         #453c1c         logo
#> 509         #221e1f         logo
#> 510         #96777a         logo
#> 511         #4b708e         logo
#> 512         #b29547         espn
#> 513         #b9a3db         logo
#> 514         #231f20         logo
#> 515         #f3d00b         logo
#> 516         #ffffff         espn
#> 517         #29618a         logo
#> 518            <NA>         logo
#> 519         #070909         logo
#> 520         #000000         espn
#> 521         #15223b         logo
#> 522         #f6cd55         logo
#> 523         #56353e         logo
#> 524         #8f7fbc         logo
#> 525            <NA>         logo
#> 526         #ffffff         espn
#> 527         #a3aaae         espn
#> 528         #7b5b95         logo
#> 529         #000000         espn
#> 530         #00583d         logo
#> 531         #bdb096         logo
#> 532         #ffd203         logo
#> 533         #7386a2         logo
#> 534         #080808         espn
#> 535         #b47b7d         logo
#> 536         #e1732d         espn
#> 537         #f7941e         espn
#> 538         #a1a1a5         logo
#> 539         #231f20         logo
#> 540         #ab9e76         espn
#> 541         #b0b1b2         logo
#> 542         #566f7c         logo
#> 543         #a1d2f1         espn
#> 544         #00275d         logo
#> 545         #4d5051         logo
#> 546         #c8c8c8         espn
#> 547         #edd38b         logo
#> 548         #ebb700         espn
#> 549         #0066b7         logo
#> 550         #a8b1b7         espn
#> 551         #f57b21         espn
#> 552         #000000         espn
#> 553         #0d1d41         logo
#> 554         #fecd01         espn
#> 555         #912429         logo
#> 556         #9d6374         logo
#> 557         #ffc72c         espn
#> 558            <NA>         espn
#> 559         #c3c4c6         espn
#> 560         #e9a126         espn
#> 561         #46927e         logo
#> 562         #093254         logo
#> 563         #4e1827         logo
#> 564         #ffcc1e         logo
#> 565         #000000         espn
#> 566         #003058         logo
#> 567            <NA>         espn
#> 568         #2f6d51         logo
#> 569         #7b95a7         logo
#> 570         #0094d2         logo
#> 571         #d0d1d4         logo
#> 572         #000000         logo
#> 573         #002b5c         logo
#> 574         #a59474         espn
#> 575         #a5a6a9         espn
#> 576         #c38d97         logo
#> 577         #a27752         espn
#> 578            <NA>         logo
#> 579         #6a5638         espn
#> 580         #ffffff         espn
#> 581         #ffffff         espn
#> 582         #3b3128         logo
#> 583         #abb4bc         espn
#> 584         #372427         logo
#> 585         #ffffff         espn
#> 586         #000000         espn
#> 587         #0b1315         espn
#> 588         #000000         espn
#> 589            <NA>         logo
#> 590         #c1c6c8         espn
#> 591         #d5b98b         espn
#> 592         #d3bc8d         espn
#> 593         #c1b585         espn
#> 594         #3e334b         logo
#> 595            <NA>         logo
#> 596         #13294b         espn
#> 597         #e61b24         logo
#> 598         #c8c372         espn
#> 599         #df983a         logo
#> 600         #c0a656         espn
#> 601         #8d5833         logo
#> 602         #482325         logo
#> 603         #ffcb00         logo
#> 604         #d1ab42         logo
#> 605         #000000         espn
#> 606         #ba8e91         logo
#> 607         #ffffff         espn
#> 608         #aed1e8         logo
#> 609         #e55204         logo
#> 610         #ecb434         logo
#> 611         #95502a         logo
#> 612         #ffcd00         espn
#> 613         #ffffff         espn
#> 614         #ffffff         espn
#> 615         #ffc629         espn
#> 616         #b1b3b3         espn
#> 617         #a2aaad         espn
#> 618         #000000         espn
#> 619         #c2a303         espn
#> 620         #01295c         logo
#> 621         #000000         logo
#> 622         #6e648e         logo
#> 623         #fee44e         logo
#> 624         #642b8a         logo
#> 625         #000000         logo
#> 626         #286dc0         espn
#> 627         #ffffff         espn
#> 628         #9ba19e         logo
#> 629         #242021         logo
#> 630         #003868         logo
#> 631            <NA>         logo
#> 632         #001c58         espn
#> 633         #e51937         espn
#> 634         #000000         espn
#> 635         #ffd200         espn
#> 636            <NA>         logo
#> 637         #3d1950         logo
#> 638         #fdb913         espn
#> 639         #00843d         espn
#> 640         #ffffff         espn
#> 641         #00529f         logo
#> 642         #ceb888         espn
#> 643         #024c8d         logo
#> 644         #3f1d20         logo
#> 645         #000000         espn
#> 646         #ad7c70         logo
#> 647         #56854e         espn
#> 648         #df6979         logo
#> 649         #fa4616         espn
#> 650         #cfc493         espn
#> 651         #c79e54         logo
#> 652         #ffffff         espn
#> 653         #bf0d3e         espn
#> 654            <NA>         logo
#> 655         #2c2a29         espn
#> 656         #fbda87         logo
#> 657            <NA>         logo
#> 658         #000000         espn
#> 659         #001440         espn
#> 660         #091b3b         logo
#> 661         #bd7a76         logo
#> 662         #ffc72a         espn
#> 663         #a5bbda         espn
#> 664         #d64309         espn
#> 665         #c9bb93         logo
#> 666         #ffffff         espn
#> 667         #8c6e4a         espn
#> 668         #0c213e         logo
#> 669            <NA>         logo
#> 670         #fed00a         logo
#> 671         #ffffff         espn
#> 672         #c2c3c0         espn
#> 673         #ffffff         espn
#> 674         #311b20         logo
#> 675         #bbbbbb         logo
#> 676         #8b7a42         logo
#> 677         #ffffff         espn
#> 678         #b3b2b1         espn
#> 679         #c99700         espn
#> 680            <NA>         logo
#> 681         #8c1d40         espn
#> 682         #ffd203         logo
#> 683         #000e00         espn
#> 684         #ffffff         espn
#> 685         #ffffff         espn
#> 686         #ffffff         espn
#> 687         #fdd023         espn
#> 688         #e2201b     cbbplotR
#> 689            <NA>     cbbplotR
#> 690            <NA>     cbbplotR
#> 691         #43c6e7     cbbplotR
#> 692            <NA>     cbbplotR
#> 693            <NA>     cbbplotR
#> 694         #e31c47     cbbplotR
#> 695         #59a14f     fallback
#> 696         #bab0ac     fallback
#> 697            <NA>     cbbplotR
#> 698         #0c2140     cbbplotR
#> 699         #feb81d     cbbplotR
#> 700         #bab0ac     fallback
#> 701         #afafaf     cbbplotR
#> 702            <NA>     cbbplotR
#> 703         #d0ae85     cbbplotR
#> 704            <NA>     cbbplotR
#> 705         #d9291c     cbbplotR
#> 706         #9c755f     fallback
#> 707         #ffd040     cbbplotR
#> 708            <NA>     cbbplotR
#> 709            <NA>     cbbplotR
#> 710            <NA>     cbbplotR
#> 711         #f5a606     cbbplotR
#> 712            <NA>     cbbplotR
```
