---
name: Missing or incorrect team data
about: A team logo, wordmark, color, or historical abbreviation is wrong or missing
title: "[DATA] "
labels: data
assignees: ''
---

**Which league?**
- [ ] NFL
- [ ] NBA
- [ ] WNBA
- [ ] MLB
- [ ] NHL
- [ ] CFB
- [ ] MBB
- [ ] WBB
- [ ] Soccer
- [ ] Other league of `sdv_leagues()` (key: ___)

**Team(s) affected**
e.g., `KC` (NFL), `OSU` (CFB), `LAL` (NBA)

**What is wrong?**
- [ ] Missing logo / logo URL is broken
- [ ] Dark / alt / classic variant is wrong or missing
- [ ] Wordmark URL is broken or missing
- [ ] Team color(s) are wrong (hex values)
- [ ] Historical abbreviation mapping is missing / wrong (e.g., `OAK` → `LV`)
- [ ] Headshot resolution or URL is wrong
- [ ] Other

**Current value(s)**
```
# paste current output, e.g.:
sdv_teams("nfl")
sdv_resolve("OAK", "nfl")
sdv_team_colors("nfl", "KC")
```

**Expected / correct value(s)**
Provide the correct hex codes, URLs, or mappings. Include a source (official team media guide, league site, ESPN CDN inspection, etc.)

**Additional context**
Add any other context or screenshots.
