# v0.22 validation · 1 November 2026

## Focused checks

- New summon/model suite: **298 checks, 0 failures**. Covers adjacent empty placement, invalid placement without spending, one worm per owner across copies, Command and its declaration, automatic owner-end activation, death/resummoning, per-owner labels, successful and blocked bites, boss/summon Poison, refresh without stacking, unavoidable ticks, Downing, faction-separated caps and Nu’gh consumption/Soul Link, cocoon break rewards, three-phase aging, early/all hatching, phase-II newborn Block/HP, Shell, Mandate, real mite Reaction windows, HP-hit debuffs, expiry, area and single-target Crash, Cleave faction filtering, legal orthogonal paths and seeded bite outcomes.
- New rendered UI suite: **28 checks, 0 failures**. Uses all four selectors and starts the corresponding models; tests real tile input, owner markers, Command labels and Resolve, death restoring Summon, phase upgrades and opening Balance Workshop.
- Nu’gh v0.21 brood regression: **2,414 checks, 0 failures**.
- A broad historical run completed 40 scripts. After adding the reason text to the new patch-note page, **33 pass**; the focused v0.22 UI suite is additional. Seven older UI scripts retain obsolete click-pinned inspector assumptions or old inspection state expectations: `boss_v13_ui_test`, `cantor_v20_ui_test`, `clarity_v17_test`, `encounter_v18_ui_test`, `encounter_v19_ui_test`, `playtest_v12_ui_test`, `update_ui_test`. The first six were also reproduced on source `a8884c3d`; the last expects a boss-intent click to pin details. They are not reported as passing. The current v0.21 feedback/hover UI test passes. Catalog-count assertions were expanded; the Lab fixture now supplies a real Summon destination.
- Existing passing coverage includes balance, catalog, Nu’gh, Cantor model, loadouts, numeric feedback, ownership/presets, soul movement, reactions, reliability, rule checks, presentation/pair checks and current feedback UI. These tests do not constitute exhaustive verification.

## Trial battles

The visible-board heuristic used seeds 1–10 for each build and Blank movement setting (OFF, Move 1, Move 2): 3 builds × 3 settings × 10 seeds × 4 bosses = **360 encounters**. Mixed builds choose two distinct bonus designs. Summoner pairs are Vesper [Summon Nu’gh, Strike Numeric], Rook [Summon Nu’gh, Brace Hero], Wren [Summon Nu’gh, Restore]. Starting builds use the default dice without bonus faces. The bot uses real actions and recorded RNG and does not rewrite combat state to obtain wins.

| Boss | Starting W/L/limit | Mixed W/L/limit | Summoner W/L/limit |
| --- | --- | --- | --- |
| The Hollow | 7 / 23 / 0 | 15 / 15 / 0 | 14 / 16 / 0 |
| Nu’gh | 2 / 28 / 0 | 5 / 25 / 0 | 16 / 14 / 0 |
| Veyl | 5 / 25 / 0 | 9 / 21 / 0 | 6 / 24 / 0 |
| Bu’gh | 3 / 21 / 6 | 12 / 13 / 5 | 20 / 9 / 1 |

Total: **114 hero wins, 234 boss wins, 12 round limits**. All twelve limits occurred against Bu’gh. Logs continued through normal turn/brood sequencing to round 51, with empty pending choices, rather than freezing on a required input. Bu’gh’s defensive/summoning loops and the bot’s target priorities can produce long fights. Starting and summoner builds differ substantially. These are small heuristic samples, not human win-rate estimates. **Bu’gh remains provisionally balanced and needs player feedback.** Raw per-setting results are in `Trial-results-v0.22.json`. No model/script errors occurred in the trials.

## Browser and graphics

The actual single-threaded Godot 4.6.3 browser export ran in Chromium/WebGL 2.0 at 1440×900. Real pointer/keyboard input selected Summon Nu’gh and a second distinct face for each hero, chose Bu’gh and entered its arena. Screenshots verify the four visible selector cards, original Cocoon Regent/cocoon sprites, readable logs and unobstructed arena. The shipped Ability Lab selector was scrolled to Summon Nu’gh; real tile input created the friendly sprite and Vesper marker; its live label changed to Command; Roll chosen face again and Resolve activated that same worm. Numeric and hover regression checks remain passing. Browser console: no script/page errors; the expected pre-gesture audio-autoplay warning is benign.

Additional rendered fixtures show phase-II Bu’gh and friendly/enemy summons together. Pixel sprites were generated with integer-grid drawing in `tools/make_bugh_art.py`, not painted or image-generated art.

## Build and documentation

The current rules exporter reads the implemented catalog and all four boss models. PDF, HTML and Markdown are generated from one rulebook source, with 60 face IDs and 48 bonus designs. In-game patch notes and Balance Workshop values are updated. `tools/export_web.sh` and the checked-in preset under `tools/` reproduce the browser export with installed Godot 4.6.3 templates.

The environment blocks direct requests to `lordtoff.github.io` and `api.github.com`. Local real-browser verification is complete; live-site verification depends on the existing GitHub Pages deployment status. The older Windows build is not part of this release.
