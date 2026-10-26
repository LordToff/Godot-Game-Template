# 1. What changed — the short version

**What this document is** — A plain-language guide to the current v0.7 prototype, compared with your Master Rules v10 and Action Faces. It explains the changes that affect play. Draft ability choices are still provisional.

**Fewer empty rolls** — Before: at least 3 Blank sides per die. Now: at least 2. Each hero can equip up to 12 abilities instead of 9. Ownership and category limits still apply.

**Two extra abilities per hero** — Before: starter faces only. Now: choose any 2 different abilities from the 47-face extended pool. They must fit a legal build; they are not extra dice.

**One starting reroll** — Before: a reroll bank had capacity but no free charge. Now: each hero starts a fight with 1 Action Reroll. It does not refill each round. Use it before resolving ordinary actions.

**Stronger attacks in Tuned mode** — Basic Strike deals 2 instead of 1. A positive Numeric Attack gains +1 damage; zero gets no extra bonus. Short Shot still cannot exceed 1 damage. Healing and Block get no extra Numeric bonus.

**Different boss balance** — Tuned boss: 16 HP, Brace gives 1 Block, and an idle close-range Advance gives no free Block. Written baseline: 18 HP and Brace 2. New boss actions are on page 2.

**What “Original” actually means** — Original mode restores the old boss dice, HP, Strike and Brace balance. It still uses the later two-Blank rule, bonus choices and prototype ability interpretations. It is not a complete reproduction of every written rule.

**What stayed the same** — Three heroes, 6 HP each, three mixed six-sided dice each, a 9×9 board and one 2×2 boss. Initiative stays fixed. Everyone rolls at the round boundary; each unit then takes its whole turn.

# 2. New tools for positioning

**Ashstep — new hero ability** — Move up to 2 orthogonal spaces, turning if needed, then gain 1 Block. You cannot pass through occupied cells.

**Oathbound Exchange — new hero ability** — Swap places with a standing ally within 3 and clear sight. Both gain 1 Block. Cannot swap with the boss, a dead hero or a Downed hero.

**First boss reward Soul** — Spend at most ONE rolled Blank per hero turn as Move 2. Its installed side stays Blank. Other Blanks may be spent without effect. The starting Soul still grants no Blank movement.

**When that allowance returns** — It resets at the hero’s next normal turn or full recovery turn. Each hero has their own allowance. Failed moves do not consume it; rerolling does not refill it.

**Ashen Chain — new boss action** — Pull the nearest standing hero within 3 one legal cell closer and remove 1 Block. No HP damage. An occupied destination stops the pull.

**Cinder Brand — new boss action** — Mark a red cross under a nearby hero. At the START of the next boss turn, each hero still on a marked square takes 1 normal damage. Moving away avoids it; Block can absorb it. Marks cannot stack.

**Grave Tithe — new boss action** — Remove 1 Block from each standing hero within 2. Give the boss the stolen amount, capped at 2. No HP damage.

**Why these were added** — Movement should offer useful choices: escape a warning, rescue an ally, or protect the front line. The boss should pressure positioning instead of only repeating attacks.

**Facing and routes** — The prototype fixes boss facing north; its southern edge counts as the rear. Boss routes are automated rather than chosen by players. These resolve gaps in the written setup, not a full facing system.

# 3. Which Skill versions did I choose?

**How to read this page** — Your Action Faces file contains conflicting or incomplete versions. These are the playable choices, not a claim that every draft is finished.

**Copying and changing dice** — Conjure copies a permitted visible immediate result; illegal-copy backlash is missing. Borrow Shape rotates your own other die rather than borrowing an ally tile. Second Chance skips one die and repeats a different spent immediate result. Conversion changes a rolled Blank to a chosen installed result and leaves a fight-long Red Tile.

**Healing and tile placement** — Blessing injects Recovery, not cleansing: choose its exact Blank slot; two placements then it blanks. Recovery heals self or an adjacent hero. Restore heals another visible hero within 3, minimum 1 except absolute Gambler zero. Passing Grace heals/passes to the same ally, uses its first Blank, and refuses a full recipient.

**Numeric setup** — Forgotten Strength buffs only the caster’s next Numeric damage, not the party. Numeric Echo stores one ordinary 0/1 instead of granting roll-twice advantage. Focus Numeric changes the next ordinary Numeric Blank to 1. Clairvoyance replenishes the Action Reroll bank; it does not place reroll tiles on boss dice.

**Marks and finishing** — Weak Point is a personal rear-attack repeat, not a shared boss mark. Mark Prey affects the boss until round end. Last Word hits the boss for 1 unavoidable damage after the other non-Blank results. Mark Prey / Last Word do not fully enforce the source sight wording.

**Risk and costs** — Gambler uses a fixed software x0/x2 approximation, not selectable physical overlays; repeat use grants Gold with no shop. Spiral samples an installed Attack and hits random legal units twice, including allies. Blood Bargain offers only the next-two-attacks +1 option, not the all-Block bypass option. Debt’s unpaid penalty persists.

**Timing choices** — Lethargic Bind and Ill Omen are chosen during resolution rather than automatically when rolled. Ill Omen converts Defense Pierce into +2 Block and Defense Echo into doubled Block. Target Override redirects implemented boss Attacks, not every enemy ability.

**Channels and generated faces** — Contained Power supplies future-roll bonuses and breaks into Red Tile on HP damage. Stonewake explicitly preserves Block while maintained, cap 8. Oath of Smoke stores only Step / Stride / Guard until the next shared roll. Bone Mutation installs a chosen Bone, classified Skill, with optional movement.

# 4. Attack and Defense choices

**Numeric attacks** — Strike Numeric is an adjacent-unit attack. Short Shot uses the capped Catalog version and range 2. Piercing Thrust bypasses 1 Block without destroying it. These can target units, including allies, rather than always being enemy-only.

**Attack riders** — Hooked Slash grants Block after at least 2 actual HP damage; it uses ordinary next-turn Block expiry, not its special Catalog round-end expiry. Flanking Blow uses the fixed southern rear edge. Engrave fills the first Blank, otherwise an unlocked non-Engrave, on its own die.

**Incomplete attack effects** — Cleave has no secondary enemy in this encounter. Break Rhythm only delays a still-upcoming boss slot and changes the order array; it is not a complete temporary initiative-delay system. Weak Point / Ill Omen repeats reuse computed damage rather than rerolling all Numeric values and costs.

**Block and protection** — Guard Numeric rolls for Block. Hero Brace gives 3 at zero Block, otherwise 1. Shield Wall gives both heroes 1 Block before a boss Attack. Bulwark gives DR1 and Attack-only Weakness1 until the next own turn.

**Redirecting and surviving** — Taunt requires adjacency and cannot redirect Sweep. Defy Death prevents lethal Attack damage, sets HP to 1, blanks itself and sets aside the first available die for Stunned. It does not prevent arbitrary non-Attack damage.

**Pain and healing** — Echo of Pain reacts to a boss Attack using actual HP lost this round, capped at 3; unused cost occurs next own turn. Last Pulse heals 1 when maintained and breaks / blanks on HP damage.

**Ambiguous costs and damage** — Black Oath uses the owner’s turn end for its cost, through the unavoidable-damage path. Wither Ward gives an adjacent damaging boss Weakness until its turn ends. Ember Burst uses normal blockable damage, including friendly fire, instead of undefined white damage.

**Leap and penalty tiles** — Leap of Echoes uses the two-space leap version with a next-Numeric-damage bonus; no projection or return teleport. Red Tiles are inert, locked and non-Blank for the fight. Permanent corruption / cleansing is not a campaign system yet.

**Important limit** — Only one active Channel per hero is currently supported. A second Channel now stays unresolved instead of silently replacing the first. Its result may be declined. Full multiple-Channel support still needs work.

# 5. Is it ready to playtest?

**Yes — for one local encounter** — You can build all three heroes, fight the boss, use reactions / recovery, win or lose, inspect dice, and restart. One person controls all three heroes. This is a limited playable prototype, not a complete campaign game.

**Fixed in v0.7** — Downed heroes now lose stale temporary buffs, wards, stored modifiers and Debt before revival. A lethal hit correctly changes Contained Power to Red Tile and Last Pulse to Blank. A second Channel cannot silently erase the first.

**Earlier reliability fixes** — Short Shot stays capped after buffs; Gambler x0 stays zero; negative damage cannot create healing; area damage checks outcomes as a batch. Mutation choices are explicit, straight sight respects blockers, and the reward Soul is limited to one conversion per hero turn.

**Still unfinished** — Campaign Events, persistent saves / inventory, layer acquisition, a shop, network play, extra enemies, a fourth die and resurrection. The full keyword system is missing, including Poison, Burn, Slow, Fear, Doom and general Crit/Echo. Numerical, Boss and Mega reroll banks are not implemented.

**Other limits to remember** — Queued recovery turns use fixed arrival order rather than a player-selected order. Copy / repeat chains and automatic triggers cover selected face versions, not every rulebook combination. No dynamic boss turning or full direct-HP-loss event system.

**How to check a questionable ability** — Open Tutorial / Ability Lab. Select the face, read its instructions, then test it against the prepared targets. Force Numeric 0 or 1 if useful. Use View dice to see mutations. Copy the test log and tell me the face, the target, what you expected and what happened.

**What to test next** — Play a starter-only fight, then a fight with two chosen bonus faces. Check whether turns are understandable, movement matters, warnings can be avoided, and recovery makes sense. Please report confusing decisions as well as crashes.

**About balance evidence** — Earlier 1,000 starter-only bot fights gave 694 player wins. That is a tuning signal, not a human win-rate prediction. No balance values were changed for this reliability update; new regression and encounter checks are recorded with the source.

**Where the old long document fits** — The v0.6 16-page comparison remains a technical reference. This guide replaces it as the readable overview. The v0.7 fixes above supersede its older notes about lethal Channel aftermath and silent Channel replacement.
