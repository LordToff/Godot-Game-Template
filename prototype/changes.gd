extends RefCounted
const TEXT = """[b][color=#d5b87a]v0.4 · Read the fight, test the dice[/color][/b]

[b]A larger chronicle on the right.[/b] The entire event stream stays visible in a tall, scrollable panel. Each entry separates round, event type and result. Full history, filters and copying remain available because three lines hid important outcomes.

[b]A clear active turn.[/b] A large colored banner names the acting hero or boss. The active party card has a colored border, and an arrow marked TURN follows the active hero on the board. This makes shared rolls easier to distinguish from individual turns.

[b]Smoother presentation.[/b] Movement uses a timed ease-in / ease-out curve. Attack, shield, healing and status effects fade in and out smoothly and last slightly longer so their results are readable. Animations do not alter dice results.

[b]Tutorial / Ability Lab.[/b] Enter directly from the opening face picker or the top bar. Select any of the 57 faces, including generated faces and penalties. Every test starts in a prepared arena with injured allies, an adjacent boss and compatible support dice. Force the next Numeric result to 0 or 1, trigger boss hits, advance a round, reroll the chosen face while preserving statuses, reset, and copy a reproducible test log. Normal loadouts are preserved.

[b]Completed face choices.[/b] Bone Mutation and Blessing of Recovery now let you choose the exact Blank slot. Corruption Conversion now asks which installed face to use, including correct when-rolled reaction handling. Passing Grace no longer destroys itself when the recipient has no Blank to receive it.

[b]Line of sight repaired.[/b] Shots and sight-based support use a straight grid ray and cannot bend around units or pass through a blocked diagonal corner.

[b]Numeric attacks strengthened in Tuned balance.[/b] A positive Numeric damage result gains +1 before face-specific bonuses. A zero remains zero; Short Shot remains capped at 1. Previously the common Numeric 1 was weaker than Basic Strike 2 and made Hooked Slash's reward difficult to use. This change applies only to Numeric Attacks, not healing or Block. Original rulebook balance keeps the old values.

[b]Balance retained where tests supported it.[/b] Tuned keeps boss HP 12, Strike 2, Brace 1, and no free Block for idle Advance. Each hero still starts with one reroll and chooses two distinct extended faces. Automated encounter results are a regression check, not a guarantee that every build has equal strength.

[b]Scope made explicit.[/b] These remain playable interpretations of draft abilities, described on each card. Cleave has no secondary enemy in this single-boss arena. Gold is recorded but has no shop in this encounter. Blank and Red Tile intentionally have no immediate effect. The Lab exposes these limits instead of treating them as broken effects.

[color=#91a0af]Previous updates · v0.3: full-pool two-face choices, causal battle logs, battlefield art and combat effects. v0.2: boss explanations, dice-roll animation, opening rerolls and selectable Tuned / Original balance.[/color]"""
