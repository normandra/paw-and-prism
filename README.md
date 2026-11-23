# Paw & Prism

A **Vampire Survivors** clone built in **Godot 4.7.2** (`GL Compatibility`) featuring 3D chibi cute animals, Diablo-style loot drops & gear comparison, Path of Exile socketed Active/Support/Passive skill gems, and a 20-minute 3-boss run.

**Play Live on GitHub Pages:** https://normandra.github.io/paw-and-prism/

## Core Features

- **3D Chibi Cute Animals**: Choose from 4 stylized heroes (*Mochi the Shiba*, *Pip the Bunny*, *Bramble the Bear*, *Nori the Cat*) with dynamic 3D hats & weapons, fighting 7 critter enemy types across a meadow whose lighting shifts from Sunny Morning to Golden Sunset to Starlit Twilight.
- **Diablo-Style Equipment & Loot**: Enemies, elites, Acorn Treasure Chests, and bosses drop `Common`, `Magic`, `Rare`, and `Unique` items across 6 gear slots (`Weapon`, `Helmet`, `Armor`, `Boots`, `Amulet`, `Ring`) with vertical loot beams, side-by-side stat comparisons, and Prism Dust salvaging.
- **Path of Exile Skill & Passive Gems**: Enemies also drop **Active**, **Support**, and **Passive** skill gems (32 total gems). Socket any gem into matching/white gear sockets, link Supports to tag-compatible Active skills, level all socketed gems with XP, and craft sockets/links/colors using Prism Dust.
- **20-Minute Run & 3 Bosses**: Escalating waves, swarm surges, and telegraphed boss encounters at **06:30** (*Sir Grizzle*), **13:00** (*Lady Whiskers*), and **19:30** (*King Bramblehorn*).

## Controls

- `WASD` / `Arrow Keys`: Move (Desktop)
- `Space` / `Shift`: Hop-Dash (brief invulnerability)
- `Tab` / `I`: Open / Close Gear & PoE Gem Socket Board (pauses combat)
- `Esc`: Pause / Resume
- `M`: Toggle procedural audio mute
- `F3`: Toggle FPS counter
- **Mobile / Touchscreens** (auto-enabled on phones/tablets, or test on desktop with `?mobile=1`):
  - **Drag anywhere** on the arena: Floating virtual joystick with smooth follow-tether
  - **Tap `DASH`** (bottom-right circular pad): Hop-Dash with live cooldown ring
  - **Tap `Gear & Gems` / Enchantment Cards**: Manage Diablo gear & PoE gem links cleanly in portrait or landscape

## Game Design Document

See [docs/GAME_DESIGN_DOCUMENT.md](docs/GAME_DESIGN_DOCUMENT.md) for the living GDD covering combat formulas, hero/gem/unique tables, wave pacing, Prism Dust economy, UI/rendering guardrails, and prioritized rework backlogs.

## Development & Building

Requires **Godot 4.7.2** (with export templates installed for `4.7.2.stable`).

- **Run headless verification suite**:
  ```bash
  godot --headless --path . --script res://tests/verify_game.gd
  ```
- **Export Web & Desktop (macOS, Windows, Linux)**:
  ```bash
  ./scripts/build_all.sh
  ```
