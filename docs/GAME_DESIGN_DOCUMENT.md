# Paw & Prism — Living Game Design Document (GDD)

> **Status:** Living Design Reference & Rework Blueprint  
> **Version:** `v2.0` (Behavioral Loot, Zero-Leveling & Playable Tutorial Revamp)  
> **Engine & Renderer:** Godot `4.7.2` (`GL Compatibility`)  
> **Live Web Build:** https://normandra.github.io/paw-and-prism/  
> **Repository:** https://github.com/normandra/paw-and-prism  
> **Target Platforms:** Web (single-threaded HTML5/WASM, no `SharedArrayBuffer`), macOS, Windows, Linux  

---

## How to Use This Document

Each section separates verified mechanics from future exploration:
1. **`Current Implementation` (Code-Verified `v2.0`):** Exact systems, tables, parameters, and script owners active in the project.
2. **`Rework Ideas & Design Knobs`:** Checkable `[ ]` balance levers and next-step feature ideas ready to edit directly.

---

## 1. High Concept, Core Pillars & Gameplay Loop

**Pitch:** *Vampire Survivors meets Diablo behavioral item tradeoffs and Path of Exile ability linking in a cozy 3D woodland meadow.* Pick a chibi critter hero (or learn step-by-step in the bare-pawed Tutorial), weave through 20 minutes of escalating critter swarms from Morning to Twilight, hunt strictly **3 ground loot types** (*Items*, *Main Socket Abilities*, and *Modifier Abilities*), weigh build-defining Relic tradeoffs inside an icon-first Satchel, and defeat 3 telegraphed bosses.

### Core Design Pillars

| Pillar | Design Choice | Current Implementation (`v2.0`) | Primary Code Owners |
|---|---|---|---|
| **1. Zero Leveling / Pure Loot Power** | No XP bars, XP shards, or "pick 1 of 3" stat-stick modals | All hero power & playstyle mutations come exclusively from equipped Items and socketed/linked Abilities | `hero_stats.gd`, `loot_manager.gd` |
| **2. Behavioral Items & Rarity Tradeoffs** | Rarity shapes socket count & behavioral tradeoffs, never dull `+X%` fluff | `Common` / `Magic` / `Rare` / `Unique` items across 6 slots grant `18` behavioral/tradeoff Global Effects + `5` Unique Keystones + fixed socket/link rolls | `item_database.gd`, `item_instance.gd`, `inventory_panel.gd` |
| **3. PoE Ability Linking (Main + Modifier)** | Clean 2-type gem grammar | `10` Main Socket Abilities + `10` Modifier Abilities insert into fixed colored (`R`/`G`/`B`/`W`) sockets and share effects across linked gaps | `gem_database.gd`, `poe_socket_widget.gd`, `skill_executor.gd` |
| **4. PoE-Style Playable Tutorial** | Learn by looting & linking hands-on | Dedicated bare-pawed `TUTORIAL` run walking through **First Item -> First Main Ability -> First Linked Modifier** | `tutorial_director.gd`, `main_game.gd` |
| **5. 20-Min 3-Boss Gauntlet + Mobile** | Readable swarms & touch support | 7 regular critter species, 3 scripted bosses (`06:30`, `13:00`, `19:30`), 3D biome shifts, icon-first UI & multi-touch virtual joystick | `wave_director.gd`, `touch_controls.gd`, `hud_controller.gd` |

### Core Moment-to-Moment Loop (`v2.0`)

```mermaid
flowchart LR
    K["Auto-Cast Linked Main Abilities + Hop-Dash"] --> D["Enemies, Elites, Chests & Bosses Drop 3 Loot Types"]
    D --> L1["1. Items / Relics (Global Behavioral Effects + Fixed Sockets/Links)"]
    D --> L2["2. Main Socket Abilities (Active Skills)"]
    D --> L3["3. Modifier Abilities (Behavior Mutators)"]
    L1 --> B["Open Hero Satchel [Tab / I] (Pauses Run)"]
    L2 --> B
    L3 --> B
    B --> T["Compare Visual Tradeoffs (+ Gained / - Lost Effects & Socket Links)"]
    B --> S["Socket & Link Main + Modifier Abilities"]
    T --> K
    S --> K
    K --> BO["Defeat 3 Bosses (06:30 -> 13:00 -> 19:30)"]
    BO --> V["Victory! Meadow Saved!"]
```

### Rework Ideas — Core Loop
- [ ] **Post-Boss Endless Mode:** Add an optional **"Endless Twilight"** button on the Victory screen after defeating Boss 3 to test fully 4-linked builds past `20:00`.
- [ ] **Risk Shrines / Pacts:** Add clickable in-world Altars that corrupt or upgrade a worn Relic (e.g., add a extra Tradeoff effect or flip socket colors).
- [ ] **Smart Quick-Swap Tray:** Allow swapping to a recently looted Relic directly from a compact bottom-right toast button without pausing for common upgrades.

---

## 2. Controls, Camera & Core Combat Rules

### Controls (`Current Implementation`)

| Input | Action | Notes |
|---|---|---|
| `WASD` / `Arrow Keys` | 8-directional movement | Clamped to `±66.5m` inside `136×136m` arena (`ArenaBuilder.ARENA_HALF_SIZE = 68.0`) |
| `Space` / `Shift` | Hop-Dash (`dash` action) | `0.22s` dash burst at `2.55×` move speed (`1.28×` extra while Zoomies active), `0.26s` i-frames, `1.85s` charge cooldown (`1` base charge, `2` charges with `double_dash` or `comet_dash`) |
| **Touch Drag** *(Mobile)* | Analog floating virtual joystick (`touch_controls.gd`) | Spawned outside HUD buttons; `10%` deadzone, `55%` full speed; auto-enabled on touchscreens or `?mobile=1` |
| **Touch `DASH` Pad** *(Mobile)* | Circular Hop-Dash pad (`bottom-right`) | `54px` radius espresso/gold button with live radial cooldown arc (`DASH_RADIUS * 1.28` hit area) |
| `Tab` / `I` | Toggle Hero Satchel | Pauses combat; shows Active Build, 6 Equipped Gear + PoE Sockets, Items/Main/Mods tabs & Tradeoff Inspector |
| `Esc` | Pause / Resume (`EndScreen`) | Also closes Satchel if open |
| `M` | Toggle procedural audio mute | Reflected in HUD `[M]` button |
| `F3` | Toggle FPS readout pill | Visible automatically when `?review=1` or `--review` is active |
| `F8` / `F9` (`?review=1` only) | Debug helpers | `F8`: seed Unique/Rare/Magic items + sample Main/Mod gems · `F9`: trigger Victory screen |

### Camera Rig (`main_game.gd`)
- **Perspective FOV:** `48.0°`, `far = 160.0`
- **Title Showcase Camera:** Landscape `Vector3(0.0, 2.38, 5.85)` aiming at `(0, 0.56, 0)`; Portrait (`vp.y > vp.x * 1.05`) `Vector3(0.0, 2.65, 7.20)` aiming at `(0, 0.25, 0)`.
- **Gameplay Chase Camera:** Landscape offset `Vector3(0.0, 17.5, 13.5)`; Portrait `Vector3(0.0, 22.5, 17.0)`; smooth lerp `min(1.0, delta * 9.0)` + quadratic trauma screen shake (`_shake_trauma² * 0.55`).

### Combat & Scaling Mechanics (`player_controller.gd`, `hero_stats.gd`, `skill_executor.gd`)
- **Hero Baseline Stats (fixed per hero, zero stat-stick bloat):**
  - `hp_regen = 0.8/s`, `crit_chance = 8.0%`, `crit_mult = 165.0%`.
  - Post-hit invulnerability: `0.45s` (`1.6s` when *Nine-Lives Bell* `cheat_death` saves from lethal hit with `55%` Max HP heal, `90s` CD).
  - Incoming damage formula: `max(1.0, raw_dmg * incoming_dmg_mult)` (`1.45×` when `glass_spark` is equipped, `1.0×` otherwise).
- **Dynamic Cooldown Flow (`skill_executor.gd`):**
  - Base compiled cooldown floor: `max(0.18s, final_cd)`.
  - Dynamic tick multiplier `cd_rate`: `1.0×` baseline; modified by **`turret_stance`** (`2.0×` faster while standing still, `0.75×` slower while moving) and **`zoomies_on_kill`** (`1.25×` cast rate + `1.28×` move speed for `2.0s` after any kill).
- **Elemental & Leech Riders:**
  - Fire skills & `mod_ignite`: apply `25–28%` DPS Burn for `3.0s`.
  - Cold skills & `mod_chill`: apply Chill slow for `2.5s` (also primes targets for `frost_shatter` icy death rings).
  - `mod_leech`: heals `5.5%` of linked skill damage dealt per hit, capped at `8%` `max_hp` per hit.

### Rework Ideas — Combat & Camera
- [ ] **Optional Cursor / Right-Stick Aiming:** Toggle between Auto-Aim Nearest and Cursor Aim (`[Q]`) for deliberate *Boomerang Bone* or *Sniper Focus* piercing shots.
- [ ] **Perfect-Hop Dash Timing:** Reward dodging just before an enemy telegraph detonates with an instant cooldown refresh or bonus spark burst.
- [ ] **Micro Impact Juice:** Subtle hit-stop freeze frames or squash/stretch pop on `cheat_death`, boss phase changes, and corpse explosions.

---

## 3. Playable Heroes (`scripts/data/hero_database.gd`)

In a standard **20-Min Run**, each hero starts equipped with a **Magic 2-link Starter Weapon** (containing their Main Ability, 1 open linked Modifier socket, and 1 signature Global Effect) plus a **Common Meadow Cap** (`[G, B]` unlinked sockets, `0` effects). In **Tutorial Mode**, all heroes start completely bare (`init_bare_for_tutorial()`).

| ID | Hero & Title | HP | Speed | Starter Weapon (`Magic`, 2-Link) | Starter Main Ability | Signature Effect | Starter Hat | Tagline |
|---|---|---|---|---|---|---|---|---|
| `shiba` | **Mochi the Shiba**<br>*Acorn Ranger* | `135` | `8.6` | *Mochi's Acorn Wand* (`G=G`) | *Acorn Barrage* (`ACRN`) | `zoomies_on_kill` (*Kills -> Speed Burst*) | `ribbon_hood` | Fast pup bursting with speed after every kill |
| `bunny` | **Pip the Bunny**<br>*Starlight Mage* | `120` | `9.0` | *Pip's Star Staff* (`B=G`) | *Starlight Orbs* (`STAR`) | `orbit_shield` (*Hit -> Star Shield*) | `wizard_hat` | Swift bunny summoning swirling star blades |
| `bear` | **Bramble the Bear**<br>*Honey Paladin* | `155` | `8.0` | *Bramble's Honey Hammer* (`R=B`) | *Honey Slam* (`SLAM`) | `dash_honey_nova` (*Dash -> Honey Nova*) | `leaf_crown` | Sturdy bear smashing honey novas on Hop-Dash |
| `cat` | **Nori the Cat**<br>*Storm Whisker* | `125` | `8.9` | *Nori's Spark Claws* (`B=G`) | *Whisker Lightning* (`ZAP`) | `static_sprint` (*Moving -> Zap Sparks*) | `knight_helm` | Zippy cat sparking lightning arcs on the run |

### Rework Ideas — Heroes
- [ ] **Permanent Innate Traits:** Keep a hero's signature trait innate in addition to weapon swaps so *Bramble* always retains melee brawling flavor or *Pip* always hovers lightly over slows.
- [ ] **5th Playable Hero:** Add *Maple the Red Panda* starting with *Spirit Bees* (`G=G`) + `short_barrage` or `ember_corpse`.

---

## 4. Behavioral Items, Global Effects & Tradeoffs (`item_database.gd`, `item_instance.gd`)

Items NEVER roll plain numerical stats like `+12% Damage` or `item_level`. Instead, every dropped Relic carries **fixed sockets/links** plus **1–2 Global Behavioral Effects** (often pairing an upside with a meaningful constraint or tradeoff!).

### Gear Slots & Fixed Socket/Link Budget (`GameEnums.slot_max_sockets`)

| Slot | Base Names | Max Sockets | Common Roll | Magic Roll | Rare Roll |
|---|---|---|---|---|---|
| **Weapon** | Acorn Wand, Honey Hammer, Starlight Staff, Paw Claws | `4` | `1` eff, `1–2S` (`38%` link, `4%` W) | `2` eff, `2–3S` (`58%` link, `6%` W) | `2` eff, `3–4S` (`76%` link, `10%` W) |
| **Helmet** | Sprout Hood, Wizard Hat, Knight Cap, Ribbon Hood | `3` | `1` eff, `1–2S` | `2` eff, `2–3S` | `2` eff, `3S` |
| **Armor** | Cozy Tunic, Bark Vest, Velvet Cloak | `4` | `1` eff, `1–2S` | `2` eff, `2–3S` | `2` eff, `3–4S` |
| **Boots** | Paw Slippers, Meadow Boots, Cloud Treads | `3` | `1` eff, `1–2S` | `2` eff, `2–3S` | `2` eff, `3S` |
| **Amulet** | Acorn Charm, Bell Pendant, Prism Locket | `2` | `1` eff, `1–2S` | `2` eff, `2S` | `2` eff, `2S` |
| **Ring** | Clover Ring, Amber Band, Dewdrop Signet | `2` | `1` eff, `1–2S` | `2` eff, `2S` | `2` eff, `2S` |

- **Drop Rarity Odds:** Standard: `5%` Unique / `22%` Rare / `43%` Magic / `30%` Common. With **`lucky_clover`**: `14%` Unique / `40%` Rare / `36%` Magic / `10%` Common (+`14%` link rate & +`5%` White socket rate).
- **Smart Magic Bias:** Magic items explicitly pair a non-tradeoff effect with a tradeoff effect (or vice-versa) so even blue drops ask an immediate build question!
- **No Crafting Clutter:** Prism Dust and manual socket/link rerolling are removed — socket layouts are fixed identity traits on each Relic, making a well-linked Rare a genuine find.

### Complete Global Behavioral Effects Catalog (`18` Standard/Tradeoff + `5` Unique Keystones)

#### Standard & Tradeoff Global Effects (`18`)

| Effect ID | In-Game Tag | Tradeoff? | Exact Gameplay Behavior |
|---|---|---|---|
| `dash_honey_nova` | **Dash -> Honey Nova** | No | Hop-Dash unleashes a `4.4m` slowing Honey Nova (`26` dmg) at origin |
| `dash_triggers_skills` | **Dash Fires Skills \| Slow Auto** | **Yes** | Hop-Dash casts all non-orbit Main Abilities at once, but automatic cooldowns slow `1.50×` (unless `comet_dash` is also active) |
| `turret_stance` | **Stand Still -> 2x Cast** | **Yes** | Standing still ticks skill cooldowns `2.0×` faster; moving ticks at `0.75×` |
| `zoomies_on_kill` | **Kills -> Speed Burst** | No | Every critter kill grants `2.0s` of Zoomies (`1.28×` move speed, `1.25×` cast rate) |
| `edge_ricochet` | **Shots Bounce Back** | No | Non-boomerang projectiles bounce back toward nearest enemy once (`0.85×` lifetime) on timeout or arena wall |
| `short_barrage` | **+2 Shots \| Short Range** | **Yes** | `+2` projectiles/orbiters globally, but projectile lifetime shrinks to `0.55×` |
| `sniper_focus` | **Pierce +2 \| 1 Fast Shot** | **Yes** | Forces `1` projectile per cast, sets `pierce +2`, `1.55×` projectile speed, `1.45×` damage |
| `giant_slow_aoe` | **Huge AoE \| Slower Cast** | **Yes** | `AoE` & `Orbit` skills gain `1.65×` radius, at `1.33×` longer cooldown |
| `ember_corpse` | **Kills -> Fire Pop** | No | Defeated critters detonate in a `3.6m` fiery nova (`24` dmg + Burn) |
| `frost_shatter` | **Chill Kills -> Ice Ring** | No | Defeating a chilled critter triggers a `4.4m` icy ring (`26` dmg + Chill slow) |
| `static_sprint` | **Moving -> Zap Sparks** | No | Every `5.5m` traveled zaps up to `2` nearby foes (`20` dmg lightning arcs) |
| `vamp_dash` | **Dash -> Siphon Heal** | No | Hop-Dash restores `+12 HP` |
| `thorns_burst` | **Hit -> Bramble Nova** | No | Taking damage triggers a `4.4m` Bramble Nova (`26` dmg, `1.2s` CD) |
| `gravity_slams` | **AoE Pulls Foes In** | No | Player novas, meteors & explosions yank hit critters inward instead of knocking away |
| `glass_spark` | **Heavy Impact \| Fragile** | **Yes** | All compiled abilities deal `1.75×` damage, but hero takes `1.45×` incoming damage |
| `double_dash` | **2x Dash Charges** | No | Grants `2` max Hop-Dash charges |
| `orbit_shield` | **Hit -> Star Shield** | No | Taking damage activates `3` orbiting star shields (`2.6m`, `22` dmg) for `5.0s` (`6.0s` CD) |
| `lucky_clover` | **Rarer Loot & Links** | No | Upgrades ground drop & chest rarity weights (`14%` Unique / `40%` Rare) and boosts socket link odds (`+14%`) |

#### Unique Items & Exclusive Keystones (`6 Uniques`, `5 Unique Effects`)

| Unique Item | Slot | Fixed Sockets | Global Effects | Signature Build Identity |
|---|---|---|---|---|
| **Grand Acorn Scepter** | Weapon | `G=G=B=R` (`4L`) | `nova_barrage` (*All Shots Fire 360 Ring*) + `short_barrage` | Turns projectile casts into short-range 360-degree bullet rings |
| **Prismwhisker Crown** | Helmet | `W=W=W` (`3L`) | `prism_echo` (*Linked Mods Double-Proc*) + `lucky_clover` | Doubles linked Modifier counts (`+2 -> +4` etc.), triggers Double Echo on linked skills & boosts rarity |
| **Honeycomb Aegis** | Armor | `R=R=B=G` (`4L`) | `aegis_freeze` (*Hit -> Freezing Honey Nova*) + `thorns_burst` | Retaliatory tank chest erupting `5.2m` freezing novas (`32` dmg) + bramble bursts when hit |
| **Paws of the Comet** | Boots | `G=G=B` (`3L`) | `comet_dash` (*Dash Fires All Skills*) + `double_dash` | Grants `2` Dash charges and unleashes all Main Abilities on every Hop-Dash **without** slow auto penalty |
| **Nine-Lives Bell** | Amulet | `W=B` (`2L`) | `cheat_death` (*Fatal Hit -> Burst Heal*) + `zoomies_on_kill` | Prevents fatal blow (`55%` heal + `1.6s` i-frames, `90s` CD) while chaining kill Zoomies |
| **Starweaver Band** | Ring | `B=G` (`2L`) | `gravity_slams` (*AoE Pulls Foes In*) + `ember_corpse` | Clusters foes into AoEs and chain-detonates kills with Fire Pops |

### Rework Ideas — Behavioral Items
- [ ] **Cross-Slot Combo Sets / Synergy Icons:** Highlight active synergies inside the Tradeoff Inspector (e.g., show an amber combo indicator when `comet_dash` + `dash_honey_nova` or `gravity_slams` + `ember_corpse` are both active).
- [ ] **Additional Uniques (`Target 12+`):** Add Unique armor/amulet built specifically around `edge_ricochet` + `sniper_focus` (super-pinball single-shot sniper) or minion/orbit loops.

---

## 5. Ability Linking System (`gem_database.gd`, `hero_stats.gd`)

Only **Main Socket Abilities (`MAIN`)** and **Modifier Abilities (`MODIFIER`)** exist. Gems do not gain XP or have numeric levels — what matters is **which Main Abilities are socketed, which Modifiers share a contiguous link group with them, and how item Global Effects reshape them**.

### Main Socket Abilities (`10`)

| ID | Name (`Short`) | Color | Tags | Damage | Cooldown | Base Behavior |
|---|---|---|---|---|---|---|
| `acorn_barrage` | **Acorn Barrage** (`ACRN`) | Green | `Proj`, `Phys` | `24` | `0.65s` | Aimed fan of flying acorns (`1` base proj, spd `22`) |
| `starlight_orb` | **Starlight Orbs** (`STAR`) | Blue | `Spell`, `Orbit`, `AoE` | `21` | `0.45s` | Persistent `2` orbiting star blades (`3.4m` radius, `99` pierce) |
| `honey_slam` | **Honey Slam** (`SLAM`) | Red | `Melee`, `AoE`, `Phys` | `38` | `1.25s` | Slowing honey shockwave near nearest target (`4.3m` radius) |
| `whisker_lightning` | **Whisker Lightning** (`ZAP`) | Blue | `Spell`, `Chain`, `Lightning` | `28` | `0.88s` | Instant static arc jumping across `2` base chains |
| `petal_cyclone` | **Petal Cyclone** (`PETL`) | Green | `AoE`, `Proj`, `Phys` | `17` | `1.08s` | Rotating `6`-petal outward spiral (`1` pierce) |
| `fireball_berry` | **Fireball Berry** (`FIRE`) | Red | `Proj`, `Spell`, `AoE`, `Fire` | `34` | `1.18s` | Explosive burning berry (`3.2m` splash + Burn DoT) |
| `frost_nova` | **Frost Nova** (`FRST`) | Blue | `Spell`, `Proj`, `AoE`, `Cold` | `22` | `1.45s` | `4.2m` Chill ring (`0.7×` dmg) + `8` radial ice shards |
| `boomerang_bone` | **Boomerang Bone** (`BONE`) | Red | `Proj`, `Phys` | `28` | `1.08s` | Heavy `99`-pierce bone flying outward and returning to hero |
| `meteor_pine` | **Meteor Pinecone** (`PINE`) | Red | `Spell`, `AoE`, `Fire` | `58` | `2.05s` | Drops heavy burning pinecone slam (`4.2m`) on densest critter cluster |
| `spirit_bees` | **Spirit Bees** (`BEES`) | Green | `Minion`, `Proj`, `Phys` | `20` | `0.98s` | Fires `2` naturally homing bees |

### Modifier Abilities (`10`)

| ID | Name (`Short`) | Color | Required Tags | Linked Mutation |
|---|---|---|---|---|
| `mod_multishot` | **Multi-Shot** (`MULT`) | Green | `Proj` or `Orbit` | `+2` projectiles/orbiters (`0.85×` dmg per hit) |
| `mod_chain` | **Chain Bounce** (`CHN`) | Green | `Proj` or `Chain` | Bounces `+2` additional targets |
| `mod_fork` | **Twin Fork** (`FORK`) | Green | `Proj` | Projectiles split into `2` angled projectiles on first hit |
| `mod_pierce` | **Deep Pierce** (`PRCE`) | Green | `Proj` | Pierces `+3` targets |
| `mod_homing` | **Homing Seekers** (`HOME`) | Green | `Proj` | Smooth steering toward nearest enemies + `1.15×` projectile speed |
| `mod_echo` | **Double Echo** (`ECHO`) | Blue | *Any Main* | Triggers a delayed echo cast (`0.16s` later) / `+1` orbiter (`0.78×` dmg/hit) |
| `mod_nova_area` | **Giant Blast** (`WIDE`) | Blue | `AoE` or `Orbit` | Expands AoE/Orbit radius (`1.55×`) |
| `mod_ignite` | **Blazing Burn** (`BURN`) | Red | *Any Main* | Hits ignite critters (`25–28%` DPS Burn for `3.0s`) |
| `mod_chill` | **Frost Chill** (`CHIL`) | Blue | *Any Main* | Hits apply `2.5s` Chill slow (combos with *Frost Shatter*) |
| `mod_leech` | **Life Siphon** (`HEAL`) | Red | *Any Main* | Heals hero for `5.5%` of linked skill damage dealt |

---

## 6. Playable PoE-Style Tutorial (`scripts/systems/tutorial_director.gd`)

Launchable directly via **`TUTORIAL`** on the Title Screen. The player starts completely **bare-pawed** (`0` equipped items, `0` abilities) and learns the entire core loop through 3 short interactive beats:

| Beat | Step Sequence | Ground Spawn / Trigger | Top HUD Plaque | Satchel Banner Guidance |
|---|---|---|---|---|
| **1/3 — First Item** | `LOOT_ITEM` -> `EQUIP_ITEM` | Drops **`Meadow Acorn Wand`** (`Magic`, `G=G` 2-link, `dash_honey_nova`) `4.2m` north | `1/3  Walk to Wand` -> `1/3  Equip Wand [Tab]` (pulses Satchel button gold) | `Items tab -> Select Meadow Acorn Wand -> Equip` |
| **2/3 — Main Ability** | `LOOT_MAIN` -> `SOCKET_MAIN` -> `KILL_WAVE_1` | Equipping wand drops **`Acorn Barrage`**; socketing spawns `3` `slime_frog` critters (`0.55×` HP) | `2/3  Pick up Acorn Barrage` -> `2/3  Socket Ability [Tab]` -> `2/3  Defeat Critters (0/3)` | `Main tab -> Select Acorn Barrage -> Click Green Socket` |
| **3/3 — Linked Modifier** | `LOOT_MOD` -> `SOCKET_MOD` -> `KILL_WAVE_2` | 3 kills drops **`Multi-Shot`**; linking spawns `5` `slime_frog` critters (`0.60×` HP) -> `EndScreen.show_tutorial_complete()` | `3/3  Pick up Multi-Shot` -> `3/3  Link Modifier [Tab]` -> `3/3  Test Multi-Shot (0/5)` | `Mods tab -> Select Multi-Shot -> Click Linked Socket` |

---

## 7. 20-Minute Run Pacing, Drop Economy & Bosses

### Loot Drop Economy (`loot_manager.gd`)
Only **3 collectible types** + **Acorn Treasure Chests** spawn on the meadow floor (`2.6m` pickup radius for Items/Main/Mod, `2.8m` for Chests; no XP shards, hearts, or dust pickups):
- **Regular Critter:** `8.5%` Item (`11.0%` Lucky) · `7.5%` Ability gem (`9.5%` Lucky, `45%` Main / `55%` Modifier).
- **Elite Critter** *(every ~52s)*: `1` Rare (`42%` / `60%` Lucky) or Magic Item · `80%` chance `1` Ability gem · Instant `+18 HP` heal.
- **Acorn Treasure Chest** *(every ~50s, `16–26m` away)*: `1` Rare (`52%` / `72%` Lucky) or Magic Item · `1` Ability gem · Instant `+35 HP` heal + announcement banner.
- **Boss (3 per Run):** `1` Unique Item + `2` Rare Items + `1` Main Ability + `2` Modifier Abilities + Instant `+50 HP` heal.

### Wave Pacing (`enemy_database.gd`, `wave_director.gd`)
Rebalanced `hp_scale` (`1.00× -> 3.60×`) and boss HP (`1250`, `2800`, `5400`) to fit pure behavioral item/link scaling without infinite numerical stat-stick inflation:

| Time Window | Biome Phase | Enemy Pool | Spawn Int | Batch | HP Scale | Dmg Scale | Max Active (Desk / Web) |
|---|---|---|---|---|---|---|---|
| `00:00–02:00` | Sunny Meadow | Frog, Hedgehog | `0.95s` | `2` | `1.00×` | `1.00×` | `42` / `30` |
| `02:00–04:20` | Sunny Meadow | Frog, Hedgehog, Owl-Bat | `0.78s` | `3` | `1.20×` | `1.10×` | `62` / `44` |
| `04:20–07:00` | Sunny Meadow | Hedgehog, Owl-Bat, Boar, Frog | `0.65s` | `3` | `1.45×` | `1.22×` | `80` / `57` |
| `07:00–10:40` | Golden Sunset | Owl-Bat, Boar, Gloom Fox, Hedgehog | `0.56s` | `4` | `1.85×` | `1.42×` | `96` / `69` |
| `10:40–14:00` | Golden Sunset | Boar, Gloom Fox, Bandit, Shroom-Toad | `0.50s` | `4` | `2.35×` | `1.65×` | `112` / `80` |
| `14:00–17:30` | Twilight Grove | Fox, Bandit, Toad, Boar, Owl-Bat | `0.44s` | `5` | `2.95×` | `1.90×` | `124` / `89` |
| `17:30–20:00` | Twilight Finale | Bandit, Toad, Gloom Fox, Boar | `0.40s` | `5` | `3.60×` | `2.20×` | `135` / `97` |

- **Swarm Surges:** `04:00`, `09:30`, `15:30`, and `18:00` (`12` Web / `14` Desktop critters).
- **Scripted Bosses (`enemy_entity.gd`):**
  - `06:30` (**Sir Grizzle**, `1,250 HP`, `24 dmg`) — Honey Slam (`5.4m`) & Dash Charge (`3.4×` spd); spawns `4x` `acorn_boar` <= `50%` HP.
  - `13:00` (**Lady Whiskers**, `2,800 HP`, `30 dmg`) — `7`-way (`9` enraged) projectile fans, `5x` meteor rings, `12`-orb radial volley.
  - `19:30` (**King Bramblehorn**, `5,400 HP`, `38 dmg`) — `12`-way (`16` enraged) spiral volley, `4x` meteors, cross nova, spawns `3x` `gloom_fox` <= `50%` HP.

---

## 8. Art Direction, Icon-First UI & Mobile Support

### Low-Text Storybook Design System (`ui_helper.gd`, `ui_icons.gd`, `poe_socket_widget.gd`)
- **Theme:** 3-tier warm timber (`BG_WOOD_DEEP #1C1412`, `BG_WALNUT #30241C`, `BG_OAK_CARD #3D2E24`, `BG_WELL #17120F`), Enchanted Gold (`#F5C957`), Antiqued Brass (`#947342`), Fredoka 700 headers & Nunito 600/800 body/labels.
- **Title Screen (`title_screen.gd`):** Concise subtitle pill, 4 visual hero cards (`Portrait + Hero Name + Role + Starter Main Ability + Starter Effect chip`), single-line hero tagline + control hint, and dual **`TUTORIAL`** + **`PLAY RUN`** CTAs (auto-collapses to `2×2` grid in portrait).
- **Gameplay HUD (`hud_controller.gd`):** Top XP bar and `Lv.` / `Dust` / passive rows removed. Displays Hero Portrait + Kills + Bosses counter, Center Clock/Biome plaque (swaps cleanly to a gold Tutorial Objective plaque during Tutorial), bottom-left `HP` / `Dash [Charges]` / `Satchel [Tab]` dock, and bottom-center Active Ability bar (icon + short code + colored Modifier pips + cooldown bar).
- **Hero Satchel & Visual Tradeoff Inspector (`inventory_panel.gd`):**
  - **Left (`Active Build`):** Compact vitals (`HP`, `Spd`, `Dash xN`), Active Ability cards with colored Modifier badges, and Global Effect chips (`UiHelper.make_effect_chip`).
  - **Center (`Equipped Gear`):** 6 equipment cards with rarity border, inline Global Effect chips, and interactive `PoESocketWidget` (**Pentagon** = Main Ability, **Round Orb** = Modifier Ability, short badge labels with zero gem-level clutter).
  - **Right (`Items` | `Main` | `Mods` + Portrait `Build`):** Selecting a bag Item shows a **Visual Tradeoff Comparison Card** contrasting `NEW (sockets)` vs `vs EQUIPPED (sockets)` using `+` emerald (gained), `-` crimson (lost), and `=` brass (kept) effect chips alongside `Equip` and `Drop`.

### Engine & Performance Guardrails
- Keep regular enemies as a single merged `ArrayMesh` (`cast_shadow = OFF`).
- Keep Web Retina `scaling_3d_scale` (`0.78` desktop / `0.72` mobile), `MSAA_DISABLED`, `max_active * 0.72` web enemy cap, throttled biome sky updates (`2.5s`), 10 Hz HUD refresh throttle, and `PoESocketWidget._init()` sizing.
- **Glyph Safety:** `Nunito.ttf` lacks Unicode arrows/triangles (`←`, `▲`, `▼`) — use ASCII (`->`, `|`, `+`, `-`) and verified `·`, `•`, `—`.
- **Module Ownership Note:** `scripts/ui/level_up_modal.gd` was removed in `v2.0`; `scripts/systems/tutorial_director.gd` was added.

---

## 9. Development, Verification & Working Notes

### Verification & Build Commands
```bash
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path /Users/normanmahendra/Documents/CardThrone --import
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path /Users/normanmahendra/Documents/CardThrone --script res://tests/verify_game.gd
./scripts/build_all.sh
```

### Change Log
- **`2026-11-24 (v2.0 Revamp):** Replaced XP/leveling, `LevelUpModal`, Passive gems, Heart/Dust ground drops, and Prism Forge crafting with pure behavioral Item Effects & Tradeoffs, strictly 3 ground loot types (`Items`, `Main Abilities`, `Modifier Abilities`) with fixed sockets/links, a 3-beat PoE-style playable Tutorial (`TutorialDirector`), and streamlined icon-first HUD/Title/Satchel (`Tradeoff Comparison Card`). Verified all checks green via headless `tests/verify_game.gd` and rebuilt Web/macOS/Windows/Linux targets.
