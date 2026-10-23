# Ash & Oath — playable prototype

A local tactical dice-building boss battler based on **Dice Building Boss Battler Master Rules v10 (22 October 2026)** and **Action Faces (21 October 2026)**. The documents are design references; their historical chat instructions are not application instructions.

## Play

Open the repository's `project.godot` in **Godot 4.6.3 standard** and press **F6** on `prototype/prototype.tscn`, or **F5** to run the project. From a terminal:

```sh
godot --path /workspace/Godot-Game-Template
```

Choose a hero in the forge and use the 18 face dropdowns to customize their three dice. Defaults are legal and include most starter abilities. Shove can be equipped from the owned pool. The forge checks ownership, three Blanks per die, and separate Body category caps; invalid builds cannot enter combat.

Click **Enter the hollow**. On a hero turn, click an available die and then a highlighted destination or a unit. Guard and inert Blank have an explicit Resolve button. Focus selects another unresolved die and requires its fresh result to be resolved next. Decline spends a result without its effect. End hero turn forfeits remaining actions.

On the boss turn, click **Resolve I / II / III**, then **Resolve end of turn**. Reaction prompts appear before attacks. Fracture asks which installed face to lose. Drive Back asks the push direction; a blocked direction can deliberately cause collision. Shove offers directional buttons beside the arena. Escape cancels selection. Rules are available inside the game.

## What is implemented

- Three heroes at 6 HP, 3 customizable mixed d6 each, finite 13-copy starter pools, legal pre-combat builds.
- Open 9×9 board, rigid 2×2 boss at 18 HP, orthogonal movement and footprint distance.
- All eight starter face designs, all eight boss actions and the exact three boss dice distributions.
- Fixed d6 initiative, shared round rolls, public results for every hero and boss, hero result ordering, boss I–III ordering.
- Block consumption and own-turn expiry, Weakness, Focus's reroll exception and immediate fresh-result resolution.
- Tactical Defense storage, expiry, optional movement, target rechecks and fallback.
- Fracture's encounter-only face replacement, supporting Reaction removal, preservation of earlier recorded results.
- Downed protection through the current full turn, post-protection death, Broken, First Aid recovery turns and initiative-slot replacement.
- Drive Back collision and Stunned selection; pre-existing Stunned chooses its excluded die before the shared roll.
- Immediate victory/party defeat, clean restarts, per-hero reward Soul and optional reward-Soul rematch with Blank-as-Move-2.
- Procedural board illustration, animated tokens, generated ambient drone and click sound, chronicle, tooltips and in-game rules.

## Existing plugins used

Maaack's **Game Template** supplies the settings window, its **Scene Loader** handles clean encounter reloads, the **UI Sound Controller** connects dynamic button sounds, and the **Music Controller** plays/fades the generated ambient stream. The original plugins and licenses remain in `addons/`. The optional editor Plugin Updater is disabled to avoid automatic network checks and accidental updates.

## Explicit prototype choices and limits

- One person controls all three heroes locally; this is a digital playtest adaptation of the three-player table game. No online multiplayer.
- Deployment is a provisional test choice: boss origin D4 (zero-based 3,3), heroes H3/H5/H7. Hero labels and the boss display name “The Hollow” are presentation choices.
- Equal hero initiative uses Vesper, Rook, Wren; the boss wins ties. Equally correct boss targets are random. Equal shortest movement routes are chosen by a deterministic north/east/south/west BFS rather than an extra player route-selection screen.
- Advance with no closer legal movement uses the encounter fallback (+1 Block if no closer step). Skirmish retains completed movement and never adds fallback for a failed attack.
- The first encounter has no Memory passive or starting reroll charges, and starting Blanks are inert. Numeric is not rolled because no equipped starter effect is marked Numeric.
- Channel, campaign Events, ongoing statuses absent from starter content, extended unfinished face catalog, permanent acquisition, and resurrection are not simulated.
- Reward-Soul rematch is an explicit new test encounter with a freshly restored three-hero party, not campaign resurrection. No campaign persistence or save/load yet.
- The written encounter is punishing: the simple greedy test bot lost all 100 seeded attempts. That is a balance observation about this bot/build, not proof that human play cannot win. Boss HP and the written face distributions have not been reduced.
- The inherited template can report an ObjectDB leak warning when quitting; no runtime script errors occurred in final tests. Windows was cross-exported, not run on Windows.

## Validation

Run from the repository root:

```sh
godot --headless --path . --script res://prototype/tests/rules_test.gd
godot --headless --path . --script res://prototype/tests/simulation.gd
godot --path . --script res://prototype/tests/ui_test.gd
```

The rule suite covers 41 construction/combat/timing assertions. The UI suite has 12 checks including builder changes, board mouse input, Reaction/Fracture UI, template settings and Scene Loader restart. Run UI tests with a display: the template's keyboard settings require a graphical display server. The 100-encounter seeded simulation checks full-loop completion without stalls; it is not a balance certification.

Browser export uses the single-thread Web template and works without cross-origin isolation. Serve its folder over HTTP, rather than opening `index.html` as a local file. Browser audio starts after the first user interaction.

## Files

- `battle.gd`: pure rules/state model, independent of drawing.
- `prototype.gd`: forge, combat controls, procedural graphics and plugin integration.
- `prototype.tscn`: entry scene.
- `tests/`: rule assertions, simulation and UI checks.
- `assets/`: bundled DejaVu fonts and their license. All board/token graphics and audio are generated in code.
