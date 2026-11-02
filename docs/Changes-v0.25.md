# Ash & Oath v0.25 — The Ash Road

The first optional event loop sits beside the four existing standalone boss encounters. From boss review, open **Expedition events**. All six numbered slots are visible. Roll one d6, read the selected event’s stakes, then choose. The result cannot be rolled again until it is resolved; **New sortie** deliberately starts another event.

| d6 | Event | Choices and exact rewards |
| --- | --- | --- |
| 1 | Abandoned Supplies | Take 1 Salve **or** 1 Reroll Seal. No cost or risk. |
| 2 | Ash Shrine | Leave safely, or pay 2 Gold now. Roll 3–6: gain 1 Soul Fragment; 1–2: offering lost, no reward. |
| 3 | Stranded Traveller | Take directions for 1 Gold, or spend 1 Salve to earn 3 Gold + 1 Reroll Seal. |
| 4 | Scavenger Ambush | Withdraw safely, or defeat two 3-HP Ash Scavengers for 3 Gold + 1 Salve. |
| 5 | Infested Ruins | Leave safely, or defeat two 4-HP Cinder Mites for 5 Gold + 1 Soul Fragment + 1 Reroll Seal. |
| 6 | Buried Reliquary | Take 1 Gold, or replace it with a search. Roll 4–6: 3 Gold + 1 Soul Fragment; 1–3: lose 1 held Salve and gain nothing. With no Salve, failure grants nothing. |

## Rewards have uses

- Shared expedition **Gold** funds shrine offerings. There is no shop. Gambler’s Coin Gold remains encounter-local.
- A **Salve** heals the active standing hero by up to 2 HP, capped at maximum HP, at most once per own turn. It cannot revive.
- A **Reroll Seal** restores 1 stored Action Reroll if below the existing bank cap. The reroll itself still follows the normal rules.
- Supplies consume no Action Die. Finish pending decisions first. Open **Menu → Expedition supplies** during combat. Supplies are unavailable in Lab and training.
- Spend **3 Soul Fragments** once to unlock the existing optional reward Soul. Its default is one rolled Blank per hero turn as Move 2. There is no free movement and installed Blanks remain Blanks. Select Blank movement on boss review; existing manual rules options and numeric overrides remain.

## Ordinary monsters, without a boss

Both event fights have two separate one-cell ordinary monsters. They share three public Action Dice, resolving each result for both living monsters, with held Reactions interrupting before damage:

- Die I: Scuttle / Scuttle / Bite / Bite / Guard / Bite.
- Die II: Scuttle / Bite / Guard / Bite / Scuttle / Bite.
- Die III: Bite / Guard / Scuttle / Bite / Guard / Scuttle.

Scuttle moves up to 2 orthogonal cells toward enemies without attacking. Bite deals 1 normal damage to the closest adjacent hero or friendly summon, otherwise holds. Guard grants 1 Block until next enemy turn. No Poison on bites, boss phase, boss summons, fire or boss Soul. Hero summons and inflicted Poison still work. **Both monsters must die** to earn the listed reward; party defeat or abandoning grants none.

## Claims, saving and scope

The local ledger records event selection, exact grants, deductions and completion state. A repeated click, redraw or reload cannot claim the same event reward again. Interrupted monster encounters give no completion reward; spent supplies stay spent. Combat is not checkpointed. Boss and event fights start fresh: event injuries and temporary mutations do not carry into the next fight. Only earned inventory persists.

Storage belongs to the current browser/device, not a cloud account. Clearing browser data removes it. Explicit new sorties may earn more rewards; no daily restriction or full campaign economy is implied. Rewards and difficulty are provisional.

All four bosses, face ownership/caps, Blank progression, friendly Summon/Command Nu’gh, soundtrack and hover descriptions remain. The Windows download is unchanged. The consolidated current Markdown, HTML and PDF include the event table, odds, exact quantities, monster dice and persistence limits.

## Validation

- Event rules: **355 checks passed**, covering costs, both risk outcomes, exact grants, duplicate claims, save/reload, interrupted fights, supply limits, two-monster victory, Reactions and tooltips.
- Event UI fixture: **24 checks passed**, including entry from boss review, six visible slots, locked roll, unaffordable choices, actual outcome grants and selected-boss preservation.
- **24 existing core regression scripts passed**: rules, catalog, presentation/pairs, lab, update, Soul, balance, boss v13, loadout, bug fixes v15, presets, encounters v18/v19, Cantor, brood, Numeric, summons, worm routing, status sweep, Warden, reliability, polish, playtest v12 and trial regressions.
- One older rendered interaction fixture was attempted headlessly and timed out waiting for `frame_post_draw`; it is not counted as passed. Other historical rendered fixtures were not rerun. The native UI fixture reports inherited shutdown resource-leak warnings, with no script errors.

The exact published browser package is validated separately in Chromium/WebGL; the browser evidence and deployment result are recorded in `Validation-v0.25.md`.
