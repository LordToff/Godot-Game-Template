# Balance Workshop additions · v0.22

The **59 · Summon Nu’gh** group exposes friendly HP, movement, bite range, damage, successful Numeric sides (out of six), and Poison. One living worm per owner is a structural limit shared by all copies.

The **Boss · Bu’gh** group exposes boss HP; enemy brood cap; initial cocoon count; cocoon base HP and phase-II HP bonus; hatch age; mite HP, movement and phase bonus; mite successful Numeric sides, damage, reach, Weakness, phase-II Rooted and newborn Block; Shell Block and phase bonus; Mandate reach, Weakness and phase-II Rooted; Feast healing, base Block and phase bonus; Crash movement and reach with phase bonuses, phase-I damage and absolute phase-II area damage; cocoon-break Block reward, boss Block removal and Weakness; cocoon placement count/radius and fallback movement.

Phase bonuses add to the base value. **Crash damage phase is the absolute phase-II damage, not an addition.** Defaults are the provisional values recorded in [v0.22 changes](CHANGES_v0.22.md). The existing shared boss HP-percent setting controls the irreversible phase threshold. Editing settings affects the next encounter; it does not certify the resulting balance.


---

# Balance Workshop additions · v0.22

The **59 · Summon Nu’gh** group exposes friendly HP, movement, bite range, damage, successful Numeric sides (out of six), and Poison. One living worm per owner is a structural limit shared by all copies.

The **Boss · Bu’gh** group exposes boss HP; enemy brood cap; initial cocoon count; cocoon base HP and phase-II HP bonus; hatch age; mite HP, movement and phase bonus; mite successful Numeric sides, damage, reach, Weakness, phase-II Rooted and newborn Block; Shell Block and phase bonus; Mandate reach, Weakness and phase-II Rooted; Feast healing, base Block and phase bonus; Crash movement and reach with phase bonuses, phase-I damage and absolute phase-II area damage; cocoon-break Block reward, boss Block removal and Weakness; cocoon placement count/radius and fallback movement.

Phase bonuses add to the base value. **Crash damage phase is the absolute phase-II damage, not an addition.** Defaults are the provisional values recorded in [v0.22 changes](CHANGES_v0.22.md). The existing shared boss HP-percent setting controls the irreversible phase threshold. Editing settings affects the next encounter; it does not certify the resulting balance.


---

> v0.21: Nu’gh → Worm Numeric successful sides (2 of 6 by default), bite damage and Poison value are editable. Poison refreshes, never stacks, and ticks once at the next own turn. [Changes](CHANGES_v0.21.md).

> v0.20: Boss · Brass Cantor edits Resonance, abilities, core bonuses and phase upgrades. Starter Reaction grants 2 Block; the old movement field is retained as unused for saved-profile compatibility. [Changes](CHANGES_v0.20.md).

> v0.19: new command movement / bite / empty-brood summon values, retreat and Hollow fire damage are editable. Soul Link’s phase cutoff is structural. Legacy Chorus fields are marked unused. [Changes](CHANGES_v0.19.md).

> v0.18: choose boss and rules on the pre-fight review screen. Advanced numeric rules includes Nu’gh’s brood, Soul Link and every Hollow phase bonus. [Changes and reasons](CHANGES_v0.18.md).

> v0.17: short combat descriptions use active custom values. Open More rules / custom values for the complete reference. Focus respects non-rerollable faces; reroll charges and the opening window are shown separately. [Combat clarity guide](CHANGES_v0.17.md).

> v0.16: Fracture count 0 now removes no face. [Trial results and fixes](CHANGES_v0.16.md). Default numeric values are retained.

> Updated for v0.15: invalid JSON is rejected without applying it. Higher-value Numeric sides are capped by the positive-side count; zero positive sides uses the Blank value on all six sides. [See the bug-fix notes](CHANGES_v0.15.md). Saved overrides remain in force.

# Balance Workshop · v0.21

Open **Menu → Game options → Balance workshop**. From the opening screens, use **Game options / Options → Balance workshop**.

1. Search an ability, a number such as damage, or a section such as Soul, Numeric die, body or boss.
2. Change the whole-number fields. The right column shows defaults for the selected Tuned / Original base.
3. Choose **Apply & restart fight / test**. In the forge, choose **Save balance profile** instead. Applying saves locally and restarts the active fight or prepared Lab test. If new body limits make a loadout illegal, you return to the forge to fix it.
4. **Reset this section** removes that section’s overrides. **Reset all values** clears the profile overrides. Apply to use the reset values.
5. **Import / export JSON** lets you copy or paste a profile. Imports remain a draft until Apply; Cancel keeps the current rules. Profiles include the selected base preset.

**Blank movement:** select **Soul · Blank movement**. Change **Movement per converted Blank** and **Blank conversions per hero turn**. The ON/OFF switch still enables or disables this Soul. Changing values restarts the fight; toggling the Soul alone never refreshes used conversions.

**Lab setup:** Lab fixtures have their own starting HP and Block section. The Lab normally uses a 30 HP boss and injured 3 HP heroes so abilities can be tested repeatedly; encounter maximum HP and Lab fixture starting HP are separate settings. Fixture hero HP is capped by the hero maximum. Defy Death / Echo of Pain fixtures also have their own setup values.

**What is covered:** 201 numeric fields for implemented effects and passives, including HP, resource banks, inventory / body limits, movement, attack and healing ranges, damage, Numeric dice and per-ability scaling, Block, reactions, Channels, repeat counts, growth thresholds and boss actions. Shared Numeric settings affect every Numeric ability; individual Numeric abilities also have a multiplier and flat bonus.

**Limits:** values are bounded whole numbers. Structural rules (9×9 board, six-sided dice, one-die copy choices, trigger / expiry rules and one active Channel) are fixed. Cleave’s secondary-enemy value is shown as inactive because this encounter has one boss. Build presets and balance profiles are separate. Custom help lists active values above the historical default-number rules reference.

The initial profile uses the current Tuned / Original defaults. The heroes are now knight sprites, and fire visuals accompany Cinder Brand arming / detonation and Ember Burst.
