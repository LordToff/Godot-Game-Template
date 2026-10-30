> v0.21: autonomous worms, chance-based bites and poison, projected 3D Numeric rolls, hover-only combat details, face-picker previews and tile-by-tile movement. [Changes](../docs/Changes-v0.21.md).

> v0.20: optional third boss Veyl, Resonance / open-core windows, original bell sprites and block-only starter Reaction. [Rules and test notes](../docs/Changes-v0.20.md).

> v0.19: retreating human-worm Nu’gh, active Brood Command, phase-I-only Soul Link, stronger Hollow hazards and persistent fallback outcomes. [Changes and trials](../docs/Changes-v0.19.md).

Versioned sections below describe their historical releases; use the current rulebook for current mechanics.

[Current consolidated rules](../docs/Current-Rules-v0.21.md) · [PDF rulebook](../docs/AshAndOath-Current-Rules-v0.21.pdf)

> v0.18 adds Nu’gh, the pre-fight review screen, Stunned stars and upgrades for every boss action. [Changes and reasons](../docs/Changes-v0.18.md).

# Ash & Oath v0.21 — playable prototype

A local tactical dice-building boss battler built from the supplied Master Rules v10 and Action Faces. This update responds to playtesting: clearer boss effects, animated Numeric rolls, pixel arena and knight sprites, one starting reroll per hero, a full-catalog starter draft, and a tuned tutorial. The original balance remains selectable.

## Current v0.17

See [combat clarity changes](../docs/Changes-v0.17.md). Focus identifies legal targets, spends / greys its source and selects the new result. Banked rerolls distinguish saved charges from the opening window. Non-rerollable faces explain why; Focus respects the same restriction. `ability_copy.gd` supplies short descriptions with active values. Weak Point has a persistent marker and inspectable duration. Boss phase upgrades remain visible; stronger impact effects can be disabled in options.

```bash
godot --path . --audio-driver Dummy --script prototype/tests/clarity_v17_test.gd
godot --path . --audio-driver Dummy --script prototype/tests/choice_layout_v17_test.gd
```

## Historical v0.16

See [the trial report and fixes](../docs/Changes-v0.16.md). 3,600 before / 3,600 after matched encounters cover six team builds and three Blank movement settings. The normal random-bonus / Soul-OFF bot wins 99/200. There were no stalls. Default balance values stay unchanged; direct regressions cover Black Oath cost expiry, Ward attacker attribution, zero-count Fracture and killing-hit rewards.

```bash
ASH_TRIAL_COUNT=200 godot --headless --path . --script prototype/tests/trial_battles.gd
godot --headless --path . --script prototype/tests/trial_regression_test.gd
```

## Historical v0.15

See [the bug-fix guide](../docs/Changes-v0.15.md). Reproduced fixes cover Stunned with no unused dice, dead Broken actors, zero-charge bargains, rear geometry independent of Ward range, Ward after damage prevention, actual-value logs and Numeric positive-side counts. Obsolete modal callbacks and invalid indices are rejected. `preset.gd` validates and normalizes a whole saved team before applying it. Manual legal presets with unequipped owned designs remain supported. Restore regenerates a legal build including the two selected designs.

```bash
godot --headless --path . --script prototype/tests/bugfix_v15_test.gd
godot --headless --path . --script prototype/tests/preset_v15_test.gd
godot --path . --audio-driver Dummy --script prototype/tests/bugfix_v15_ui_test.gd
```

## Historical v0.14

See [the v0.14 change guide](../docs/Changes-v0.14.md). Bonus cards quick-equip with one click and support actual drag gestures onto a die or exact square. Installed faces swap by dragging. The draft shows the live dice and preserves placements through hero switching and starting combat. `face_loadout.gd` validates previews and placements atomically. Body / ownership / Blank rules remain enforced.

Blank movement uses its numeric counter as the source of truth, with one reset function for normal / recovery own turns and visible refresh events. Combat guidance distinguishes exhausted allowance, spent die, Soul OFF and Rooted. Rooted and Weakness have persistent procedural sprite effects that consume no gameplay RNG.

```bash
godot --headless --path . --script prototype/tests/loadout_v14_test.gd
godot --path . --audio-driver Dummy --script prototype/tests/interaction_v14_test.gd
```

## Historical v0.13

See [the v0.13 boss guide](../docs/Changes-v0.13.md). Phase I Brand is a cross, phase II Brand is a square. Phase II Chain adds Rooted until next boss turn; voluntary movement stops while forced movement remains legal. Advance pursues highest current HP and gains 1 Block if already adjacent to any tied highest-HP hero. Distort prefers highest HP if reachable, otherwise closest in range. Drive Back pushes automatically along the hit direction. Smoking Strike causes persistent cell fire only on HP damage, consuming existing fire for normal detonation damage.

The boss has HP / Block beneath its sprite and a separate phase-II sprite and ember animation. Lab tools can trigger the real half-HP threshold. New numeric parameters use the existing workshop; legacy `boss.Strike.damage` / `range` keys remain compatible. Earlier sections below describe historical versions.

```bash
godot --headless --path . --script prototype/tests/boss_v13_test.gd
godot --path . --audio-driver Dummy --script prototype/tests/boss_v13_ui_test.gd
```

## Historical v0.12

See [the short v0.12 change guide](../docs/Changes-v0.12.md) for exact before/after rules, reasons and test results. Strike 1; Numeric 2/2/1/1/1/0 without the former extra attack bonus; Short Shot cap 2. Stonewake breaks on HP damage or 2 cumulative Block lost per own-turn window. Engrave grows only once per turn on HP damage, into Blanks, up to 3 copies. Tuned boss 12 HP / Strike 1; Cinder Brand is 3×3; Furnace Roar unlocks once at half HP. New numbers are exposed in the balance workshop.

Ability and boss descriptions open beside the arena. Hover and active-turn summaries expose status effects. Player HP uses dots. Both editing and viewing dice use unfolded six-square nets. Reroll eligibility and repeated-Blank outcomes are explained. Lab supports forced Numeric 2. Saved custom settings remain authoritative; Reset all to load new defaults. Earlier sections below describe historical versions.

```bash
godot --headless --path . --script prototype/tests/playtest_v12_test.gd
godot --path . --audio-driver Dummy --script prototype/tests/playtest_v12_ui_test.gd
```

## New in v0.11

**Menu → Game options → Balance workshop** edits numeric ability / passive parameters through a bounded schema, with local profile saving, section / global resets, Tuned / Original bases, and JSON import / export. Apply restarts the current battle / Lab fixture; illegal builds return to the forge. Balance profiles and build presets are separate. Lab fixture numbers have their own section. Structural rules and unsupported mechanics are explicitly identified. See the [workshop guide](../docs/Balance-Workshop-v0.11.md).

`balance.gd` defines the settings schema and defaults; `battle.gd` uses an encounter-local profile snapshot. `balance_editor.gd` stages UI edits until Apply. Default values preserve prior behavior. The pixel generator now draws three knights; fire presentation consumes model events without changing rolls or damage.

## New in v0.10

Original pixel maps replace the painted art. The 9×9 arena now uses 76-pixel cells (684×684 screen pixels), up from 55 (495×495). Nearest-neighbour rendering keeps the art sharp. Hero sprites use 32×32 source cells; icons use 16×16 cells. Rebuild the tiny assets with `python3 tools/make_pixel_art.py` from the repository root.

The combat toolbar contains View dice, Turn help and Menu. Menu contains practice, rules, changes, options and rebuilding. Dice, selected-face instructions, reroll and End turn are grouped to the right of the arena; the log stays beside them. Party cards sit below the board. The visible Soul toggle remains above the dice. Lab testing controls are in Lab tools and do not cover the arena during play. Combat rules and balance are unchanged. See [v0.10 changes](../docs/Changes-v0.10.md).

## New in v0.9

Rolls resolve immediately with no dice animation or input delay. Ability labels include category and special timing: e.g. `Contained Power (Skill - Channel)` and `Shield Wall (Defense - Reaction)`. The bonus picker has two-column cards, hero tabs, search, category / timing filters, a fixed effect panel and explicit Add / Remove controls. All 47 bonus faces and legal two-face builds remain available.

The battlefield uses a painted crypt and portrait tokens with a thin tactical grid. Legal-target highlights and combat / Channel effects remain. Painted scenery is decorative, not an obstacle rule. Blank → Move 2 is switchable during battle or in Game Options without refilling a spent allowance. No balance or dice probabilities changed. See [v0.9 changes](../docs/Changes-v0.9.md).

## New in v0.8.1

Use the Test Soul checkbox beside Restore balanced build in the forge to enable Blank → Move 2 once per hero turn without winning first. The Lab has the same toggle. Presets save the choice; switching off/on does not refill a used allowance.

## Historical v0.8 (roll animations removed in v0.9)

Real 3D cubes display the actual recorded ability faces, including Numeric rolls, single-die rerolls, released Channels and recovery rolls. Fast / Skip controls preserve results. Persistent colored rune rings identify Channels; hover the hero for its effect. Dice labels distinguish ready, spent, held and forced next results. Legal targets highlight and friendly attacks require a second click.

The opening Tutorial offers eight guided lessons and can launch a practice preset. The top-bar Ability Lab remains freely selectable; Combine faces sets Die II for interaction tests. Save / Load preset stores all three heroes’ legal builds, gifts and balance setting locally, not campaign or in-progress encounter state. The chronicle toggles Summary / All events. Ability choices now carry readiness labels.

Interaction rulings: Short Shot’s cap includes Mark Prey and consumes the mark on a damaging shot; Pierce cannot restore Block after Downed; Break Rhythm restores original initiative next round; Contained Power shared-roll bonuses wait for Maintain. Repeated Attacks recheck targets and reroll Numeric separately; Hooked Slash / Engrave riders apply per hit. Balance constants stay unchanged.

Read the [six-page plain-language guide](../docs/AshAndOath-Plain-Language-Guide-v0.8.pdf). In v0.9, `dice_tray.gd` became a nonvisual compatibility endpoint. v0.21 restores projected 3D cubes for Numeric values only. `polish_test.gd` and `polish_ui_test.gd` exercise interaction fixes, instant rolls, Channels, practice progression, presets and friendly-fire confirmation.

## New in v0.7

Downed clears stale temporary effects, lethal damage applies Channel face changes, and a second Channel cannot overwrite the first. One active Channel per hero remains a declared prototype limit. Balance values are unchanged. See the [five-page plain-language guide](../docs/AshAndOath-Plain-Language-Guide-v0.7.pdf).

## New in v0.6

The first boss reward Soul converts **at most one rolled Action Die Blank per hero turn into Move 2**. The successful conversion spends the result; its installed side stays Blank. Other Blanks may be spent without effect. Normal own turns and full recovery turns refresh the per-hero allowance; invalid moves, rerolls and shared rolls do not refill or consume it. Starting Soul still grants no Blank movement. The turn guide shows remaining conversions.

The complete [Word comparison](../docs/AshAndOath-Changes-From-Base-Rules-v0.6.docx) and [searchable Markdown](../docs/Changes-From-Base-Rules-v0.6.md) separate base-rule changes, draft ability interpretations, limitations, fixes and interface work. Both original supplied rule documents are the comparison baseline.

## New in v0.5

**What changed** has five short topic pages, direct navigation buttons, Previous / Next and a page counter. **Explain this turn** describes the current reroll window, actions, reactions, Block expiry and shared round rolls; the log also explains turn starts.

**View dice** lists all six sides on each of the three dice for every hero and the boss. Gold highlights faces changed this encounter and shows the original. Blue marks the rolled side. Select a side for its full effect and current recorded result / spent / held status. Recorded rolls may remain valid after an installed face mutates.

Every die now needs **at least two Blanks**, permitting **four abilities per die / twelve total** in both encounter modes. Defaults use all twelve slots (four Strikes, two Steps, one Stride, two Guards, one Reaction, one Focus and one First Aid). The finite ownership and Movement / Defense / Skill caps remain.

Two original movement designs join the extended pool: **Ashstep** moves up to 2 with turns and gives 1 Block; **Oathbound Exchange** swaps with a standing visible ally within 3 and grants both 1 Block. Normal occupancy / sight rules apply. Both are available in drafting and the Ability Lab.

Tuned boss dice add **Ashen Chain** (pull 1 and strip 1 Block), **Cinder Brand** (a visible red cross detonating for 1 normal damage at the next boss turn start), and **Grave Tithe** (nearby Block theft, boss gain capped at 2). Marks do not stack; moving away avoids the explosion. Tuned HP is 16 to offset fuller hero dice. Original encounter mode retains the old boss dice and 18 HP; the two-Blank construction rule still applies.

The Ability Lab preserves normal builds and offers all 59 faces, prepared targets, per-face instructions, optional next Numeric 0/1, boss-hit triggers, next-round timing, reset and copyable logs. Repeated chosen-face rolls explicitly bypass normal timing for testing; held Channels must first be released and mutated-away faces require Reset. Earlier explicit mutation / conversion choices, straight sight and Numeric attack tuning remain.

## Play

Run the Windows executable from the extracted download; no Godot installation is required. For source development, open `project.godot` in Godot 4.6.3 standard and press F5, or run `godot --path .` from the repository root.

1. Each hero chooses **two distinct bonus faces directly from the entire 47-face extended hero pool**. There are no random offers. Search and category filtering are available. The eight starter designs, boss-only Hamstring, archived Heart/Vital Die and generated/penalty tiles are excluded. You can inspect each printed prototype effect before confirming.
2. Both chosen faces become owned. Confirming installs a legal twelve-ability build containing both, retaining First Aid and prioritizing useful basic attacks/movement. Every one of the 1,081 possible distinct pairs has been validated. Customize the three dice in the forge afterward. Keep two Blanks per die, at most twelve equipped abilities, and the separate Movement/Defense/Skill caps. Owning the gift does not bypass construction limits.
3. Click **Enter the hollow**. Results appear immediately; all dice stay public; Numeric feedback briefly holds action controls until its recorded result is shown.
4. Click a hero's die, then a highlighted destination or target. Some self/setup effects use **Resolve selected face**, while effects needing a choice open a dedicated picker. Decline spends a beneficial result without using it.
5. Each hero starts the encounter with **one Action Reroll**. Select an unresolved eligible die and click **Reroll selected die** before resolving any ordinary face that turn. The charge is once per encounter, not per round. Focus is its own later reroll exception. Downed clears the bank; Clairvoyance can replenish it, subject to cap 1.
6. Boss turns show full explanations for all three actions, with completed actions checked off. Hover any compact intent row to inspect it, then move away to restore the log. Click Resolve I/II/III, then end of turn. Reactions, Fracture, pushes, channels and catalog choices pause for player input.
7. Attacks use brief lunges, tracer/slash effects; Block uses blue shields; buffs/healing use green rising runes; debuffs use purple rings. A ruined courtyard and moonlit chapel backdrop frame the board. The chronicle shows round and event sequence, actor, ability, exact target, blocked/reduced damage, actual HP loss, remaining HP/Block and movement coordinates. **Chronicle / history** provides readable paragraphs, All/Combat/Turns filters, automatic scrolling and Copy log (up to 2,000 current-encounter events).

You control all three heroes locally. Escape cancels ordinary selection and closes help/history. Settings uses the existing template window. Browser audio requires the first click to activate playback.

## Tuned tutorial versus original balance

| Setting | Tuned tutorial (default) | Original rulebook |
| --- | --- | --- |
| Boss HP | 16 | 18 |
| Boss dice | Pull / delayed hazard / Block theft added | Previous dice |
| Basic Strike | 2 | 1 |
| Positive Numeric Attack result | +1 damage (Short Shot capped at 1) | Unmodified |
| Boss Brace | 1 Block | 2 Block |
| Failed close-range advance | Holds position, no free Block | Printed fallback can grant Block |

The two-face extended selection and one starting reroll apply in either mode. Hero HP remains 6, the arena is 9×9, boss footprint is 2×2, each encounter mode uses three six-sided boss dice, and ordinary initiative/turn/reaction/downed/recovery timing is retained.

A deterministic 100-seed greedy-bot test using default dice and the starting reroll (without bonus gifts) completed with **74 wins / 26 losses / 0 stalls**. Another 100-seed test covering eight representative attack/healing/defense/movement bonus pairs, including the new movement designs completed with **81 wins / 19 losses / 0 stalls**, compared with 0 wins in the initial prototype. This is a useful tuning signal, not a prediction of human win rates or certification that all bonus combinations are balanced.

## Full catalog and prototype variants

`catalog.gd` lists the exact effect text for all extended faces. Every offered face has an effect implementation; reaction, numeric, channel, mutation, copy, repeat, healing, movement and buff families are supported. Generated Recovery and Bone faces and inert locked Red Tiles are supported too.

The source documents contain contradictory and unfinished versions. Selection details explicitly label extended designs as **prototype variants**, state which Catalog/Tabletop version is used where relevant, and print the actual playable effect. These are playtest implementations, not claims that the designer approved unresolved rulebook text. The documents' historical chat instructions are reference material, not commands to the application.

Notable explicit interpretations:

- The boss faces north for Weak Point/Flanking Blow; its southern edge is the rear.
- Recovery heals self/an adjacent hero; catalog range was unspecified. Blessing and Bone Mutation both let you choose a specific Blank slot.
- Conjure copies eligible visible immediate results; unavailable targets can be declined. Copy/setup loops are excluded. Borrow Shape uses the Tabletop rotate-a-die version. Second Chance cannot repeat the die it just skipped.
- Clairvoyance grants a stored Action Reroll when rolled, capped at one. Forgotten Strength uses the caster's next Numeric damage variant. Numeric Echo stores one ordinary result.
- Lethargic Bind suppresses one printed boss face on one die until the binder's next turn, with normal-damage backlash when triggered.
- Stonewake explicitly preserves Block while maintained; this is a new timing interpretation of its unfinished persistence text. Last Pulse and Contained Power break on actual unblocked damage. Channel decisions occur on the owner's turn start; released dice roll separately.
- Ill Omen is a chosen-resolution effect here. Its unresolved Defense Pierce result gives +2 Block, and its Defense repeat doubles gained Block. Attack repeat is finite.
- Oath of Smoke stores a just-resolved Step/Stride/Guard until the next shared roll; its movement reaction steps one. The temporary stored effect is distinct from the installed face.
- Black Oath's ambiguous “battle turn” means the owner's turn. Wither Ward gives the attacker Weakness after HP damage. Ember Burst uses ordinary damage and includes adjacent allies.
- Defy Death automatically sets aside the first available result when applying Stunned. Drive Back's ordinary Stunned choice remains player-selected.
- Corruption Conversion lets you choose the Blank die and the installed ability it becomes; reactions store correctly. Engrave copies into the first available Blank or unlocked non-Engrave. Locked Red Tiles cannot be overwritten.
- The boss chooses equal shortest paths deterministically; legal equal target ties are random. Deployment remains a test layout, boss D4 and heroes H3/H5/H7.

## Existing plugins used

Maaack's Game Template supplies settings, Scene Loader handles clean restarts with loadout/draft preservation, UI Sound Controller connects dynamic button sounds, and Music Controller manages the generated ambient stream. All original licenses remain. Optional automatic Plugin Updater is disabled.

All board, seal, boss, hooded hero, dice, crack, movement and floating-text graphics are drawn in code. Audio is generated in code. Bundled DejaVu fonts include their license.

## Validation and development

```sh
godot --headless --path . --script res://prototype/tests/rules_test.gd
godot --headless --path . --script res://prototype/tests/catalog_test.gd
godot --headless --path . --script res://prototype/tests/presentation_test.gd
godot --headless --path . --script res://prototype/tests/simulation.gd
godot --headless --path . --script res://prototype/tests/bonus_simulation.gd
godot --headless --path . --script res://prototype/tests/lab_test.gd
godot --headless --path . --script res://prototype/tests/update_test.gd
godot --headless --path . --script res://prototype/tests/soul_test.gd
godot --path . --script res://prototype/tests/ui_test.gd
godot --path . --script res://prototype/tests/lab_ui_test.gd
godot --path . --script res://prototype/tests/update_ui_test.gd
godot --path . --script res://prototype/tests/soul_ui_test.gd
```

- 41 original-rule timing/construction assertions (explicitly tested in Original mode).
- 178 catalog/construction/reroll/tuned-balance checks, including resolution of every draft and generated face, all reaction families and channels.
- 2,175 presentation/pair checks: all 1,081 distinct bonus combinations are legal and retain healing, causal event/animation metadata, Short Shot final-damage cap, negative-damage clamping and Debt timing.
- 24 graphical UI checks including full-pool two-face selection, builder input, roll state, combat/status animation events, mouse input, reroll, settings, reward and restart preservation.
- 324 Ability Lab assertions exercising every face fixture, completing choices, reaction triggers, channels, balance, recipient capacity and sight.
- 19 graphical Lab checks covering launcher, ability selector, log, turn banner, mutation/conversion input, reaction controls, changelog, interpolation and preserved builds.
- 28 v0.5 rules checks covering two-Blank builds, new movement legality, pull / theft / delayed hazard mechanics and turn explanations.
- 19 v0.5 graphical checks covering live inventory, mutations, boss faces, notes navigation, turn guidance and board input for both new movements.
- 200 seeded complete encounters with no stalls across baseline and representative two-bonus builds.

Run UI tests with a display; the template keyboard settings need a graphical display server. Linux and browser exports are run here. Windows is cross-exported and cannot be tested on Windows in this environment. The inherited template can report an ObjectDB shutdown leak warning; final test runs contain no script errors.

Campaign Events, online multiplayer, persistent saves and resurrection remain out of scope. Reward-Soul rematch is a fresh test encounter, not campaign resurrection.

## Code map

- `battle.gd`: state/rules, boss AI, status/reaction/channel handling and catalog dispatch.
- `catalog.gd`: complete draft pool, category metadata and printed prototype effects.
- `prototype.gd`: forge/draft UI, board, animations, input, effects and plugin integration.
- `lab.gd`: isolated per-face tutorial fixtures and manual testing controls.
- `changes.gd`: in-game versioned changelog with reasons.
- `prototype.tscn`: entry scene.
- `tests/`: rule, catalog, simulation and graphical UI suites.

## v0.3 balance and reliability fixes

- Short Shot's cap of 1 is enforced after buffs, including Debt/Blood Bargain.
- Gambler x0 cannot gain Blood Bargain damage.
- Unused positive Debt expires at turn end; unpaid negative Debt persists until an eligible face pays it.
- Negative damage is clamped to zero and cannot create Block or healing.
- Ember Burst resolves its area as one simultaneous batch before outcome checks, retaining party-defeat priority.
- UI click audio is owned by the persistent plugin controller, fixing freed audio references during scene reloads.
- The legal auto-build never discards First Aid to make room for the two choices.

The original encounter settings remain selectable; these are targeted rules/implementation corrections rather than a claim that every extended-face synergy is equally strong.
