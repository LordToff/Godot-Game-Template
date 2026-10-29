extends RefCounted
# Every numeric balance field has a bounded, named schema entry. Structural die/party sizes stay fixed.
const DEFINITIONS = [
 {
  "key": "hero.hp",
  "group": "General & passives",
  "label": "Maximum hero HP",
  "default": 6,
  "min": 1,
  "max": 999
 },
 {
  "key": "hero.rerolls",
  "group": "General & passives",
  "label": "Starting Action Rerolls (capped by bank)",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "hero.reroll_cap",
  "group": "General & passives",
  "label": "Action Reroll bank cap",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "hero.reroll_cost",
  "group": "General & passives",
  "label": "Action Reroll cost",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "initiative.min",
  "group": "General & passives",
  "label": "Initiative roll minimum",
  "default": 1,
  "min": 1,
  "max": 99
 },
 {
  "key": "initiative.max",
  "group": "General & passives",
  "label": "Initiative roll maximum",
  "default": 6,
  "min": 1,
  "max": 99
 },
 {
  "key": "body.blanks",
  "group": "Body & owned tiles",
  "label": "Minimum Blanks per die",
  "default": 2,
  "min": 0,
  "max": 6
 },
 {
  "key": "body.Movement",
  "group": "Body & owned tiles",
  "label": "Movement face cap per hero",
  "default": 3,
  "min": 0,
  "max": 18
 },
 {
  "key": "body.Defense",
  "group": "Body & owned tiles",
  "label": "Defense face cap per hero",
  "default": 3,
  "min": 0,
  "max": 18
 },
 {
  "key": "body.Skill",
  "group": "Body & owned tiles",
  "label": "Skill face cap per hero",
  "default": 3,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.1",
  "group": "Body & owned tiles",
  "label": "Owned starter copies: Strike",
  "default": 4,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.2",
  "group": "Body & owned tiles",
  "label": "Owned starter copies: Step",
  "default": 2,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.3",
  "group": "Body & owned tiles",
  "label": "Owned starter copies: Stride",
  "default": 1,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.4",
  "group": "Body & owned tiles",
  "label": "Owned starter copies: Guard",
  "default": 2,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.5",
  "group": "Body & owned tiles",
  "label": "Owned starter copies: Reaction",
  "default": 1,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.6",
  "group": "Body & owned tiles",
  "label": "Owned starter copies: Focus",
  "default": 1,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.7",
  "group": "Body & owned tiles",
  "label": "Owned starter copies: First Aid",
  "default": 1,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.8",
  "group": "Body & owned tiles",
  "label": "Owned starter copies: Shove",
  "default": 1,
  "min": 0,
  "max": 18
 },
 {
  "key": "owned.bonus",
  "group": "Body & owned tiles",
  "label": "Copies of each owned bonus design",
  "default": 1,
  "min": 0,
  "max": 18
 },
 {
  "key": "soul.move",
  "group": "Soul · Blank movement",
  "label": "Movement per converted Blank",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "soul.uses",
  "group": "Soul · Blank movement",
  "label": "Blank conversions per hero turn",
  "default": 1,
  "min": 0,
  "max": 18
 },
 {
  "key": "numeric.positive_faces",
  "group": "Numeric die",
  "label": "Positive sides on the ordinary d6",
  "default": 5,
  "min": 0,
  "max": 6,
  "original": 4
 },
 {
  "key": "numeric.positive",
  "group": "Numeric die",
  "label": "Value on a positive side",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "numeric.blank",
  "group": "Numeric die",
  "label": "Value on a Blank side",
  "default": 0,
  "min": 0,
  "max": 99
 },
 {
  "key": "numeric.tuned_bonus",
  "group": "Numeric die",
  "label": "Positive Numeric Attack bonus",
  "default": 0,
  "min": 0,
  "max": 99,
  "original": 0
 },
 {
  "key": "face1.damage",
  "group": "01 · Strike",
  "label": "Damage",
  "default": 1,
  "min": 0,
  "max": 99,
  "original": 1
 },
 {
  "key": "face1.range",
  "group": "01 · Strike",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face2.move",
  "group": "02 · Step",
  "label": "Movement distance",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face3.move",
  "group": "03 · Stride",
  "label": "Straight movement distance",
  "default": 3,
  "min": 0,
  "max": 16
 },
 {
  "key": "face4.block",
  "group": "04 · Guard",
  "label": "Block gained",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face5.block",
  "group": "05 · Reaction",
  "label": "Reaction Block",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face5.move",
  "group": "05 · Reaction",
  "label": "Optional reaction movement",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face7.heal",
  "group": "07 · First Aid",
  "label": "HP healed",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face7.range",
  "group": "07 · First Aid",
  "label": "Healing range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face8.range",
  "group": "08 · Shove",
  "label": "Shove target range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face8.move",
  "group": "08 · Shove",
  "label": "Push distance",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face9.gold",
  "group": "09 · Gambler's Coin",
  "label": "Gold on second resolution",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face9.multiplier",
  "group": "09 · Gambler's Coin",
  "label": "Gambler multiplier",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face10.duration",
  "group": "10 · Weak Point",
  "label": "Extra rounds the marker lasts",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face10.repeat",
  "group": "10 · Weak Point",
  "label": "Extra rear Attack repetitions",
  "default": 1,
  "min": 0,
  "max": 20
 },
 {
  "key": "face11.range",
  "group": "11 · Conjure",
  "label": "Copy source range",
  "default": 99,
  "min": 0,
  "max": 99
 },
 {
  "key": "face12.placements",
  "group": "12 · Blessing of Recovery",
  "label": "Placements before becoming Blank",
  "default": 2,
  "min": 1,
  "max": 99
 },
 {
  "key": "face13.rerolls",
  "group": "13 · Clairvoyance",
  "label": "Action Rerolls gained",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face14.boost",
  "group": "14 · Forgotten Strength",
  "label": "Next Numeric damage bonus",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face15.range",
  "group": "15 · Passing Grace",
  "label": "Healing / passing range",
  "default": 3,
  "min": 0,
  "max": 16
 },
 {
  "key": "face19.range",
  "group": "19 · Restore",
  "label": "Healing / passing range",
  "default": 3,
  "min": 0,
  "max": 16
 },
 {
  "key": "face55.range",
  "group": "55 · Recovery",
  "label": "Healing / passing range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face18.backlash",
  "group": "18 · Lethargic Bind",
  "label": "Damage when a bound face triggers",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face19.minimum",
  "group": "19 · Restore",
  "label": "Minimum healing (except Gambler x0)",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face20.blank_value",
  "group": "20 · Focus Numeric",
  "label": "Focused Numeric Blank value",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face21.damage",
  "group": "21 · Mark Prey",
  "label": "Mark bonus damage",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face22.damage",
  "group": "22 · Last Word",
  "label": "Unavoidable damage",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face24.repeat",
  "group": "24 · Spiral Instability",
  "label": "Attack resolutions",
  "default": 2,
  "min": 0,
  "max": 20
 },
 {
  "key": "face25.blank_block",
  "group": "25 · Contained Power",
  "label": "Block per future Blank",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face25.boost",
  "group": "25 · Contained Power",
  "label": "Numeric bonus per non-Blank",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face25.cap",
  "group": "25 · Contained Power",
  "label": "Numeric bonus cap",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face25.backlash",
  "group": "25 · Contained Power",
  "label": "HP backlash when broken",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face27.charges",
  "group": "27 · Blood Bargain",
  "label": "Empowered Attacks",
  "default": 2,
  "min": 1,
  "max": 99
 },
 {
  "key": "face27.damage",
  "group": "27 · Blood Bargain",
  "label": "Bonus per Attack",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face27.backlash",
  "group": "27 · Blood Bargain",
  "label": "HP paid after final charge",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face28.range",
  "group": "28 · Target Override",
  "label": "Alternative target range from boss",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face29.boost",
  "group": "29 · Debt",
  "label": "Attack / Defense bonus",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face29.penalty",
  "group": "29 · Debt",
  "label": "Next-turn Attack / Defense penalty",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face30.bad",
  "group": "30 · Ill Omen",
  "label": "Penalty on roll 1",
  "default": 1,
  "min": 0,
  "max": 20
 },
 {
  "key": "face30.good",
  "group": "30 · Ill Omen",
  "label": "Bonus on rolls 2–4",
  "default": 1,
  "min": 0,
  "max": 20
 },
 {
  "key": "face30.pierce",
  "group": "30 · Ill Omen",
  "label": "Pierce on roll 5",
  "default": 2,
  "min": 0,
  "max": 20
 },
 {
  "key": "face30.defense",
  "group": "30 · Ill Omen",
  "label": "Defense bonus on roll 5",
  "default": 2,
  "min": 0,
  "max": 20
 },
 {
  "key": "face30.repeat",
  "group": "30 · Ill Omen",
  "label": "Extra repeats on roll 6",
  "default": 1,
  "min": 0,
  "max": 20
 },
 {
  "key": "face31.initial",
  "group": "31 · Stonewake",
  "label": "Block on starting Channel",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face31.gain",
  "group": "31 · Stonewake",
  "label": "Block per maintained turn",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face31.cap",
  "group": "31 · Stonewake",
  "label": "Maintained Block cap",
  "default": 8,
  "min": 0,
  "max": 99
 },
 {
  "key": "face32.block",
  "group": "32 · Oath of Smoke",
  "label": "Stored defense reaction Block",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face32.move",
  "group": "32 · Oath of Smoke",
  "label": "Stored movement reaction distance",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face33.placements",
  "group": "33 · Bone Mutation",
  "label": "Placements before becoming Blank (0 = unlimited)",
  "default": 0,
  "min": 0,
  "max": 99
 },
 {
  "key": "face34.range",
  "group": "34 · Strike Numeric",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face35.range",
  "group": "35 · Short Shot",
  "label": "Attack range",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "face36.range",
  "group": "36 · Hooked Slash",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face37.range",
  "group": "37 · Piercing Thrust",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face38.range",
  "group": "38 · Cleave",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face39.range",
  "group": "39 · Flanking Blow",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face40.range",
  "group": "40 · Break Rhythm",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face41.range",
  "group": "41 · Engrave",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face35.cap",
  "group": "35 · Short Shot",
  "label": "Final damage cap",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face36.threshold",
  "group": "36 · Hooked Slash",
  "label": "Minimum HP loss to gain Block",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face36.multiplier",
  "group": "36 · Hooked Slash",
  "label": "Block per HP damage dealt",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face37.pierce",
  "group": "37 · Piercing Thrust",
  "label": "Block bypassed",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face38.splash",
  "group": "38 · Cleave",
  "label": "Secondary-enemy damage",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face39.rear",
  "group": "39 · Flanking Blow",
  "label": "Rear damage bonus",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face40.delay",
  "group": "40 · Break Rhythm",
  "label": "Initiative slots to delay boss",
  "default": 1,
  "min": 0,
  "max": 3
 },
 {
  "key": "face41.threshold1",
  "group": "41 · Engrave",
  "label": "First copy threshold",
  "default": 3,
  "min": 0,
  "max": 6
 },
 {
  "key": "face41.bonus1",
  "group": "41 · Engrave",
  "label": "First threshold damage bonus",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face41.threshold2",
  "group": "41 · Engrave",
  "label": "Second copy threshold",
  "default": 6,
  "min": 0,
  "max": 6
 },
 {
  "key": "face41.bonus2",
  "group": "41 · Engrave",
  "label": "Second threshold damage bonus",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face41.copies",
  "group": "41 · Engrave",
  "label": "New copies per hit",
  "default": 1,
  "min": 0,
  "max": 6
 },
 {
  "key": "face43.empty",
  "group": "43 · Brace Hero",
  "label": "Block when starting at zero",
  "default": 3,
  "min": 0,
  "max": 99
 },
 {
  "key": "face43.normal",
  "group": "43 · Brace Hero",
  "label": "Block otherwise",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face44.range",
  "group": "44 · Shield Wall",
  "label": "Ally reaction range",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "face44.self",
  "group": "44 · Shield Wall",
  "label": "Block gained by user",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face44.ally",
  "group": "44 · Shield Wall",
  "label": "Block given to ally",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face45.range",
  "group": "45 · Taunt",
  "label": "Taunt range from boss (must be a legal target)",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face46.hp",
  "group": "46 · Defy Death",
  "label": "HP preserved when death is defied",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face47.reduction",
  "group": "47 · Bulwark",
  "label": "Damage Reduction",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face47.weakness",
  "group": "47 · Bulwark",
  "label": "Self Weakness penalty",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face48.cap",
  "group": "48 · Echo of Pain",
  "label": "Retaliation damage cap",
  "default": 3,
  "min": 0,
  "max": 99
 },
 {
  "key": "face48.penalty",
  "group": "48 · Echo of Pain",
  "label": "Unavoidable damage if unused",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face49.heal",
  "group": "49 · Last Pulse",
  "label": "HP per maintained turn",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face50.block",
  "group": "50 · Black Oath",
  "label": "Flat Block bonus",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face50.penalty",
  "group": "50 · Black Oath",
  "label": "HP loss if Block remains",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face51.range",
  "group": "51 · Wither Ward",
  "label": "Ward retaliation range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face51.weakness",
  "group": "51 · Wither Ward",
  "label": "Weakness inflicted on boss",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face52.burn",
  "group": "52 · Ember Burst",
  "label": "Maximum Block burned",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face52.damage",
  "group": "52 · Ember Burst",
  "label": "Damage per Block burned",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face52.range",
  "group": "52 · Ember Burst",
  "label": "Burst radius",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face53.move",
  "group": "53 · Leap of Echoes",
  "label": "Leap distance",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "face53.boost",
  "group": "53 · Leap of Echoes",
  "label": "Bonus after landing near boss",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face53.range",
  "group": "53 · Leap of Echoes",
  "label": "Boss proximity for bonus",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face54.block",
  "group": "54 · Bone",
  "label": "Block gained",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face54.move",
  "group": "54 · Bone",
  "label": "Optional movement",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "face57.move",
  "group": "57 · Ashstep",
  "label": "Movement distance",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "face57.block",
  "group": "57 · Ashstep",
  "label": "Block gained",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face58.range",
  "group": "58 · Oathbound Exchange",
  "label": "Ally swap range",
  "default": 3,
  "min": 0,
  "max": 16
 },
 {
  "key": "face58.block",
  "group": "58 · Oathbound Exchange",
  "label": "Block gained by each hero",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face15.numeric_multiplier",
  "group": "15 · Passing Grace",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face15.numeric_bonus",
  "group": "15 · Passing Grace",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face19.numeric_multiplier",
  "group": "19 · Restore",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face19.numeric_bonus",
  "group": "19 · Restore",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face34.numeric_multiplier",
  "group": "34 · Strike Numeric",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face34.numeric_bonus",
  "group": "34 · Strike Numeric",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face35.numeric_multiplier",
  "group": "35 · Short Shot",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face35.numeric_bonus",
  "group": "35 · Short Shot",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face36.numeric_multiplier",
  "group": "36 · Hooked Slash",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face36.numeric_bonus",
  "group": "36 · Hooked Slash",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face37.numeric_multiplier",
  "group": "37 · Piercing Thrust",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face37.numeric_bonus",
  "group": "37 · Piercing Thrust",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face38.numeric_multiplier",
  "group": "38 · Cleave",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face38.numeric_bonus",
  "group": "38 · Cleave",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face39.numeric_multiplier",
  "group": "39 · Flanking Blow",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face39.numeric_bonus",
  "group": "39 · Flanking Blow",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face40.numeric_multiplier",
  "group": "40 · Break Rhythm",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face40.numeric_bonus",
  "group": "40 · Break Rhythm",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face41.numeric_multiplier",
  "group": "41 · Engrave",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face41.numeric_bonus",
  "group": "41 · Engrave",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face42.numeric_multiplier",
  "group": "42 · Guard Numeric",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face42.numeric_bonus",
  "group": "42 · Guard Numeric",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face50.numeric_multiplier",
  "group": "50 · Black Oath",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face50.numeric_bonus",
  "group": "50 · Black Oath",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face51.numeric_multiplier",
  "group": "51 · Wither Ward",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face51.numeric_bonus",
  "group": "51 · Wither Ward",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face52.numeric_multiplier",
  "group": "52 · Ember Burst",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face52.numeric_bonus",
  "group": "52 · Ember Burst",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "face55.numeric_multiplier",
  "group": "55 · Recovery",
  "label": "Numeric multiplier",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "face55.numeric_bonus",
  "group": "55 · Recovery",
  "label": "Flat Numeric bonus",
  "default": 0,
  "min": -99,
  "max": 99
 },
 {
  "key": "boss.hp",
  "group": "Boss · general",
  "label": "Encounter maximum / starting HP",
  "default": 12,
  "min": 1,
  "max": 999,
  "original": 18
 },
 {
  "key": "boss.fallback.move",
  "group": "Boss · fallback",
  "label": "Fallback movement",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.fallback.block",
  "group": "Boss · fallback",
  "label": "Block if no path is possible",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.fallback.idle",
  "group": "Boss · fallback",
  "label": "Block while already adjacent",
  "default": 0,
  "min": 0,
  "max": 99,
  "original": 1
 },
 {
  "key": "boss.Strike.damage",
  "group": "Boss · Smoking Strike",
  "label": "Attack damage",
  "default": 1,
  "min": 0,
  "max": 99,
  "original": 2
 },
 {
  "key": "boss.Strike.range",
  "group": "Boss · Smoking Strike",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.Sweep.damage",
  "group": "Boss · Sweep",
  "label": "Attack damage",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.Sweep.range",
  "group": "Boss · Sweep",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.Skirmish.damage",
  "group": "Boss · Skirmish",
  "label": "Attack damage",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.Skirmish.range",
  "group": "Boss · Skirmish",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.Drive Back.damage",
  "group": "Boss · Drive Back",
  "label": "Attack damage",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.Drive Back.range",
  "group": "Boss · Drive Back",
  "label": "Attack range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.advance.move",
  "group": "Boss · Advance",
  "label": "Movement distance",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.skirmish.move",
  "group": "Boss · Skirmish",
  "label": "Movement before Attack",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.brace.block",
  "group": "Boss · Brace",
  "label": "Block gained",
  "default": 1,
  "min": 0,
  "max": 99,
  "original": 2
 },
 {
  "key": "boss.chain.range",
  "group": "Boss · Ashen Chain",
  "label": "Pull target range",
  "default": 3,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.chain.move",
  "group": "Boss · Ashen Chain",
  "label": "Pull distance",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.chain.strip",
  "group": "Boss · Ashen Chain",
  "label": "Block removed",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.brand.range",
  "group": "Boss · Cinder Brand",
  "label": "Targeting range",
  "default": 3,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.brand.radius",
  "group": "Boss · Cinder Brand",
  "label": "Cross arms in phase I / square radius in phase II",
  "default": 1,
  "min": 0,
  "max": 8
 },
 {
  "key": "boss.brand.damage",
  "group": "Boss · Cinder Brand",
  "label": "Detonation damage per hero",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.tithe.range",
  "group": "Boss · Grave Tithe",
  "label": "Theft range",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.tithe.strip",
  "group": "Boss · Grave Tithe",
  "label": "Block removed per hero",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.tithe.cap",
  "group": "Boss · Grave Tithe",
  "label": "Maximum Block gained",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.distort.range",
  "group": "Boss · Distort",
  "label": "Target range",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.distort.weakness",
  "group": "Boss · Distort",
  "label": "Weakness penalty",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.fracture.range",
  "group": "Boss · Fracture",
  "label": "Target range",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.fracture.count",
  "group": "Boss · Fracture",
  "label": "Installed faces removed",
  "default": 1,
  "min": 1,
  "max": 18
 },
 {
  "key": "boss.push.move",
  "group": "Boss · Drive Back",
  "label": "Push distance",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.push.collision",
  "group": "Boss · Drive Back",
  "label": "Unavoidable collision damage",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "status.stun_repeat",
  "group": "General & passives",
  "label": "Damage when Stunned is applied again",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "lab.boss_hp",
  "group": "Lab fixtures",
  "label": "Lab boss maximum / starting HP",
  "default": 30,
  "min": 1,
  "max": 999
 },
 {
  "key": "lab.hero_hp",
  "group": "Lab fixtures",
  "label": "Lab hero starting HP (capped by maximum)",
  "default": 3,
  "min": 1,
  "max": 999
 },
 {
  "key": "lab.hero_block",
  "group": "Lab fixtures",
  "label": "Lab hero starting Block",
  "default": 0,
  "min": 0,
  "max": 999
 },
 {
  "key": "lab.boss_block",
  "group": "Lab fixtures",
  "label": "Lab boss starting Block",
  "default": 0,
  "min": 0,
  "max": 999
 },
 {
  "key": "lab.defy_hp",
  "group": "Lab fixtures",
  "label": "Defy Death fixture starting HP",
  "default": 1,
  "min": 1,
  "max": 999
 },
 {
  "key": "lab.echo_taken",
  "group": "Lab fixtures",
  "label": "Echo of Pain fixture damage already taken",
  "default": 2,
  "min": 0,
  "max": 999
 },
 {
  "key": "numeric.high_faces",
  "group": "Numeric die",
  "label": "Leading positive sides using higher value (capped by positive side count)",
  "default": 2,
  "min": 0,
  "max": 6,
  "original": 0
 },
 {
  "key": "numeric.high",
  "group": "Numeric die",
  "label": "Higher side value",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face31.break_block",
  "group": "31 · Stonewake",
  "label": "Cumulative Block loss that breaks Channel",
  "default": 2,
  "min": 0,
  "max": 99
 },
 {
  "key": "face41.cap",
  "group": "41 · Engrave",
  "label": "Maximum copies on one die",
  "default": 3,
  "min": 0,
  "max": 6
 },
 {
  "key": "face41.growth",
  "group": "41 · Engrave",
  "label": "Growth triggers per hero turn",
  "default": 1,
  "min": 0,
  "max": 18
 },
 {
  "key": "boss.phase.percent",
  "group": "Boss · phase change",
  "label": "HP percent that unlocks Furnace Roar",
  "default": 50,
  "min": 0,
  "max": 100
 },
 {
  "key": "boss.Furnace Roar.damage",
  "group": "Boss · Furnace Roar",
  "label": "Attack damage per hero",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.Furnace Roar.range",
  "group": "Boss · Furnace Roar",
  "label": "Area range from boss footprint",
  "default": 2,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.roar.push",
  "group": "Boss · Furnace Roar",
  "label": "Push distance (blocked cells stop it)",
  "default": 1,
  "min": 0,
  "max": 16
 },
 {
  "key": "boss.advance.block",
  "group": "Boss · Advance",
  "label": "Block when adjacent to any highest-HP hero",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.chain.root",
  "group": "Boss · Ashen Chain",
  "label": "Rooted stacks in phase II (expires next boss turn)",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {
  "key": "boss.smoking.fire_damage",
  "group": "Boss · Smoking Strike",
  "label": "Damage from a consumed fire tile",
  "default": 1,
  "min": 0,
  "max": 99
 },
 {"key": "phase.boss.advance.move", "group": "Boss · Half-HP upgrades", "label": "Advance movement bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.advance.block", "group": "Boss · Half-HP upgrades", "label": "Advance adjacent Block bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.smoking.fire_damage", "group": "Boss · Half-HP upgrades", "label": "Smoking Strike detonation damage bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.brace.block", "group": "Boss · Half-HP upgrades", "label": "Brace Block bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.skirmish.move", "group": "Boss · Half-HP upgrades", "label": "Skirmish movement bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.Sweep.range", "group": "Boss · Half-HP upgrades", "label": "Sweep reach bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.push.move", "group": "Boss · Half-HP upgrades", "label": "Drive Back push distance bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.distort.weakness", "group": "Boss · Half-HP upgrades", "label": "Distort Weakness bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.fracture.range", "group": "Boss · Half-HP upgrades", "label": "Fracture reach bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.tithe.strip", "group": "Boss · Half-HP upgrades", "label": "Grave Tithe Block stolen bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.tithe.cap", "group": "Boss · Half-HP upgrades", "label": "Grave Tithe Block cap bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "phase.boss.Furnace Roar.range", "group": "Boss · Half-HP upgrades", "label": "Furnace Roar reach bonus at half HP", "default": 1, "min": 0, "max": 9},
 {"key": "nugh.hp", "group": "Boss · Nu’gh", "label": "Boss HP", "default": 10, "min": 1, "max": 999},
 {"key": "nugh.worm_hp", "group": "Boss · Nu’gh", "label": "Worm HP", "default": 1, "min": 1, "max": 99},
 {"key": "nugh.worm_cap", "group": "Boss · Nu’gh", "label": "Maximum living worms", "default": 4, "min": 0, "max": 12},
 {"key": "nugh.initial_worms", "group": "Boss · Nu’gh", "label": "Starting worms", "default": 2, "min": 0, "max": 12},
 {"key": "nugh.summon", "group": "Boss · Nu’gh", "label": "Birth Cry summons", "default": 1, "min": 0, "max": 12},
 {"key": "nugh.summon_bonus", "group": "Boss · Nu’gh", "label": "Half HP: extra Birth Cry summons", "default": 1, "min": 0, "max": 12},
 {"key": "nugh.pressure_cap", "group": "Boss · Nu’gh", "label": "Maximum worm bonus damage", "default": 1, "min": 0, "max": 9},
 {"key": "nugh.pressure_bonus", "group": "Boss · Nu’gh", "label": "Half HP: extra pressure cap", "default": 1, "min": 0, "max": 9},
 {"key": "nugh.chorus_range", "group": "Boss · Nu’gh", "label": "Screaming Chorus range", "default": 4, "min": 1, "max": 16},
 {"key": "nugh.chorus_damage", "group": "Boss · Nu’gh", "label": "Screaming Chorus base damage", "default": 1, "min": 0, "max": 99},
 {"key": "nugh.maw_range", "group": "Boss · Nu’gh", "label": "Gnashing Maw range", "default": 1, "min": 1, "max": 16},
 {"key": "nugh.maw_range_bonus", "group": "Boss · Nu’gh", "label": "Half HP: extra Maw reach", "default": 1, "min": 0, "max": 9},
 {"key": "nugh.maw_damage", "group": "Boss · Nu’gh", "label": "Gnashing Maw base damage", "default": 1, "min": 0, "max": 99},
 {"key": "nugh.burrow_move", "group": "Boss · Nu’gh", "label": "Burrow movement", "default": 2, "min": 0, "max": 16},
 {"key": "nugh.burrow_worms", "group": "Boss · Nu’gh", "label": "Half HP: Burrow summons", "default": 1, "min": 0, "max": 12},
 {"key": "nugh.guard_block", "group": "Boss · Nu’gh", "label": "Brood Guard base Block", "default": 1, "min": 0, "max": 99},
 {"key": "nugh.guard_worm_cap", "group": "Boss · Nu’gh", "label": "Brood Guard maximum worm bonus", "default": 1, "min": 0, "max": 12},
 {"key": "nugh.guard_worm_block", "group": "Boss · Nu’gh", "label": "Half HP: Guard shields one worm (non-stacking)", "default": 1, "min": 0, "max": 99},
 {"key": "nugh.devour_heal", "group": "Boss · Nu’gh", "label": "Devour Brood healing", "default": 1, "min": 0, "max": 99},
 {"key": "nugh.devour_heal_bonus", "group": "Boss · Nu’gh", "label": "Half HP: extra Devour healing", "default": 1, "min": 0, "max": 99},
 {"key": "nugh.devour_block", "group": "Boss · Nu’gh", "label": "Half HP: Devour Block", "default": 1, "min": 0, "max": 99},
 {"key":"nugh.link_damage","group":"Boss · Nu’gh","label":"Soul Link damage when a hero kills a worm","default":1,"min":0,"max":99}
]

static var INDEX: Dictionary = make_index()
static func make_index() -> Dictionary:
 var result := {}
 for entry in DEFINITIONS:result[entry.key] = entry
 return result
static func value(values: Dictionary, key: String, tuned: bool = true) -> int:
 assert(INDEX.has(key), "Unknown balance key: "+key)
 var entry: Dictionary = INDEX[key]
 return int(values.get(key,entry.default if tuned else entry.get("original",entry.default)))
static func validate(values: Variant) -> String:
 if not values is Dictionary:return "A balance profile must be an object of named numeric values."
 for key in values:
  if not INDEX.has(key):return "Unknown setting: "+str(key)
  var n = values[key];var entry: Dictionary = INDEX[key]
  if not (n is int or n is float) or not is_finite(float(n)) or float(n) != floor(float(n)):return "Whole numbers required: "+key
  if n < entry.min or n > entry.max:return "%s must be between %d and %d." % [entry.label,entry.min,entry.max]
 if value(values,"initiative.min") > value(values,"initiative.max"):return "Initiative minimum must not exceed its maximum."
 return ""
static func summary(values: Dictionary, group: String, tuned: bool = true) -> String:
 var lines: Array[String] = []
 for entry in DEFINITIONS:
  if entry.group == group:lines.append(entry.label+": "+str(value(values,entry.key,tuned))+(" · inactive in this encounter" if entry.get("inactive",false) else ""))
 return "\n".join(lines)
static func face_group(id: int) -> String:
 var names = preload("res://prototype/catalog.gd")
 return "%02d · %s" % [id,names.name_for(id)]
static func groups() -> Array[String]:
 var result: Array[String] = ["General & passives","Body & owned tiles","Soul · Blank movement","Numeric die","Lab fixtures"]
 for id in range(59):result.append(face_group(id))
 for entry in DEFINITIONS:
  if entry.group.begins_with("Boss · ") and entry.group not in result:result.append(entry.group)
 return result
