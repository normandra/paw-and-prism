# Paw & Prism (`v3.0`)

A **Vampire Survivors + Slay-the-Spire Card-Forging** action roguelite built in **Godot 4.7.2** (`GL Compatibility`) featuring **Mochi the Shiba**, **10 Template Ability Cards**, **24 Permanent Add-on Cards**, illustrated vector card UI, a **playable Card-Forging Tutorial**, and a **20-minute 3-boss gauntlet**.

**Play Live on GitHub Pages:** https://normandra.github.io/paw-and-prism/

## Core Design Pillars (`v3.0`)

- **Streamlined Single Hero:** Focused entirely on **Mochi the Shiba** (*Acorn Forgemaster* — `110 HP`, `6.7` speed), starting runs with an **Uncommon Acorn Barrage** (`0/2` Forges).
- **Slay-the-Spire Card Deck & Forge System:** Gear slots, gems, and socket puzzles are unified into a single **Card System** with custom `160x120` SVG artwork, live `DMG · CD` readouts, rarity borders, and forge pips:
  1. **10 Template Cards** *(Auto-Cast Abilities)*: Equip as many as you want into your Active Deck (`1.00×` CD at 1 card -> `1.25×` sweet spot at 3 cards -> steeper cooldown tax for bloat beyond 3), encouraging **~3 well-forged endgame cards**.
  2. **24 Add-on Cards** *(Permanent Forge Upgrades)*: Forging an Add-on onto a compatible Template Card **consumes** the Add-on and permanently upgrades the Template Card. Duplicate Add-ons stack cleanly!
  3. **Rarity Forge Limits:** Template capacity scales with rarity — **Common `1` / Uncommon `2` / Rare `3` / Legendary `4`** forges.
- **Playable Card-Forging Tutorial (`TUTORIAL`):** Start bare-pawed (`0` cards), loot & equip `Acorn Barrage`, clear 3 critters, then loot & forge `Multi-Shot` onto `Acorn Barrage` (`1/2`) against 5 critters.
- **Mobile-First Portrait Play & Android APK:** Clean one-handed virtual joystick without Dash clutter, responsive portrait scaling, momentum `TouchScrollContainer` scrolling across Card grids, and signed ARM64 Android APK releases via GitHub Actions.
- **Quantitative Balance Audit (`balance_config.gd` + `balance_audit.gd`):** Single-source-of-truth tuning verified headless against T0 DPS bounds, `3-Card Forged` vs `6-Card Bloat` comparisons, Boss 1/2/3 TTKs (`06:30` *Sir Grizzle*, `13:00` *Lady Whiskers*, `19:30` *King Bramblehorn*), lethality hits-to-die, and spawn-normalized drop rates.

## Controls

- `WASD` / `Arrow Keys`: Move (Desktop)
- `Tab` / `I`: Toggle **Card Deck & Forge** (equip/unequip Template Cards, tap `Forge onto Card` on Add-ons to permanently forge them onto compatible Templates)
- `Esc`: Pause / Resume
- `M`: Toggle procedural audio mute
- `F3`: Toggle FPS counter
- **Mobile / Touchscreens** (auto-enabled on phones/tablets & Android APK, or test on desktop with `?mobile=1`):
  - **Drag anywhere** on the arena: Floating virtual joystick
  - **Swipe vertically** in Deck / Summary panels: Momentum touch scrolling
  - **Tap `Deck`**: Switch between `Active | Tpl | Add-on` tabs and tap-to-forge cards cleanly

## Documentation on GitHub

- **Cards & Forging Catalog (`v3.0`):** [docs/ITEMS_AND_SKILLS.md](https://github.com/normandra/paw-and-prism/blob/main/docs/ITEMS_AND_SKILLS.md) — Mochi profile, rarity forge limits, Deck Focus curve, all 10 Template Cards, all 24 Add-on Cards, and audited benchmarks.
- **Living Game Design Document (`v3.0`):** [docs/GAME_DESIGN_DOCUMENT.md](https://github.com/normandra/paw-and-prism/blob/main/docs/GAME_DESIGN_DOCUMENT.md) — core loop, economy formulas, bosses/waves, and technical architecture.

## Development & Building

Requires **Godot 4.7.2** (`GL Compatibility`, export templates installed for `4.7.2.stable`).

- **Run headless verification & balance audit suites:**
  ```bash
  godot --headless --path . --import
  godot --headless --path . --script res://tests/verify_game.gd
  godot --headless --path . --script res://tests/balance_audit.gd
  ```
- **Export Web & Desktop (macOS, Windows, Linux):**
  ```bash
  ./scripts/build_all.sh
  ```
- **Stripped Web WASM Build & PWA Deploy:** `.github/workflows/web-release.yml` runs `verify_game.gd` + `balance_audit.gd`, builds with cached `web_nothreads_release.zip` (`build/web_custom.py`), and deploys to `gh-pages`.
- **Android APK Release:** Signed ARM64 portrait builds (`builds/android/PawAndPrism.apk`, preset `Android` in `export_presets.cfg`) are built and uploaded to GitHub Releases via `.github/workflows/android-release.yml`.
