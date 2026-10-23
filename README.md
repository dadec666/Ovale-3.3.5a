# Ovale Spell Priority (3.3.5a Modernized)

[![WoW Version](https://img.shields.io/badge/WoW-3.3.5a%20(12340)-blue.svg)](https://github.com/dadec666/ovale-3.3.5a)
[![Release](https://img.shields.io/badge/Release-v3.3.35--modernized--1.0.0-brightgreen.svg)](https://github.com/dadec666/ovale-3.3.5a/releases)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-orange.svg)](LICENSE)

A modernized, heavily optimized, and refactored version of the **Ovale Spell Priority** addon (v3.3.35) designed specifically for World of Warcraft: Wrath of the Lich King (Patch 3.3.5a).

---

## What's New in v3.3.35-modernized-1.0.0

### 1. Performance & Engine Optimizations
- **Throttled Simulation Loop:** Replaced heavy per-frame calculations with a responsive `0.05s` interval ticker, drastically decreasing script execution time and eliminating framerate drops in 25-man raids.
- **Event-Driven Recalculation:** Instant recalculation triggers on core combat events (`SPELL_UPDATE_COOLDOWN`, `UNIT_SPELLCAST_SENT`, `UNIT_SPELLCAST_INTERRUPTED`, `PLAYER_TARGET_CHANGED`, and combat state transitions).
- **Blizzard API Localization:** Frequently called Blizzard functions (`UnitAura`, `GetTime`, `UnitCastingInfo`, etc.) are cached in local upvalues.
- **Garbage Collection (GC) Cleanup:** Removed temporary table churn and unnecessary string allocations within critical combat loops.

### 2. Modern UI & Styling
- **Full Masque Support:** Complete element structure registration (`Icon`, `Cooldown`, `HotKey`, `Count`, `Name`, `Normal`) ensures clean skinning with modern button skins (Zoomed, ElvUI, CleanIcons, Caith, etc.).
- **Standalone Pixel-Perfect Design:** 
  - Standard icon margins trimmed with `SetTexCoord(0.08, 0.92, 0.08, 0.92)` to strip default bulky gray borders.
  - Built-in 1px solid black border outline when running without button skinning addons.
  - Removed outdated default `UI-Quickslot2` textures.
- **OmniCC / tullaCC Guard:** Automatically hides built-in cooldown text when external cooldown counters are active, preventing overlapping fonts.
- **Crisp Typography:** High-contrast outlined fonts (`OUTLINE`) for hotkeys, stacks, and timers.

### 3. Dual Specialization Integration
- **Embedded LibDualSpec-1.0 (v1.3):** Built directly into `embeds.xml` and tied to `OvaleDB`.
- Automatically swaps active rotation profiles when switching talent specs without requiring an interface reload (`/reload`).
- Full Russian localization added to `LibDualSpec-1.0`.

### 4. Overhauled Class Rotations (`defaut/`)
All class rotation scripts have been updated from scratch to match 3.3.5a TrinityCore/AzerothCore mechanics, gear progression, and leveling realities:
- **Leveling vs. Raid Mode Switch:** Every class now includes a quick UI dropdown (`Mode: Raid / Dungeon` vs `Leveling / Solo`).
  - *Raid Mode:* Features strict FCFS/priority queues, tier bonuses (T9/T10), execute tracking, and DoT snapshotting.
  - *Leveling Mode:* Prioritizes fast direct damage, mana conservation, instant procs, and survival tools (e.g., self-healing, spirit taps, Victory Rush).
- **Class-Specific Mechanics:**
  - **Warlock (`Demoniste.lua`):** Decimation execute (<35% HP), Molten Core Incinerate priority, melee-range Shadowflame/Immolation Aura detection, and Glyph of Life Tap tracking.
  - **Death Knight (`Chevalier.lua`):** Unholy disease rolling via Pestilence, Scourge Strike death-rune conversion, Killing Machine 100% crit Frost Strike, Rime free Howling Blast, and leveling Death Strike self-healing.
  - **Paladin (`Paladin.lua`):** Strict FCFS priority, T10 2pc Divine Storm reset detection, <20% Hammer of Wrath priority, Seal of Command vs. Vengeance switching, and Holy Wrath undead/demon targeting.
  - **Warrior (`Guerrier.lua`):** Separated off-GCD rage spenders (Heroic Strike / Cleave) to prevent rage starving, Bloodsurge instant Slam tracking, Taste for Blood Overpower, and Arms/Fury burst timing.
  - **Hunter (`Chasseur.lua`):** Lock and Load DoT clipping prevention, Armor Penetration switch (skipping Arcane Shot at high gear), Viper Aspect mana-recovery automation, and Kill Shot execute.
  - **Mage (`Mage.lua`):** 4x Arcane Blast stack tracking with Missile Barrage dumping, zero-clipping Living Bomb explosion detection, and Hot Streak instant Pyroblasts.
  - **Druid (`Druide.lua`):** Feral Cat energy pooling, Ferocious Bite bite-lock protection, Savage Roar uptime enforcement, and Balance Eclipse-safe casting without clipping Solar/Lunar procs.
  - **Shaman (`Chaman.lua`):** 5x Maelstrom Weapon instant Lightning Bolt / Healing Wave, shared shock cooldown management, and 100% crit Lava Burst under Flame Shock.
  - **Priest (`Pretre.lua`):** Strict 5-stack Shadow Weaving snapshotting for Shadow Word: Pain, Mind Flay channeling protection, and mobile SW:Death usage.
  - **Rogue (`Voleur.lua`):** Assassination energy pooling before Envenom, Hunger for Blood bleed tracking, auto-refreshing Slice and Dice, and anti-clipping Killing Spree execution.

### 5. Localization & Housekeeping
- Fully translated and restored `ruRU` localization.
- Sanitized corrupted legacy character encodings.
- Removed deprecated `OvaleSwing.lua` module.

---

## Installation

1. Download the latest release (`v3.3.35-modernized-1.0.0.zip`) from the [Releases](https://github.com/dadec666/ovale-3.3.5a/releases) tab.
2. Extract the archive into your World of Warcraft directory:
   ```text
   World of Warcraft/Interface/AddOns/
