# v0.13 — boss rules and phase upgrades

## Phase one versus phase two

The phase changes **once**, when the boss reaches **half its starting HP or lower**. With the default 12 HP boss, that is 6 HP. The Ability Lab uses 30 HP, so its threshold is 15 HP.

| Ability | Before half HP | At half HP and below |
| --- | --- | --- |
| Cinder Brand | Marks the original five-cell **cross**. | New casts mark a **3×3 square**, including corners. |
| Ashen Chain | Pulls and strips Block. | Also applies **Rooted 1** until the boss’s next turn starts. |
| Furnace Roar | Not on the boss die. | Replaces Brace on Die I. The first Roar replaces the next unresolved boss die. |

A Brand that was already armed keeps its original marked cells until it detonates. Crossing half HP does not silently enlarge an existing warning. Custom Brand radius affects the cross arms in phase one and the square radius in phase two.

**Rooted 1:** prevents voluntary walking, Stride, leaping, Ashstep, Blank movement, Exchange and reaction steps. Attacks and defense still work. Forced movement from pushes or pulls still works. Rooted ends at the next **boss** turn start, not at the hero’s turn. Its value and expiry appear in hero hover text and the active-turn status display. This expiry is the requested prototype rule; the source document’s provisional Rooted expiry was different.

## Targeting and attacks

| Ability | What it does now |
| --- | --- |
| Advance | Chooses a standing hero with the **highest current HP** and moves up to 2 toward that hero. Highest-HP ties are random. If already adjacent to **any** hero tied for highest HP, stays and gains **1 Block**. Arriving adjacent after moving does not also grant this Block. If its chosen hero has no legal route, it stays and gains fallback Block. |
| Distort | Targets a highest-current-HP hero if one is within range. If none of the globally highest-HP heroes is reachable, targets the **closest hero within range**. Ties are random. With no hero in range, uses fallback. |
| Drive Back | Pushes automatically along the direction from the boss to the struck hero. Heroes no longer choose a push direction. A collision still causes the existing unavoidable damage and Stunned. If the geometry gives two equally aligned directions, the game chooses randomly. Choosing a die for Stunned is still a player decision. |
| Smoking Strike | Replaces the boss’s plain Strike name. Default attack damage stays **1**. If it causes actual HP loss, puts **one fire tile** beneath the struck hero. If a Smoking Strike fire tile is already there, consumes it and deals **1 extra normal damage** on that cell instead. A fully blocked or reduced hit neither places nor detonates fire. |

Fire stays on its original cell when the hero moves. Another hero can later occupy and trigger that cell. Stepping onto fire alone does not detonate it. These fire tiles are separate from Cinder Brand’s timed warning cells. The extra damage is normal damage, so Block and Damage Reduction apply; it is not unavoidable damage.

**These targeting rules and Smoking Strike apply in both phases.** Only Brand geometry, Chain’s Rooted effect and the availability of Furnace Roar change at half HP. No additional damage upgrades were added.

## What you can see and test

- The boss shows **current / maximum HP and Block beneath its sprite**, in addition to the existing top display.
- At the phase transition, ember rings and sparks flare, a brief “The Hollow ignites” announcement appears, and the boss changes to a separate burning-crown pixel sprite. The header continues to say Phase II after the animation ends.
- Upgraded Cinder Brand and Ashen Chain intents show a **+**. Their descriptions explain the current phase’s effect.
- Smoking Strike fire stays visibly marked on the grid. Hover a burning cell for its detonation rule.
- **Lab tools → Test boss phase II** reduces the Lab boss to its actual threshold and triggers the real transition. Reset test returns to phase one.
- Balance workshop adds Advance’s adjacency Block, phase-II Rooted value and Smoking Strike fire damage. Existing saved Strike damage / range settings still control Smoking Strike. There are now **201** numeric settings. Saved custom profiles are preserved.

## Checks and balance comparison

Targeted rules checks cover phase-gated cross / square geometry, unchanged armed warnings, Rooted movement restrictions and expiry, forced movement, highest-HP pursuit, Distort’s fallback, automatic pushes in all four directions, collisions, and Smoking Strike placement / detonation / prevention. UI checks cover the real Lab phase transition, animation event, separate sprite, status text and disabled rooted reaction steps.

With the existing simple automated strategy and unchanged 12 HP boss, 100 starter-only encounters produced **17 hero wins / 83 boss wins / no stalls**. The existing bonus-pair builds produced **59 / 41 / no stalls**. The new boss is stronger than v0.12, especially against starter-only builds. These scripts do not plan around persistent fire and are a comparison, not a forecast of human results. No compensating HP or damage changes were made in this update; the workshop remains available for experiments.
