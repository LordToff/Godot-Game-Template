> Updated for v0.13: adds Advance adjacency Block, phase-II Chain Rooted and Smoking Strike fire damage. [See current boss rules](CHANGES_v0.13.md). Saved overrides remain in force.

# Balance Workshop · v0.13

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
