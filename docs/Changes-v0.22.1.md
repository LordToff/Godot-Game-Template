# v0.22.1 — Friendly Nu’gh movement fix

A friendly worm could activate after its summoner’s turn without moving. Its movement search considered only destinations within its two-step allowance and preferred staying still whenever every short detour was initially farther from an enemy. A line of heroes between the worm and boss could trap it this way indefinitely, despite an open route around them.

Friendly worms now plan the complete shortest legal route to an enemy-adjacent tile, then move only the first two orthogonal steps. They can take a detour that initially increases their distance. Command and automatic owner-end activations share this fix. They still stop adjacent and bite after movement; Rooted, occupancy, movement allowance and genuinely blocked routes remain enforced. A truly blocked worm explains the lack of a legal route in the chronicle.

The exact three-hero-line reproduction now moves from F5 to F7 after the summoner’s turn, then reaches D7 and bites on its next activation. Other heroes’ turns do not activate the worm. Existing enemy Nu’gh worms and Bu’gh mites keep their prior movement behavior; no balance values or declared rules changed.

Validation: 75 new movement checks, 5 rendered input/animation checks, the 298-check summon suite, Nu’gh’s 2,414-check brood regression and the 28-check encounter/summon UI suite pass. Browser verification uses the actual export and clicks End hero turn to confirm both the changed model tile and visible worm movement. The v0.22 trial report remains historical; its results are not new hotfix balance estimates. Bu’gh remains provisional.

The existing v0.22 rulebook still describes the intended Move 2 behavior. The older Windows download is unchanged.
