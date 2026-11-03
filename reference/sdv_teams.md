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
#>     league            team_id               abbr
#> 1      cfb                101               ERKA
#> 2      cfb             101442               CTLA
#> 3      cfb             101784               ERSK
#> 4      cfb                103                 BC
#> 5      cfb                107                 HC
#> 6      cfb                108               HARV
#> 7      cfb                109                MIT
#> 8      cfb                 11               COMU
#> 9      cfb                110                MMT
#> 10     cfb             110242                UWF
#> 11     cfb             110243               UTPB
#> 12     cfb             110438               DEAN
#> 13     cfb             111610               STAU
#> 14     cfb             111674               ALVR
#> 15     cfb             111675                UNE
#> 16     cfb                112               TUFT
#> 17     cfb             112334                 FP
#> 18     cfb             112335               WHLG
#> 19     cfb                113               MASS
#> 20     cfb                114               FBSU
#> 21     cfb                118                JHU
#> 22     cfb                119                TOW
#> 23     cfb                 12               ARIZ
#> 24     cfb                120                 MD
#> 25     cfb                121               BATE
#> 26     cfb             122666               BART
#> 27     cfb             122774               KYSN
#> 28     cfb             123086               NAMU
#> 29     cfb                124               AUGS
#> 30     cfb             124179               LNCA
#> 31     cfb             124180               BLUS
#> 32     cfb                125               GVSU
#> 33     cfb             125974               HLBT
#> 34     cfb                126               KALC
#> 35     cfb             126086               POST
#> 36     cfb                127                MSU
#> 37     cfb             127954                 EU
#> 38     cfb                128                NMI
#> 39     cfb                129               SVSU
#> 40     cfb             129469               ANSC
#> 41     cfb             129738               CALU
#> 42     cfb                 13                 CP
#> 43     cfb                130               MICH
#> 44     cfb                131               WSMI
#> 45     cfb                132                BST
#> 46     cfb                133               OLAF
#> 47     cfb                134                UMD
#> 48     cfb                135               MINN
#> 49     cfb                137               MOWE
#> 50     cfb                138               MWMO
#> 51     cfb                142                MIZ
#> 52     cfb                143               WUMO
#> 53     cfb                145               MISS
#> 54     cfb                146                GRO
#> 55     cfb                147               MTST
#> 56     cfb                149               MONT
#> 57     cfb                150               DUKE
#> 58     cfb                151                ECU
#> 59     cfb                152               NCSU
#> 60     cfb                153                UNC
#> 61     cfb                154               WAKE
#> 62     cfb                155                UND
#> 63     cfb                158                NEB
#> 64     cfb                159               DART
#> 65     cfb                 16                SAC
#> 66     cfb                160                UNH
#> 67     cfb                162               HMLN
#> 68     cfb                163               PRIN
#> 69     cfb                164               RUTG
#> 70     cfb                166               NMSU
#> 71     cfb                167                UNM
#> 72     cfb                 17                CMS
#> 73     cfb                171               COLU
#> 74     cfb                172                COR
#> 75     cfb                173               HRTW
#> 76     cfb                174               HBRT
#> 77     cfb                175                ITH
#> 78     cfb                 18               BRIS
#> 79     cfb                183                SYR
#> 80     cfb                184               URNY
#> 81     cfb                188                 BW
#> 82     cfb                189               BGSU
#> 83     cfb                190                DEF
#> 84     cfb                191               HDBG
#> 85     cfb                193               M-OH
#> 86     cfb                194                OSU
#> 87     cfb                195               OHIO
#> 88     cfb                196               NESU
#> 89     cfb                197               OKST
#> 90     cfb                199               SEOK
#> 91     cfb                  2                AUB
#> 92     cfb                200                SNU
#> 93     cfb               2000                ACU
#> 94     cfb               2001               ADSU
#> 95     cfb               2003                ADR
#> 96     cfb               2005                 AF
#> 97     cfb               2006                AKR
#> 98     cfb                201                 OU
#> 99     cfb               2010               AAMU
#> 100    cfb               2011               ALST
#> 101    cfb               2013               ABSU
#> 102    cfb               2015               ALBR
#> 103    cfb               2016               ALCN
#> 104    cfb               2018               ALLG
#> 105    cfb               2019               ALNU
#> 106    cfb                202               TLSA
#> 107    cfb               2022                AIC
#> 108    cfb               2023               ANIN
#> 109    cfb               2025               AGSU
#> 110    cfb               2026                APP
#> 111    cfb               2028                UAM
#> 112    cfb               2029               UAPB
#> 113    cfb                203               LINF
#> 114    cfb               2032               ARST
#> 115    cfb               2033               ARTE
#> 116    cfb               2038                ASP
#> 117    cfb                204               ORST
#> 118    cfb               2042               AUGC
#> 119    cfb               2043               AUSD
#> 120    cfb               2044                AUR
#> 121    cfb               2045                AUS
#> 122    cfb               2046               APSU
#> 123    cfb               2047               AVER
#> 124    cfb               2049                APU
#> 125    cfb                205               PCOR
#> 126    cfb               2050               BALL
#> 127    cfb               2056               BELH
#> 128    cfb               2060               BENT
#> 129    cfb               2062               BCWV
#> 130    cfb               2064               BTTN
#> 131    cfb               2065                BCU
#> 132    cfb               2069               BHSU
#> 133    cfb               2071                BBU
#> 134    cfb               2074                BLF
#> 135    cfb               2075               BOWE
#> 136    cfb               2079                BRI
#> 137    cfb               2083               BUCK
#> 138    cfb               2084                BUF
#> 139    cfb               2085                BSU
#> 140    cfb               2086               BTLR
#> 141    cfb                209                LHU
#> 142    cfb               2094                CLU
#> 143    cfb               2097                CAM
#> 144    cfb                 21               SDSU
#> 145    cfb                210               MILL
#> 146    cfb               2101                CAR
#> 147    cfb               2102               CGMU
#> 148    cfb               2105                 CN
#> 149    cfb               2106                CCW
#> 150    cfb               2107                CAT
#> 151    cfb               2108               CATH
#> 152    cfb               2110               CARK
#> 153    cfb               2115               CCSU
#> 154    cfb               2116                UCF
#> 155    cfb               2117                CMU
#> 156    cfb               2118                UCM
#> 157    cfb               2119               CNSU
#> 158    cfb               2120               CWAU
#> 159    cfb               2121                CCO
#> 160    cfb               2122                UCO
#> 161    cfb               2123               CHAD
#> 162    cfb               2127               CHSO
#> 163    cfb               2128               UCWV
#> 164    cfb                213                PSU
#> 165    cfb               2130               CHST
#> 166    cfb               2132                CIN
#> 167    cfb               2134               CLRN
#> 168    cfb               2141                COE
#> 169    cfb               2142               COLG
#> 170    cfb               2146               CMIN
#> 171    cfb               2148               CONC
#> 172    cfb                215                SRU
#> 173    cfb               2151                CUC
#> 174    cfb               2152               CCMN
#> 175    cfb               2155               CNIA
#> 176    cfb                216               SUSQ
#> 177    cfb               2166                DAV
#> 178    cfb               2168                DAY
#> 179    cfb               2169                DSU
#> 180    cfb               2170               DLST
#> 181    cfb               2171                DSN
#> 182    cfb               2175               DKSN
#> 183    cfb                218                TEM
#> 184    cfb               2181               DRKE
#> 185    cfb               2184                DUQ
#> 186    cfb               2188                ESU
#> 187    cfb                219               PENN
#> 188    cfb               2191               ECNU
#> 189    cfb               2193               ETSU
#> 190    cfb               2194               ETBU
#> 191    cfb               2197                EIU
#> 192    cfb               2198                EKU
#> 193    cfb               2199                EMU
#> 194    cfb               2201               ENMU
#> 195    cfb               2202               EORE
#> 196    cfb               2205               EDBR
#> 197    cfb               2206                EDW
#> 198    cfb               2207               ECSU
#> 199    cfb                221               PITT
#> 200    cfb               2210               ELON
#> 201    cfb               2213                EHC
#> 202    cfb               2214               EMSU
#> 203    cfb                222               VILL
#> 204    cfb               2220               FAYU
#> 205    cfb               2221               FDUF
#> 206    cfb               2222               FRST
#> 207    cfb               2224                 UF
#> 208    cfb               2226                FAU
#> 209    cfb               2229                FIU
#> 210    cfb                223               WCHT
#> 211    cfb               2230                FOR
#> 212    cfb               2231               FHSU
#> 213    cfb               2232               FVSU
#> 214    cfb               2233               FRKL
#> 215    cfb               2234                FMC
#> 216    cfb               2237               FLWC
#> 217    cfb               2241               GWEB
#> 218    cfb               2242                GEN
#> 219    cfb               2244                GMU
#> 220    cfb               2245               GTKY
#> 221    cfb               2247               GAST
#> 222    cfb               2248               GTYB
#> 223    cfb               2249               GVLS
#> 224    cfb                225               BRWN
#> 225    cfb               2254          GRANDVIEW
#> 226    cfb               2256               GRNB
#> 227    cfb               2257               GRNV
#> 228    cfb               2258               GLFD
#> 229    cfb               2261               HAMP
#> 230    cfb               2262               HNVR
#> 231    cfb               2264               HARD
#> 232    cfb                227                URI
#> 233    cfb               2271               HSTU
#> 234    cfb               2273               HLDL
#> 235    cfb               2274               HIRM
#> 236    cfb               2277                HCU
#> 237    cfb                228               CLEM
#> 238    cfb               2280               HUSS
#> 239    cfb               2283               BNIL
#> 240    cfb               2286               ILLC
#> 241    cfb               2287               ILST
#> 242    cfb               2291                IUP
#> 243    cfb               2292               INDY
#> 244    cfb               2294               IOWA
#> 245    cfb               2296               JKST
#> 246    cfb                 23               SJSU
#> 247    cfb               2302                JCU
#> 248    cfb               2304               JCSU
#> 249    cfb               2305                 KU
#> 250    cfb               2306                KSU
#> 251    cfb               2309               KENT
#> 252    cfb                231                FUR
#> 253    cfb               2310               KYSU
#> 254    cfb               2315               KUTZ
#> 255    cfb               2316                KWC
#> 256    cfb               2318                ULV
#> 257    cfb               2320                LAM
#> 258    cfb               2323               LANE
#> 259    cfb               2324               LNGT
#> 260    cfb               2329                LEH
#> 261    cfb                233               SDAK
#> 262    cfb               2331               LENR
#> 263    cfb               2333                 LC
#> 264    cfb               2335                LIB
#> 265    cfb               2339               LNPA
#> 266    cfb               2341                LIU
#> 267    cfb               2348                 LT
#> 268    cfb                235                MEM
#> 269    cfb               2354               LYCO
#> 270    cfb               2359                MAC
#> 271    cfb                236                UTC
#> 272    cfb               2362               MNCH
#> 273    cfb               2364               MNST
#> 274    cfb               2365               MNFD
#> 275    cfb               2368               MRST
#> 276    cfb               2369                MHU
#> 277    cfb                237               UNNY
#> 278    cfb               2371                MHB
#> 279    cfb               2373               MCTN
#> 280    cfb               2377                MCN
#> 281    cfb                238                VAN
#> 282    cfb               2382                MER
#> 283    cfb               2383                MMA
#> 284    cfb               2385               MERC
#> 285    cfb                239                BAY
#> 286    cfb               2390                MIA
#> 287    cfb               2392                MTU
#> 288    cfb               2393               MTSU
#> 289    cfb               2394               MIDB
#> 290    cfb               2396               MILE
#> 291    cfb               2398               MLSP
#> 292    cfb               2399               MNMO
#> 293    cfb                 24               STAN
#> 294    cfb               2400               MVSU
#> 295    cfb               2402               MS&T
#> 296    cfb               2403               MSSU
#> 297    cfb               2405               MONM
#> 298    cfb                241                MCM
#> 299    cfb               2413               MORE
#> 300    cfb               2415               MORG
#> 301    cfb               2416               MNGS
#> 302    cfb               2419                MSJ
#> 303    cfb                242               RICE
#> 304    cfb               2422               MUHL
#> 305    cfb               2424               NMHU
#> 306    cfb               2426               NAVY
#> 307    cfb               2428               NCCU
#> 308    cfb               2429                CLT
#> 309    cfb               2433                ULM
#> 310    cfb               2438               NEBK
#> 311    cfb               2439               UNLV
#> 312    cfb               2440                NEV
#> 313    cfb               2441               NHVN
#> 314    cfb               2442               TCNJ
#> 315    cfb               2444               NBRY
#> 316    cfb               2447               NICH
#> 317    cfb               2448               NCAT
#> 318    cfb               2449               NDSU
#> 319    cfb                245               TA&M
#> 320    cfb               2450               NORF
#> 321    cfb               2453                UNA
#> 322    cfb               2458               UNCO
#> 323    cfb               2459                NIU
#> 324    cfb                246                JUN
#> 325    cfb               2460                UNI
#> 326    cfb               2464                NAU
#> 327    cfb               2466               NWST
#> 328    cfb               2467               NWCH
#> 329    cfb                247               KNGS
#> 330    cfb               2477               OHDU
#> 331    cfb                248                HOU
#> 332    cfb               2483                ORE
#> 333    cfb               2486               PCLT
#> 334    cfb               2487               PACE
#> 335    cfb                249                UNT
#> 336    cfb                 25                CAL
#> 337    cfb               2502               PRST
#> 338    cfb               2504                 PV
#> 339    cfb               2506               PRES
#> 340    cfb               2508                PUG
#> 341    cfb               2509                PUR
#> 342    cfb                251                TEX
#> 343    cfb               2516                RMC
#> 344    cfb               2519               RHDS
#> 345    cfb                252                BYU
#> 346    cfb               2523                RMU
#> 347    cfb               2524                RFU
#> 348    cfb               2528                RPI
#> 349    cfb               2529                SHU
#> 350    cfb                253                SUU
#> 351    cfb               2532                SAL
#> 352    cfb               2534               SHSU
#> 353    cfb               2535                SAM
#> 354    cfb                254               UTAH
#> 355    cfb               2542                SAV
#> 356    cfb               2545               SELA
#> 357    cfb               2546               SEMO
#> 358    cfb                255               KNOX
#> 359    cfb               2551               SHAW
#> 360    cfb               2553               SEWA
#> 361    cfb               2557               USCG
#> 362    cfb               2559               SHIP
#> 363    cfb                256                JMU
#> 364    cfb               2560               SHOU
#> 365    cfb               2564               SCIA
#> 366    cfb               2567                SMU
#> 367    cfb               2568                SAR
#> 368    cfb               2569               SCST
#> 369    cfb                257               RICH
#> 370    cfb               2570               CSUP
#> 371    cfb               2571               SDST
#> 372    cfb               2572                USM
#> 373    cfb               2579                 SC
#> 374    cfb                258                UVA
#> 375    cfb               2582                SOU
#> 376    cfb               2583               SCTS
#> 377    cfb               2584                SOR
#> 378    cfb               2586               SWBU
#> 379    cfb               2587               SWMS
#> 380    cfb               2588                SWU
#> 381    cfb                259                 VT
#> 382    cfb               2591               STAM
#> 383    cfb               2595               SFIL
#> 384    cfb               2598               SFPA
#> 385    cfb                 26               UCLA
#> 386    cfb               2600               STJM
#> 387    cfb               2614                SVC
#> 388    cfb               2617                SFA
#> 389    cfb               2619               STBK
#> 390    cfb                262                LFC
#> 391    cfb               2623               MOST
#> 392    cfb               2627                TAR
#> 393    cfb               2628                TCU
#> 394    cfb                263                LOR
#> 395    cfb               2630                UTM
#> 396    cfb               2633               TENN
#> 397    cfb               2634               TNST
#> 398    cfb               2635               TNTC
#> 399    cfb               2636               UTSA
#> 400    cfb               2637               TXCL
#> 401    cfb               2638               UTEP
#> 402    cfb               2639               TXLU
#> 403    cfb                264               WASH
#> 404    cfb               2640               TXSO
#> 405    cfb               2641                TTU
#> 406    cfb               2643                CIT
#> 407    cfb               2644                THI
#> 408    cfb               2646               TMOR
#> 409    cfb               2649                TOL
#> 410    cfb                265                WSU
#> 411    cfb               2651               TRNE
#> 412    cfb               2653               TROY
#> 413    cfb               2654               TRST
#> 414    cfb               2655               TULN
#> 415    cfb               2657               TUSK
#> 416    cfb               2658               TAMK
#> 417    cfb                266               BELO
#> 418    cfb               2667               URSN
#> 419    cfb               2673               VALD
#> 420    cfb               2674                VAL
#> 421    cfb               2676                VUU
#> 422    cfb               2678                VMI
#> 423    cfb                268                LAW
#> 424    cfb               2681                WAG
#> 425    cfb               2682               WLSH
#> 426    cfb               2685               WTBG
#> 427    cfb               2686                W&J
#> 428    cfb               2687               WSBN
#> 429    cfb               2688                W&L
#> 430    cfb               2692                WEB
#> 431    cfb               2695                UWA
#> 432    cfb               2698                WGA
#> 433    cfb               2699                WLU
#> 434    cfb               2700                MCD
#> 435    cfb               2701                UMW
#> 436    cfb               2702                WNE
#> 437    cfb               2703               WNMU
#> 438    cfb               2704               WTAM
#> 439    cfb               2706               WVUT
#> 440    cfb               2707               WVSU
#> 441    cfb                271                UWO
#> 442    cfb               2710                WIU
#> 443    cfb               2711                WMU
#> 444    cfb               2714               WCOL
#> 445    cfb               2717                WCU
#> 446    cfb                272                UWP
#> 447    cfb               2721               WHIW
#> 448    cfb               2723               UWRF
#> 449    cfb               2725               WIDE
#> 450    cfb               2729                W&M
#> 451    cfb               2731                WLM
#> 452    cfb               2733               WCOH
#> 453    cfb               2736               WSSU
#> 454    cfb               2738               UWEC
#> 455    cfb                274               UMMA
#> 456    cfb               2740                UWL
#> 457    cfb               2741                WLC
#> 458    cfb               2743               UWSP
#> 459    cfb               2744               UWST
#> 460    cfb               2745                UWW
#> 461    cfb               2746               WITT
#> 462    cfb               2747                WOF
#> 463    cfb               2748                WOO
#> 464    cfb               2749                WPI
#> 465    cfb                275                WIS
#> 466    cfb               2751                WYO
#> 467    cfb               2754                YSU
#> 468    cfb               2755               GRAM
#> 469    cfb               2757               BERR
#> 470    cfb               2758               HWPU
#> 471    cfb                276               MRSH
#> 472    cfb                277                WVU
#> 473    cfb               2771               MRMK
#> 474    cfb               2776               SALV
#> 475    cfb               2779                USL
#> 476    cfb                278               FRES
#> 477    cfb               2781                BRO
#> 478    cfb               2782               NYCL
#> 479    cfb               2790               ALBI
#> 480    cfb               2800               ALMA
#> 481    cfb               2802               BUMN
#> 482    cfb               2803                BRY
#> 483    cfb               2804               CWAN
#> 484    cfb               2805               CKGA
#> 485    cfb               2808                DVU
#> 486    cfb               2810                HSU
#> 487    cfb               2812               HOPE
#> 488    cfb               2815                LIN
#> 489    cfb               2816                MCK
#> 490    cfb               2817               MSUM
#> 491    cfb               2818               MCST
#> 492    cfb                282               INST
#> 493    cfb               2822                NGU
#> 494    cfb               2823               NWOK
#> 495    cfb               2824               OPSU
#> 496    cfb               2825                QUI
#> 497    cfb               2827                ROW
#> 498    cfb               2828               SHEN
#> 499    cfb               2830               SANS
#> 500    cfb               2832               STNC
#> 501    cfb               2834               SRST
#> 502    cfb               2837               ETAM
#> 503    cfb               2838               TIFF
#> 504    cfb               2839               TUSC
#> 505    cfb                284                STO
#> 506    cfb               2842               UVAW
#> 507    cfb               2843               WCSU
#> 508    cfb               2844               WSNE
#> 509    cfb               2845               WAYN
#> 510    cfb               2848               WORU
#> 511    cfb               2849               WCPA
#> 512    cfb               2850               WHTR
#> 513    cfb               2851               WNST
#> 514    cfb               2858               CAPA
#> 515    cfb                286                NCW
#> 516    cfb               2871               KEAN
#> 517    cfb               2876               LNMO
#> 518    cfb               2880               MOBU
#> 519    cfb               2882               UNCP
#> 520    cfb               2884               NICC
#> 521    cfb               2886                NWD
#> 522    cfb               2888                OBU
#> 523    cfb               2891                RIP
#> 524    cfb               2894                SFU
#> 525    cfb               2896               SOVA
#> 526    cfb                 29               REDL
#> 527    cfb                290               GASO
#> 528    cfb               2900               STMN
#> 529    cfb               2909               WFST
#> 530    cfb                291                 MU
#> 531    cfb               2911                WJC
#> 532    cfb               2912               WPEN
#> 533    cfb               2913                BRE
#> 534    cfb               2916                UIW
#> 535    cfb               2919               MNIL
#> 536    cfb                292                RGV
#> 537    cfb               2923               POPI
#> 538    cfb               2927               SOSU
#> 539    cfb                293               VTSC
#> 540    cfb               2930               WLMT
#> 541    cfb               2938               HNTC
#> 542    cfb               2940                LIV
#> 543    cfb                295                ODU
#> 544    cfb               2951               NYMT
#> 545    cfb               2963               CWRU
#> 546    cfb               2964               CNTC
#> 547    cfb               2967               FRSU
#> 548    cfb               2968                GAC
#> 549    cfb               2969               MISE
#> 550    cfb                297                HSC
#> 551    cfb               2970                WPU
#> 552    cfb               2972               PLYM
#> 553    cfb               2974               SHEP
#> 554    cfb               2977               TCCT
#> 555    cfb               2980                OWU
#> 556    cfb               2986               FMSU
#> 557    cfb                 30                USC
#> 558    cfb                301                USD
#> 559    cfb                302                UCD
#> 560    cfb                304               IDST
#> 561    cfb                306               ILWU
#> 562    cfb               3066                CSP
#> 563    cfb               3071                NCC
#> 564    cfb                308                ASH
#> 565    cfb                309                 UL
#> 566    cfb               3101                UTU
#> 567    cfb                311                 ME
#> 568    cfb               3110               NYMS
#> 569    cfb               3112                CNU
#> 570    cfb               3162               AFST
#> 571    cfb                317               MRTT
#> 572    cfb                319               OKBU
#> 573    cfb                 32                CRU
#> 574    cfb                322                LAF
#> 575    cfb                323                MOR
#> 576    cfb               3237               HVCC
#> 577    cfb                324                CCU
#> 578    cfb               3253              COLLE
#> 579    cfb                326               TXST
#> 580    cfb                328                USU
#> 581    cfb                 33               CLBY
#> 582    cfb                330                VSU
#> 583    cfb                331                EWU
#> 584    cfb                332                MSK
#> 585    cfb                333                ALA
#> 586    cfb                336               WSCT
#> 587    cfb                338               KENN
#> 588    cfb                340                BOW
#> 589    cfb                341               FSTU
#> 590    cfb                344               MSST
#> 591    cfb                348                HAM
#> 592    cfb                349               ARMY
#> 593    cfb                351               WINU
#> 594    cfb                352                KNY
#> 595    cfb                354                UOO
#> 596    cfb                356                ILL
#> 597    cfb                359               OTTB
#> 598    cfb                 36                CSU
#> 599    cfb                365               ALFR
#> 600    cfb                366                 FC
#> 601    cfb                367               GANN
#> 602    cfb                374               STJF
#> 603    cfb                375                CSS
#> 604    cfb                379               MDAR
#> 605    cfb                 38               COLO
#> 606    cfb                386               TUTX
#> 607    cfb                388                LVC
#> 608    cfb                389                UIU
#> 609    cfb                390               UTIC
#> 610    cfb                391                OBE
#> 611    cfb                396               WCIL
#> 612    cfb                398               WILK
#> 613    cfb                399               UALB
#> 614    cfb                 40                 CC
#> 615    cfb                402               WORC
#> 616    cfb                409                CUW
#> 617    cfb                 41               CONN
#> 618    cfb                411               CHAP
#> 619    cfb                415                GFU
#> 620    cfb                417               GLDT
#> 621    cfb                418                HDX
#> 622    cfb                424               CAPU
#> 623    cfb                425                NSU
#> 624    cfb                426                UMU
#> 625    cfb                427               OHNU
#> 626    cfb                 43               YALE
#> 627    cfb                433               WCMO
#> 628    cfb                437               LKER
#> 629    cfb                446                MLC
#> 630    cfb                452               ENDC
#> 631    cfb                455               WVWC
#> 632    cfb                 46               GTWN
#> 633    cfb                 47                HOW
#> 634    cfb                471               STVS
#> 635    cfb                 48                DEL
#> 636    cfb                 49                DBQ
#> 637    cfb                490                BEN
#> 638    cfb                  5                UAB
#> 639    cfb                 50               FAMU
#> 640    cfb                509               CRWN
#> 641    cfb                512              DAKOT
#> 642    cfb                 52                FSU
#> 643    cfb                530                GRC
#> 644    cfb                548                LGC
#> 645    cfb                 55               JXST
#> 646    cfb                559               MARY
#> 647    cfb                 56               STET
#> 648    cfb                568               MINS
#> 649    cfb                 57                FLA
#> 650    cfb                 58                USF
#> 651    cfb                583                UNW
#> 652    cfb                 59                 GT
#> 653    cfb                  6                USA
#> 654    cfb                 60               MRHO
#> 655    cfb                 61                UGA
#> 656    cfb                611               SEHI
#> 657    cfb                613               SDMT
#> 658    cfb                 62                HAW
#> 659    cfb                 63                BVU
#> 660    cfb               6353               LKLD
#> 661    cfb                 65               GRNL
#> 662    cfb                 66                ISU
#> 663    cfb                 67               LUTH
#> 664    cfb                 68               BOIS
#> 665    cfb               6845                NWU
#> 666    cfb                  7                AMH
#> 667    cfb                 70               IDHO
#> 668    cfb                 72               ELMH
#> 669    cfb                 74               MILK
#> 670    cfb                 75                NPU
#> 671    cfb                 77                 NU
#> 672    cfb                 79                SIU
#> 673    cfb                  8                ARK
#> 674    cfb                 80                CHI
#> 675    cfb                 81                SPR
#> 676    cfb                 83                DPU
#> 677    cfb                 84                 IU
#> 678    cfb                 86               RHIT
#> 679    cfb                 87                 ND
#> 680    cfb                 89                WAB
#> 681    cfb                  9                ASU
#> 682    cfb                 90               PTSU
#> 683    cfb                 93                MUR
#> 684    cfb                 96                 UK
#> 685    cfb                 97                LOU
#> 686    cfb                 98                WKU
#> 687    cfb                 99                LSU
#> 688    cfb                AAC                AAC
#> 689    cfb                ACC                ACC
#> 690    cfb                ASC                ASC
#> 691    cfb    American Rivers    American Rivers
#> 692    cfb             Big 12             Big 12
#> 693    cfb            Big Sky            Big Sky
#> 694    cfb            Big Ten            Big Ten
#> 695    cfb                CAA                CAA
#> 696    cfb               CCIW               CCIW
#> 697    cfb               CIAA               CIAA
#> 698    cfb                CNE                CNE
#> 699    cfb               CUSA               CUSA
#> 700    cfb          Carolinas          Carolinas
#> 701    cfb         Centennial         Centennial
#> 702    cfb           Empire 8           Empire 8
#> 703    cfb         FBS Indep.         FBS Indep.
#> 704    cfb         FCS Indep.         FCS Indep.
#> 705    cfb              G-MAC              G-MAC
#> 706    cfb              GLIAC              GLIAC
#> 707    cfb               GLVC               GLVC
#> 708    cfb                GSC                GSC
#> 709    cfb     Great American     Great American
#> 710    cfb               HCAC               HCAC
#> 711    cfb                Ivy                Ivy
#> 712    cfb                LSC                LSC
#> 713    cfb           Landmark           Landmark
#> 714    cfb     Liberty League     Liberty League
#> 715    cfb                MAC                MAC
#> 716    cfb             MASCAC             MASCAC
#> 717    cfb               MEAC               MEAC
#> 718    cfb                MEC                MEC
#> 719    cfb               MIAA               MIAA
#> 720    cfb          MIAA (MI)          MIAA (MI)
#> 721    cfb               MIAC               MIAC
#> 722    cfb               MVFC               MVFC
#> 723    cfb    Middle Atlantic    Middle Atlantic
#> 724    cfb Midwest Conference Midwest Conference
#> 725    cfb      Mountain West      Mountain West
#> 726    cfb               NACC               NACC
#> 727    cfb               NCAA               NCAA
#> 728    cfb               NCAC               NCAC
#> 729    cfb               NE10               NE10
#> 730    cfb                NEC                NEC
#> 731    cfb             NESCAC             NESCAC
#> 732    cfb             NEWMAC             NEWMAC
#> 733    cfb               NJAC               NJAC
#> 734    cfb               NSIC               NSIC
#> 735    cfb                NWC                NWC
#> 736    cfb                OAC                OAC
#> 737    cfb               ODAC               ODAC
#> 738    cfb                OVC                OVC
#> 739    cfb                PAC                PAC
#> 740    cfb               PSAC               PSAC
#> 741    cfb             Pac-12             Pac-12
#> 742    cfb            Patriot            Patriot
#> 743    cfb            Pioneer            Pioneer
#> 744    cfb               RMAC               RMAC
#> 745    cfb                SAA                SAA
#> 746    cfb               SCAC               SCAC
#> 747    cfb              SCIAC              SCIAC
#> 748    cfb                SEC                SEC
#> 749    cfb               SIAC               SIAC
#> 750    cfb               SWAC               SWAC
#> 751    cfb              SoCon              SoCon
#> 752    cfb          Southland          Southland
#> 753    cfb           Sun Belt           Sun Belt
#> 754    cfb               UMAC               UMAC
#> 755    cfb          USA South          USA South
#> 756    cfb                WAC                WAC
#> 757    cfb               WIAC               WIAC
#>                                                        name         short_name
#> 1                                         Eureka Red Devils             Eureka
#> 2                                  Centenary (LA) Gentlemen     Centenary (LA)
#> 3                                      Erskine Flying Fleet            Erskine
#> 4                                     Boston College Eagles     Boston College
#> 5                                      Holy Cross Crusaders         Holy Cross
#> 6                                           Harvard Crimson            Harvard
#> 7                                             MIT Engineers                MIT
#> 8                                   Colorado Mesa Mavericks      Colorado Mesa
#> 9                                  Mass Maritime Buccaneers      Mass Maritime
#> 10                                   West Florida Argonauts       West Florida
#> 11                                 UT Permian Basin Falcons     UT Prmian Basn
#> 12                                            Dean Bulldogs               Dean
#> 13                                      St. Andrews Knights         St Andrews
#> 14                                   Alvernia Golden Wolves           Alvernia
#> 15                                  New England Nor'easters        New England
#> 16                                             Tufts Jumbos              Tufts
#> 17                                   Franklin Pierce Ravens    Franklin Pierce
#> 18                                       Wheeling Cardinals           Wheeling
#> 19                                  Massachusetts Minutemen              UMass
#> 20                                  Fitchburg State Falcons       Fitchburg St
#> 21                                  Johns Hopkins Blue Jays      Johns Hopkins
#> 22                                            Towson Tigers             Towson
#> 23                                         Arizona Wildcats            Arizona
#> 24                                       Maryland Terrapins           Maryland
#> 25                                            Bates Bobcats              Bates
#> 26                                          Barton Bulldogs             Barton
#> 27                                          Keystone Giants           Keystone
#> 28                                 North American Stallions         N American
#> 29                                         Augsburg Auggies           Augsburg
#> 30                                  Lincoln (CA) Oaklanders       Lincoln (CA)
#> 31                                 Bluefield State Big Blue       Bluefield St
#> 32                                Grand Valley State Lakers       Grand Val St
#> 33                                            Hilbert Hawks            Hilbert
#> 34                                        Kalamazoo Hornets          Kalamazoo
#> 35                                              Post Eagles               Post
#> 36                                  Michigan State Spartans        Michigan St
#> 37                                           Eastern Eagles            Eastern
#> 38                               Northern Michigan Wildcats         N Michigan
#> 39                           Saginaw Valley State Cardinals     Saginaw Valley
#> 40                                    Anderson (SC) Trojans      Anderson (SC)
#> 41                                           Calvin Knights             Calvin
#> 42                                        Cal Poly Mustangs           Cal Poly
#> 43                                      Michigan Wolverines           Michigan
#> 44                                Wayne State (MI) Warriors      Wayne St (MI)
#> 45                                    Bemidji State Beavers         Bemidji St
#> 46                                            St. Olaf Oles            St Olaf
#> 47                                Minnesota Duluth Bulldogs        Minn Duluth
#> 48                                 Minnesota Golden Gophers          Minnesota
#> 49                                Missouri Western Griffons         MO Western
#> 50                        Northwest Missouri State Bearcats     NW Missouri St
#> 51                                          Missouri Tigers           Missouri
#> 52                               Washington St. Louis Bears      Wash St Louis
#> 53                                          Ole Miss Rebels           Ole Miss
#> 54                                    Grove City Wolverines         Grove City
#> 55                                    Montana State Bobcats         Montana St
#> 56                                        Montana Grizzlies            Montana
#> 57                                         Duke Blue Devils               Duke
#> 58                                    East Carolina Pirates      East Carolina
#> 59                                        NC State Wolfpack           NC State
#> 60                                 North Carolina Tar Heels     North Carolina
#> 61                                Wake Forest Demon Deacons        Wake Forest
#> 62                              North Dakota Fighting Hawks       North Dakota
#> 63                                     Nebraska Cornhuskers           Nebraska
#> 64                                      Dartmouth Big Green          Dartmouth
#> 65                                 Sacramento State Hornets      Sacramento St
#> 66                                   New Hampshire Wildcats      New Hampshire
#> 67                                           Hamline Pipers            Hamline
#> 68                                         Princeton Tigers          Princeton
#> 69                                  Rutgers Scarlet Knights            Rutgers
#> 70                                  New Mexico State Aggies      New Mexico St
#> 71                                         New Mexico Lobos         New Mexico
#> 72                             Claremont Mudd Scripps Stags      Claremont-M-S
#> 73                                           Columbia Lions           Columbia
#> 74                                          Cornell Big Red            Cornell
#> 75                                           Hartwick Hawks           Hartwick
#> 76                                         Hobart Statesmen             Hobart
#> 77                                           Ithaca Bombers             Ithaca
#> 78                                  Bridgewater State Bears     Bridgewater St
#> 79                                          Syracuse Orange           Syracuse
#> 80                            Rochester (NY) Yellow Jackets     Rochester (NY)
#> 81                           Baldwin Wallace Yellow Jackets       Baldwin Wall
#> 82                                    Bowling Green Falcons      Bowling Green
#> 83                          Defiance College Yellow Jackets           Defiance
#> 84                               Heidelberg Student Princes         Heidelberg
#> 85                                      Miami (OH) RedHawks           Miami OH
#> 86                                      Ohio State Buckeyes         Ohio State
#> 87                                             Ohio Bobcats               Ohio
#> 88                            Northeastern State RiverHawks           NE State
#> 89                                   Oklahoma State Cowboys        Oklahoma St
#> 90                 Southeastern Oklahoma State Savage Storm     SE Oklahoma St
#> 91                                            Auburn Tigers             Auburn
#> 92                          Southern Nazarene Crimson Storm         S Nazarene
#> 93                               Abilene Christian Wildcats     Abilene Chrstn
#> 94                                    Adams State Grizzlies           Adams St
#> 95                                          Adrian Bulldogs             Adrian
#> 96                                        Air Force Falcons          Air Force
#> 97                                               Akron Zips              Akron
#> 98                                         Oklahoma Sooners           Oklahoma
#> 99                                     Alabama A&M Bulldogs        Alabama A&M
#> 100                                   Alabama State Hornets         Alabama St
#> 101                                Albany State Golden Rams          Albany St
#> 102                                          Albright Lions           Albright
#> 103                                     Alcorn State Braves          Alcorn St
#> 104                                        Allegheny Gators          Allegheny
#> 105                                    Allen Yellow Jackets              Allen
#> 106                                  Tulsa Golden Hurricane              Tulsa
#> 107                   American International Yellow Jackets     American Int'l
#> 108                                    Anderson (IN) Ravens      Anderson (IN)
#> 109                                       Angelo State Rams          Angelo St
#> 110                                  App State Mountaineers          App State
#> 111                        Arkansas Monticello Boll Weevils      UA Monticello
#> 112                        Arkansas-Pine Bluff Golden Lions      AR-Pine Bluff
#> 113                                       Linfield Wildcats           Linfield
#> 114                               Arkansas State Red Wolves        Arkansas St
#> 115                               Arkansas Tech Wonder Boys      Arkansas Tech
#> 116                                   Assumption Greyhounds         Assumption
#> 117                                    Oregon State Beavers          Oregon St
#> 118                                  Augustana (IL) Vikings     Augustana (IL)
#> 119                                  Augustana (SD) Vikings     Augustana (SD)
#> 120                                         Aurora Spartans             Aurora
#> 121                                            Austin 'Roos             Austin
#> 122                                   Austin Peay Governors        Austin Peay
#> 123                                         Averett Cougars            Averett
#> 124                                   Azusa Pacific Cougars      Azusa Pacific
#> 125                                     Pacific (OR) Boxers       Pacific (OR)
#> 126                                    Ball State Cardinals         Ball State
#> 127                                        Belhaven Blazers           Belhaven
#> 128                                         Bentley Falcons            Bentley
#> 129                                      Bethany (WV) Bison       Bethany (WV)
#> 130                                    Bethel (TN) Wildcats        Bethel (TN)
#> 131                                Bethune-Cookman Wildcats            Bethune
#> 132                        Black Hills State Yellow Jackets     Black Hills St
#> 133                                      Bloomsburg Huskies         Bloomsburg
#> 134                                        Bluffton Beavers           Bluffton
#> 135                                    Bowie State Bulldogs           Bowie St
#> 136                                      Bridgewater Eagles        Bridgewater
#> 137                                          Bucknell Bison           Bucknell
#> 138                                           Buffalo Bulls            Buffalo
#> 139                                   Buffalo State Bengals         Buffalo St
#> 140                                         Butler Bulldogs             Butler
#> 141                                  Lock Haven Bald Eagles         Lock Haven
#> 142                                   Cal Lutheran Kingsmen       Cal Lutheran
#> 143                                Campbell Fighting Camels           Campbell
#> 144                                  San Diego State Aztecs       San Diego St
#> 145                                  Millersville Marauders       Millersville
#> 146                                        Carleton Knights           Carleton
#> 147                                 Carnegie Mellon Tartans        Carn Mellon
#> 148                                    Carson Newman Eagles      Carson Newman
#> 149                                      Carthage Firebirds           Carthage
#> 150                                         Catawba Indians            Catawba
#> 151                                      Catholic Cardinals           Catholic
#> 152                                  Central Arkansas Bears         C Arkansas
#> 153                         Central Connecticut Blue Devils      C Connecticut
#> 154                                             UCF Knights                UCF
#> 155                              Central Michigan Chippewas         C Michigan
#> 156                                  Central Missouri Mules         C Missouri
#> 157                                 Central State Marauders         Central St
#> 158                             Central Washington Wildcats       C Washington
#> 159                                         Centre Colonels             Centre
#> 160                               Central Oklahoma Bronchos         C Oklahoma
#> 161                                    Chadron State Eagles         Chadron St
#> 162                          Charleston Southern Buccaneers      Charleston So
#> 163                           Charleston (WV) Golden Eagles      Charleston WV
#> 164                                Penn State Nittany Lions         Penn State
#> 165                                   Chicago State Cougars         Chicago St
#> 166                                     Cincinnati Bearcats         Cincinnati
#> 167                                   Clarion Golden Eagles            Clarion
#> 168                                             Coe Kohawks                Coe
#> 169                                         Colgate Raiders            Colgate
#> 170                     Colorado School of Mines Orediggers     Colorado Mines
#> 171                                  Concord Mountain Lions            Concord
#> 172                                  Slippery Rock The Rock      Slippery Rock
#> 173                               Concordia Chicago Cougars      Concordia Chi
#> 174                                  Concordia (MN) Cobbers     Concordia (MN)
#> 175                                       Cornell (IA) Rams       Cornell (IA)
#> 176                                 Susquehanna River Hawks        Susquehanna
#> 177                                       Davidson Wildcats           Davidson
#> 178                                           Dayton Flyers             Dayton
#> 179                                  Delaware State Hornets        Delaware St
#> 180                                   Delta State Statesmen           Delta St
#> 181                                         Denison Big Red            Denison
#> 182                                    Dickinson Red Devils          Dickinson
#> 183                                             Temple Owls             Temple
#> 184                                          Drake Bulldogs              Drake
#> 185                                          Duquesne Dukes           Duquesne
#> 186                               East Stroudsburg Warriors      E Stroudsburg
#> 187                                    Pennsylvania Quakers               Penn
#> 188                                     East Central Tigers       East Central
#> 189                         East Tennessee State Buccaneers               ETSU
#> 190                               East Texas Baptist Tigers       E TX Baptist
#> 191                               Eastern Illinois Panthers         E Illinois
#> 192                               Eastern Kentucky Colonels         E Kentucky
#> 193                                 Eastern Michigan Eagles         E Michigan
#> 194                           Eastern New Mexico Greyhounds         Eastern NM
#> 195                                          Eastern Oregon           E Oregon
#> 196                                 Edinboro Fighting Scots           Edinboro
#> 197                                    Edward Waters Tigers      Edward Waters
#> 198                            Elizabeth City State Vikings     Elizabeth City
#> 199                                     Pittsburgh Panthers               Pitt
#> 200                                            Elon Phoenix               Elon
#> 201                                     Emory & Henry Wasps      Emory & Henry
#> 202                                   Emporia State Hornets         Emporia St
#> 203                                      Villanova Wildcats          Villanova
#> 204                              Fayetteville State Broncos       Fay'ville St
#> 205                                      FDU Florham Devils        FDU Florham
#> 206                                   Ferris State Bulldogs          Ferris St
#> 207                                          Findlay Oilers            Findlay
#> 208                                   Florida Atlantic Owls                FAU
#> 209                          Florida International Panthers                FIU
#> 210                                West Chester Golden Rams       West Chester
#> 211                                            Fordham Rams            Fordham
#> 212                                        Fort Hays Tigers          Fort Hays
#> 213                              Fort Valley State Wildcats     Fort Valley St
#> 214                                      Franklin Grizzlies           Franklin
#> 215                           Franklin & Marshall Diplomats     Franklin Marsh
#> 216                                     Fort Lewis Skyhawks         Fort Lewis
#> 217                           Gardner-Webb Runnin' Bulldogs       Gardner-Webb
#> 218                                 Geneva Golden Tornadoes             Geneva
#> 219                        George Mason University Patriots       George Mason
#> 220                                  Georgetown (KY) Tigers      Georgetown KY
#> 221                                  Georgia State Panthers         Georgia St
#> 222                                      Gettysburg Bullets         Gettysburg
#> 223                                Glenville State Pioneers       Glenville St
#> 224                                             Brown Bears              Brown
#> 225                                      Des Moines Vikings         Grand View
#> 226                                        Greensboro Pride         Greensboro
#> 227                                     Greenville Panthers         Greenville
#> 228                                        Guilford Quakers           Guilford
#> 229                                         Hampton Pirates            Hampton
#> 230                                        Hanover Panthers            Hanover
#> 231                                          Harding Bisons            Harding
#> 232                                       Rhode Island Rams       Rhode Island
#> 233                                 Henderson State Reddies       Henderson St
#> 234                                      Hillsdale Chargers          Hillsdale
#> 235                                          Hiram Terriers              Hiram
#> 236                               Houston Christian Huskies      Hou Christian
#> 237                                          Clemson Tigers            Clemson
#> 238                                           Husson Eagles             Husson
#> 239                                 Benedictine (IL) Eagles     Benedictine IL
#> 240                               Illinois College Blueboys       Illinois Col
#> 241                                 Illinois State Redbirds        Illinois St
#> 242                           IU Pennsylvania Crimson Hawks            IU Penn
#> 243                                 Indianapolis Greyhounds       Indianapolis
#> 244                                           Iowa Hawkeyes               Iowa
#> 245                                    Jackson State Tigers         Jackson St
#> 246                                 San José State Spartans        San José St
#> 247                               John Carroll Blue Streaks       John Carroll
#> 248                           Johnson C. Smith Golden Bulls     Johnson C Smth
#> 249                                         Kansas Jayhawks             Kansas
#> 250                                   Kansas State Wildcats          Kansas St
#> 251                               Kent State Golden Flashes         Kent State
#> 252                                         Furman Paladins             Furman
#> 253                               Kentucky State Thorobreds        Kentucky St
#> 254                                   Kutztown Golden Bears           Kutztown
#> 255                              Kentucky Wesleyan Panthers        KY Wesleyan
#> 256                                       La Verne Leopards           La Verne
#> 257                                         Lamar Cardinals              Lamar
#> 258                                    Lane College Dragons       Lane College
#> 259                                          Langston Lions           Langston
#> 260                                   Lehigh Mountain Hawks             Lehigh
#> 261                                    South Dakota Coyotes       South Dakota
#> 262                                      Lenoir Rhyne Bears       Lenoir Rhyne
#> 263                              Lewis & Clark River Otters      Lewis & Clark
#> 264                                          Liberty Flames            Liberty
#> 265                                      Lincoln (PA) Lions       Lincoln (PA)
#> 266                           Long Island University Sharks        Long Island
#> 267                                 Louisiana Tech Bulldogs     Louisiana Tech
#> 268                                          Memphis Tigers            Memphis
#> 269                                       Lycoming Warriors           Lycoming
#> 270                                        Macalester Scots         Macalester
#> 271                                        Chattanooga Mocs        Chattanooga
#> 272                                     Manchester Spartans         Manchester
#> 273                               Minnesota State Mavericks       Minnesota St
#> 274                                  Mansfield Mountaineers          Mansfield
#> 275                                        Marist Red Foxes             Marist
#> 276                                         Mars Hill Lions          Mars Hill
#> 277                                   Union Garnet Chargers              Union
#> 278                            Mary Hardin Baylor Crusaders        Mary Hardin
#> 279                                    Maryville (TN) Scots     Maryville (TN)
#> 280                                         McNeese Cowboys            McNeese
#> 281                                   Vanderbilt Commodores         Vanderbilt
#> 282                                            Mercer Bears             Mercer
#> 283                                Merchant Marine Mariners       Merch Marine
#> 284                                       Mercyhurst Lakers         Mercyhurst
#> 285                                            Baylor Bears             Baylor
#> 286                                        Miami Hurricanes              Miami
#> 287                                   Michigan Tech Huskies      Michigan Tech
#> 288                           Middle Tennessee Blue Raiders               MTSU
#> 289                                     Middlebury Panthers         Middlebury
#> 290                                      Miles Golden Bears              Miles
#> 291                                         Millsaps Majors           Millsaps
#> 292                                Minnesota Morris Cougars        Minn Morris
#> 293                                       Stanford Cardinal           Stanford
#> 294                   Mississippi Valley State Delta Devils     Miss Valley St
#> 295                                     Missouri S&T Miners       Missouri S&T
#> 296                           Missouri Southern State Lions     Missouri So St
#> 297                                          Monmouth Hawks           Monmouth
#> 298                                       McMurry War Hawks            McMurry
#> 299                                   Morehead State Eagles        Morehead St
#> 300                                      Morgan State Bears          Morgan St
#> 301                                      Morningside Chiefs        Morningside
#> 302                                   Mount St Joseph Lions       Mt St Joseph
#> 303                                               Rice Owls               Rice
#> 304                                        Muhlenberg Mules         Muhlenberg
#> 305                            New Mexico Highlands Cowboys       NM Highlands
#> 306                                         Navy Midshipmen               Navy
#> 307                           North Carolina Central Eagles         NC Central
#> 308                                         Charlotte 49ers          Charlotte
#> 309                                      UL Monroe Warhawks          UL Monroe
#> 310                                 Nebraska Kearney Lopers         NE Kearney
#> 311                                             UNLV Rebels               UNLV
#> 312                                        Nevada Wolf Pack             Nevada
#> 313                                      New Haven Chargers          New Haven
#> 314                         The College of New Jersey Lions      College of NJ
#> 315                                         Newberry Wolves           Newberry
#> 316                                       Nicholls Colonels           Nicholls
#> 317                               North Carolina A&T Aggies             NC A&T
#> 318                                North Dakota State Bison        N Dakota St
#> 319                                        Texas A&M Aggies          Texas A&M
#> 320                                  Norfolk State Spartans         Norfolk St
#> 321                                     North Alabama Lions      North Alabama
#> 322                                 Northern Colorado Bears         N Colorado
#> 323                               Northern Illinois Huskies         N Illinois
#> 324                                          Juniata Eagles            Juniata
#> 325                                  Northern Iowa Panthers      Northern Iowa
#> 326                            Northern Arizona Lumberjacks          N Arizona
#> 327                               Northwestern State Demons       N'Western St
#> 328                                          Norwich Cadets            Norwich
#> 329                                         King's Monarchs             King's
#> 330                                 Ohio Dominican Panthers     Ohio Dominican
#> 331                                         Houston Cougars            Houston
#> 332                                            Oregon Ducks             Oregon
#> 333                                  Pacific Lutheran Lutes       Pac Lutheran
#> 334                                            Pace Setters               Pace
#> 335                                  North Texas Mean Green        North Texas
#> 336                                 California Golden Bears         California
#> 337                                  Portland State Vikings        Portland St
#> 338                               Prairie View A&M Panthers       Prairie View
#> 339                                  Presbyterian Blue Hose       Presbyterian
#> 340                                     Puget Sound Loggers        Puget Sound
#> 341                                     Purdue Boilermakers             Purdue
#> 342                                         Texas Longhorns              Texas
#> 343                           Randolph Macon Yellow Jackets     Randolph Macon
#> 344                                             Rhodes Lynx             Rhodes
#> 345                                             BYU Cougars                BYU
#> 346                                 Robert Morris Colonials      Robert Morris
#> 347                                        Rockford Regents           Rockford
#> 348                                    Rensselaer Engineers         Rensselaer
#> 349                                   Sacred Heart Pioneers       Sacred Heart
#> 350                              Southern Utah Thunderbirds      Southern Utah
#> 351                                     Salisbury Sea Gulls          Salisbury
#> 352                                    Sam Houston Bearkats        Sam Houston
#> 353                                        Samford Bulldogs            Samford
#> 354                                               Utah Utes               Utah
#> 355                                   Savannah State Tigers        Savannah St
#> 356                                      SE Louisiana Lions       SE Louisiana
#> 357                       Southeast Missouri State Redhawks        SE Missouri
#> 358                                       Knox Prairie Fire               Knox
#> 359                                              Shaw Bears               Shaw
#> 360                                          Sewanee Tigers            Sewanee
#> 361                                       Coast Guard Bears        Coast Guard
#> 362                                    Shippensburg Raiders       Shippensburg
#> 363                                     James Madison Dukes      James Madison
#> 364                                           Shorter Hawks            Shorter
#> 365                                      Simpson (IA) Storm       Simpson (IA)
#> 366                                            SMU Mustangs                SMU
#> 367                            Southern Arkansas Muleriders         S Arkansas
#> 368                           South Carolina State Bulldogs           SC State
#> 369                                        Richmond Spiders           Richmond
#> 370                                CSU Pueblo ThunderWolves         CSU Pueblo
#> 371                          South Dakota State Jackrabbits        S Dakota St
#> 372                             Southern Miss Golden Eagles      Southern Miss
#> 373                                South Carolina Gamecocks     South Carolina
#> 374                                      Virginia Cavaliers           Virginia
#> 375                                        Southern Jaguars           Southern
#> 376                         Southern Connecticut State Owls          S Conn St
#> 377                                 Southern Oregon Raiders           S Oregon
#> 378                              Southwest Baptist Bearcats         SW Baptist
#> 379                      Southwest Minnesota State Mustangs         SW Minn St
#> 380                                  Southwestern U Pirates       Southwestern
#> 381                                    Virginia Tech Hokies      Virginia Tech
#> 382                               St. Ambrose Fighting Bees         St Ambrose
#> 383                        St. Francis (IL) Fighting Saints      St Francis IL
#> 384                                 Saint Francis Red Flash      Saint Francis
#> 385                                             UCLA Bruins               UCLA
#> 386                              Saint John's (MN) Johnnies      St Johns (MN)
#> 387                                  Saint Vincent Bearcats      Saint Vincent
#> 388                           Stephen F. Austin Lumberjacks          SF Austin
#> 389                                   Stony Brook Seawolves        Stony Brook
#> 390                                   Lake Forest Foresters        Lake Forest
#> 391                                    Missouri State Bears        Missouri St
#> 392                                   Tarleton State Texans        Tarleton St
#> 393                                        TCU Horned Frogs                TCU
#> 394                                           Loras Duhawks              Loras
#> 395                                      UT Martin Skyhawks          UT Martin
#> 396                                    Tennessee Volunteers          Tennessee
#> 397                                  Tennessee State Tigers       Tennessee St
#> 398                            Tennessee Tech Golden Eagles     Tennessee Tech
#> 399                                        UTSA Roadrunners               UTSA
#> 400                                    Texas College Steers      Texas College
#> 401                                             UTEP Miners               UTEP
#> 402                                 Texas Lutheran Bulldogs     Texas Lutheran
#> 403                                      Washington Huskies         Washington
#> 404                                   Texas Southern Tigers     Texas Southern
#> 405                                  Texas Tech Red Raiders         Texas Tech
#> 406                                    The Citadel Bulldogs        The Citadel
#> 407                                           Thiel Tomcats              Thiel
#> 408                                      Thomas More Saints        Thomas More
#> 409                                          Toledo Rockets             Toledo
#> 410                                Washington State Cougars      Washington St
#> 411                                           Trine Thunder              Trine
#> 412                                            Troy Trojans               Troy
#> 413                                   Truman State Bulldogs          Truman St
#> 414                                       Tulane Green Wave             Tulane
#> 415                                  Tuskegee Golden Tigers           Tuskegee
#> 416                          Texas A&M-Kingsville Javelinas     TAMU-Kingsvlle
#> 417                                       Beloit Buccaneers             Beloit
#> 418                                           Ursinus Bears            Ursinus
#> 419                                  Valdosta State Blazers        Valdosta St
#> 420                                      Valparaiso Beacons         Valparaiso
#> 421                                 Virginia Union Panthers     Virginia Union
#> 422                                             VMI Keydets                VMI
#> 423                                        Lawrence Vikings           Lawrence
#> 424                                         Wagner Seahawks             Wagner
#> 425                                         Walsh Cavaliers              Walsh
#> 426                                        Wartburg Knights           Wartburg
#> 427                       Washington & Jefferson Presidents        Wash & Jeff
#> 428                                       Washburn Ichabods           Washburn
#> 429                             Washington and Lee Generals       Wash and Lee
#> 430                                    Weber State Wildcats           Weber St
#> 431                                     West Alabama Tigers       West Alabama
#> 432                                     West Georgia Wolves       West Georgia
#> 433                                West Liberty Hilltoppers       West Liberty
#> 434                                   McDaniel Green Terror           McDaniel
#> 435                                Montana Western Bulldogs         MT Western
#> 436                        Western New England Golden Bears      W New England
#> 437                             Western New Mexico Mustangs         Western NM
#> 438                                    West Texas Buffaloes         West Texas
#> 439                                   WVU Tech Golden Bears           WVU Tech
#> 440                      West Virginia State Yellow Jackets      W Virginia St
#> 441                                Wisconsin Oshkosh Titans         UW-Oshkosh
#> 442                           Western Illinois Leathernecks         W Illinois
#> 443                                Western Michigan Broncos         W Michigan
#> 444                           Western Colorado Mountaineers         W Colorado
#> 445                             Western Carolina Catamounts         W Carolina
#> 446                          Wisconsin Platteville Pioneers     UW-Platteville
#> 447                                       Whitworth Pirates          Whitworth
#> 448                           Wisconsin River Falls Falcons     UW-River Falls
#> 449                                           Widener Pride            Widener
#> 450                                    William & Mary Tribe     William & Mary
#> 451                                           Williams Ephs           Williams
#> 452                        Wilmington (OH) Fightin' Quakers      Wilmington OH
#> 453                                Winston-Salem State Rams      Winston-Salem
#> 454                           Wisconsin Eau Claire Blugolds      UW-Eau Claire
#> 455                                 Maine Maritime Mariners     Maine Maritime
#> 456                              Wisconsin La Crosse Eagles       UW-La Crosse
#> 457                             Wisconsin Lutheran Warriors      Wisc Lutheran
#> 458                        Wisconsin Stevens Point Pointers      UW-Stevens Pt
#> 459                             Wisconsin Stout Blue Devils           UW-Stout
#> 460                           Wisconsin Whitewater Warhawks      UW-Whitewater
#> 461                                       Wittenberg Tigers         Wittenberg
#> 462                                        Wofford Terriers            Wofford
#> 463                                  Wooster Fighting Scots            Wooster
#> 464                                           WPI Engineers                WPI
#> 465                                       Wisconsin Badgers          Wisconsin
#> 466                                         Wyoming Cowboys            Wyoming
#> 467                               Youngstown State Penguins      Youngstown St
#> 468                                        Grambling Tigers          Grambling
#> 469                                           Berry Vikings              Berry
#> 470                             Howard Payne Yellow Jackets       Howard Payne
#> 471                                Marshall Thundering Herd           Marshall
#> 472                              West Virginia Mountaineers      West Virginia
#> 473                                      Merrimack Warriors          Merrimack
#> 474                                   Salve Regina Seahawks       Salve Regina
#> 475                                     St. Lawrence Saints        St Lawrence
#> 476                                   Fresno State Bulldogs          Fresno St
#> 477                                 Brockport Golden Eagles          Brockport
#> 478                               SUNY Cortland Red Dragons      SUNY Cortland
#> 479                                          Albion Britons             Albion
#> 480                                              Alma Scots               Alma
#> 481                                      Bethel (MN) Royals        Bethel (MN)
#> 482                                         Bryant Bulldogs             Bryant
#> 483                                            Chowan Hawks             Chowan
#> 484                                  Clark Atlanta Panthers         Clark (GA)
#> 485                                  Delaware Valley Aggies            Del Val
#> 486                                  Hardin Simmons Cowboys     Hardin Simmons
#> 487                                    Hope Flying Dutchmen               Hope
#> 488                                        Lindenwood Lions         Lindenwood
#> 489                                      McKendree Bearcats          McKendree
#> 490                           Minnesota St Moorhead Dragons      Minn Moorhead
#> 491                               Montclair State Red Hawks          Montclair
#> 492                                 Indiana State Sycamores         Indiana St
#> 493                           North Greenville Trailblazers       N Greenville
#> 494                               Northwestern (OK) Rangers     N'Western (OK)
#> 495                               Oklahoma Panhandle Aggies       OK Panhandle
#> 496                                            Quincy Hawks             Quincy
#> 497                                             Rowan Profs              Rowan
#> 498                                      Shenandoah Hornets         Shenandoah
#> 499                                      Saint Anselm Hawks       Saint Anselm
#> 500                               St. Norbert Green Knights         St Norbert
#> 501                                    Sul Ross State Lobos        Sul Ross St
#> 502                                    East Texas A&M Lions     East Texas A&M
#> 503                                          Tiffin Dragons             Tiffin
#> 504                                       Tusculum Pioneers           Tusculum
#> 505                                      Stonehill Skyhawks          Stonehill
#> 506                                      UVA Wise Cavaliers           UVA Wise
#> 507                        Western Connecticut State Wolves           WestConn
#> 508                               Wayne State (NE) Wildcats      Wayne St (NE)
#> 509                               Waynesburg Yellow Jackets         Waynesburg
#> 510                                   Western Oregon Wolves        West Oregon
#> 511                                 Westminster (PA) Titans     Westminster PA
#> 512                                          Whittier Poets           Whittier
#> 513                                   Winona State Warriors          Winona St
#> 514                                 California (PA) Vulcans           Cal (PA)
#> 515                North Carolina Wesleyan Battling Bishops        NC Wesleyan
#> 516                                            Kean Cougars               Kean
#> 517                                Lincoln (MO) Blue Tigers       Lincoln (MO)
#> 518                               Missouri Baptist Spartans      Missouri Bapt
#> 519                                     UNC Pembroke Braves       UNC Pembroke
#> 520                                           Nichols Bison            Nichols
#> 521                                  Northwood Timberwolves          Northwood
#> 522                                 Ouachita Baptist Tigers      Ouachita Bapt
#> 523                                         Ripon Red Hawks              Ripon
#> 524                                     Sioux Falls Cougars        Sioux Falls
#> 525                               Southern Virginia Knights         S Virginia
#> 526                                       Redlands Bulldogs           Redlands
#> 527                                 Georgia Southern Eagles        GA Southern
#> 528                                      St. Thomas Tommies          St Thomas
#> 529                                    Westfield State Owls       Westfield St
#> 530                                      Methodist Monarchs          Methodist
#> 531                                William Jewell Cardinals     William Jewell
#> 532                                  William Penn Statesmen       William Penn
#> 533                                        Brevard Tornados            Brevard
#> 534                                Incarnate Word Cardinals     Incarnate Word
#> 535                            Monmouth (IL) Fighting Scots      Monmouth (IL)
#> 536                           UT Rio Grande Valley Vaqueros               <NA>
#> 537                                  Pomona Pitzer Sagehens      Pomona Pitzer
#> 538                    Southwestern Oklahoma State Bulldogs     SW Oklahoma St
#> 539                        Vermont State Castleton Spartans     VTSU Castleton
#> 540                                     Willamette Bearcats         Willamette
#> 541                                        Huntingdon Hawks         Huntingdon
#> 542                                  Livingstone Blue Bears        Livingstone
#> 543                                   Old Dominion Monarchs       Old Dominion
#> 544                                SUNY Maritime Privateers      SUNY Maritime
#> 545                           Case Western Reserve Spartans       Case Western
#> 546                                   Central College Dutch        Central Col
#> 547                                   Framingham State Rams      Framingham St
#> 548                        Gustavus Adolphus Golden Gusties           Gustavus
#> 549                                    Misericordia Cougars       Misericordia
#> 550                                   Hampden Sydney Tigers     Hampden Sydney
#> 551                               William Paterson Pioneers        Wm Paterson
#> 552                                 Plymouth State Panthers        Plymouth St
#> 553                                           Shepherd Rams           Shepherd
#> 554                                    Trinity (CT) Bantams       Trinity (CT)
#> 555                          Ohio Wesleyan Battling Bishops      Ohio Wesleyan
#> 556                                  Fairmont State Falcons        Fairmont St
#> 557                                             USC Trojans                USC
#> 558                                       San Diego Toreros          San Diego
#> 559                                         UC Davis Aggies           UC Davis
#> 560                                     Idaho State Bengals           Idaho St
#> 561                                Illinois Wesleyan Titans        IL Wesleyan
#> 562                         Concordia St. Paul Golden Bears     Concordia St P
#> 563                         North Central College Cardinals     N Central (IL)
#> 564                                          Ashland Eagles            Ashland
#> 565                                 Louisiana Ragin' Cajuns          Louisiana
#> 566                                  Utah Tech Trailblazers          Utah Tech
#> 567                                       Maine Black Bears              Maine
#> 568                               SUNY Morrisville Mustangs     SUNY Morrisvle
#> 569                            Christopher Newport Captains      Chris Newport
#> 570                                   Alfred State Pioneers          Alfred St
#> 571                                       Marietta Pioneers           Marietta
#> 572                                  Oklahoma Baptist Bison         OK Baptist
#> 573                                   Carroll (WI) Pioneers       Carroll (WI)
#> 574                                      Lafayette Leopards          Lafayette
#> 575                                     Moravian Greyhounds           Moravian
#> 576                                            Troy Vikings             Hudson
#> 577                           Coastal Carolina Chanticleers            Coastal
#> 578                                        Charlotte Saints           Faith NC
#> 579                                     Texas State Bobcats           Texas St
#> 580                                       Utah State Aggies         Utah State
#> 581                                       Colby White Mules              Colby
#> 582                                  Virginia State Trojans        Virginia St
#> 583                               Eastern Washington Eagles       E Washington
#> 584                              Muskingum Fighting Muskies          Muskingum
#> 585                                    Alabama Crimson Tide            Alabama
#> 586                                 Wesleyan (CT) Cardinals      Wesleyan (CT)
#> 587                                     Kennesaw State Owls        Kennesaw St
#> 588                                     Bowdoin Polar Bears            Bowdoin
#> 589                                 Frostburg State Bobcats       Frostburg St
#> 590                              Mississippi State Bulldogs     Mississippi St
#> 591                                   Hamilton Continentals           Hamilton
#> 592                                      Army Black Knights               Army
#> 593                                        Wingate Bulldogs            Wingate
#> 594                                             Kenyon Owls             Kenyon
#> 595                                           Olivet Comets             Olivet
#> 596                                Illinois Fighting Illini           Illinois
#> 597                                     Otterbein Cardinals          Otterbein
#> 598                                     Colorado State Rams        Colorado St
#> 599                                           Alfred Saxons             Alfred
#> 600                                         Ferrum Panthers             Ferrum
#> 601                                   Gannon Golden Knights             Gannon
#> 602                               St. John Fisher Cardinals     St John Fisher
#> 603                                  St. Scholastica Saints     St Scholastica
#> 604                                UMass Dartmouth Corsairs      UMass Dartmth
#> 605                                      Colorado Buffaloes           Colorado
#> 606                                     Trinity (TX) Tigers       Trinity (TX)
#> 607                          Lebanon Valley Flying Dutchmen     Lebanon Valley
#> 608                                     Upper Iowa Peacocks         Upper Iowa
#> 609                                          Utica Pioneers              Utica
#> 610                                          Oberlin Yeomen            Oberlin
#> 611                                    Wheaton (IL) Thunder       Wheaton (IL)
#> 612                                         Wilkes Colonels             Wilkes
#> 613                                     UAlbany Great Danes            UAlbany
#> 614                                          Curry Colonels              Curry
#> 615                                 Worcester State Lancers       Worcester St
#> 616                                  Concordia (WI) Falcons     Concordia (WI)
#> 617                                           UConn Huskies              UConn
#> 618                                        Chapman Panthers            Chapman
#> 619                                       George Fox Bruins         George Fox
#> 620                                         Gallaudet Bison          Gallaudet
#> 621                                        Hendrix Warriors            Hendrix
#> 622                                          Capital Comets            Capital
#> 623                                   Northern State Wolves        Northern St
#> 624                              Mount Union Purple Raiders           Mt Union
#> 625                               Ohio Northern Polar Bears      Ohio Northern
#> 626                                           Yale Bulldogs               Yale
#> 627                              Westminster (MO) Blue Jays     Westminster MO
#> 628                                         Lake Erie Storm          Lake Erie
#> 629                                   Martin Luther Knights      Martin Luther
#> 630                                          Endicott Gulls           Endicott
#> 631                          West Virginia Wesleyan Bobcats        WV Wesleyan
#> 632                                        Georgetown Hoyas         Georgetown
#> 633                                            Howard Bison             Howard
#> 634                                      Stevenson Mustangs          Stevenson
#> 635                                      Delaware Blue Hens           Delaware
#> 636                                        Dubuque Spartans            Dubuque
#> 637                                         Benedict Tigers           Benedict
#> 638                                             UAB Blazers                UAB
#> 639                                    Florida A&M Rattlers        Florida A&M
#> 640                                            Crown Polars              Crown
#> 641                         Dakota State University Trojans          Dakota St
#> 642                                 Florida State Seminoles         Florida St
#> 643                          Graceland University Graceland          Graceland
#> 644                                       LaGrange Panthers           LaGrange
#> 645                            Jacksonville State Gamecocks          Jax State
#> 646                            University of Mary Marauders              UMary
#> 647                                         Stetson Hatters            Stetson
#> 648                                     Minot State Beavers           Minot St
#> 649                                          Florida Gators            Florida
#> 650                                     South Florida Bulls      South Florida
#> 651                                Northwestern (MN) Eagles     N'Western (MN)
#> 652                             Georgia Tech Yellow Jackets       Georgia Tech
#> 653                                   South Alabama Jaguars      South Alabama
#> 654                                 Morehouse Maroon Tigers          Morehouse
#> 655                                        Georgia Bulldogs            Georgia
#> 656                                     Seton Hill Griffins         Seton Hill
#> 657                          South Dakota Mines Hardrockers           SD Mines
#> 658                                Hawai'i Rainbow Warriors            Hawai'i
#> 659                                     Buena Vista Beavers        Buena Vista
#> 660                                        Lakeland Muskies           Lakeland
#> 661                                       Grinnell Pioneers           Grinnell
#> 662                                     Iowa State Cyclones         Iowa State
#> 663                                            Luther Norse             Luther
#> 664                                     Boise State Broncos           Boise St
#> 665                        Nebraska Wesleyan Prairie Wolves        NE Wesleyan
#> 666                                        Amherst Mammoths            Amherst
#> 667                                           Idaho Vandals              Idaho
#> 668                                       Elmhurst Bluejays           Elmhurst
#> 669                                       Millikin Big Blue           Millikin
#> 670                                      North Park Vikings         North Park
#> 671                                   Northwestern Wildcats       Northwestern
#> 672                               Southern Illinois Salukis         S Illinois
#> 673                                     Arkansas Razorbacks           Arkansas
#> 674                                         Chicago Maroons            Chicago
#> 675                                       Springfield Pride        Springfield
#> 676                                           DePauw Tigers             DePauw
#> 677                                        Indiana Hoosiers            Indiana
#> 678                          Rose Hulman Fightin' Engineers        Rose Hulman
#> 679                               Notre Dame Fighting Irish         Notre Dame
#> 680                                    Wabash Little Giants             Wabash
#> 681                                Arizona State Sun Devils         Arizona St
#> 682                                Pittsburg State Gorillas       Pittsburg St
#> 683                                     Murray State Racers          Murray St
#> 684                                       Kentucky Wildcats           Kentucky
#> 685                                    Louisville Cardinals         Louisville
#> 686                            Western Kentucky Hilltoppers         Western KY
#> 687                                              LSU Tigers                LSU
#> 688                                     American Conference           American
#> 689                               Atlantic Coast Conference                ACC
#> 690                           American Southwest Conference American Southwest
#> 691                              American Rivers Conference    American Rivers
#> 692                                       Big 12 Conference             Big 12
#> 693                                      Big Sky Conference            Big Sky
#> 694                                      Big Ten Conference            Big Ten
#> 695                            Coastal Athletic Association                CAA
#> 696            College Conference of Illinois and Wisconsin               CCIW
#> 697            Central Intercollegiate Athletic Association               CIAA
#> 698                               Conference of New England                CNE
#> 699                                          Conference USA     Conference USA
#> 700                                    Conference Carolinas          Carolinas
#> 701                                   Centennial Conference         Centennial
#> 702                                                Empire 8           Empire 8
#> 703                                        FBS Independents   FBS Independents
#> 704                                        FCS Independents   FCS Independents
#> 705                       Great Midwest Athletic Conference              G-MAC
#> 706         Great Lakes Intercollegiate Athletic Conference              GLIAC
#> 707                           Great Lakes Valley Conference        Great Lakes
#> 708                                   Gulf South Conference         Gulf South
#> 709                               Great American Conference     Great American
#> 710                Heartland Collegiate Athletic Conference          Heartland
#> 711                                              Ivy League                Ivy
#> 712                                    Lone Star Conference          Lone Star
#> 713                                     Landmark Conference           Landmark
#> 714                                          Liberty League     Liberty League
#> 715                                 Mid-American Conference       Mid-American
#> 716      Massachusetts State Collegiate Athletic Conference             MASCAC
#> 717                         Mid-Eastern Athletic Conference               MEAC
#> 718                                Mountain East Conference      Mountain East
#> 719       Mid-America Intercollegiate Athletics Association        Mid-America
#> 720           Michigan Intercollegiate Athletic Association           Michigan
#> 721           Minnesota Intercollegiate Athletic Conference          Minnesota
#> 722                     Missouri Valley Football Conference    Missouri Valley
#> 723                             Middle Atlantic Conferences    Middle Atlantic
#> 724                                      Midwest Conference            Midwest
#> 725                                Mountain West Conference      Mountain West
#> 726                Northern Athletics Collegiate Conference               NACC
#> 727                National Collegiate Athletic Association               NCAA
#> 728                         North Coast Athletic Conference        North Coast
#> 729                                 Northeast-10 Conference       Northeast-10
#> 730                                    Northeast Conference          Northeast
#> 731           New England Small College Athletic Conference             NESCAC
#> 732       New England Women's and Men's Athletic Conference             NEWMAC
#> 733                          New Jersey Athletic Conference         New Jersey
#> 734                 Northern Sun Intercollegiate Conference       Northern Sun
#> 735                                    Northwest Conference          Northwest
#> 736                                Ohio Athletic Conference               Ohio
#> 737                        Old Dominion Athletic Conference       Old Dominion
#> 738                                  Ohio Valley Conference                OVC
#> 739                         Presidents' Athletic Conference        Presidents'
#> 740                  Pennsylvania State Athletic Conference               PSAC
#> 741                                       Pac-12 Conference             Pac-12
#> 742                                          Patriot League     Patriot League
#> 743                                 Pioneer Football League            Pioneer
#> 744                      Rocky Mountain Athletic Conference     Rocky Mountain
#> 745                           Southern Athletic Association                SAA
#> 746                 Southern Collegiate Athletic Conference               SCAC
#> 747 Southern California Intercollegiate Athletic Conference              SCIAC
#> 748                                 Southeastern Conference                SEC
#> 749            Southern Intercollegiate Athletic Conference               SIAC
#> 750                        Southwestern Athletic Conference               SWAC
#> 751                                     Southern Conference           Southern
#> 752                                    Southland Conference          Southland
#> 753                                     Sun Belt Conference           Sun Belt
#> 754                       Upper Midwest Athletic Conference      Upper Midwest
#> 755                           USA South Athletic Conference          USA South
#> 756                             Western Athletic Conference                WAC
#> 757           Wisconsin Intercollegiate Athletic Conference               WIAC
#>                        location    program                    conference_id
#> 1                        Eureka   football                         cfb:nacc
#> 2                Centenary (LA)   football cfb:southern-collegiate-athletic
#> 3                       Erskine   football                    cfb:carolinas
#> 4                Boston College   football                          cfb:acc
#> 5                    Holy Cross   football                      cfb:patriot
#> 6                       Harvard   football                          cfb:ivy
#> 7                           MIT   football                       cfb:newmac
#> 8                 Colorado Mesa   football               cfb:rocky-mountain
#> 9                 Mass Maritime   football                        cfb:mscac
#> 10                 West Florida   football                          cfb:uac
#> 11             UT Permian Basin   football                    cfb:lone-star
#> 12                         Dean   football                        cfb:mscac
#> 13                  St. Andrews   football                             <NA>
#> 14                     Alvernia   football                 cfb:mid-atlantic
#> 15                  New England   football           cfb:commonwealth-coast
#> 16                        Tufts   football                       cfb:nescac
#> 17              Franklin Pierce   football                 cfb:northeast-10
#> 18                     Wheeling   football                cfb:mountain-east
#> 19                Massachusetts   football                          cfb:mac
#> 20              Fitchburg State   football                        cfb:mscac
#> 21                Johns Hopkins   football                   cfb:centennial
#> 22                       Towson   football                          cfb:caa
#> 23                      Arizona   football                       cfb:big-12
#> 24                     Maryland   football                      cfb:big-ten
#> 25                        Bates   football                       cfb:nescac
#> 26                       Barton   football                    cfb:carolinas
#> 27                     Keystone   football              cfb:d3-independents
#> 28               North American   football                             <NA>
#> 29                     Augsburg   football                    cfb:minnesota
#> 30                 Lincoln (CA)   football              cfb:d2-independents
#> 31              Bluefield State   football                         cfb:ciaa
#> 32           Grand Valley State   football                        cfb:gliac
#> 33                      Hilbert   football                     cfb:empire-8
#> 34                    Kalamazoo   football                     cfb:michigan
#> 35                         Post   football                 cfb:northeast-10
#> 36               Michigan State   football                      cfb:big-ten
#> 37                      Eastern   football                 cfb:mid-atlantic
#> 38            Northern Michigan   football                        cfb:gliac
#> 39         Saginaw Valley State   football                        cfb:gliac
#> 40                Anderson (SC)   football               cfb:south-atlantic
#> 41                       Calvin   football                     cfb:michigan
#> 42                     Cal Poly   football                      cfb:big-sky
#> 43                     Michigan   football                      cfb:big-ten
#> 44             Wayne State (MI)   football                        cfb:gliac
#> 45                Bemidji State   football                 cfb:northern-sun
#> 46                     St. Olaf   football                    cfb:minnesota
#> 47             Minnesota Duluth   football                 cfb:northern-sun
#> 48                    Minnesota   football                      cfb:big-ten
#> 49             Missouri Western   football                  cfb:mid-america
#> 50     Northwest Missouri State   football                  cfb:mid-america
#> 51                     Missouri   football                          cfb:sec
#> 52         Washington St. Louis   football                  cfb:north-coast
#> 53                     Ole Miss   football                          cfb:sec
#> 54                   Grove City   football                   cfb:presidents
#> 55                Montana State   football                      cfb:big-sky
#> 56                      Montana   football                      cfb:big-sky
#> 57                         Duke   football                          cfb:acc
#> 58                East Carolina   football                     cfb:american
#> 59                     NC State   football                          cfb:acc
#> 60               North Carolina   football                          cfb:acc
#> 61                  Wake Forest   football                          cfb:acc
#> 62                 North Dakota   football                         cfb:mvfc
#> 63                     Nebraska   football                      cfb:big-ten
#> 64                    Dartmouth   football                          cfb:ivy
#> 65             Sacramento State   football                          cfb:mac
#> 66                New Hampshire   football                          cfb:caa
#> 67                      Hamline   football                    cfb:minnesota
#> 68                    Princeton   football                          cfb:ivy
#> 69                      Rutgers   football                      cfb:big-ten
#> 70             New Mexico State   football                         cfb:cusa
#> 71                   New Mexico   football                cfb:mountain-west
#> 72       Claremont Mudd Scripps   football                        cfb:sciac
#> 73                     Columbia   football                          cfb:ivy
#> 74                      Cornell   football                          cfb:ivy
#> 75                     Hartwick   football                     cfb:empire-8
#> 76                       Hobart   football               cfb:liberty-league
#> 77                       Ithaca   football               cfb:liberty-league
#> 78            Bridgewater State   football                        cfb:mscac
#> 79                     Syracuse   football                          cfb:acc
#> 80               Rochester (NY)   football               cfb:liberty-league
#> 81              Baldwin Wallace   football                         cfb:ohio
#> 82                Bowling Green   football                          cfb:mac
#> 83             Defiance College   football                    cfb:heartland
#> 84                   Heidelberg   football                         cfb:ohio
#> 85                   Miami (OH)   football                          cfb:mac
#> 86                   Ohio State   football                      cfb:big-ten
#> 87                         Ohio   football                          cfb:mac
#> 88           Northeastern State   football              cfb:d2-independents
#> 89               Oklahoma State   football                       cfb:big-12
#> 90  Southeastern Oklahoma State   football               cfb:great-american
#> 91                       Auburn   football                          cfb:sec
#> 92            Southern Nazarene   football               cfb:great-american
#> 93            Abilene Christian   football                          cfb:uac
#> 94                  Adams State   football               cfb:rocky-mountain
#> 95                       Adrian   football                     cfb:michigan
#> 96                    Air Force   football                cfb:mountain-west
#> 97                        Akron   football                          cfb:mac
#> 98                     Oklahoma   football                          cfb:sec
#> 99                  Alabama A&M   football                         cfb:swac
#> 100               Alabama State   football                         cfb:swac
#> 101                Albany State   football                         cfb:siac
#> 102                    Albright   football                 cfb:mid-atlantic
#> 103                Alcorn State   football                         cfb:swac
#> 104                   Allegheny   football                   cfb:presidents
#> 105                       Allen   football                         cfb:siac
#> 106                       Tulsa   football                     cfb:american
#> 107      American International   football                 cfb:northeast-10
#> 108               Anderson (IN)   football                    cfb:heartland
#> 109                Angelo State   football                    cfb:lone-star
#> 110                   App State   football                     cfb:sun-belt
#> 111         Arkansas Monticello   football               cfb:great-american
#> 112         Arkansas-Pine Bluff   football                         cfb:swac
#> 113                    Linfield   football                    cfb:northwest
#> 114              Arkansas State   football                     cfb:sun-belt
#> 115               Arkansas Tech   football               cfb:great-american
#> 116                  Assumption   football                 cfb:northeast-10
#> 117                Oregon State   football                       cfb:pac-12
#> 118              Augustana (IL)   football                         cfb:cciw
#> 119              Augustana (SD)   football                 cfb:northern-sun
#> 120                      Aurora   football                         cfb:nacc
#> 121                      Austin   football cfb:southern-collegiate-athletic
#> 122                 Austin Peay   football                          cfb:uac
#> 123                     Averett   football                 cfb:old-dominion
#> 124               Azusa Pacific   football                        cfb:sciac
#> 125                Pacific (OR)   football                    cfb:northwest
#> 126                  Ball State   football                          cfb:mac
#> 127                    Belhaven   football                    cfb:usa-south
#> 128                     Bentley   football                 cfb:northeast-10
#> 129                Bethany (WV)   football                   cfb:presidents
#> 130                 Bethel (TN)   football                             <NA>
#> 131             Bethune-Cookman   football                         cfb:swac
#> 132           Black Hills State   football               cfb:rocky-mountain
#> 133                  Bloomsburg   football  cfb:pennsylvania-state-athletic
#> 134                    Bluffton   football                    cfb:heartland
#> 135                 Bowie State   football                         cfb:ciaa
#> 136                 Bridgewater   football                 cfb:old-dominion
#> 137                    Bucknell   football                      cfb:patriot
#> 138                     Buffalo   football                          cfb:mac
#> 139               Buffalo State   football               cfb:liberty-league
#> 140                      Butler   football                      cfb:pioneer
#> 141                  Lock Haven   football  cfb:pennsylvania-state-athletic
#> 142                Cal Lutheran   football                        cfb:sciac
#> 143                    Campbell   football                          cfb:caa
#> 144             San Diego State   football                       cfb:pac-12
#> 145                Millersville   football  cfb:pennsylvania-state-athletic
#> 146                    Carleton   football                    cfb:minnesota
#> 147             Carnegie Mellon   football                   cfb:presidents
#> 148               Carson Newman   football               cfb:south-atlantic
#> 149                    Carthage   football                         cfb:cciw
#> 150                     Catawba   football               cfb:south-atlantic
#> 151                    Catholic   football          cfb:landmark-conference
#> 152            Central Arkansas   football                          cfb:uac
#> 153         Central Connecticut   football                          cfb:nec
#> 154                         UCF   football                       cfb:big-12
#> 155            Central Michigan   football                          cfb:mac
#> 156            Central Missouri   football                  cfb:mid-america
#> 157               Central State   football                         cfb:siac
#> 158          Central Washington   football                    cfb:lone-star
#> 159                      Centre   football            cfb:southern-athletic
#> 160            Central Oklahoma   football                  cfb:mid-america
#> 161               Chadron State   football               cfb:rocky-mountain
#> 162         Charleston Southern   football                          cfb:ovc
#> 163             Charleston (WV)   football                cfb:mountain-east
#> 164                  Penn State   football                      cfb:big-ten
#> 165               Chicago State   football             cfb:fcs-independents
#> 166                  Cincinnati   football                       cfb:big-12
#> 167                     Clarion   football  cfb:pennsylvania-state-athletic
#> 168                         Coe   football              cfb:american-rivers
#> 169                     Colgate   football                      cfb:patriot
#> 170    Colorado School of Mines   football               cfb:rocky-mountain
#> 171                     Concord   football                cfb:mountain-east
#> 172               Slippery Rock   football  cfb:pennsylvania-state-athletic
#> 173           Concordia Chicago   football                         cfb:nacc
#> 174              Concordia (MN)   football                    cfb:minnesota
#> 175                Cornell (IA)   football                      cfb:midwest
#> 176                 Susquehanna   football          cfb:landmark-conference
#> 177                    Davidson   football                      cfb:pioneer
#> 178                      Dayton   football                      cfb:pioneer
#> 179              Delaware State   football                         cfb:meac
#> 180                 Delta State   football                   cfb:gulf-south
#> 181                     Denison   football                  cfb:north-coast
#> 182                   Dickinson   football                   cfb:centennial
#> 183                      Temple   football                     cfb:american
#> 184                       Drake   football                      cfb:pioneer
#> 185                    Duquesne   football                          cfb:nec
#> 186            East Stroudsburg   football  cfb:pennsylvania-state-athletic
#> 187                Pennsylvania   football                          cfb:ivy
#> 188                East Central   football               cfb:great-american
#> 189        East Tennessee State   football                     cfb:southern
#> 190          East Texas Baptist   football           cfb:american-southwest
#> 191            Eastern Illinois   football                          cfb:ovc
#> 192            Eastern Kentucky   football                          cfb:uac
#> 193            Eastern Michigan   football                          cfb:mac
#> 194          Eastern New Mexico   football                    cfb:lone-star
#> 195              Eastern Oregon   football                             <NA>
#> 196                    Edinboro   football  cfb:pennsylvania-state-athletic
#> 197               Edward Waters   football                         cfb:siac
#> 198        Elizabeth City State   football                         cfb:ciaa
#> 199                  Pittsburgh   football                          cfb:acc
#> 200                        Elon   football                          cfb:caa
#> 201               Emory & Henry   football               cfb:south-atlantic
#> 202               Emporia State   football                  cfb:mid-america
#> 203                   Villanova   football                      cfb:patriot
#> 204          Fayetteville State   football                         cfb:ciaa
#> 205                 FDU Florham   football                 cfb:mid-atlantic
#> 206                Ferris State   football                        cfb:gliac
#> 207                     Findlay   football       cfb:great-midwest-athletic
#> 208            Florida Atlantic   football                     cfb:american
#> 209       Florida International   football                         cfb:cusa
#> 210                West Chester   football  cfb:pennsylvania-state-athletic
#> 211                     Fordham   football                      cfb:patriot
#> 212                   Fort Hays   football                  cfb:mid-america
#> 213           Fort Valley State   football                         cfb:siac
#> 214                    Franklin   football                    cfb:heartland
#> 215         Franklin & Marshall   football                   cfb:centennial
#> 216                  Fort Lewis   football               cfb:rocky-mountain
#> 217                Gardner-Webb   football                          cfb:ovc
#> 218                      Geneva   football                   cfb:presidents
#> 219     George Mason University   football                             <NA>
#> 220             Georgetown (KY)   football                             <NA>
#> 221               Georgia State   football                     cfb:sun-belt
#> 222                  Gettysburg   football                   cfb:centennial
#> 223             Glenville State   football                cfb:mountain-east
#> 224                       Brown   football                          cfb:ivy
#> 225                  Des Moines   football                             <NA>
#> 226                  Greensboro   football                    cfb:usa-south
#> 227                  Greenville   football                cfb:upper-midwest
#> 228                    Guilford   football                 cfb:old-dominion
#> 229                     Hampton   football                          cfb:caa
#> 230                     Hanover   football                    cfb:heartland
#> 231                     Harding   football               cfb:great-american
#> 232                Rhode Island   football                          cfb:caa
#> 233             Henderson State   football               cfb:great-american
#> 234                   Hillsdale   football       cfb:great-midwest-athletic
#> 235                       Hiram   football                   cfb:presidents
#> 236           Houston Christian   football                    cfb:southland
#> 237                     Clemson   football                          cfb:acc
#> 238                      Husson   football           cfb:commonwealth-coast
#> 239            Benedictine (IL)   football                         cfb:nacc
#> 240            Illinois College   football                      cfb:midwest
#> 241              Illinois State   football                         cfb:mvfc
#> 242             IU Pennsylvania   football  cfb:pennsylvania-state-athletic
#> 243                Indianapolis   football                  cfb:great-lakes
#> 244                        Iowa   football                      cfb:big-ten
#> 245               Jackson State   football                         cfb:swac
#> 246              San José State   football                cfb:mountain-west
#> 247                John Carroll   football                         cfb:ohio
#> 248            Johnson C. Smith   football                         cfb:ciaa
#> 249                      Kansas   football                       cfb:big-12
#> 250                Kansas State   football                       cfb:big-12
#> 251                  Kent State   football                          cfb:mac
#> 252                      Furman   football                     cfb:southern
#> 253              Kentucky State   football                         cfb:siac
#> 254                    Kutztown   football  cfb:pennsylvania-state-athletic
#> 255           Kentucky Wesleyan   football       cfb:great-midwest-athletic
#> 256                    La Verne   football                        cfb:sciac
#> 257                       Lamar   football                    cfb:southland
#> 258                Lane College   football                         cfb:siac
#> 259                    Langston   football                             <NA>
#> 260                      Lehigh   football                      cfb:patriot
#> 261                South Dakota   football                         cfb:mvfc
#> 262                Lenoir Rhyne   football               cfb:south-atlantic
#> 263               Lewis & Clark   football                    cfb:northwest
#> 264                     Liberty   football                         cfb:cusa
#> 265                Lincoln (PA)   football                         cfb:ciaa
#> 266      Long Island University   football                          cfb:nec
#> 267              Louisiana Tech   football                     cfb:sun-belt
#> 268                     Memphis   football                     cfb:american
#> 269                    Lycoming   football          cfb:landmark-conference
#> 270                  Macalester   football                    cfb:minnesota
#> 271                 Chattanooga   football                     cfb:southern
#> 272                  Manchester   football                    cfb:heartland
#> 273             Minnesota State   football                 cfb:northern-sun
#> 274                   Mansfield   football                             <NA>
#> 275                      Marist   football                      cfb:pioneer
#> 276                   Mars Hill   football               cfb:south-atlantic
#> 277                       Union   football               cfb:liberty-league
#> 278          Mary Hardin Baylor   football           cfb:american-southwest
#> 279              Maryville (TN)   football                    cfb:usa-south
#> 280                     McNeese   football                    cfb:southland
#> 281                  Vanderbilt   football                          cfb:sec
#> 282                      Mercer   football                     cfb:southern
#> 283             Merchant Marine   football                       cfb:newmac
#> 284                  Mercyhurst   football                          cfb:nec
#> 285                      Baylor   football                       cfb:big-12
#> 286                       Miami   football                          cfb:acc
#> 287               Michigan Tech   football                        cfb:gliac
#> 288            Middle Tennessee   football                         cfb:cusa
#> 289                  Middlebury   football                       cfb:nescac
#> 290                       Miles   football                         cfb:siac
#> 291                    Millsaps   football            cfb:southern-athletic
#> 292            Minnesota Morris   football                cfb:upper-midwest
#> 293                    Stanford   football                          cfb:acc
#> 294    Mississippi Valley State   football                         cfb:swac
#> 295                Missouri S&T   football                  cfb:great-lakes
#> 296     Missouri Southern State   football                  cfb:mid-america
#> 297                    Monmouth   football                          cfb:caa
#> 298                     McMurry   football           cfb:american-southwest
#> 299              Morehead State   football                      cfb:pioneer
#> 300                Morgan State   football                         cfb:meac
#> 301                 Morningside   football                             <NA>
#> 302             Mount St Joseph   football                    cfb:heartland
#> 303                        Rice   football                     cfb:american
#> 304                  Muhlenberg   football                   cfb:centennial
#> 305        New Mexico Highlands   football               cfb:rocky-mountain
#> 306                        Navy   football                     cfb:american
#> 307      North Carolina Central   football                         cfb:meac
#> 308                   Charlotte   football                     cfb:american
#> 309                   UL Monroe   football                     cfb:sun-belt
#> 310            Nebraska Kearney   football                  cfb:mid-america
#> 311                        UNLV   football                cfb:mountain-west
#> 312                      Nevada   football                cfb:mountain-west
#> 313                   New Haven   football                          cfb:nec
#> 314   The College of New Jersey   football                   cfb:new-jersey
#> 315                    Newberry   football               cfb:south-atlantic
#> 316                    Nicholls   football                    cfb:southland
#> 317          North Carolina A&T   football                          cfb:caa
#> 318          North Dakota State   football                cfb:mountain-west
#> 319                   Texas A&M   football                          cfb:sec
#> 320               Norfolk State   football                         cfb:meac
#> 321               North Alabama   football                          cfb:uac
#> 322           Northern Colorado   football                      cfb:big-sky
#> 323           Northern Illinois   football                cfb:mountain-west
#> 324                     Juniata   football          cfb:landmark-conference
#> 325               Northern Iowa   football                         cfb:mvfc
#> 326            Northern Arizona   football                      cfb:big-sky
#> 327          Northwestern State   football                    cfb:southland
#> 328                     Norwich   football                       cfb:newmac
#> 329                      King's   football                 cfb:mid-atlantic
#> 330              Ohio Dominican   football       cfb:great-midwest-athletic
#> 331                     Houston   football                       cfb:big-12
#> 332                      Oregon   football                      cfb:big-ten
#> 333            Pacific Lutheran   football                    cfb:northwest
#> 334                        Pace   football                 cfb:northeast-10
#> 335                 North Texas   football                     cfb:american
#> 336                  California   football                          cfb:acc
#> 337              Portland State   football                      cfb:big-sky
#> 338            Prairie View A&M   football                         cfb:swac
#> 339                Presbyterian   football                      cfb:pioneer
#> 340                 Puget Sound   football                    cfb:northwest
#> 341                      Purdue   football                      cfb:big-ten
#> 342                       Texas   football                          cfb:sec
#> 343              Randolph Macon   football                 cfb:old-dominion
#> 344                      Rhodes   football            cfb:southern-athletic
#> 345                         BYU   football                       cfb:big-12
#> 346               Robert Morris   football                          cfb:nec
#> 347                    Rockford   football                         cfb:nacc
#> 348                  Rensselaer   football               cfb:liberty-league
#> 349                Sacred Heart   football                          cfb:caa
#> 350               Southern Utah   football                      cfb:big-sky
#> 351                   Salisbury   football                   cfb:new-jersey
#> 352                 Sam Houston   football                         cfb:cusa
#> 353                     Samford   football                     cfb:southern
#> 354                        Utah   football                       cfb:big-12
#> 355              Savannah State   football                         cfb:siac
#> 356                SE Louisiana   football                    cfb:southland
#> 357    Southeast Missouri State   football                          cfb:ovc
#> 358                        Knox   football                      cfb:midwest
#> 359                        Shaw   football                         cfb:ciaa
#> 360                     Sewanee   football            cfb:southern-athletic
#> 361                 Coast Guard   football                       cfb:newmac
#> 362                Shippensburg   football  cfb:pennsylvania-state-athletic
#> 363               James Madison   football                     cfb:sun-belt
#> 364                     Shorter   football                    cfb:carolinas
#> 365                Simpson (IA)   football              cfb:american-rivers
#> 366                         SMU   football                          cfb:acc
#> 367           Southern Arkansas   football               cfb:great-american
#> 368        South Carolina State   football                         cfb:meac
#> 369                    Richmond   football                      cfb:patriot
#> 370                  CSU Pueblo   football               cfb:rocky-mountain
#> 371          South Dakota State   football                         cfb:mvfc
#> 372               Southern Miss   football                     cfb:sun-belt
#> 373              South Carolina   football                          cfb:sec
#> 374                    Virginia   football                          cfb:acc
#> 375                    Southern   football                         cfb:swac
#> 376  Southern Connecticut State   football                 cfb:northeast-10
#> 377             Southern Oregon   football                             <NA>
#> 378           Southwest Baptist   football                  cfb:great-lakes
#> 379   Southwest Minnesota State   football                 cfb:northern-sun
#> 380              Southwestern U   football            cfb:southern-athletic
#> 381               Virginia Tech   football                          cfb:acc
#> 382                 St. Ambrose   football                             <NA>
#> 383            St. Francis (IL)   football                             <NA>
#> 384               Saint Francis   football                   cfb:presidents
#> 385                        UCLA   football                      cfb:big-ten
#> 386           Saint John's (MN)   football                    cfb:minnesota
#> 387               Saint Vincent   football                   cfb:presidents
#> 388           Stephen F. Austin   football                    cfb:southland
#> 389                 Stony Brook   football                          cfb:caa
#> 390                 Lake Forest   football                      cfb:midwest
#> 391              Missouri State   football                         cfb:cusa
#> 392              Tarleton State   football                          cfb:uac
#> 393                         TCU   football                       cfb:big-12
#> 394                       Loras   football              cfb:american-rivers
#> 395                   UT Martin   football                          cfb:ovc
#> 396                   Tennessee   football                          cfb:sec
#> 397             Tennessee State   football                          cfb:ovc
#> 398              Tennessee Tech   football                     cfb:southern
#> 399                        UTSA   football                     cfb:american
#> 400               Texas College   football                             <NA>
#> 401                        UTEP   football                cfb:mountain-west
#> 402              Texas Lutheran   football cfb:southern-collegiate-athletic
#> 403                  Washington   football                      cfb:big-ten
#> 404              Texas Southern   football                         cfb:swac
#> 405                  Texas Tech   football                       cfb:big-12
#> 406                 The Citadel   football                     cfb:southern
#> 407                       Thiel   football                   cfb:presidents
#> 408                 Thomas More   football       cfb:great-midwest-athletic
#> 409                      Toledo   football                          cfb:mac
#> 410            Washington State   football                       cfb:pac-12
#> 411                       Trine   football                     cfb:michigan
#> 412                        Troy   football                     cfb:sun-belt
#> 413                Truman State   football                  cfb:great-lakes
#> 414                      Tulane   football                     cfb:american
#> 415                    Tuskegee   football                         cfb:siac
#> 416        Texas A&M-Kingsville   football                    cfb:lone-star
#> 417                      Beloit   football                      cfb:midwest
#> 418                     Ursinus   football                   cfb:centennial
#> 419              Valdosta State   football                   cfb:gulf-south
#> 420                  Valparaiso   football                      cfb:pioneer
#> 421              Virginia Union   football                         cfb:ciaa
#> 422                         VMI   football                     cfb:southern
#> 423                    Lawrence   football                      cfb:midwest
#> 424                      Wagner   football                          cfb:nec
#> 425                       Walsh   football       cfb:great-midwest-athletic
#> 426                    Wartburg   football              cfb:american-rivers
#> 427      Washington & Jefferson   football                   cfb:presidents
#> 428                    Washburn   football                  cfb:mid-america
#> 429          Washington and Lee   football                 cfb:old-dominion
#> 430                 Weber State   football                      cfb:big-sky
#> 431                West Alabama   football                   cfb:gulf-south
#> 432                West Georgia   football                          cfb:uac
#> 433                West Liberty   football                cfb:mountain-east
#> 434                    McDaniel   football                   cfb:centennial
#> 435             Montana Western   football                             <NA>
#> 436         Western New England   football           cfb:commonwealth-coast
#> 437          Western New Mexico   football                    cfb:lone-star
#> 438                  West Texas   football                    cfb:lone-star
#> 439                    WVU Tech   football                             <NA>
#> 440         West Virginia State   football                cfb:mountain-east
#> 441           Wisconsin Oshkosh   football                    cfb:wisconsin
#> 442            Western Illinois   football                          cfb:ovc
#> 443            Western Michigan   football                          cfb:mac
#> 444            Western Colorado   football               cfb:rocky-mountain
#> 445            Western Carolina   football                     cfb:southern
#> 446       Wisconsin Platteville   football                    cfb:wisconsin
#> 447                   Whitworth   football                    cfb:northwest
#> 448       Wisconsin River Falls   football                    cfb:wisconsin
#> 449                     Widener   football                 cfb:mid-atlantic
#> 450              William & Mary   football                      cfb:patriot
#> 451                    Williams   football                       cfb:nescac
#> 452             Wilmington (OH)   football                         cfb:ohio
#> 453         Winston-Salem State   football                         cfb:ciaa
#> 454        Wisconsin Eau Claire   football                    cfb:wisconsin
#> 455              Maine Maritime   football           cfb:commonwealth-coast
#> 456         Wisconsin La Crosse   football                    cfb:wisconsin
#> 457          Wisconsin Lutheran   football                         cfb:nacc
#> 458     Wisconsin Stevens Point   football                    cfb:wisconsin
#> 459             Wisconsin Stout   football                    cfb:wisconsin
#> 460        Wisconsin Whitewater   football                    cfb:wisconsin
#> 461                  Wittenberg   football                  cfb:north-coast
#> 462                     Wofford   football                     cfb:southern
#> 463                     Wooster   football                  cfb:north-coast
#> 464                         WPI   football                       cfb:newmac
#> 465                   Wisconsin   football                      cfb:big-ten
#> 466                     Wyoming   football                cfb:mountain-west
#> 467            Youngstown State   football                         cfb:mvfc
#> 468                   Grambling   football                         cfb:swac
#> 469                       Berry   football            cfb:southern-athletic
#> 470                Howard Payne   football           cfb:american-southwest
#> 471                    Marshall   football                     cfb:sun-belt
#> 472               West Virginia   football                       cfb:big-12
#> 473                   Merrimack   football             cfb:fcs-independents
#> 474                Salve Regina   football                       cfb:newmac
#> 475                St. Lawrence   football               cfb:liberty-league
#> 476                Fresno State   football                       cfb:pac-12
#> 477                   Brockport   football                     cfb:empire-8
#> 478               SUNY Cortland   football                     cfb:empire-8
#> 479                      Albion   football                     cfb:michigan
#> 480                        Alma   football                     cfb:michigan
#> 481                 Bethel (MN)   football                    cfb:minnesota
#> 482                      Bryant   football                          cfb:caa
#> 483                      Chowan   football                    cfb:carolinas
#> 484               Clark Atlanta   football                         cfb:siac
#> 485             Delaware Valley   football                 cfb:mid-atlantic
#> 486              Hardin Simmons   football           cfb:american-southwest
#> 487                        Hope   football                     cfb:michigan
#> 488                  Lindenwood   football                          cfb:ovc
#> 489                   McKendree   football                  cfb:great-lakes
#> 490       Minnesota St Moorhead   football                 cfb:northern-sun
#> 491             Montclair State   football                   cfb:new-jersey
#> 492               Indiana State   football                         cfb:mvfc
#> 493            North Greenville   football                    cfb:carolinas
#> 494           Northwestern (OK)   football               cfb:great-american
#> 495          Oklahoma Panhandle   football              cfb:d2-independents
#> 496                      Quincy   football                  cfb:great-lakes
#> 497                       Rowan   football                   cfb:new-jersey
#> 498                  Shenandoah   football                 cfb:old-dominion
#> 499                Saint Anselm   football                 cfb:northeast-10
#> 500                 St. Norbert   football                         cfb:nacc
#> 501              Sul Ross State   football                    cfb:lone-star
#> 502              East Texas A&M   football                    cfb:southland
#> 503                      Tiffin   football       cfb:great-midwest-athletic
#> 504                    Tusculum   football               cfb:south-atlantic
#> 505                   Stonehill   football                          cfb:nec
#> 506                    UVA Wise   football               cfb:south-atlantic
#> 507   Western Connecticut State   football          cfb:landmark-conference
#> 508            Wayne State (NE)   football                 cfb:northern-sun
#> 509                  Waynesburg   football                   cfb:presidents
#> 510              Western Oregon   football                    cfb:lone-star
#> 511            Westminster (PA)   football                   cfb:presidents
#> 512                    Whittier   football                        cfb:sciac
#> 513                Winona State   football                 cfb:northern-sun
#> 514             California (PA)   football  cfb:pennsylvania-state-athletic
#> 515     North Carolina Wesleyan   football                    cfb:usa-south
#> 516                        Kean   football                   cfb:new-jersey
#> 517                Lincoln (MO)   football                  cfb:great-lakes
#> 518            Missouri Baptist   football                             <NA>
#> 519                UNC Pembroke   football                    cfb:carolinas
#> 520                     Nichols   football           cfb:commonwealth-coast
#> 521                   Northwood   football       cfb:great-midwest-athletic
#> 522            Ouachita Baptist   football               cfb:great-american
#> 523                       Ripon   football                      cfb:midwest
#> 524                 Sioux Falls   football                 cfb:northern-sun
#> 525           Southern Virginia   football                    cfb:usa-south
#> 526                    Redlands   football                        cfb:sciac
#> 527            Georgia Southern   football                     cfb:sun-belt
#> 528                  St. Thomas   football                      cfb:pioneer
#> 529             Westfield State   football                        cfb:mscac
#> 530                   Methodist   football                    cfb:usa-south
#> 531              William Jewell   football                  cfb:great-lakes
#> 532                William Penn   football                             <NA>
#> 533                     Brevard   football                    cfb:usa-south
#> 534              Incarnate Word   football                    cfb:southland
#> 535               Monmouth (IL)   football                      cfb:midwest
#> 536                        <NA>   football                    cfb:southland
#> 537               Pomona Pitzer   football                        cfb:sciac
#> 538 Southwestern Oklahoma State   football               cfb:great-american
#> 539     Vermont State Castleton   football                   cfb:new-jersey
#> 540                  Willamette   football                    cfb:northwest
#> 541                  Huntingdon   football                    cfb:usa-south
#> 542                 Livingstone   football                         cfb:ciaa
#> 543                Old Dominion   football                     cfb:sun-belt
#> 544               SUNY Maritime   football                       cfb:newmac
#> 545        Case Western Reserve   football                   cfb:presidents
#> 546             Central College   football              cfb:american-rivers
#> 547            Framingham State   football                        cfb:mscac
#> 548           Gustavus Adolphus   football                    cfb:minnesota
#> 549                Misericordia   football                 cfb:mid-atlantic
#> 550              Hampden Sydney   football                 cfb:old-dominion
#> 551            William Paterson   football                   cfb:new-jersey
#> 552              Plymouth State   football                        cfb:mscac
#> 553                    Shepherd   football  cfb:pennsylvania-state-athletic
#> 554                Trinity (CT)   football                       cfb:nescac
#> 555               Ohio Wesleyan   football                  cfb:north-coast
#> 556              Fairmont State   football                cfb:mountain-east
#> 557                         USC   football                      cfb:big-ten
#> 558                   San Diego   football                      cfb:pioneer
#> 559                    UC Davis   football                      cfb:big-sky
#> 560                 Idaho State   football                      cfb:big-sky
#> 561           Illinois Wesleyan   football                         cfb:cciw
#> 562          Concordia St. Paul   football                 cfb:northern-sun
#> 563       North Central College   football                         cfb:cciw
#> 564                     Ashland   football       cfb:great-midwest-athletic
#> 565                   Louisiana   football                     cfb:sun-belt
#> 566                   Utah Tech   football                      cfb:big-sky
#> 567                       Maine   football                          cfb:caa
#> 568            SUNY Morrisville   football                     cfb:empire-8
#> 569         Christopher Newport   football                   cfb:new-jersey
#> 570                Alfred State   football                     cfb:empire-8
#> 571                    Marietta   football                         cfb:ohio
#> 572            Oklahoma Baptist   football               cfb:great-american
#> 573                Carroll (WI)   football                         cfb:cciw
#> 574                   Lafayette   football                      cfb:patriot
#> 575                    Moravian   football          cfb:landmark-conference
#> 576                        Troy   football                             <NA>
#> 577            Coastal Carolina   football                     cfb:sun-belt
#> 578                   Charlotte   football                             <NA>
#> 579                 Texas State   football                       cfb:pac-12
#> 580                  Utah State   football                       cfb:pac-12
#> 581                       Colby   football                       cfb:nescac
#> 582              Virginia State   football                         cfb:ciaa
#> 583          Eastern Washington   football                      cfb:big-sky
#> 584                   Muskingum   football                         cfb:ohio
#> 585                     Alabama   football                          cfb:sec
#> 586               Wesleyan (CT)   football                       cfb:nescac
#> 587              Kennesaw State   football                         cfb:cusa
#> 588                     Bowdoin   football                       cfb:nescac
#> 589             Frostburg State   football                cfb:mountain-east
#> 590           Mississippi State   football                          cfb:sec
#> 591                    Hamilton   football                       cfb:nescac
#> 592                        Army   football                     cfb:american
#> 593                     Wingate   football               cfb:south-atlantic
#> 594                      Kenyon   football                  cfb:north-coast
#> 595                      Olivet   football                     cfb:michigan
#> 596                    Illinois   football                      cfb:big-ten
#> 597                   Otterbein   football                         cfb:ohio
#> 598              Colorado State   football                       cfb:pac-12
#> 599                      Alfred   football                     cfb:empire-8
#> 600                      Ferrum   football                    cfb:carolinas
#> 601                      Gannon   football  cfb:pennsylvania-state-athletic
#> 602             St. John Fisher   football                     cfb:empire-8
#> 603             St. Scholastica   football                    cfb:minnesota
#> 604             UMass Dartmouth   football                        cfb:mscac
#> 605                    Colorado   football                       cfb:big-12
#> 606                Trinity (TX)   football            cfb:southern-athletic
#> 607              Lebanon Valley   football                 cfb:mid-atlantic
#> 608                  Upper Iowa   football                  cfb:great-lakes
#> 609                       Utica   football                     cfb:empire-8
#> 610                     Oberlin   football                  cfb:north-coast
#> 611                Wheaton (IL)   football                         cfb:cciw
#> 612                      Wilkes   football          cfb:landmark-conference
#> 613                     UAlbany   football                          cfb:caa
#> 614                       Curry   football           cfb:commonwealth-coast
#> 615             Worcester State   football                        cfb:mscac
#> 616              Concordia (WI)   football                         cfb:nacc
#> 617                       UConn   football             cfb:fbs-independents
#> 618                     Chapman   football                        cfb:sciac
#> 619                  George Fox   football                    cfb:northwest
#> 620                   Gallaudet   football cfb:southern-collegiate-athletic
#> 621                     Hendrix   football            cfb:southern-athletic
#> 622                     Capital   football                         cfb:ohio
#> 623              Northern State   football                 cfb:northern-sun
#> 624                 Mount Union   football                         cfb:ohio
#> 625               Ohio Northern   football                         cfb:ohio
#> 626                        Yale   football                          cfb:ivy
#> 627            Westminster (MO)   football                cfb:upper-midwest
#> 628                   Lake Erie   football       cfb:great-midwest-athletic
#> 629               Martin Luther   football                cfb:upper-midwest
#> 630                    Endicott   football           cfb:commonwealth-coast
#> 631      West Virginia Wesleyan   football                cfb:mountain-east
#> 632                  Georgetown   football                      cfb:patriot
#> 633                      Howard   football                         cfb:meac
#> 634                   Stevenson   football                 cfb:mid-atlantic
#> 635                    Delaware   football                         cfb:cusa
#> 636                     Dubuque   football              cfb:american-rivers
#> 637                    Benedict   football                         cfb:siac
#> 638                         UAB   football                     cfb:american
#> 639                 Florida A&M   football                         cfb:swac
#> 640                       Crown   football                cfb:upper-midwest
#> 641     Dakota State University   football                             <NA>
#> 642               Florida State   football                          cfb:acc
#> 643        Graceland University   football                             <NA>
#> 644                    LaGrange   football                    cfb:usa-south
#> 645          Jacksonville State   football                         cfb:cusa
#> 646          University of Mary   football                 cfb:northern-sun
#> 647                     Stetson   football                      cfb:pioneer
#> 648                 Minot State   football                 cfb:northern-sun
#> 649                     Florida   football                          cfb:sec
#> 650               South Florida   football                     cfb:american
#> 651           Northwestern (MN)   football                cfb:upper-midwest
#> 652                Georgia Tech   football                          cfb:acc
#> 653               South Alabama   football                     cfb:sun-belt
#> 654                   Morehouse   football                         cfb:siac
#> 655                     Georgia   football                          cfb:sec
#> 656                  Seton Hill   football  cfb:pennsylvania-state-athletic
#> 657          South Dakota Mines   football               cfb:rocky-mountain
#> 658                     Hawai'i   football                cfb:mountain-west
#> 659                 Buena Vista   football              cfb:american-rivers
#> 660                    Lakeland   football                         cfb:nacc
#> 661                    Grinnell   football                      cfb:midwest
#> 662                  Iowa State   football                       cfb:big-12
#> 663                      Luther   football                      cfb:midwest
#> 664                 Boise State   football                       cfb:pac-12
#> 665           Nebraska Wesleyan   football              cfb:american-rivers
#> 666                     Amherst   football                       cfb:nescac
#> 667                       Idaho   football                      cfb:big-sky
#> 668                    Elmhurst   football                         cfb:cciw
#> 669                    Millikin   football                         cfb:cciw
#> 670                  North Park   football                         cfb:cciw
#> 671                Northwestern   football                      cfb:big-ten
#> 672           Southern Illinois   football                         cfb:mvfc
#> 673                    Arkansas   football                          cfb:sec
#> 674                     Chicago   football                      cfb:midwest
#> 675                 Springfield   football                       cfb:newmac
#> 676                      DePauw   football                  cfb:north-coast
#> 677                     Indiana   football                      cfb:big-ten
#> 678                 Rose Hulman   football                    cfb:heartland
#> 679                  Notre Dame   football             cfb:fbs-independents
#> 680                      Wabash   football                  cfb:north-coast
#> 681               Arizona State   football                       cfb:big-12
#> 682             Pittsburg State   football                  cfb:mid-america
#> 683                Murray State   football                         cfb:mvfc
#> 684                    Kentucky   football                          cfb:sec
#> 685                  Louisville   football                          cfb:acc
#> 686            Western Kentucky   football                         cfb:cusa
#> 687                         LSU   football                          cfb:sec
#> 688                        <NA> conference                     cfb:american
#> 689                        <NA> conference                          cfb:acc
#> 690                        <NA> conference           cfb:american-southwest
#> 691                        <NA> conference              cfb:american-rivers
#> 692                        <NA> conference                       cfb:big-12
#> 693                        <NA> conference                      cfb:big-sky
#> 694                        <NA> conference                      cfb:big-ten
#> 695                        <NA> conference                          cfb:caa
#> 696                        <NA> conference                         cfb:cciw
#> 697                        <NA> conference                         cfb:ciaa
#> 698                        <NA> conference                             <NA>
#> 699                        <NA> conference                         cfb:cusa
#> 700                        <NA> conference                    cfb:carolinas
#> 701                        <NA> conference                   cfb:centennial
#> 702                        <NA> conference                     cfb:empire-8
#> 703                        <NA> conference             cfb:fbs-independents
#> 704                        <NA> conference             cfb:fcs-independents
#> 705                        <NA> conference       cfb:great-midwest-athletic
#> 706                        <NA> conference                        cfb:gliac
#> 707                        <NA> conference                  cfb:great-lakes
#> 708                        <NA> conference                   cfb:gulf-south
#> 709                        <NA> conference               cfb:great-american
#> 710                        <NA> conference                    cfb:heartland
#> 711                        <NA> conference                          cfb:ivy
#> 712                        <NA> conference                    cfb:lone-star
#> 713                        <NA> conference          cfb:landmark-conference
#> 714                        <NA> conference               cfb:liberty-league
#> 715                        <NA> conference                          cfb:mac
#> 716                        <NA> conference                        cfb:mscac
#> 717                        <NA> conference                         cfb:meac
#> 718                        <NA> conference                cfb:mountain-east
#> 719                        <NA> conference                  cfb:mid-america
#> 720                        <NA> conference                     cfb:michigan
#> 721                        <NA> conference                    cfb:minnesota
#> 722                        <NA> conference                         cfb:mvfc
#> 723                        <NA> conference                 cfb:mid-atlantic
#> 724                        <NA> conference                      cfb:midwest
#> 725                        <NA> conference                cfb:mountain-west
#> 726                        <NA> conference                         cfb:nacc
#> 727                        <NA>     league                             <NA>
#> 728                        <NA> conference                  cfb:north-coast
#> 729                        <NA> conference                 cfb:northeast-10
#> 730                        <NA> conference                          cfb:nec
#> 731                        <NA> conference                       cfb:nescac
#> 732                        <NA> conference                       cfb:newmac
#> 733                        <NA> conference                   cfb:new-jersey
#> 734                        <NA> conference                 cfb:northern-sun
#> 735                        <NA> conference                    cfb:northwest
#> 736                        <NA> conference                         cfb:ohio
#> 737                        <NA> conference                 cfb:old-dominion
#> 738                        <NA> conference                          cfb:ovc
#> 739                        <NA> conference                   cfb:presidents
#> 740                        <NA> conference  cfb:pennsylvania-state-athletic
#> 741                        <NA> conference                       cfb:pac-12
#> 742                        <NA> conference                      cfb:patriot
#> 743                        <NA> conference                      cfb:pioneer
#> 744                        <NA> conference               cfb:rocky-mountain
#> 745                        <NA> conference            cfb:southern-athletic
#> 746                        <NA> conference cfb:southern-collegiate-athletic
#> 747                        <NA> conference                        cfb:sciac
#> 748                        <NA> conference                          cfb:sec
#> 749                        <NA> conference                         cfb:siac
#> 750                        <NA> conference                         cfb:swac
#> 751                        <NA> conference                     cfb:southern
#> 752                        <NA> conference                    cfb:southland
#> 753                        <NA> conference                     cfb:sun-belt
#> 754                        <NA> conference                cfb:upper-midwest
#> 755                        <NA> conference                    cfb:usa-south
#> 756                        <NA> conference                             <NA>
#> 757                        <NA> conference                    cfb:wisconsin
#>                                                  conference color_primary
#> 1                  Northern Athletics Collegiate Conference       #960a2c
#> 2                   Southern Collegiate Athletic Conference       #8a2432
#> 3                                      Conference Carolinas       #701931
#> 4                                 Atlantic Coast Conference       #8c2232
#> 5                                            Patriot League       #582c83
#> 6                                                Ivy League       #990000
#> 7         New England Women's and Men's Athletic Conference       #b20838
#> 8                                            Rocky Mountain       #860038
#> 9        Massachusetts State Collegiate Athletic Conference       #212c62
#> 10                               United Athletic Conference       #087dc2
#> 11                                                Lone Star       #e35205
#> 12       Massachusetts State Collegiate Athletic Conference       #43252a
#> 13                                                     <NA>       #001681
#> 14                               Middle Atlantic Conference       #9e053b
#> 15                            Commonwealth Coast Conference       #0079c2
#> 16                                                   NESCAC       #3e8ede
#> 17                                             Northeast 10       #701931
#> 18                                 Mountain East Conference       #e31937
#> 19                                  Mid-American Conference       #881c1c
#> 20       Massachusetts State Collegiate Athletic Conference       #024d36
#> 21                                               Centennial       #68aee0
#> 22                             Coastal Athletic Association       #ffc229
#> 23                                        Big 12 Conference       #cc0033
#> 24                                       Big Ten Conference       #ce1126
#> 25                                                   NESCAC       #a51e36
#> 26                                     Conference Carolinas       #004684
#> 27                                         Independent DIII       #001e4e
#> 28                                                     <NA>       #2a388c
#> 29                                                Minnesota       #74233d
#> 30                                          Independent DII       #a61d2f
#> 31                                                     CIAA       #0f1f43
#> 32                                                    GLIAC       #0f298f
#> 33                                                 Empire 8       #233f94
#> 34                                                 Michigan       #ec6820
#> 35                                             Northeast 10       #632d4f
#> 36                                       Big Ten Conference       #173f35
#> 37                               Middle Atlantic Conference       #6a1f32
#> 38                                                    GLIAC       #0f553a
#> 39                                                    GLIAC       #c41230
#> 40                                           South Atlantic       #bca271
#> 41                                                 Michigan       #891b2f
#> 42                                       Big Sky Conference       #1e4d2b
#> 43                                       Big Ten Conference       #00274c
#> 44                                                    GLIAC       #4a8075
#> 45                                             Northern Sun       #d3af7e
#> 46                                                Minnesota       #000000
#> 47                                             Northern Sun       #fec050
#> 48                                       Big Ten Conference       #5e0a2f
#> 49                                              Mid America       #fab615
#> 50                                              Mid America       #006e51
#> 51                                  Southeastern Conference       #f1b82d
#> 52                                              North Coast       #007360
#> 53                                  Southeastern Conference       #13294b
#> 54                                              Presidents'       #eb1f25
#> 55                                       Big Sky Conference       #00205c
#> 56                                       Big Sky Conference       #751d4a
#> 57                                Atlantic Coast Conference       #00539b
#> 58                                      American Conference       #582c83
#> 59                                Atlantic Coast Conference       #cc0000
#> 60                                Atlantic Coast Conference       #7bafd4
#> 61                                Atlantic Coast Conference       #ceb888
#> 62                      Missouri Valley Football Conference       #00a26b
#> 63                                       Big Ten Conference       #e31937
#> 64                                               Ivy League       #005730
#> 65                                  Mid-American Conference       #00573c
#> 66                             Coastal Athletic Association       #004990
#> 67                                                Minnesota       #98012e
#> 68                                               Ivy League       #000000
#> 69                                       Big Ten Conference       #ce0e2d
#> 70                                           Conference USA       #7e141b
#> 71                                 Mountain West Conference       #ba0c2f
#> 72                                                 So. Cal.       #981a31
#> 73                                               Ivy League       #7ba4db
#> 74                                               Ivy League       #b31b1b
#> 75                                                 Empire 8       #0058a9
#> 76                                           Liberty League       #4f1079
#> 77                                           Liberty League       #000000
#> 78       Massachusetts State Collegiate Athletic Conference       #bf2f38
#> 79                                Atlantic Coast Conference       #000e54
#> 80                                           Liberty League       #f8d000
#> 81                                                     Ohio       #f6c406
#> 82                                  Mid-American Conference       #fd5000
#> 83                                                Heartland       #4e2d8a
#> 84                                                     Ohio       #d55929
#> 85                                  Mid-American Conference       #c41230
#> 86                                       Big Ten Conference       #ba0c2f
#> 87                                  Mid-American Conference       #154734
#> 88                                          Independent DII       #008265
#> 89                                        Big 12 Conference       #fe5c00
#> 90                                Great American Conference       #00498e
#> 91                                  Southeastern Conference       #002b5c
#> 92                                Great American Conference       #841617
#> 93                               United Athletic Conference       #592d82
#> 94                                           Rocky Mountain       #007954
#> 95                                                 Michigan       #ffc423
#> 96                                 Mountain West Conference       #003594
#> 97                                  Mid-American Conference       #041e42
#> 98                                  Southeastern Conference       #990000
#> 99                         Southwestern Athletic Conference       #790000
#> 100                        Southwestern Athletic Conference       #e9a900
#> 101                                                    SIAC       #eaab00
#> 102                              Middle Atlantic Conference       #c82e48
#> 103                        Southwestern Athletic Conference       #4b0058
#> 104                                             Presidents'       #0b2340
#> 105                                                    SIAC       #025399
#> 106                                     American Conference       #003595
#> 107                                            Northeast 10       #ffbc15
#> 108                                               Heartland       #f78f1e
#> 109                                               Lone Star       #245397
#> 110                                     Sun Belt Conference       #000000
#> 111                               Great American Conference       #28825a
#> 112                        Southwestern Athletic Conference       #e0aa0f
#> 113                                               Northwest       #46256a
#> 114                                     Sun Belt Conference       #cc092f
#> 115                               Great American Conference       #ffd20a
#> 116                                            Northeast 10       #004b87
#> 117                                       Pac-12 Conference       #dc4405
#> 118                                                    CCIW       #00437c
#> 119                                            Northern Sun       #002d62
#> 120                Northern Athletics Collegiate Conference       #00549f
#> 121                 Southern Collegiate Athletic Conference       #b20838
#> 122                              United Athletic Conference       #8e0b0b
#> 123                                            Old Dominion       #012853
#> 124                                                So. Cal.       #ffffff
#> 125                                               Northwest       #b4183a
#> 126                                 Mid-American Conference       #ba0c2f
#> 127                                               USA South       #215732
#> 128                                            Northeast 10       #86a7bb
#> 129                                             Presidents'       #00583d
#> 130                                                    <NA>       #613394
#> 131                        Southwestern Athletic Conference       #7b1831
#> 132                                          Rocky Mountain       #f5bc21
#> 133                  Pennsylvania State Athletic Conference       #7a001f
#> 134                                               Heartland       #46166a
#> 135                                                    CIAA       #ffec9f
#> 136                                            Old Dominion       #990022
#> 137                                          Patriot League       #000060
#> 138                                 Mid-American Conference       #005bbb
#> 139                                          Liberty League       #e77324
#> 140                                 Pioneer Football League       #0d1361
#> 141                  Pennsylvania State Athletic Conference       #922135
#> 142                                                So. Cal.       #3b2361
#> 143                            Coastal Athletic Association       #ff4713
#> 144                                       Pac-12 Conference       #a6192e
#> 145                  Pennsylvania State Athletic Conference       #dda10e
#> 146                                               Minnesota       #173a79
#> 147                                             Presidents'       #c71230
#> 148                                          South Atlantic       #f2682a
#> 149                                                    CCIW       #ce0e2d
#> 150                                          South Atlantic       #0c233f
#> 151                                     Landmark Conference       #bf2e1a
#> 152                              United Athletic Conference       #a7a9ac
#> 153                                    Northeast Conference       #1b49a2
#> 154                                       Big 12 Conference       #000000
#> 155                                 Mid-American Conference       #4c0027
#> 156                                             Mid America       #d31145
#> 157                                                    SIAC       #770022
#> 158                                               Lone Star       #ad1d37
#> 159                           Southern Athletic Association       #f5d116
#> 160                                             Mid America       #002d62
#> 161                                          Rocky Mountain       #650934
#> 162                                  Ohio Valley Conference       #2e3192
#> 163                                Mountain East Conference       #651d32
#> 164                                      Big Ten Conference       #061440
#> 165                                        FCS Independents       #006700
#> 166                                       Big 12 Conference       #000000
#> 167                  Pennsylvania State Athletic Conference       #133880
#> 168                              American Rivers Conference       #881922
#> 169                                          Patriot League       #821019
#> 170                                          Rocky Mountain       #011e47
#> 171                                Mountain East Conference       #74043a
#> 172                  Pennsylvania State Athletic Conference       #016f54
#> 173                Northern Athletics Collegiate Conference       #572a31
#> 174                                               Minnesota       #701d45
#> 175                                                 Midwest       #533379
#> 176                                     Landmark Conference       #6b1a31
#> 177                                 Pioneer Football League       #000000
#> 178                                 Pioneer Football League       #004b8d
#> 179                         Mid-Eastern Athletic Conference       #009cdb
#> 180                                              Gulf South       #00753e
#> 181                                             North Coast       #c8032b
#> 182                                              Centennial       #ed192d
#> 183                                     American Conference       #a41e35
#> 184                                 Pioneer Football League       #005596
#> 185                                    Northeast Conference       #002d62
#> 186                  Pennsylvania State Athletic Conference       #dd0632
#> 187                                              Ivy League       #082a74
#> 188                               Great American Conference       #f05423
#> 189                                     Southern Conference       #002d61
#> 190                                      American Southwest       #002b44
#> 191                                  Ohio Valley Conference       #000000
#> 192                              United Athletic Conference       #660819
#> 193                                 Mid-American Conference       #006938
#> 194                                               Lone Star       #006430
#> 195                                                    <NA>       #434445
#> 196                  Pennsylvania State Athletic Conference       #bb131a
#> 197                                                    SIAC       #f68428
#> 198                                                    CIAA       #1235c5
#> 199                               Atlantic Coast Conference       #003594
#> 200                            Coastal Athletic Association       #020303
#> 201                                          South Atlantic       #1e376d
#> 202                                             Mid America       #c29209
#> 203                                          Patriot League       #00205b
#> 204                                                    CIAA       #1468b2
#> 205                              Middle Atlantic Conference       #003f87
#> 206                                                   GLIAC       #ffc423
#> 207                       Great Midwest Athletic Conference       #ff8300
#> 208                                     American Conference       #003366
#> 209                                          Conference USA       #091f3f
#> 210                  Pennsylvania State Athletic Conference       #fec526
#> 211                                          Patriot League       #830032
#> 212                                             Mid America       #a69671
#> 213                                                    SIAC       #f9bd0a
#> 214                                               Heartland       #1b295b
#> 215                                              Centennial       #25377d
#> 216                                          Rocky Mountain       #004785
#> 217                                  Ohio Valley Conference       #c12535
#> 218                                             Presidents'       #8b732f
#> 219                                                    <NA>       #016600
#> 220                                                    <NA>       #fc671a
#> 221                                     Sun Belt Conference       #0039a6
#> 222                                              Centennial       #f4711f
#> 223                                Mountain East Conference       #004f93
#> 224                                              Ivy League       #411e09
#> 225                                                    <NA>       #d01b35
#> 226                                               USA South       #007853
#> 227                                           Upper Midwest       #f36917
#> 228                                            Old Dominion       #910028
#> 229                            Coastal Athletic Association       #0067ac
#> 230                                               Heartland       #0b486d
#> 231                               Great American Conference       #a48544
#> 232                            Coastal Athletic Association       #091f3f
#> 233                               Great American Conference       #7a0026
#> 234                       Great Midwest Athletic Conference       #0d1d41
#> 235                                             Presidents'       #1c4077
#> 236                                    Southland Conference       #00539c
#> 237                               Atlantic Coast Conference       #f56600
#> 238                           Commonwealth Coast Conference       #004b44
#> 239                Northern Athletics Collegiate Conference       #ba0c2f
#> 240                                                 Midwest       #014a91
#> 241                     Missouri Valley Football Conference       #ce1126
#> 242                  Pennsylvania State Athletic Conference       #aa0632
#> 243                                             Great Lakes       #880c2c
#> 244                                      Big Ten Conference       #231f20
#> 245                        Southwestern Athletic Conference       #123297
#> 246                                Mountain West Conference       #0038a8
#> 247                                                    Ohio       #28334a
#> 248                                                    CIAA       #002d56
#> 249                                       Big 12 Conference       #0051ba
#> 250                                       Big 12 Conference       #330a57
#> 251                                 Mid-American Conference       #002664
#> 252                                     Southern Conference       #582c83
#> 253                                                    SIAC       #ffcf06
#> 254                  Pennsylvania State Athletic Conference       #c6b884
#> 255                       Great Midwest Athletic Conference       #3b2e81
#> 256                                                So. Cal.       #004812
#> 257                                    Southland Conference       #000000
#> 258                                                    SIAC       #083254
#> 259                                                    <NA>       #1b3667
#> 260                                          Patriot League       #6c2b2a
#> 261                     Missouri Valley Football Conference       #cd1241
#> 262                                          South Atlantic       #000000
#> 263                                               Northwest       #f37737
#> 264                                          Conference USA       #0a254e
#> 265                                                    CIAA       #fc6c0f
#> 266                                    Northeast Conference       #50c9f7
#> 267                                     Sun Belt Conference       #003087
#> 268                                     American Conference       #004991
#> 269                                     Landmark Conference       #15283f
#> 270                                               Minnesota       #09426a
#> 271                                     Southern Conference       #00386b
#> 272                                               Heartland       #ddac14
#> 273                                            Northern Sun       #480059
#> 274                                                    <NA>       #ad162c
#> 275                                 Pioneer Football League       #e53730
#> 276                                          South Atlantic       #004b8d
#> 277                                          Liberty League       #762334
#> 278                                      American Southwest       #492f92
#> 279                                               USA South       #5f0014
#> 280                                    Southland Conference       #00529c
#> 281                                 Southeastern Conference       #000000
#> 282                                     Southern Conference       #ff7f29
#> 283       New England Women's and Men's Athletic Conference       #244788
#> 284                                    Northeast Conference       #036857
#> 285                                       Big 12 Conference       #154734
#> 286                               Atlantic Coast Conference       #f47423
#> 287                                                   GLIAC       #facd03
#> 288                                          Conference USA       #036eb7
#> 289                                                  NESCAC       #365a8a
#> 290                                                    SIAC       #580d69
#> 291                           Southern Athletic Association       #20145f
#> 292                                           Upper Midwest       #8d191b
#> 293                               Atlantic Coast Conference       #8c1515
#> 294                        Southwestern Athletic Conference       #005328
#> 295                                             Great Lakes       #f0dbaa
#> 296                                             Mid America       #f6cf3c
#> 297                            Coastal Athletic Association       #051844
#> 298                                      American Southwest       #98002e
#> 299                                 Pioneer Football League       #094fa3
#> 300                         Mid-Eastern Athletic Conference       #014786
#> 301                                                    <NA>       #0d0c0c
#> 302                                               Heartland       #002d5d
#> 303                                     American Conference       #00205b
#> 304                                              Centennial       #a51e36
#> 305                                          Rocky Mountain       #4e2683
#> 306                                     American Conference       #00225b
#> 307                         Mid-Eastern Athletic Conference       #880023
#> 308                                     American Conference       #005035
#> 309                                     Sun Belt Conference       #840029
#> 310                                             Mid America       #004d86
#> 311                                Mountain West Conference       #cf0a2c
#> 312                                Mountain West Conference       #041e42
#> 313                                    Northeast Conference       #041e42
#> 314                                              New Jersey       #154c7d
#> 315                                          South Atlantic       #d02030
#> 316                                    Southland Conference       #c41230
#> 317                            Coastal Athletic Association       #0505aa
#> 318                                Mountain West Conference       #01402a
#> 319                                 Southeastern Conference       #500000
#> 320                         Mid-Eastern Athletic Conference       #0c8968
#> 321                              United Athletic Conference       #663399
#> 322                                      Big Sky Conference       #13558d
#> 323                                Mountain West Conference       #c8102e
#> 324                                     Landmark Conference       #031832
#> 325                     Missouri Valley Football Conference       #473282
#> 326                                      Big Sky Conference       #003976
#> 327                                    Southland Conference       #492f91
#> 328       New England Women's and Men's Athletic Conference       #822130
#> 329                              Middle Atlantic Conference       #c41230
#> 330                       Great Midwest Athletic Conference       #ffcf28
#> 331                                       Big 12 Conference       #c8102e
#> 332                                      Big Ten Conference       #00934b
#> 333                                               Northwest       #ffc423
#> 334                                            Northeast 10       #fedc1e
#> 335                                     American Conference       #068f33
#> 336                               Atlantic Coast Conference       #041e42
#> 337                                      Big Sky Conference       #00311e
#> 338                        Southwestern Athletic Conference       #582c83
#> 339                                 Pioneer Football League       #194896
#> 340                                               Northwest       #680001
#> 341                                      Big Ten Conference       #ceb888
#> 342                                 Southeastern Conference       #af5c37
#> 343                                            Old Dominion       #fcdf12
#> 344                           Southern Athletic Association       #cf152d
#> 345                                       Big 12 Conference       #0047ba
#> 346                                    Northeast Conference       #00214d
#> 347                Northern Athletics Collegiate Conference       #5a3f99
#> 348                                          Liberty League       #ed3023
#> 349                            Coastal Athletic Association       #a40012
#> 350                                      Big Sky Conference       #c72026
#> 351                                              New Jersey       #8b0e04
#> 352                                          Conference USA       #f56423
#> 353                                     Southern Conference       #005485
#> 354                                       Big 12 Conference       #be0000
#> 355                                                    SIAC       #280298
#> 356                                    Southland Conference       #215732
#> 357                                  Ohio Valley Conference       #c8102e
#> 358                                                 Midwest       #5b2b82
#> 359                                                    CIAA       #6a1432
#> 360                           Southern Athletic Association       #d0b786
#> 361       New England Women's and Men's Athletic Conference       #f26722
#> 362                  Pennsylvania State Athletic Conference       #0b2240
#> 363                                     Sun Belt Conference       #450084
#> 364                                    Conference Carolinas       #0068b3
#> 365                              American Rivers Conference       #b20838
#> 366                               Atlantic Coast Conference       #a80000
#> 367                               Great American Conference       #003da5
#> 368                         Mid-Eastern Athletic Conference       #7d1315
#> 369                                          Patriot League       #9e0712
#> 370                                          Rocky Mountain       #162856
#> 371                     Missouri Valley Football Conference       #0033a0
#> 372                                     Sun Belt Conference       #ffc72c
#> 373                                 Southeastern Conference       #73000a
#> 374                               Atlantic Coast Conference       #232d4b
#> 375                        Southwestern Athletic Conference       #004b97
#> 376                                            Northeast 10       #071689
#> 377                                                    <NA>       #e51d3a
#> 378                                             Great Lakes       #502583
#> 379                                            Northern Sun       #3a1707
#> 380                           Southern Athletic Association       #000000
#> 381                               Atlantic Coast Conference       #6a2c3e
#> 382                                                    <NA>       #00529b
#> 383                                                    <NA>       #434445
#> 384                                             Presidents'       #a20012
#> 385                                      Big Ten Conference       #2774ae
#> 386                                               Minnesota       #ce153e
#> 387                                             Presidents'       #daad27
#> 388                                    Southland Conference       #393996
#> 389                            Coastal Athletic Association       #990000
#> 390                                                 Midwest       #e12a3d
#> 391                                          Conference USA       #5e0009
#> 392                              United Athletic Conference       #592b82
#> 393                                       Big 12 Conference       #4d1979
#> 394                              American Rivers Conference       #452d7d
#> 395                                  Ohio Valley Conference       #ff6700
#> 396                                 Southeastern Conference       #ff8200
#> 397                                  Ohio Valley Conference       #171796
#> 398                                     Southern Conference       #5a4099
#> 399                                     American Conference       #0c2340
#> 400                                                    <NA>       #e05e15
#> 401                                Mountain West Conference       #ff8200
#> 402                 Southern Collegiate Athletic Conference       #fdbe10
#> 403                                      Big Ten Conference       #33006f
#> 404                        Southwestern Athletic Conference       #860038
#> 405                                       Big 12 Conference       #da291c
#> 406                                     Southern Conference       #7badd3
#> 407                                             Presidents'       #b6964b
#> 408                       Great Midwest Athletic Conference       #004f9d
#> 409                                 Mid-American Conference       #0b2240
#> 410                                       Pac-12 Conference       #a60f2d
#> 411                                                Michigan       #0b335e
#> 412                                     Sun Belt Conference       #862633
#> 413                                             Great Lakes       #510c76
#> 414                                     American Conference       #006747
#> 415                                                    SIAC       #a32035
#> 416                                               Lone Star       #005daa
#> 417                                                 Midwest       #003865
#> 418                                              Centennial       #98012e
#> 419                                              Gulf South       #dd1a32
#> 420                                 Pioneer Football League       #794500
#> 421                                                    CIAA       #72171a
#> 422                                     Southern Conference       #ae122a
#> 423                                                 Midwest       #062336
#> 424                                    Northeast Conference       #00483a
#> 425                       Great Midwest Athletic Conference       #6e0022
#> 426                              American Rivers Conference       #f5822b
#> 427                                             Presidents'       #a93339
#> 428                                             Mid America       #003876
#> 429                                            Old Dominion       #000399
#> 430                                      Big Sky Conference       #18005a
#> 431                                              Gulf South       #d31d33
#> 432                              United Athletic Conference       #0033a1
#> 433                                Mountain East Conference       #ffcd32
#> 434                                              Centennial       #00674d
#> 435                                                    <NA>       #b5121b
#> 436                           Commonwealth Coast Conference       #feb610
#> 437                                               Lone Star       #42196e
#> 438                                               Lone Star       #6a1831
#> 439                                                    <NA>       #005dab
#> 440                                Mountain East Conference       #d2ac2a
#> 441                                               Wisconsin       #b38707
#> 442                                  Ohio Valley Conference       #4e1e8a
#> 443                                 Mid-American Conference       #532e1f
#> 444                                          Rocky Mountain       #c61230
#> 445                                     Southern Conference       #492f91
#> 446                                               Wisconsin       #0068b5
#> 447                                               Northwest       #930036
#> 448                                               Wisconsin       #cd1041
#> 449                              Middle Atlantic Conference       #0056ba
#> 450                                          Patriot League       #115740
#> 451                                                  NESCAC       #500082
#> 452                                                    Ohio       #92c648
#> 453                                                    CIAA       #bb0100
#> 454                                               Wisconsin       #023576
#> 455                           Commonwealth Coast Conference       #1a64b7
#> 456                                               Wisconsin       #850129
#> 457                Northern Athletics Collegiate Conference       #006241
#> 458                                               Wisconsin       #492f91
#> 459                                               Wisconsin       #0c233f
#> 460                                               Wisconsin       #5b3085
#> 461                                             North Coast       #d31145
#> 462                                     Southern Conference       #533b23
#> 463                                             North Coast       #f7be00
#> 464       New England Women's and Men's Athletic Conference       #c41230
#> 465                                      Big Ten Conference       #a00000
#> 466                                Mountain West Conference       #492f24
#> 467                     Missouri Valley Football Conference       #e51936
#> 468                        Southwestern Athletic Conference       #ee8601
#> 469                           Southern Athletic Association       #00205b
#> 470                                      American Southwest       #02215b
#> 471                                     Sun Belt Conference       #00b140
#> 472                                       Big 12 Conference       #eaaa00
#> 473                                        FCS Independents       #2f4f93
#> 474       New England Women's and Men's Athletic Conference       #005588
#> 475                                          Liberty League       #663a2b
#> 476                                       Pac-12 Conference       #b1102b
#> 477                                                Empire 8       #00462d
#> 478                                                Empire 8       #c00c26
#> 479                                                Michigan       #efb30f
#> 480                                                Michigan       #421d2f
#> 481                                               Minnesota       #002d62
#> 482                            Coastal Athletic Association       #000000
#> 483                                    Conference Carolinas       #00529b
#> 484                                                    SIAC       #ad141a
#> 485                              Middle Atlantic Conference       #004c23
#> 486                                      American Southwest       #5b2d83
#> 487                                                Michigan       #f36b23
#> 488                                  Ohio Valley Conference       #b3a068
#> 489                                             Great Lakes       #54237f
#> 490                                            Northern Sun       #c8102e
#> 491                                              New Jersey       #c20f2f
#> 492                     Missouri Valley Football Conference       #00669a
#> 493                                    Conference Carolinas       #d91e39
#> 494                               Great American Conference       #d02030
#> 495                                         Independent DII       #ce0e2d
#> 496                                             Great Lakes       #947e1b
#> 497                                              New Jersey       #571b04
#> 498                                            Old Dominion       #b80835
#> 499                                            Northeast 10       #0c233f
#> 500                Northern Athletics Collegiate Conference       #004712
#> 501                                               Lone Star       #eb0626
#> 502                                    Southland Conference       #ffc333
#> 503                       Great Midwest Athletic Conference       #00401f
#> 504                                          South Atlantic       #f2682a
#> 505                                    Northeast Conference       #300a48
#> 506                                          South Atlantic       #e30000
#> 507                                     Landmark Conference       #002857
#> 508                                            Northern Sun       #ffd02e
#> 509                                             Presidents'       #9a5627
#> 510                                               Lone Star       #e2383f
#> 511                                             Presidents'       #00355f
#> 512                                                So. Cal.       #4a217b
#> 513                                            Northern Sun       #4b09a2
#> 514                  Pennsylvania State Athletic Conference       #b42622
#> 515                                               USA South       #005288
#> 516                                              New Jersey       #092f56
#> 517                                             Great Lakes       #112845
#> 518                                                    <NA>       #082443
#> 519                                    Conference Carolinas       #8d754f
#> 520                           Commonwealth Coast Conference       #007b5f
#> 521                       Great Midwest Athletic Conference       #7fb0d6
#> 522                               Great American Conference       #542989
#> 523                                                 Midwest       #c10e3f
#> 524                                            Northern Sun       #492f91
#> 525                                               USA South       #9b2036
#> 526                                                So. Cal.       #751708
#> 527                                     Sun Belt Conference       #041e42
#> 528                                 Pioneer Football League       #512873
#> 529      Massachusetts State Collegiate Athletic Conference       #1b509e
#> 530                                               USA South       #fec325
#> 531                                             Great Lakes       #ea1c2d
#> 532                                                    <NA>       #00457c
#> 533                                               USA South       #003c78
#> 534                                    Southland Conference       #000000
#> 535                                                 Midwest       #d4282f
#> 536                                    Southland Conference       #dc6000
#> 537                                                So. Cal.       #00549a
#> 538                               Great American Conference       #2e3d50
#> 539                                              New Jersey       #01573c
#> 540                                               Northwest       #960a2c
#> 541                                               USA South       #d21f36
#> 542                                                    CIAA       #86b0c6
#> 543                                     Sun Belt Conference       #003768
#> 544       New England Women's and Men's Athletic Conference       #790032
#> 545                                             Presidents'       #083150
#> 546                              American Rivers Conference       #ea0029
#> 547      Massachusetts State Collegiate Athletic Conference       #edb317
#> 548                                               Minnesota       #000000
#> 549                              Middle Atlantic Conference       #ffe315
#> 550                                            Old Dominion       #900028
#> 551                                              New Jersey       #000000
#> 552      Massachusetts State Collegiate Athletic Conference       #054e39
#> 553                  Pennsylvania State Athletic Conference       #c0b45f
#> 554                                                  NESCAC       #032d58
#> 555                                             North Coast       #e82524
#> 556                                Mountain East Conference       #75243e
#> 557                                      Big Ten Conference       #9d2235
#> 558                                 Pioneer Football League       #2f99d4
#> 559                                      Big Sky Conference       #002855
#> 560                                      Big Sky Conference       #ef8c00
#> 561                                                    CCIW       #006f51
#> 562                                            Northern Sun       #d8ab27
#> 563                                                    CCIW       #b20838
#> 564                       Great Midwest Athletic Conference       #513093
#> 565                                     Sun Belt Conference       #ce181e
#> 566                                      Big Sky Conference       #ba1c21
#> 567                            Coastal Athletic Association       #127dbe
#> 568                                                Empire 8       #00502f
#> 569                                              New Jersey       #005394
#> 570                                                Empire 8       #00467f
#> 571                                                    Ohio       #00275c
#> 572                               Great American Conference       #255f2b
#> 573                                                    CCIW       #f16723
#> 574                                          Patriot League       #790000
#> 575                                     Landmark Conference       #1f3361
#> 576                                                    <NA>       #871c30
#> 577                                     Sun Belt Conference       #006f71
#> 578                                                    <NA>       #124d39
#> 579                                       Pac-12 Conference       #501214
#> 580                                       Pac-12 Conference       #0f2439
#> 581                                                  NESCAC       #012778
#> 582                                                    CIAA       #a9712c
#> 583                                      Big Sky Conference       #a10022
#> 584                                                    Ohio       #bf2037
#> 585                                 Southeastern Conference       #9e1b32
#> 586                                                  NESCAC       #d72121
#> 587                                          Conference USA       #fdbb30
#> 588                                                  NESCAC       #ffffff
#> 589                                Mountain East Conference       #d31145
#> 590                                 Southeastern Conference       #5d1725
#> 591                                                  NESCAC       #062f87
#> 592                                     American Conference       #000000
#> 593                                          South Atlantic       #182441
#> 594                                             North Coast       #613394
#> 595                                                Michigan       #e72623
#> 596                                      Big Ten Conference       #ff5f05
#> 597                                                    Ohio       #cca05b
#> 598                                       Pac-12 Conference       #004c23
#> 599                                                Empire 8       #633394
#> 600                                    Conference Carolinas       #000000
#> 601                  Pennsylvania State Athletic Conference       #fcb040
#> 602                                                Empire 8       #c02f39
#> 603                                               Minnesota       #00447c
#> 604      Massachusetts State Collegiate Athletic Conference       #0f223f
#> 605                                       Big 12 Conference       #cfb87c
#> 606                           Southern Athletic Association       #8c2129
#> 607                              Middle Atlantic Conference       #003767
#> 608                                             Great Lakes       #1a2d5d
#> 609                                                Empire 8       #0b2240
#> 610                                             North Coast       #ad0935
#> 611                                                    CCIW       #002857
#> 612                                     Landmark Conference       #002856
#> 613                            Coastal Athletic Association       #3d2777
#> 614                           Commonwealth Coast Conference       #65448b
#> 615      Massachusetts State Collegiate Athletic Conference       #004b8e
#> 616                Northern Athletics Collegiate Conference       #245699
#> 617                                        FBS Independents       #0c2340
#> 618                                                So. Cal.       #ab1d38
#> 619                                               Northwest       #002d62
#> 620                 Southern Collegiate Athletic Conference       #d1ac54
#> 621                           Southern Athletic Association       #f58023
#> 622                                                    Ohio       #35236a
#> 623                                            Northern Sun       #8e0a26
#> 624                                                    Ohio       #291f2e
#> 625                                                    Ohio       #ff5324
#> 626                                              Ivy League       #004a81
#> 627                                           Upper Midwest       #06496f
#> 628                       Great Midwest Athletic Conference       #113d2a
#> 629                                           Upper Midwest       #de1b22
#> 630                           Commonwealth Coast Conference       #008265
#> 631                                Mountain East Conference       #ff4c00
#> 632                                          Patriot League       #110e42
#> 633                         Mid-Eastern Athletic Conference       #003a63
#> 634                              Middle Atlantic Conference       #005747
#> 635                                          Conference USA       #00539f
#> 636                              American Rivers Conference       #1c3c75
#> 637                                                    SIAC       #fcd309
#> 638                                     American Conference       #1a5632
#> 639                        Southwestern Athletic Conference       #f89728
#> 640                                           Upper Midwest       #5c2f92
#> 641                                                    <NA>       #fff200
#> 642                               Atlantic Coast Conference       #782f40
#> 643                                                    <NA>       #f0b310
#> 644                                               USA South       #df1c2b
#> 645                                          Conference USA       #cc0000
#> 646                                            Northern Sun       #0a2e6e
#> 647                                 Pioneer Football League       #0a5640
#> 648                                            Northern Sun       #ce0e2d
#> 649                                 Southeastern Conference       #0021a5
#> 650                                     American Conference       #006747
#> 651                                           Upper Midwest       #291d40
#> 652                               Atlantic Coast Conference       #b3a369
#> 653                                     Sun Belt Conference       #00205b
#> 654                                                    SIAC       #840028
#> 655                                 Southeastern Conference       #ba0c2f
#> 656                  Pennsylvania State Athletic Conference       #d11042
#> 657                                          Rocky Mountain       #131f48
#> 658                                Mountain West Conference       #005737
#> 659                              American Rivers Conference       #feba12
#> 660                Northern Athletics Collegiate Conference       #fec425
#> 661                                                 Midwest       #ee3124
#> 662                                       Big 12 Conference       #ae192d
#> 663                                                 Midwest       #015a9c
#> 664                                       Pac-12 Conference       #0033a0
#> 665                              American Rivers Conference       #aa985d
#> 666                                                  NESCAC       #3f1f69
#> 667                                      Big Sky Conference       #000000
#> 668                                                    CCIW       #00a2e0
#> 669                                                    CCIW       #014576
#> 670                                                    CCIW       #0057a8
#> 671                                      Big Ten Conference       #492f92
#> 672                     Missouri Valley Football Conference       #85283d
#> 673                                 Southeastern Conference       #a32136
#> 674                                                 Midwest       #8b0021
#> 675       New England Women's and Men's Athletic Conference       #862633
#> 676                                             North Coast       #ffce34
#> 677                                      Big Ten Conference       #970310
#> 678                                               Heartland       #800000
#> 679                                        FBS Independents       #062340
#> 680                                             North Coast       #ce0e19
#> 681                                       Big 12 Conference       #ffc627
#> 682                                             Mid America       #e51837
#> 683                     Missouri Valley Football Conference       #002148
#> 684                                 Southeastern Conference       #0033a0
#> 685                               Atlantic Coast Conference       #c9001f
#> 686                                          Conference USA       #e13a3e
#> 687                                 Southeastern Conference       #461d76
#> 688                                     American Conference       #0e1d41
#> 689                               Atlantic Coast Conference       #003ca6
#> 690                           American Southwest Conference       #ff9da7
#> 691                              American Rivers Conference       #edc948
#> 692                                       Big 12 Conference       #fa4238
#> 693                                      Big Sky Conference       #0133a0
#> 694                                      Big Ten Conference       #0082cb
#> 695                            Coastal Athletic Association       #002648
#> 696            College Conference of Illinois and Wisconsin       #f28e2b
#> 697            Central Intercollegiate Athletic Association       #bab0ac
#> 698                               Conference of New England       #9c755f
#> 699                                          Conference USA       #002638
#> 700                                    Conference Carolinas       #e15759
#> 701                                   Centennial Conference       #e15759
#> 702                                                Empire 8       #4e79a7
#> 703                                        FBS Independents       #76b7b2
#> 704                                        FCS Independents       #9c755f
#> 705                       Great Midwest Athletic Conference       #76b7b2
#> 706         Great Lakes Intercollegiate Athletic Conference       #ff9da7
#> 707                           Great Lakes Valley Conference       #bab0ac
#> 708                                   Gulf South Conference       #edc948
#> 709                               Great American Conference       #76b7b2
#> 710                Heartland Collegiate Athletic Conference       #bab0ac
#> 711                                              Ivy League       #18563f
#> 712                                    Lone Star Conference       #9c755f
#> 713                                     Landmark Conference       #edc948
#> 714                                          Liberty League       #edc948
#> 715                                 Mid-American Conference       #009844
#> 716      Massachusetts State Collegiate Athletic Conference       #ff9da7
#> 717                         Mid-Eastern Athletic Conference       #582c82
#> 718                                Mountain East Conference       #59a14f
#> 719       Mid-America Intercollegiate Athletics Association       #bab0ac
#> 720           Michigan Intercollegiate Athletic Association       #4e79a7
#> 721           Minnesota Intercollegiate Athletic Conference       #bab0ac
#> 722                     Missouri Valley Football Conference       #9c755f
#> 723                             Middle Atlantic Conferences       #59a14f
#> 724                                      Midwest Conference       #4e79a7
#> 725                                Mountain West Conference       #4e2d7f
#> 726                Northern Athletics Collegiate Conference       #e15759
#> 727                                                    <NA>       #e15759
#> 728                         North Coast Athletic Conference       #e15759
#> 729                                 Northeast-10 Conference       #ff9da7
#> 730                                    Northeast Conference       #035f9b
#> 731           New England Small College Athletic Conference       #76b7b2
#> 732       New England Women's and Men's Athletic Conference       #76b7b2
#> 733                          New Jersey Athletic Conference       #59a14f
#> 734                 Northern Sun Intercollegiate Conference       #9c755f
#> 735                                    Northwest Conference       #f28e2b
#> 736                                Ohio Athletic Conference       #edc948
#> 737                        Old Dominion Athletic Conference       #59a14f
#> 738                                  Ohio Valley Conference       #a51844
#> 739                         Presidents' Athletic Conference       #edc948
#> 740                  Pennsylvania State Athletic Conference       #4e79a7
#> 741                                       Pac-12 Conference       #001a6f
#> 742                                          Patriot League       #00205a
#> 743                                 Pioneer Football League       #ff9da7
#> 744                      Rocky Mountain Athletic Conference       #59a14f
#> 745                           Southern Athletic Association       #f28e2b
#> 746                 Southern Collegiate Athletic Conference       #b07aa1
#> 747 Southern California Intercollegiate Athletic Conference       #4e79a7
#> 748                                 Southeastern Conference       #012d74
#> 749            Southern Intercollegiate Athletic Conference       #bab0ac
#> 750                        Southwestern Athletic Conference       #e2201b
#> 751                                     Southern Conference       #001588
#> 752                                    Southland Conference       #c1a552
#> 753                                     Sun Belt Conference       #0c2140
#> 754                       Upper Midwest Athletic Conference       #ff9da7
#> 755                           USA South Athletic Conference       #bab0ac
#> 756                             Western Athletic Conference       #8a2432
#> 757           Wisconsin Intercollegiate Athletic Conference       #bab0ac
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
#> 690         #9c755f     fallback
#> 691         #b07aa1     fallback
#> 692            <NA>     cbbplotR
#> 693         #43c6e7     cbbplotR
#> 694            <NA>     cbbplotR
#> 695            <NA>     cbbplotR
#> 696         #e15759     fallback
#> 697         #4e79a7     fallback
#> 698         #bab0ac     fallback
#> 699         #e31c47     cbbplotR
#> 700         #76b7b2     fallback
#> 701         #76b7b2     fallback
#> 702         #f28e2b     fallback
#> 703         #59a14f     fallback
#> 704         #bab0ac     fallback
#> 705         #59a14f     fallback
#> 706         #9c755f     fallback
#> 707         #4e79a7     fallback
#> 708         #b07aa1     fallback
#> 709         #59a14f     fallback
#> 710         #4e79a7     fallback
#> 711            <NA>     cbbplotR
#> 712         #bab0ac     fallback
#> 713         #b07aa1     fallback
#> 714         #b07aa1     fallback
#> 715         #0c2140     cbbplotR
#> 716         #9c755f     fallback
#> 717         #feb81d     cbbplotR
#> 718         #edc948     fallback
#> 719         #4e79a7     fallback
#> 720         #f28e2b     fallback
#> 721         #4e79a7     fallback
#> 722         #bab0ac     fallback
#> 723         #edc948     fallback
#> 724         #f28e2b     fallback
#> 725         #afafaf     cbbplotR
#> 726         #76b7b2     fallback
#> 727         #76b7b2     fallback
#> 728         #76b7b2     fallback
#> 729         #9c755f     fallback
#> 730            <NA>     cbbplotR
#> 731         #59a14f     fallback
#> 732         #59a14f     fallback
#> 733         #edc948     fallback
#> 734         #bab0ac     fallback
#> 735         #e15759     fallback
#> 736         #b07aa1     fallback
#> 737         #edc948     fallback
#> 738         #d0ae85     cbbplotR
#> 739         #b07aa1     fallback
#> 740         #f28e2b     fallback
#> 741            <NA>     cbbplotR
#> 742         #d9291c     cbbplotR
#> 743         #9c755f     fallback
#> 744         #edc948     fallback
#> 745         #e15759     fallback
#> 746         #ff9da7     fallback
#> 747         #f28e2b     fallback
#> 748         #ffd040     cbbplotR
#> 749         #4e79a7     fallback
#> 750            <NA>     cbbplotR
#> 751            <NA>     cbbplotR
#> 752            <NA>     cbbplotR
#> 753         #f5a606     cbbplotR
#> 754         #9c755f     fallback
#> 755         #4e79a7     fallback
#> 756            <NA>     cbbplotR
#> 757         #4e79a7     fallback
```
