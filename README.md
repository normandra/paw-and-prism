# Paw & Prism

A **Vampire Survivors** clone built in **Godot 4.7.2** (`GL Compatibility`) featuring 3D chibi cute animals, **Diablo-style behavioral item tradeoffs**, **Path of Exile socketed Main & Modifier abilities**, a **playable PoE-style Tutorial**, and a **20-minute 3-boss gauntlet**.

**Play Live on GitHub Pages:** https://normandra.github.io/paw-and-prism/

## Core Design Pillars

- **Zero XP / Leveling Clutter**: No level-up interruptions or plain numerical stat-stick cards. Power and playstyle transformations come purely from what you loot and how you link it.
- **Strictly 3 Ground Loot Types**:
  1. **Items (Relics)**: Drop across 6 gear slots (`Weapon`, `Helmet`, `Armor`, `Boots`, `Amulet`, `Ring`) in `Common`, `Magic`, `Rare`, and `Unique` rarities. Every item rolls fixed PoE sockets/links and grants **Global Behavioral Effects & Tradeoffs** (e.g., *Moving -> Honey Nova*, *4th Cast -> Burst | Slow*, *Stand Still -> 2x Cast*, *+2 Shots | Short Range*, *Shots Bounce Back*).
  2. **Main Socket Abilities (10)**: Auto-casting active skills (*Acorn Barrage*, *Starlight Orbs*, *Honey Slam*, *Whisker Lightning*, *Petal Cyclone*, *Fireball Berry*, *Frost Nova*, *Boomerang Bone*, *Meteor Pinecone*, *Spirit Bees*).
  3. **Modifier Abilities (10)**: Tag-compatible link mutators (*Multi-Shot*, *Chain Bounce*, *Twin Fork*, *Deep Pierce*, *Homing Seekers*, *Double Echo*, *Giant Blast*, *Blazing Burn*, *Frost Chill*, *Life Siphon*) that alter linked Main Abilities.
- **Playable PoE-Style Tutorial (`TUTORIAL`)**: Start bare-pawed (`0` items, `0` skills), loot & equip your first wand (`Meadow Acorn Wand`), loot & socket your first Main Ability (`Acorn Barrage`), defeat 3 critters, then loot & link your first Modifier (`Multi-Shot`) against 5 critters.
- **Mobile-First Portrait Play & Android APK**: Clean auto-cast movement without Dash clutter, `2.75×` portrait UI scaling on phones, momentum touch scrolling across Satchel/Summary panels (`TouchScrollContainer`), a 4-tab mobile Satchel (`Gear | Items | Skills | Build`), and automated signed ARM64 Android APK releases via GitHub Actions.
- **Balanced Drop Economy & Focus Tax (`v2.2`)**: Spawn-rate-normalized drop formula with dry-streak pity prevents item floods, equipping extra Main Abilities incurs a `+25%` cooldown Focus Tax per extra Main skill, and same-volley repeat hits are dampened (`0.35×`) against `3,000 / 7,000 / 15,000 HP` bosses.
- **3D Chibi Critters & 3 Bosses**: 4 heroes (*Mochi the Shiba*, *Pip the Bunny*, *Bramble the Bear*, *Nori the Cat*) with dynamic 3D hats & weapons fighting through Morning -> Golden Sunset -> Twilight against 7 critter species and 3 scripted bosses (**06:30** *Sir Grizzle*, **13:00** *Lady Whiskers*, **19:30** *King Bramblehorn*).

## Controls

- `WASD` / `Arrow Keys`: Move (Desktop)
- `Tab` / `I`: Toggle Hero Satchel (tap **Equip** directly on any Relic row or compare tradeoffs below, insert/remove Main & Modifier abilities)
- `Esc`: Pause / Resume
- `M`: Toggle procedural audio mute
- `F3`: Toggle FPS counter
- **Mobile / Touchscreens** (auto-enabled on phones/tablets & Android APK, or test on desktop with `?mobile=1`):
  - **Drag anywhere** on the arena: Pure floating virtual joystick (one-handed portrait play; Hop-Dash removed)
  - **Swipe vertically** in Satchel / Summary lists: Native momentum touch scrolling (`TouchScrollContainer`)
  - **Tap `Satchel`**: Manage Relics (one-tap **Equip** + Tradeoff view) & Ability links in 4-tab Portrait mode (`Gear | Items | Skills | Build`) or 3-column Landscape mode

## Game Design Document

See [docs/GAME_DESIGN_DOCUMENT.md](https://github.com/normandra/paw-and-prism/blob/main/docs/GAME_DESIGN_DOCUMENT.md) for the complete `v2.2` living GDD covering behavioral effects, Unique items, ability linking rules, exact drop-rate formulas, maxed single-ability DPS math & enemy HP baselines, tutorial flow, UI guidelines, and rework backlogs.

## Development & Building

Requires **Godot 4.7.2** (`GL Compatibility`, export templates installed for `4.7.2.stable`).

- **Run headless verification suite**:
  ```bash
  godot --headless --path . --import
  godot --headless --path . --script res://tests/verify_game.gd
  ```
- **Export Web & Desktop (macOS, Windows, Linux)**:
  ```bash
  ./scripts/build_all.sh
  ```
- **Stripped Web WASM Build & PWA Deploy**: `.github/workflows/web-release.yml` builds a minimal `web_nothreads_release.zip` using `build/web_custom.py` (LTO + size optimization, unused modules disabled), pairs it with PWA Service Worker caching and `<link rel="preload">`, and deploys to `gh-pages`.
- **Android APK Release**: Signed ARM64 portrait builds (`builds/android/PawAndPrism.apk`, preset `Android` in `export_presets.cfg`) are built and uploaded to GitHub Releases automatically via `.github/workflows/android-release.yml`.
