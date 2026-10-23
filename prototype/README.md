# Ash & Oath v0.5 — playable prototype

A local tactical dice-building boss battler built from the supplied Master Rules v10 and Action Faces. This update responds to playtesting: clearer boss effects, dice animations, restrained graphic improvements, one starting reroll per hero, a full-catalog starter draft, and a tuned tutorial. The original balance remains selectable.

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
3. Click **Enter the hollow**. Dice tumble briefly; controls unlock when the animation finishes. All results remain public.
4. Click a hero's die, then a highlighted destination or target. Some self/setup effects use **Resolve selected face**, while effects needing a choice open a dedicated picker. Decline spends a beneficial result without using it.
5. Each hero starts the encounter with **one Action Reroll**. Select an unresolved eligible die and click **Reroll selected die** before resolving any ordinary face that turn. The charge is once per encounter, not per round. Focus is its own later reroll exception. Downed clears the bank; Clairvoyance can replenish it, subject to cap 1.
6. Boss turns show full explanations for all three actions, with completed actions checked off. On hero turns click any compact intent row to inspect it. Click Resolve I/II/III, then end of turn. Reactions, Fracture, pushes, channels and catalog choices pause for player input.
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
godot --path . --script res://prototype/tests/ui_test.gd
godot --path . --script res://prototype/tests/lab_ui_test.gd
godot --path . --script res://prototype/tests/update_ui_test.gd
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
