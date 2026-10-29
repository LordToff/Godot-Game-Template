# v0.18 — room to play, a new boss, and encounter review

## What changed and why

| Change | What you will see | Why |
|---|---|---|
| Combat layout | Party cards and boss intents fill the header; actions and history have separate columns. The arena keeps its size. | Use the empty top space and reduce crowding. |
| Stunned effect | Gold stars orbit any Stunned hero, including inactive heroes. | Make the status visible on the battlefield. |
| Pre-fight review | After all bonus faces are picked, choose boss, balance preset and Blank movement OFF / Move 1 / Move 2, then press Start. | Confirm rules before rolling or fighting. |
| Nu’gh | A second boss with original pixel sprites and screaming worms. | Teach target priority rather than only attacking the boss. |
| Half-HP upgrades | Every action of both bosses has an upgrade; the phase guide lists each one. | Make the second phase change the full encounter. |

## Nu’gh: how the encounter works

Nu’gh starts with **10 HP and two worms**. Each worm has **1 HP**. Living worms add up to **+1 damage** to his attacks, increasing to **+2 at half HP**. They occupy cells and block sight, but do not take separate attack turns. Up to four worms can live at once.

Killing a worm deals **1 unavoidable Soul Link damage to Nu’gh**, as well as lowering pressure. Nu’gh consuming a worm does not trigger Soul Link. Kill Nu’gh to win; his remaining worms disappear. All these values can be edited in Advanced numeric rules.

| Ability | Before half HP | Upgrade at half HP |
|---|---|---|
| Birth Cry | Summon one worm. | Summon two. |
| Screaming Chorus | Closest hero within four: 1 damage + worm pressure. An empowered attack spends one worm while keeping its declared bonus. | Worm bonus cap rises from 1 to 2. |
| Gnashing Maw | Adjacent hero: 1 damage + worm pressure. | Reach increases to two; uses stronger pressure. |
| Burrow | Move two toward the nearest hero; gain 1 Block if unable to move. | Also summon one worm near the old position. |
| Brood Guard | Gain 1 Block, plus 1 if any worms live. | Also give one worm 1 non-stacking Block. |
| Devour Brood | Consume the nearest worm and heal 1; summon one if none remain. | Heal 2 and gain 1 Block when consuming. |

An early test version made clearing worms too costly. Soul Link, 10 boss HP, Chorus consuming its own ammunition, and removing healing from Brood Guard give clearing the brood a useful payoff. These are prototype balance choices, not rules from the supplied documents.

## The Hollow: additional half-HP upgrades

Advance gains +1 movement and adjacent Block. Smoking Strike gains +1 fire detonation damage. Brace gains +1 Block where it remains on a die. Skirmish gains +1 movement. Sweep gains +1 reach. Drive Back pushes one extra cell. Distort adds one more Weakness. Fracture gains +1 reach. Tithe strips one more Block and raises its gain cap by one. Furnace Roar gains +1 reach when unlocked. Cinder Brand still expands from a cross to a 3×3 square, and Ashen Chain still adds Rooted. Already armed Brands keep their original marked cells.

## Other corrections

- Cleave now splashes onto one other enemy adjacent to its target, making the secondary hit useful against worms.
- Enemy worms cannot receive hero healing; corpses free their cells and no longer block sight.
- Worm shields show Block on the sprite and in inspection. Logs state blocked damage, HP loss and deaths.
- Retry preserves the boss, custom values and the reviewed Blank movement setting.
- The reaction window shows incoming damage and gives descriptions and buttons separate space.
- Sound and heavy impact effects can be controlled separately.

## Automated checks and their limits

Thirty seeds were tested across six legal team configurations and three Blank-movement settings: **540 battles per cohort**.

| Opponent / bot approach | Hero wins | Boss wins | Stalls |
|---|---:|---:|---:|
| The Hollow | 325 | 215 | 0 |
| Nu’gh, prioritize reachable worms | 266 | 274 | 0 |
| Nu’gh, ignore worms | 100 | 440 | 0 |

These are scripted-bot results, not predicted human win rates. Builds and movement settings are combined in this table; the comparison does not isolate individual abilities. Decisions also change later random draws. The worm-priority advantage supports Nu’gh’s intended lesson. The older downloadable spreadsheet remains a historical **v0.16** report.
