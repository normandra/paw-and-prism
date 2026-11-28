# Paw & Prism (`v3.1`)

A **Vampire Survivors + Brotato Arena + Slay-the-Spire Card-Forging & Relic Shop** roguelite built in **Godot 4.7.2** (`GL Compatibility`) featuring **Mochi the Shiba**, **10 Template Ability Cards**, **24 Permanent Add-on Cards**, **12 Passive Relics**, deterministic **3-minute Caravan Shops**, a compact `56×56m` arena with a live **Minimap**, illustrated vector cards, animated anvil forging, a playable **Card-Forging & Shop Tutorial**, and a **20-minute 3-boss gauntlet**.

**Play Live on GitHub Pages:** https://normandra.github.io/paw-and-prism/

## What's New in `v3.1`

- **Deterministic 3-Minute Caravan Shops + Gold Economy:** Critters, Elites, Bosses, and Gold Chests drop **Gold** coins/pouches instead of random card drops. At `03:00`, `06:00`, `09:00`, `12:00`, `15:00`, and `18:00`, all loose Gold magnet-vacuums to Mochi and a **Caravan Shop** opens offering **3 Template Cards**, **4 Add-on Cards**, and **2 Slay-the-Spire Relics** (with Rerolls).
- **12 Slay-the-Spire-Style Relics:** Collect permanent passive artifacts (`Golden Acorn`, `Merchant's Bell`, `Prism Dice`, `Masterwork Anvil`, `Meadow Hourglass`, `Endless Honey Jar`, `Swiftwind Feather`, `Prism Mirror`, `Bramble Collar`, `Clover Magnet`, `Ember Lantern`, `Glacier Compass`).
- **Compact Brotato-Scale Arena + Live Minimap:** Arena resized to `56×56m` (`ArenaBuilder.ARENA_HALF_SIZE = 28.0`) with visible timber perimeter rails and stone lanterns, paired with a live HUD **Minimap** showing terrain, Gold pickups, critters, Elites, Bosses, and Mochi.
- **Self-Explaining Forged Cards & Animated Anvil Forging:** Every forged Template Card lists both the forged Add-on name/count and its full effect text directly on the card (`"Life Siphon — Hits heal Mochi..."`), mobile deck tabs spell out **`Templates`**, and forging triggers a juicy multi-stage **`ForgeAnimationOverlay`** (flying card arc, anvil impact, shockwave rings, and sparks).
- **Build Freedom:** No artificial run prescription — equip and forge as many or as few cards as you want!

## Controls

- `WASD` / `Arrow Keys`: Move (Desktop)
- `Tab` / `I`: Toggle **Card Deck & Forge** (equip/unequip Template Cards, inspect Owned Relics, and forge Add-on Cards onto compatible Templates)
- `Esc`: Pause / Resume (or close Shop / Deck)
- `M`: Toggle procedural audio mute
- `F3`: Toggle FPS counter
- **Mobile / Touchscreens** (auto-enabled on phones/tablets & Android APK, or test on desktop with `?mobile=1`):
  - **Drag anywhere** on the arena: Floating virtual joystick
  - **Swipe vertically** in Shop / Deck / Summary panels: Momentum touch scrolling
  - **Tap `Deck`**: Switch cleanly between `Active | Templates | Add-ons` tabs and tap-to-forge cards

## Documentation on GitHub

- **Cards, Relics & Shop Catalog (`v3.1`):** [docs/ITEMS_AND_SKILLS.md](https://github.com/normandra/paw-and-prism/blob/main/docs/ITEMS_AND_SKILLS.md) — Mochi profile, rarity forge limits, Deck Focus curve, Gold & Shop economy, all 12 Relics, all 10 Template Cards, and all 24 Add-on Cards.
- **Living Game Design Document (`v3.1`):** [docs/GAME_DESIGN_DOCUMENT.md](https://github.com/normandra/paw-and-prism/blob/main/docs/GAME_DESIGN_DOCUMENT.md) — core loop, economy formulas, bosses/waves, and technical architecture.

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
