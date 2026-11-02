# Ash & Oath v0.25 validation

Godot 4.6.3 official Linux engine; official export templates verified against release SHA-512 sums. Runtime logic remains compatible with the prior release engine.

355 event-rule checks and 24 event UI checks passed. All 24 core regression scripts listed in `Validation-v0.25.json` passed (7,541 reported checks). Tests exercise costs, successful and failed risks, exact rewards, one-time settlement, local save/reload, interrupted fights, supply use/caps, two ordinary monsters, held Reactions and preserved boss selection.

Chromium ran the exported WebGL build at 1440×900 with software rendering. The test selected two legal bonus faces for each hero, entered boss review, rolled all six events, resolved each safe choice, checked reward summaries, reloaded and verified unchanged inventory and a completed claim, entered an ordinary encounter, and inspected supplies and public dice. There were no console or page errors. `tools/verify_events_browser.py` reproduces this flow against an export served at port 8765; it writes screenshots and a report under ignored `exports/validation-v0.25/`. Requires Playwright, Chromium and Tesseract.

The Pages package uses `index.v0.25.pck` in `GODOT_CONFIG.mainPack` and its size table. Its pack is byte-identical to the browser-tested export. A separate Chromium smoke test verifies the exact staged Pages package loads the versioned pack successfully and reaches a selected event. `BUILD.json` on Pages records SHA-256 values and source provenance.

One historical `interaction_v14_test.gd` fixture was attempted headlessly and timed out waiting for `frame_post_draw`. It is not passed. Other historical rendered fixtures were not rerun. Native UI tests report inherited resource-leak warnings at shutdown, without script errors. Core test exit statuses and reported checks were inspected; this is not a claim that every historical test passes.

Monster victory grants and consumed supplies were exercised by the model/UI fixtures; the browser test covers real navigation/rendering, safe event rewards and persistence, not a full manually played monster victory. No new human balance study was performed. Event fights and bosses start fresh, only the local ledger persists, and the Windows build is unchanged.

Deployment is verified separately through GitHub Pages Actions after pushing `gh-pages`. A local browser pass alone does not establish live deployment.
