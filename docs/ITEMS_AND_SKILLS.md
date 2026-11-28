# Paw & Prism `v3.0` — Cards & Forging Catalog

> **Single-Hero Card-Forging Core (`v3.0`)** — All values below reflect `scripts/data/hero_database.gd`, `scripts/data/card_database.gd`, `scripts/data/balance_config.gd`, `scripts/data/enemy_database.gd`, and automated verification in `tests/balance_audit.gd`.  
> **Living GDD:** [GAME_DESIGN_DOCUMENT.md](https://github.com/normandra/paw-and-prism/blob/main/docs/GAME_DESIGN_DOCUMENT.md) · **Play Live:** https://normandra.github.io/paw-and-prism/

---

## 1. Playable Hero (`HeroDatabase`)

Paw & Prism `v3.0` streamlines gameplay around one focused mascot hero with fixed baseline survivability and movement speed:

| Hero | Title | HP | Speed | Regen | Crit | Hit i-Frames | Starter Card |
|---|---|---|---|---|---|---|---|
| **Mochi the Shiba** (`shiba`) | Acorn Forgemaster | `110` | `6.7` | `0.25 HP/s` | `8.0%` (`165%`, `E[crit] = 1.052`) | `0.30s` | **Acorn Barrage** (`Uncommon`, `0/2` Forges) |

---

## 2. Core Card & Forging Rules

1. **Cards Only:** Items, gear slots, gems, and socket linking are replaced by a unified Slay-the-Spire-inspired Card system (`CardWidget`).
2. **Unlimited Active Deck + Focus Scaling (`BalanceConfig.compute_deck_cd_mult`):** You can equip as many **Template Cards** as you want, with active cooldowns scaled by deck size so **~3 well-forged cards** are the strategic endgame sweet spot:

| Equipped Template Cards | Cooldown Multiplier | Effective Cast Rate | Strategic Feel |
|---|---|---|---|
| `1 Card` | `1.00×` | `100%` | Hyper-focused single card |
| `2 Cards` | `1.12×` | `89%` | Clean early/mid duo |
| `3 Cards` *(Sweet Spot)* | `1.25×` | `80%` | Ideal 20-min forged trio |
| `4 Cards` | `1.60×` | `63%` | Light spread tax |
| `5 Cards` | `1.95×` | `51%` | Noticeable dilution |
| `6 Cards` | `2.30×` | `43%` | Heavy deck bloat (`3 Forged + 3 Raw` deals less DPS than `3 Forged`) |

3. **Rarity Forge Limits (`GameEnums.rarity_forge_limit`):** Higher-rarity Template Cards hold more permanent Add-on Forges:

| Template Rarity | Forge Capacity | Drop Tendency Across 20-Min Run |
|---|---|---|
| **Common** | `1` Forge | Common early (`50%` at `00:00` -> `14%` at `20:00`) |
| **Uncommon** | `2` Forges | Steady mid-run backbone (`36%` -> `34%`); Starter Acorn Barrage starts Uncommon (`0/2`) |
| **Rare** | `3` Forges | Mid/late upgrade & Chest drops (`12%` -> `36%`) |
| **Legendary** | `4` Forges | Guaranteed on Boss kills + rare late-wave drops (`2%` -> `16%`) |

4. **Permanent Consumption & Stacking:** Forging an **Add-on Card** permanently bakes its effect onto the chosen Template Card and **consumes** that Add-on Card. Duplicate Add-ons **can stack** on the same Template Card cleanly (with diminishing/multiplicative balance rules).

---

## 3. Template Cards (10 Active Abilities)

Audited at **T0 Baseline** (Common, `0` forges, `1` equipped card, `E[crit] = 1.052`):

| ID | Template Card | Category | Tags | Base Dmg | Base CD | Projectiles / Chains / Area | Audited T0 ST DPS | Description |
|---|---|---|---|---:|---:|---|---:|---|
| `acorn_barrage` | **Acorn Barrage** | Attack | `Projectile, Physical` | `21` | `0.70s` | `1` proj, spd `22.0` | **31.6** | Fires an aimed woodland acorn at the nearest critter. |
| `starlight_orb` | **Starlight Orbs** | Spell | `Spell, Orbit, AoE` | `16` | `0.58s` | `2` orbs, orbit `3.4m` (`0.30×` repeat) | **37.7** | Summons orbiting star blades that slice nearby foes. |
| `honey_slam` | **Honey Slam** | Attack | `Melee, AoE, Physical` | `38` | `1.40s` | `4.0m` slam radius (slows) | **28.6** | Smashes a sticky honey shockwave that slows critters. |
| `whisker_lightning` | **Whisker Lightning** | Spell | `Spell, Chain, Lightning` | `24` | `0.92s` | `1` bolt + `2` chains | **27.4** | Strikes with crackling static that arcs across critters. |
| `petal_cyclone` | **Petal Cyclone** | Attack | `AoE, Projectile, Physical` | `14` | `1.15s` | `6` petals, pierce `1` | **12.8** *(x6 AoE)* | Whirls out 6 piercing blossom petals in a spiral. |
| `fireball_berry` | **Fireball Berry** | Spell | `Projectile, Spell, AoE, Fire` | `30` | `1.28s` | `3.0m` blast + `22%` Burn | **31.6** | Launches an ember berry that detonates & burns. |
| `frost_nova` | **Frost Nova** | Spell | `Spell, Projectile, AoE, Cold` | `19` | `1.55s` | `4.0m` chill ring + `8` icicles (`1` pierce) | **12.9** *(+shards)* | Shatters a chilling frost ring + 8 outward icicles. |
| `boomerang_bone` | **Boomerang Bone** | Attack | `Projectile, Physical` | `22` | `1.20s` | `1` bone, pierce `99`, returns | **19.3** | Hurls a spinning bone that returns right to Mochi. |
| `meteor_pine` | **Meteor Pinecone** | Spell | `Spell, AoE, Fire` | `56` | `2.25s` | `4.0m` cluster meteor + `22%` Burn | **39.1** | Calls a blazing pinecone crash onto dense packs. |
| `spirit_bees` | **Spirit Bees** | Attack | `Minion, Projectile, Physical` | `17` | `1.05s` | `2` homing bees (`0.30×` repeat) | **22.1** | Releases homing spirit bees that chase targets. |

> **Shotgun Dampening Rule:** Multiple projectiles/orbs from the same cast volley hitting the same enemy deal `1.00×` on the first hit and `0.30×` (`VOLLEY_REPEAT_MULT`) on repeat hits from that same volley.

---

## 4. Add-on Cards (24 Permanent Forge Upgrades)

### A. Core Skill Modifiers (10)

| ID | Add-on Card | Rarity | Category | Applies To | Permanent Effect & Stacking |
|---|---|---|---|---|---|
| `addon_multishot` | **Multi-Shot** | `Uncommon` | Attack | `Projectile` / `Orbit` | `+2` projectiles (or `+2` orbs) per stack; hit dmg `× 0.78^k`. |
| `addon_chain` | **Chain Bounce** | `Uncommon` | Spell | `Projectile` / `Chain` | `+2` chain arcs per stack; hit dmg `× 0.92^k`. |
| `addon_fork` | **Twin Fork** | `Uncommon` | Attack | `Projectile` | Splits into 2 angled shots on hit (up to `2` gens); hit dmg `× 0.90^k`. |
| `addon_pierce` | **Deep Pierce** | `Common` | Attack | `Projectile` | Projectiles pierce `+3` extra critters per stack. |
| `addon_homing` | **Homing Seekers** | `Common` | Utility | `Projectile` | Shots steer toward critters (`+15%` speed/stack); hit dmg `× 0.95^k`. |
| `addon_echo` | **Double Echo** | `Rare` | Spell | `Any Template` | `+1` delayed repeat cast after `0.16s` (or `+1` orb) per stack; hit dmg `× 0.74^k`. |
| `addon_giant_blast` | **Giant Blast** | `Uncommon` | Spell | `AoE` / `Orbit` | Increases explosion, slam, or orbit radius by `+45%` per stack (`1.0 + 0.45*k`). |
| `addon_ignite` | **Blazing Burn** | `Common` | Spell | `Any Template` | Hits ignite critters for `22%` DPS fire burn over `3.0s` (`+15%` burn/stack). |
| `addon_chill` | **Frost Chill** | `Common` | Spell | `Any Template` | Hits chill critters, slowing speed to `74%` for `2.2s`. |
| `addon_leech` | **Life Siphon** | `Uncommon` | Utility | `Any Template` | Hits heal `2.2%` dmg (`+1.2%`/stack), capped at `2.5 HP/proc`, `0.35s` ICD (max `7.14 HP/s`). |

### B. Behavioral & Tradeoff Add-ons (10)

| ID | Add-on Card | Rarity | Category | Applies To | Permanent Effect & Stacking |
|---|---|---|---|---|---|
| `addon_sniper_focus` | **Sniper Focus** | `Rare` | Keystone | `Projectile` | Forces `1` fast piercing bolt (`+50%` spd, `+2` pierce/stack, `×1.42` 1st / `×1.25` per extra stack dmg). |
| `addon_short_barrage` | **Short Barrage** | `Uncommon` | Keystone | `Projectile` / `Orbit` | `+2` projectiles per stack, but halves range (`0.52^k` lifetime, floor `0.30×`). |
| `addon_glass_spark` | **Glass Spark** | `Rare` | Keystone | `Any Template` | `+52%` card dmg per stack, but Mochi takes `+35%` incoming dmg per total stack across deck (cap `2.40×`). |
| `addon_ember_corpse` | **Ember Corpse** | `Uncommon` | Spell | `Any Template` | Slain critters erupt for `16` (`+6`/stack) fire AoE dmg in `3.0m` (`0.25s` ICD). |
| `addon_frost_shatter` | **Frost Shatter** | `Uncommon` | Spell | `Any Template` | Chilled kills burst for `16` (`+6`/stack) frost AoE dmg in `3.6m` (`0.25s` ICD). |
| `addon_gravity_pull` | **Gravity Slam** | `Uncommon` | Utility | `AoE` | AoE blasts pull critters inward (`+15%` radius per extra stack). |
| `addon_ricochet` | **Edge Ricochet** | `Uncommon` | Utility | `Projectile` | Shots bounce back once toward nearest critter at arena edges (`+12%` spd/extra stack). |
| `addon_nova_ring` | **Nova Barrage** | `Legendary` | Keystone | `Projectile` | Fires all shots in a `360°` ring (`min 6`, `+2`/stack). |
| `addon_cadence_burst` | **Cadence Burst** | `Rare` | Keystone | `Any Template` | Every 4th cast triggers a `24` (`+10`/stack) shockwave (`4.0m`), but `+20%` cooldown per stack. |
| `addon_overclock` | **Turret Overclock** | `Rare` | Keystone | `Any Template` | Standing still casts `1.65×` (`+0.25×`/stack) faster; moving casts at `0.80×`. |

### C. Utility & Defense Add-ons (4)

| ID | Add-on Card | Rarity | Category | Applies To | Permanent Effect & Stacking |
|---|---|---|---|---|---|
| `addon_zoomies` | **Zoomies Frenzy** | `Common` | Utility | `Any Template` | Kills grant `+18%` move speed & `+15%` cast rate (`+6%/+5%`/stack) for `1.8s`. |
| `addon_thorns` | **Bramble Thorns** | `Uncommon` | Utility | `Any Template` | Taking a hit blasts a `18` (`+8`/stack) bramble AoE in `3.8m` (`2.0s` CD). |
| `addon_orbit_shield` | **Star Shield** | `Rare` | Utility | `Any Template` | Taking a hit summons 3 orbiting guard stars for `3.8s` (`14 + 5`/stack dmg, `8.5s` CD). |
| `addon_nine_lives` | **Nine-Lives Bell** | `Legendary` | Keystone | `Any Template` | Cheats a fatal hit: heals `45%` Max HP + `1.4s` invuln (`105s` CD, `-20s`/stack, min `30s`). |

---

## 5. Automated Balance Benchmarks (`tests/balance_audit.gd`)

Verified directly from `godot --headless --path . --script res://tests/balance_audit.gd`:

- **3-Card Well-Forged Endgame Deck** (*Legendary 4/4 Acorn Sniper + Rare 3/3 Meteor + Rare 3/3 Whisker Lightning*, `1.25×` Focus CD):
  - **199.0 DPS** standing still (`Overclock`), **125.3 DPS** moving
- **1-Card Legendary Hyper-Forge** (*4/4 Acorn Sniper*): **166.3 DPS** still / **80.7 DPS** moving
- **3-Forged + 3-Raw Bloat (`6` Cards, `2.30×` CD):** **92.4 DPS** moving (strictly weaker than trimmed 3-card deck!)
- **6-Card Unforged Random Spam (`6` Cards, `2.30×` CD):** **67.1 DPS** total (`3×` weaker than forged trio)
- **Boss TTKs:** `06:30` *Sir Grizzle* (`2,000 HP`) @ T1 = **`33.9s`** · `13:00` *Lady Whiskers* (`4,500 HP`) @ T2 = **`51.5s`** · `19:30` *King Bramblehorn* (`9,500 HP`) @ 3-Card = **`47.7s` Still / `75.8s` Move**
- **Lethality & Speed (`19:30`):** Regular *Bandit Guard* (`645 HP`, `39.6` dmg, `6.66` spd = `99%` of Mochi's `6.7`) downs Mochi in `3` hits; *King Bramblehorn* Cross Slam (`93.7` dmg) `2`-shots normal Mochi and `1`-shots *Glass Spark* Mochi. Max capped sustain = `7.39 HP/s`.
