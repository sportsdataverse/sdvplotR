# Social game-day graphics (automation example)

`sdvplotR_social.R` makes social-media graphics from SportsDataverse data and posts them to
Bluesky:

- **Leaderboards**: a season's leaders in one stat, as a gt table with headshots and logos,
  dressed in the leading player's team colors.
- **Final-score cards**: one per game, with both logos on their team colors.
- **A player-of-the-game card**: the headshot on the team's color.

It covers the NFL, the NBA, the WNBA, MLB and the NHL. The data comes from the SportsDataverse
release files (nflreadr, hoopR, wehoop, fastRhockey) and the MLB Stats API (baseballr); nothing
needs a key. Images are 1080 x 1080 or 1200 x 675.

The walk-through, with sample images, is the
[Social graphics, automated](https://sdvplotR.sportsdataverse.org/articles/automation-social.html)
article.

## Quick start

From a clone of sdvplotR, with sdvplotR installed:

```sh
Rscript -e 'install.packages(c("nflreadr", "hoopR", "wehoop", "fastRhockey", "baseballr", "httr2", "jsonlite", "webshot2"))'
Rscript examples/automation/sdvplotR_social.R leaderboard --league nfl
Rscript examples/automation/sdvplotR_social.R gameday --league nba
Rscript examples/automation/sdvplotR_social.R post         # dry-run of the newest out/<date>/manifest.json
Rscript examples/automation/sdvplotR_social.R post --post  # posts its fresh, not-yet-posted posts
```

Posting needs `BSKY_HANDLE` and `BSKY_APP_PASSWORD` (a Bluesky app password, never the account
password); `BSKY_SERVICE` picks another PDS. The leaderboard tables render in headless Chrome
(webshot2), so Chrome or Chromium must be installed.

## Files

| File | What |
| --- | --- |
| `sdvplotR_social.R` | the script: `leaderboard`, `gameday` and `post` subcommands |
| `workflows/sdvplotR-social.yml` | a GitHub Actions template to copy into your repository (weekly, posts on request) |

`tests/test-sdvplotR_social.R` tests the script offline (argument handling, the
manifest, the posted-ledger and the Bluesky requests, with a fake transport).
`.github/workflows/automation-example.yaml` runs it weekly on live data in dry-run mode; it has no
secrets, and the script refuses `--post` in sdvplotR's own GitHub Actions.
