# Paw & Prism — Items, Abilities & Balance Reference (`v2.3`)

> **Live Web Game:** https://normandra.github.io/paw-and-prism/  
> **Full Living GDD:** [docs/GAME_DESIGN_DOCUMENT.md](https://github.com/normandra/paw-and-prism/blob/main/docs/GAME_DESIGN_DOCUMENT.md)  
> **Single Source of Balance Constants:** [scripts/data/balance_config.gd](https://github.com/normandra/paw-and-prism/blob/main/scripts/data/balance_config.gd)

---

## 1. Playable Heroes & Starters

Every hero starts a normal **20-Minute Run** with a **Magic 2-Link Starter Weapon** (`1` Main Ability + `1` open linked Modifier socket + `1` signature Effect) and a **Common Meadow Cap** (`[G, B]` unlinked, `0` effects).  
Hero baseline combat stats (zero leveling or stat-stick scaling): **`0.25 HP/s` regen**, **`8.0%` crit chance**, **`165%` crit multiplier** ($\mathbb{E}[\text{crit}] = 1.052$), **`0.30s` post-hit invulnerability**.

| Hero ID | Name & Title | Max HP | Move Speed | Starter Weapon (`Magic`, `2L`) | Starter Main Ability | Signature Global Effect | Starter Hat |
|---|---|---|---|---|---|---|---|
| `shiba` | **Mochi the Shiba** (*Acorn Ranger*) | `110` | `6.7` | *Mochi's Acorn Wand* (`G=G`) | *Acorn Barrage* (`ACRN`) | `zoomies_on_kill` (*Kills -> Speed Burst*) | `ribbon_hood` |
| `bunny` | **Pip the Bunny** (*Starlight Mage*) | `95` | `7.0` | *Pip's Star Staff* (`B=G`) | *Starlight Orbs* (`STAR`) | `orbit_shield` (*Hit -> Star Shield*) | `wizard_hat` |
| `bear` | **Bramble the Bear** (*Honey Paladin*) | `130` | `6.2` | *Bramble's Honey Hammer* (`R=B`) | *Honey Slam* (`SLAM`) | `stride_honey_nova` (*Moving -> Honey Nova*) | `leaf_crown` |
| `cat` | **Nori the Cat** (*Storm Whisker*) | `100` | `6.9` | *Nori's Spark Claws* (`B=G`) | *Whisker Lightning* (`ZAP`) | `static_sprint` (*Moving -> Zap Sparks*) | `knight_helm` |

---

## 2. Equipment Slots, Rarities & Fixed Sockets

Items drop across **6 equipment slots** and **4 rarities**. Sockets and link gaps are **fixed on drop** (never randomly crafted):

| Slot | Base Relic Names | Max Sockets | Common (`30%` / `10%` Lucky) | Magic (`43%` / `36%` Lucky) | Rare (`22%` / `40%` Lucky) | Unique (`5%` / `14%` Lucky) |
|---|---|---|---|---|---|---|
| **Weapon** | Acorn Wand, Honey Hammer, Starlight Staff, Paw Claws | `4` | `1` eff, `1–2S` (`38%` link, `4%` W) | `2` eff, `2–3S` (`58%` link, `6%` W) | `2` eff, `3–4S` (`76%` link, `10%` W) | *Grand Acorn Scepter* (`4L`) |
| **Helmet** | Sprout Hood, Wizard Hat, Knight Cap, Ribbon Hood | `3` | `1` eff, `1–2S` | `2` eff, `2–3S` | `2` eff, `3S` | *Prismwhisker Crown* (`3L`) |
| **Armor** | Cozy Tunic, Bark Vest, Velvet Cloak | `4` | `1` eff, `1–2S` | `2` eff, `2–3S` | `2` eff, `3–4S` | *Honeycomb Aegis* (`4L`) |
| **Boots** | Paw Slippers, Meadow Boots, Cloud Treads | `3` | `1` eff, `1–2S` | `2` eff, `2–3S` | `2` eff, `3S` | *Paws of the Comet* (`3L`) |
| **Amulet** | Acorn Charm, Bell Pendant, Prism Locket | `2` | `1` eff, `1–2S` | `2` eff, `2S` | `2` eff, `2S` | *Nine-Lives Bell* (`2L`) |
| **Ring** | Clover Ring, Amber Band, Dewdrop Signet | `2` | `1` eff, `1–2S` | `2` eff, `2S` | `2` eff, `2S` | *Starweaver Band* (`2L`) |

- **Socket Colors:** `(R)` Red, `(G)` Green, `(B)` Blue, `(W)` White wildcard (`lucky_clover` adds `+14%` link rate and `+5%` White socket rate).
- **Magic Build Tradeoff Rule:** Magic drops explicitly bias toward pairing 1 upside effect with 1 Tradeoff effect so even blue Relics pose a build decision.

---

## 3. Global Behavioral Effects & Unique Relics

Every non-unique item rolls **1–2 effects** from the `18` Standard/Tradeoff catalog below. None of them are flat `+X%` stat sticks — every effect alters combat behavior or enforces a risk/reward tradeoff.

### Standard & Tradeoff Effects (`18`)

| Effect ID | In-Game Tag | Tradeoff? | Exact `v2.3` Mechanics (`BalanceConfig`) |
|---|---|---|---|
| `stride_honey_nova` | **Moving -> Honey Nova** | No | Every `9.0m` traveled pulses a `3.6m` slowing Honey Nova (`16` dmg) |
| `cadence_burst` | **4th Cast -> Burst \| Slow** | **Yes** | Every `4th` non-orbit cast erupts a `4.0m` burst (`24` dmg), at `1.20×` skill cooldowns |
| `turret_stance` | **Stand Still -> 2x Cast** | **Yes** | Standing still ticks skill cooldowns at `1.75×`; moving ticks at `0.78×` |
| `zoomies_on_kill` | **Kills -> Speed Burst** | No | Kills grant `1.8s` of Zoomies (`1.18×` move speed, `1.15×` cast rate) |
| `edge_ricochet` | **Shots Bounce Back** | No | Non-boomerang projectiles bounce back toward nearest enemy once (`0.85×` lifetime, resets volley hit ID) |
| `short_barrage` | **+2 Shots \| Short Range** | **Yes** | `+2` projectiles/orbiters globally, but projectile lifetime shrinks to `0.52×` |
| `sniper_focus` | **Pierce +2 \| 1 Fast Shot** | **Yes** | Forces `1` projectile per cast, `+2` pierce, `1.50×` projectile speed, `1.42×` damage |
| `giant_slow_aoe` | **Huge AoE \| Slower Cast** | **Yes** | `AoE` & `Orbit` skills gain `1.55×` radius, at `1.35×` longer cooldown |
| `ember_corpse` | **Kills -> Fire Pop** | No | Defeated critters burst a `3.0m` fiery nova (`16` dmg + Burn, `0.25s` global kill-proc ICD) |
| `frost_shatter` | **Chill Kills -> Ice Ring** | No | Chilled kills trigger a `3.6m` icy nova (`16` dmg + Chill, shares `0.25s` kill-proc ICD) |
| `static_sprint` | **Moving -> Zap Sparks** | No | Every `7.5m` traveled zaps up to `2` nearby critters (`14` dmg lightning arcs) |
| `kill_siphon` | **Kills -> Siphon Heal** | No | Restores `+1.2 HP` on kill (`0.80s` ICD -> max `1.50 HP/s` sustained) |
| `thorns_burst` | **Hit -> Bramble Nova** | No | Taking damage triggers a `3.8m` Bramble Nova (`18` dmg, `2.0s` CD) |
| `gravity_slams` | **AoE Pulls Foes In** | No | Player novas, meteors & explosions pull hit enemies inward instead of knocking back |
| `glass_spark` | **Heavy Impact \| Fragile** | **Yes** | Compiled skills deal `1.62×` damage, but hero takes `1.65×` incoming damage |
| `fleet_paws` | **Moving -> Speed Ramp** | No | Continuous movement ramps up to `+16%` move speed over `2.2s` |
| `orbit_shield` | **Hit -> Star Shield** | No | Taking damage spawns `3` orbiting star shields (`2.6m`, `14` dmg) for `3.8s` (`8.5s` CD) |
| `lucky_clover` | **Rarer Loot & Links** | No | Boosts rarity weights (`14%` Unique / `40%` Rare), Drop rates (`1.30×`), link rate (`+14%`), and White sockets (`+5%`) |

### Unique Relics & Exclusive Keystones (`6` Relics, `5` Unique Keystones)

| Unique Item | Slot | Fixed Sockets | Global Effects | Signature Identity |
|---|---|---|---|---|
| **Grand Acorn Scepter** | Weapon | `G=G=B=R` (`4L`) | `nova_barrage` (*All Shots Fire 360 Ring*) + `short_barrage` | Turns projectile casts into short-range 360-degree rings (`>= 6` projectiles) |
| **Prismwhisker Crown** | Helmet | `W=W=W` (`3L`) | `prism_echo` (*Linked Mods Double-Proc*) + `lucky_clover` | Doubles linked Modifier counts (`+2 -> +4`, etc.) & grants Double Echo (`0.80×` per cast) |
| **Honeycomb Aegis** | Armor | `R=R=B=G` (`4L`) | `aegis_freeze` (*Hit -> Freezing Honey Nova*) + `thorns_burst` | Tank armor triggering `4.4m` freezing nova (`22` dmg, `3.0s` CD) + bramble bursts when hit |
| **Paws of the Comet** | Boots | `G=G=B` (`3L`) | `comet_stride` (*Moving -> Bonus Casts*) + `fleet_paws` | Ramps up to `+16%` speed and triggers bonus casts of non-orbit skills (`0.65×` dmg) every `13.5m` traveled |
| **Nine-Lives Bell** | Amulet | `W=B` (`2L`) | `cheat_death` (*Fatal Hit -> Burst Heal*) + `zoomies_on_kill` | Prevents fatal hit (`45%` Max HP heal + `1.4s` i-frames, `105s` CD) + kill Zoomies |
| **Starweaver Band** | Ring | `B=G` (`2L`) | `gravity_slams` (*AoE Pulls Foes In*) + `ember_corpse` | Clusters packs inward into AoE zones and chain-detonates kills |

---

## 4. Main Socket Abilities & Modifier Abilities

### How Ability Linking & Focus Rules Work
1. **Color & Link Matching:** A Main Ability in socket `i` only receives Modifiers inside its **same contiguous linked group** (`===`) whose `Required Tags` intersect the Main Ability's `Tags`.
2. **Multi-Main Focus Tax:** Equipping $N$ Main Abilities multiplies ALL Main skill cooldowns by:
   $$\text{CD}_{\text{focus}}(N) = 1.0 + 0.28 \cdot (N - 1)$$
   - `1` Main = `1.00×` CD · `2` Mains = `1.28×` CD · `3` Mains = `1.56×` CD · `5` Mains = `2.12×` CD.
3. **Same-Volley Shotgun Dampener:** When multiple projectiles from the **same cast volley** (`cast_uid`) strike the same target, the 1st hit deals **`1.00×`** damage and repeat projectiles from that volley deal **`0.30×`**.
4. **Elemental & Leech Rules:** Fire / `mod_ignite` applies `22%` hit DPS Burn for `3.0s` (`max` stack). Cold / `mod_chill` slows enemy movement to `74%` speed for `2.2s`. Life Siphon is capped at `2.5 HP` per proc on a `0.35s` global ICD (`<= 7.14 HP/s`).

### Main Socket Abilities (`10`) — Audited T0 Baseline DPS

All `10` Main Abilities are calibrated via `tests/balance_audit.gd` within `[10, 40]` T0 single-target DPS ($\mathbb{E}[\text{crit}] = 1.052$):

| ID | Name (`Short`) | Color | Tags | Base Dmg | Cooldown | Base Proj / Chains | Area | Audited T0 ST DPS | Combat Behavior |
|---|---|---|---|---|---|---|---|---|---|
| `acorn_barrage` | **Acorn Barrage** (`ACRN`) | `(G)` | `Proj`, `Phys` | `21` | `0.70s` | `1` proj (`spd 22`) | `0.55m` | `31.6` | Accurate high-tempo aimed acorn shots |
| `starlight_orb` | **Starlight Orbs** (`STAR`) | `(B)` | `Spell`, `Orbit`, `AoE` | `16` | `0.58s` | `2` orbs (`r 3.4m`) | `3.4m` | `37.7` | Persistent rotating star blades around hero |
| `honey_slam` | **Honey Slam** (`SLAM`) | `(R)` | `Melee`, `AoE`, `Phys` | `38` | `1.40s` | `1` nova (`99` prc) | `4.0m` | `28.6` | Slowing honey shockwave near nearest critter |
| `whisker_lightning` | **Whisker Lightning** (`ZAP`) | `(B)` | `Spell`, `Chain`, `Light` | `24` | `0.92s` | `1` bolt + `2` chains | `1.0m` | `27.4` | Instant arcing static jumps (`10.5m` chain range) |
| `petal_cyclone` | **Petal Cyclone** (`PETL`) | `(G)` | `AoE`, `Proj`, `Phys` | `14` | `1.15s` | `6` petals (`1` prc) | `0.55m` | `12.8` | 360-degree rotating spiral fan (strong pack clear) |
| `fireball_berry` | **Fireball Berry** (`FIRE`) | `(R)` | `Proj`, `Spell`, `AoE`, `Fire` | `30` | `1.28s` | `1` berry (`spd 18`) | `3.0m` | `31.6` | Explodes on impact (`3.0m` AoE + `22%` Burn DoT) |
| `frost_nova` | **Frost Nova** (`FRST`) | `(B)` | `Spell`, `Proj`, `AoE`, `Cold` | `19` | `1.55s` | `8` shards (`1` prc) | `4.0m` | `12.9` | Chill nova (`0.7×` dmg, slow) + `8` ice shards |
| `boomerang_bone` | **Boomerang Bone** (`BONE`) | `(R)` | `Proj`, `Phys` | `22` | `1.20s` | `1` bone (`99` prc) | `0.75m` | `19.3` | Piercing bone returning to hero |
| `meteor_pine` | **Meteor Pinecone** (`PINE`) | `(R)` | `Spell`, `AoE`, `Fire` | `56` | `2.25s` | `1` meteor (`99` prc) | `4.0m` | `39.1` | Heavy pinecone crash on densest pack + Burn |
| `spirit_bees` | **Spirit Bees** (`BEES`) | `(G)` | `Minion`, `Proj`, `Phys` | `17` | `1.05s` | `2` homing (`spd 16.5`) | `0.55m` | `22.1` | Fast-turning homing bees chasing targets |

### Modifier Abilities (`10`)

| ID | Name (`Short`) | Color | Required Tags | Exact Mutator & Tradeoff |
|---|---|---|---|---|
| `mod_multishot` | **Multi-Shot** (`MULT`) | `(G)` | `Proj` or `Orbit` | `+2` projectiles/orbiters (`+4` w/ Crown) at **`0.78×` dmg per hit** |
| `mod_chain` | **Chain Bounce** (`CHN`) | `(G)` | `Proj` or `Chain` | Bounces `+2` additional targets (`+4` w/ Crown) at **`0.92×` dmg per hit** |
| `mod_fork` | **Twin Fork** (`FORK`) | `(G)` | `Proj` | Splits into `2` angled projectiles on hit (`+1` fork / `+2` w/ Crown) at **`0.90×` dmg** |
| `mod_pierce` | **Deep Pierce** (`PRCE`) | `(G)` | `Proj` | Pierces `+3` targets (`+6` w/ Crown) |
| `mod_homing` | **Homing Seekers** (`HOME`) | `(G)` | `Proj` | Steers toward foes (`1.12×` proj speed) at **`0.95×` dmg** |
| `mod_echo` | **Double Echo** (`ECHO`) | `(B)` | *Any Main* | Delayed repeat cast (`0.16s` later) / `+1` orbiter at **`0.72×` dmg per hit** |
| `mod_nova_area` | **Giant Blast** (`WIDE`) | `(B)` | `AoE` or `Orbit` | Expands AoE/Orbit radius **`1.45×`** (`1.90×` w/ Crown) |
| `mod_ignite` | **Blazing Burn** (`BURN`) | `(R)` | *Any Main* | Applies `22%` hit DPS Burn DoT for `3.0s` |
| `mod_chill` | **Frost Chill** (`CHIL`) | `(B)` | *Any Main* | Applies `2.2s` Chill (`74%` enemy speed; triggers *Frost Shatter*) |
| `mod_leech` | **Life Siphon** (`HEAL`) | `(R)` | *Any Main* | Restores `2.2%` hit damage as HP (`max 2.5 HP/proc`, `0.35s` ICD) |

---

## 5. Quantitative Balance Summary (`balance_audit.gd`)

Verify all combat, sustain, speed, and boss pacing checks locally at any time:
```bash
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --script res://tests/balance_audit.gd
```

- **Focused Single-Ability Ceiling vs. Random Unlinked Spam:**
  - *T1 Early Acorn Sniper (`sniper_focus` + `mod_pierce`):* **`44.8 DPS`** -> **06:30 Sir Grizzle (`2,000 HP`)** = **`44.6s`** fight
  - *T2 Mid Acorn + Prismwhisker Crown:* **`68.1 DPS`** -> **13:00 Lady Whiskers (`4,500 HP`)** = **`66.1s`** fight (`~45–53s` w/ extra Ignite/Comet procs)
  - *T3 Max Acorn Sniper (`sniper_focus` + `glass_spark` + `prism_echo` + `turret_stance` + `mod_ignite`):* **`201.6 DPS`** stationary / **`94.6 DPS`** moving -> **19:30 King Bramblehorn (`9,500 HP`)** = **`47.1s`** stationary peak (**`129.5s`** Solid non-glass build)
  - *T3 Max Spirit Bees (`6` homing bees, `0.30×` shotgun rule):* **`146.9 DPS`** still / **`67.6 DPS`** moving
  - *Random `5`-Main Unlinked Spam (`N = 5`, `Focus CD = 2.12×`):* **`70.3 DPS`** total (loses decisively to focused 4-link builds)
- **Enemy Lethality & Late-Game Pressure (`19:30`, `Bandit Raccoon` = `645 HP`, Elite = `2,451 HP`):**
  - Regular late Bandit deals `39.6 dmg` (**3-shots** `110 HP` Mochi) and runs at `6.66` (**107%** of slowest hero *Bramble*'s `6.2` speed).
  - Boss 3 Cross Slam telegraph deals `93.7 dmg` (**2-shots** standard `110 HP` Mochi, **1-shots** `glass_spark`).
  - Max total sustain across Regen (`0.25`) + Kill Siphon (`1.50`) + Leech (`7.14`) = **`8.89 HP/s`** — facetanking late swarms or Boss slams kills the player quickly.
