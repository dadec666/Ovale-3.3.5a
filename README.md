# Ovale Spell Priority (3.3.5a Modernized)

A modernized and optimized version of the **Ovale Spell Priority** addon (v3.3.35) tailored specifically for World of Warcraft: Wrath of the Lich King (Patch 3.3.5a).

---

## Key Features & Improvements

### 1. Performance & Execution Throttling
- **Throttled OnUpdate Loop:** Replaced per-frame heavy tree simulation recalculations with a stable `0.05s` interval ticker, drastically reducing CPU frame-time spikes in 25-man raids.
- **Event-Driven Instant Refreshes:** Forced instant recalculations on critical combat events (`SPELL_UPDATE_COOLDOWN`, `UNIT_SPELLCAST_SENT`, `COMBAT_LOG_EVENT_UNFILTERED`, and target switches).
- **Blizzard API Localization:** Frequently queried global functions (`UnitAura`, `GetTime`, `UnitCastingInfo`, etc.) are upvalued locally to minimize global table lookups.

### 2. Styling & Modern UI Enhancements
- **Masque & LibButtonFacade Support:** Full button element registration (`Icon`, `Cooldown`, `HotKey`, `Count`, `Name`, `Normal`), ensuring seamless skinning with modern button skins.
- **Built-in Pixel-Perfect Skin (Fallback):** 
  - Standard icon margins trimmed with `SetTexCoord(0.08, 0.92, 0.08, 0.92)` to eliminate gray borders.
  - Clean 1px solid black border outline when running without button skinning addons.
  - Stripped default bulky `UI-Quickslot2` overlay.
- **OmniCC / tullaCC Compatibility:** Prevents overlapping text by automatically suppressing built-in numeric timers when an external cooldown addon is detected.
- **Typography:** High-contrast outlined fonts (`OUTLINE`) for hotkeys and cooldown counters.

### 3. Dual Specialization Support
- **Embedded LibDualSpec-1.0:** Seamlessly integrated into `AceDB-3.0` database and profile options.
- Automatically swaps rotation profiles when changing talent specs without requiring an interface reload (`/reload`).

### 4. Localization & Cleanup
- Restored and completed full Russian (`ruRU`) localization.
- Cleaned corrupted character encodings in locale dictionaries.
- Removed deprecated legacy modules (`OvaleSwing`).

---

## Installation

1. Download the latest release or repository zip (**Code** -> **Download ZIP**).
2. Extract the archive into your WoW directory:
   ```text
   World of Warcraft/Interface/AddOns/
