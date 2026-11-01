# Ash & Oath v0.22.1

[Play in your browser](https://lordtoff.github.io/Godot-Game-Template/?v=0.22.1)

**v0.22.1 fixes friendly worm movement:** a worm can now take a full legal detour around heroes, moving up to two steps after its owner’s turn or through Command. [Hotfix details and tests](CHANGES_v0.22.1.md). The resource pack uses a fresh versioned URL so the old cached build does not hide the fix.

Bu’gh, the Cocoon Regent is the optional fourth encounter. Break cocoons for Block and boss Weakness; control its hatching mites. All six abilities upgrade at half HP. The Hollow, Nu’gh and Veyl remain selectable.

Choose the new Skill **Summon Nu’gh**: one friendly 1-HP worm per hero. It moves and bites after its owner’s turn; while alive the face becomes **Command Nu’gh**, granting an extra activation. Bites roll 1,1,0,0,0,0; HP damage applies Poison 1. Friendly summons have owner markers and never feed enemy brood mechanics.

[Changes](CHANGES_v0.22.md) · [Current rules](current-rules.html) · [PDF rulebook](AshAndOath-Current-Rules-v0.22.pdf) · [Balance Workshop](BALANCE_WORKSHOP.md) · [Validation](Validation-v0.22.md) · [Trial scenarios](Trial-results-v0.22.json)

Balance remains provisional. 360 seeded heuristic battles: 114 hero wins, 234 boss wins, 12 Bu’gh round limits. These are not human win-rate estimates. New focused tests pass 298 model and 28 rendered UI checks; Nu’gh’s 2,414-check brood regression passes. Historical UI-test limitations are documented. The real browser export was checked in Chromium/WebGL.

The Windows download remains an older release. Historical reports and downloads retain their versions.

Source: [`38af1644`](https://github.com/LordToff/Godot-Game-Template/commit/38af164471de2cbcd42fc1d508ead75e83699660).
