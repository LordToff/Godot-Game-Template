# v0.14 — Blank movement, quick face selection and debuff effects

## Blank movement

Blank movement now uses one numeric counter for its remaining allowance. A second legacy “spent” flag can no longer override a refreshed counter. Normal turns and full recovery turns share the same reset function, and the battle log explicitly records each refresh.

The combat controls explain the difference between:

- **This turn’s allowance used:** it refreshes at the next own turn.
- **This particular die spent:** select another ready die; dice roll again next round.
- **Rooted:** voluntary movement is blocked until the next boss turn; a failed attempt does not spend the Blank or its allowance.
- **Soul OFF or movement set to zero:** enable or configure the Soul before using Blank movement.

Trying to move with Soul OFF no longer silently spends a Blank without moving. You can still deliberately resolve or decline an inert Blank. The default remains one Blank → Move 2 per hero turn; balance settings still control movement distance and uses. Toggling Soul OFF/ON never restores spent uses.

The reported once-per-combat lock did not reproduce in the basic unchanged v0.13 rules test. The updated normal-combat UI was then checked across four complete rounds: all three heroes successfully converted a Blank on every own turn, including a test with a stale legacy flag. No boss balance values were changed.

## Pick and place your two faces

The opening screen shows the full bonus pool on the left and all three live unfolded dice on the right.

1. **Click a card once** to select it and equip it into a legal space automatically.
2. **Drag a card onto a die** to auto-fit it on that die, or **onto a square** to choose its exact position.
3. **Drag an installed square onto another square** to swap the two faces.
4. Choose **Next hero** after two designs. When all three heroes are ready, choose **Start battle** directly.

Your placements are preserved when switching heroes and starting combat. The game still enforces two distinct bonus designs, owned copies, body caps and minimum Blanks.

If you drop a new design onto a required Blank, the game can clear one starter square on that same die to preserve the Blank minimum. It tells you which starter was removed. If the requested placement cannot fit the body caps, it is rejected without changing your choices. Dropping a third design onto one of your two selected bonus faces replaces that design when legal. The Remove button remains available, and search / category / timing filters remain.

## Rooted and Weakness on the sprites

- **Rooted:** pulsing roots wrap around the knight’s legs, with visible shackles and a root badge.
- **Weakness:** purple motes drift around the knight, with a broken-sword badge.
- Both effects remain visible on inactive heroes and can appear together. Each disappears when its actual status ends. Hover text and the active-turn Effects summary still explain the rules.

These visuals use no gameplay random numbers and do not change damage, movement, or status durations.
