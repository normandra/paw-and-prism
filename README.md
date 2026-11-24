# Paw & Prism

A **Vampire Survivors** clone built in **Godot 4.7.2** (`GL Compatibility`) featuring 3D chibi cute animals, **Diablo-style behavioral item tradeoffs**, **Path of Exile socketed Main & Modifier abilities**, a **playable PoE-style Tutorial**, and a **20-minute 3-boss gauntlet**.

**Play Live on GitHub Pages:** https://normandra.github.io/paw-and-prism/

## Core Design Pillars

- **Zero XP / Leveling Clutter**: No level-up interruptions or plain numerical stat-stick cards. Power and playstyle transformations come purely from what you loot and how you link it.
- **Strictly 3 Ground Loot Types**:
  1. **Items (Relics)**: Drop across 6 gear slots (`Weapon`, `Helmet`, `Armor`, `Boots`, `Amulet`, `Ring`) in `Common`, `Magic`, `Rare`, and `Unique` rarities. Every item rolls fixed PoE sockets/links and grants **Global Behavioral Effects & Tradeoffs** (e.g., *Dash -> Honey Nova*, *Stand Still -> 2x Cast*, *+2 Shots | Short Range*, *Shots Bounce Back*).
  2. **Main Socket Abilities (10)**: Auto-casting active skills (*Acorn Barrage*, *Starlight Orbs*, *Honey Slam*, *Whisker Lightning*, *Petal Cyclone*, *Fireball Berry*, *Frost Nova*, *Boomerang Bone*, *Meteor Pinecone*, *Spirit Bees*).
  3. **Modifier Abilities (10)**: Tag-compatible link mutators (*Multi-Shot*, *Chain Bounce*, *Twin Fork*, *Deep Pierce*, *Homing Seekers*, *Double Echo*, *Giant Blast*, *Blazing Burn*, *Frost Chill*, *Life Siphon*) that alter linked Main Abilities.
- **Playable PoE-Style Tutorial (`TUTORIAL`)**: Start bare-pawed (`0` items, `0` skills), loot & equip your first wand (`Meadow Acorn Wand`), loot & socket your first Main Ability (`Acorn Barrage`), defeat 3 critters, then loot & link your first Modifier (`Multi-Shot`) against 5 critters.
- **3D Chibi Critters & 3 Bosses**: 4 heroes (*Mochi the Shiba*, *Pip the Bunny*, *Bramble the Bear*, *Nori the Cat*) with dynamic 3D hats & weapons fighting through Morning -> Golden Sunset -> Twilight against 7 critter species and 3 scripted bosses (**06:30** *Sir Grizzle*, **13:00** *Lady Whiskers*, **19:30** *King Bramblehorn*).

## Controls

- `WASD` / `Arrow Keys`: Move (Desktop)
- `Space` / `Shift`: Hop-Dash (short i-frames; stacks to 2 charges with *Double Dash* / *Paws of the Comet*)
- `Tab` / `I`: Toggle Hero Satchel (compare item tradeoffs with `+`/`-` effect chips, swap gear safely, insert/remove Main & Modifier abilities)
- `Esc`: Pause / Resume
- `M`: Toggle procedural audio mute
- `F3`: Toggle FPS counter
- **Mobile / Touchscreens** (auto-enabled on phones/tablets, or test on desktop with `?mobile=1`):
  - **Drag anywhere** on the arena: Floating virtual joystick with smooth follow-tether
  - **Tap `DASH`** (bottom-right circular pad): Hop-Dash with radial cooldown arc
  - **Tap `Satchel`**: Manage Relics & Ability links in responsive portrait or landscape layout

## Game Design Document

See [docs/GAME_DESIGN_DOCUMENT.md](docs/GAME_DESIGN_DOCUMENT.md) for the complete living GDD covering behavioral effects, Unique items, ability linking rules, tutorial flow, enemy/boss pacing, UI guidelines, and rework backlogs.

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
