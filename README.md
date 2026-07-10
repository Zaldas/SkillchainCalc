# SkillchainCalc

**An FFXI addon for HorizonXI (Ashita v4) that calculates skillchain combinations between jobs and weapon types.**

SkillchainCalc provides two dedicated ImGui windows — one tuned for real party play, one for general-purpose planning. Both feed into the same GDI results window, where any result can be clicked to send directly to chat.

> Adjusted for HorizonXI. Minimal support for retail.

<img width="1099" height="539" alt="image" src="https://github.com/user-attachments/assets/203d9b67-0814-4659-995b-052e567ac734" />
  
---

## Party Calculator

Open with `/scc` or `/scc party`.

The Party window reads your live party from memory and lets you calculate skillchains for your actual group. It has two tabs: **Party** and **Settings**.

### Party Tab

**Party section**

- Press **Update Party** to load the current party from game memory. Each member appears with their name, job, subjob, levels, and a weapon type dropdown.
- Casters and support jobs (BLM, WHM, SMN, BRD, RDM) default to disabled — toggle the checkbox next to any member's name to include or exclude them.
- Change any member's weapon type via the dropdown to explore different skillchain options for that combination.
- The local player's weapon is auto-detected from their currently equipped main-hand weapon when loading.
- Press **Clear Party** to reset.

**Filter section**

| Filter | Description |
|--------|-------------|
| **Skillchain** | Limit results by chain family: All, Any Tier 2+, Fragmentation, Fusion, Gravitation, Distortion, or Light / Darkness |
| **REMA** *(Advanced)* | Expand to mark which members have REMA (Relic/Empyrean/Mythic/Aeonic) weapons. Members flagged as REMA will include those weapon skills (marked ²) in the calculation. |
| **Fav WS** *(Advanced)* | Pin a preferred weapon skill per member. A member with a fav WS set contributes only that WS to the calculation; members without one are unrestricted. |

REMA and Fav WS are collapsible panels that are mutually exclusive — opening one closes the other. Both are disabled by default and can be enabled in the **Settings** tab.

Press **Calculate Skillchains** to run the calculation. If party data is stale (member joined, left, changed job, or leveled since the last Update Party), a warning is shown in chat.

### Settings Tab

- **Results Window** — X/Y sliders and a drag checkbox to position the results window on screen.
- **Advanced Filters** — Toggles to globally enable the REMA and Fav WS sections in the Party tab.
- **Local Player** — Declare which weapon types you personally own a REMA weapon for. When you are loaded into the party list, your REMA status is flagged automatically based on your equipped weapon and this configuration.

---

## Calculator

Open with `/scc calc`.

The Calculator window is for general-purpose planning — pick any two jobs (not necessarily your party) and find all viable skillchain combinations. It has three tabs: **Calculator**, **Filters**, and **Settings**.

### Calculator Tab

- Select a job for each side from the dropdown. Primary weapons for that job are pre-selected (highlighted in gold).
- Check or uncheck weapon types to narrow which weapon skills are considered.
- Press **Calculate** to display results, or **Clear** to reset the results window.

**Optional controls** (enabled via the Filters tab):

| Control | What It Does |
|---------|-------------|
| **Subjob** | Adds a `/subjob` dropdown under each job. Useful for jobs that access weapon skills through a subjob (e.g., RNG subjob for Marksmanship). |
| **Fav WS** | Adds a favorite weapon skill dropdown per side. Results are filtered to combos that include the chosen WS on at least one side. |
| **Character Level** | Adds a level selector. Weapon skills requiring more skill than achievable at that level are excluded. |

### Filters Tab

| Filter | Description |
|--------|-------------|
| **Skillchain Element** | Show only skillchains whose burst element matches (e.g., Ice, Fire, Light). |
| **Skillchain Level** | Minimum tier: 1 = all, 2 = Tier 2+, 3 = Tier 3 only. |
| **Custom Character Level** | Enables the level selector in the Calculator tab. |
| **Enable SubJob** | Enables subjob dropdowns in the Calculator tab. |
| **Enable Favorite WS** | Enables the Fav WS dropdowns in the Calculator tab. |
| **Both Directions** | Calculates Job1→Job2 and Job2→Job1. |
| **Show REMA WS (²)** | Includes Relic/Empyrean/Mythic/Aeonic weapon skills. Hidden by default. |

**Set as Defaults** saves the current filter state as your startup defaults. **Reset Filters** reverts to those stored defaults.

### Settings Tab

- **Results Window** — X/Y sliders and a drag checkbox to position the results window. The GUI window itself is draggable by its title bar.
- **Stored Defaults** — A read-only view of currently saved default filter values.

---

## Results Window

The results window appears after any calculation and displays all valid skillchain combinations grouped by chain name and tier.

- Results are laid out in columns when there are many entries. If results exceed the display limit, a notice prompts you to narrow your filters.
- **Click any result** to send it to your current chat channel with the skillchain name formatted using the game's auto-translate system.
- The window is draggable when **Enable Mouse Drag** is checked in Settings. Drag is automatically disabled when a new calculation runs.
- Position is remembered between sessions.

### Weapon Skill Notation

| Marker | Meaning |
|--------|---------|
| ¹ | Quested weapon skill |
| ² | REMA-only weapon skill (Relic/Empyrean/Mythic/Aeonic) |

---

## Commands

| Command | Action |
|---------|--------|
| `/scc` | Toggle the Party Calculator |
| `/scc party` | Toggle the Party Calculator |
| `/scc calc` | Toggle the Calculator |

---

## Advanced Command Line Interface (CLI)

The CLI lets you run calculations directly. The Calculator window opens alongside the results.

Calculations take two **tokens** — one per job. A token describes the job, an optional subjob, and an optional weapon restriction:

```
job[/subjob][:weapon,weapon,...]
```

| Part | Description |
|------|-------------|
| `job` | Any job abbreviation |
| `/subjob` | Optional — adds weapon skills accessible through that subjob |
| `:weapon,...` | Optional — comma-separated list of weapon types to restrict the calculation to |

**Usage:**

```
/scc <token1> <token2> [options]
```

> Options not specified in the command fall back to your saved filter defaults (set via **Set as Defaults** in the Calculator's Filters tab); any option specified overrides the default for that run.

**Options:**

| Option | Format | Description |
|--------|--------|-------------|
| Tier filter | `1` / `2` / `3` | Minimum skillchain tier to include |
| Both directions | `both` | Calculate both Job1→Job2 and Job2→Job1 |
| Element filter | `sc:<element>` | Limit results to a specific burst element |
| Level cap | `lvl:<n>` or `level:<n>` | Exclude weapon skills above the skill cap for level n |

**Examples:**

| Command | What it does |
|---------|-------------|
| `/scc war mnk` | All skillchains between WAR and MNK using their default weapons |
| `/scc thf:sword war` | THF restricted to Sword only (non-default weapon), WAR unrestricted |
| `/scc sam/rng nin` | SAM with RNG subjob — pulls in Archery/Marksmanship weapon skills via subjob |
| `/scc war mnk 2 both` | Tier 2+ only, both directions |
| `/scc sam drk lvl:66 sc:distortion` | Level-capped at 66, results filtered to Distortion burst |

---

## Files

| File | Purpose |
|------|---------|
| `SkillchainCalc.lua` | Main addon, command handling, event wiring |
| `SkillchainParty.lua` | Party window UI and party data logic |
| `SkillchainGui.lua` | Calculator window UI |
| `SkillchainUI.lua` | Shared ImGui helpers (styled buttons, gradient headers, window scaffolding) |
| `SkillchainCore.lua` | Filtering, skillchain calculation, party pair logic |
| `SkillchainRenderer.lua` | GDI results window rendering |
| `Skills.lua` | Weapon skill data, properties, and colors |
| `Jobs.lua` | Job skill caps and primary weapon lists |
| `JobIds.lua` | Numeric Ashita job ID -> job key map, shared by both the Horizon and retail builds |
| `SkillRanks.lua` | Skill rank progression tables (A+, A−, B+, etc.) |
| `Autotranslate.lua` | Auto-translate formatting for chat output |
| `retail/` | Data variants (`Jobs.lua`, `Skills.lua`) swapped in for the retail release build |
