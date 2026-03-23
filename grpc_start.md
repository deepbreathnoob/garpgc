# grpc_start.md

# Diablo II – technical system inventory for implementation planning

Source basis: analysis of the following pages:
- Diablo II
- Diablo II Walkthrough
- Act Boss
- Horadric Cube

Goal of this document: provide a technical, implementation-oriented list of systems visible in Diablo II so the list can later be turned into Codex tasks, epics, or work packages.

---

## 1. Product-level gameplay architecture

### 1.1 Core gameplay loop system
**Purpose:** define the repeatable player loop.

**Observed loop:**
- enter town / hub
- prepare build and inventory
- travel to an act location
- clear enemies while exploring connected areas
- complete mandatory or optional quest objectives
- unlock movement shortcuts (waypoints, portals)
- defeat area boss / act boss
- return to town
- sell, store, equip, craft, repeat

**Implementation concerns:**
- state transitions between hub, field, dungeon, boss room
- mission lifecycle state machine
- completion rewards and failure conditions
- restart / rerun support for farming

---

### 1.2 Campaign progression by acts
**Purpose:** structure the game into macro progression chapters.

**Observed structure:**
- 5 acts total
- each act has its own town hub, location set, quest chain, and act boss
- progression is gated by key quest completions and boss kills

**Implementation concerns:**
- act registry and metadata
- per-act content loading
- act unlock dependencies
- transition cutover from one act to next
- support for future difficulty tiers or campaign replays

---

### 1.3 Quest-driven world progression
**Purpose:** drive progression using explicit objectives.

**Observed structure from walkthrough:**
- acts are divided into numbered quests
- quests can be mandatory, optional, or reward-oriented
- quest flow is tied to locations, items, NPCs, and bosses

**Implementation concerns:**
- quest definition schema
- objective types: kill, find, interact, collect, combine, travel
- per-step trigger system
- quest journal state persistence
- reward dispatcher
- quest gating for portals, entrances, bosses, NPC dialog, and act transitions

---

## 2. World navigation and traversal systems

### 2.1 Area graph / zone connectivity system
**Purpose:** connect overworld and dungeon areas into a traversable campaign.

**Observed structure:**
- acts are split into chained areas
- areas lead into sub-areas and dungeons
- player advances by finding exits and special destination rooms

**Implementation concerns:**
- graph-based area definitions
- entrance / exit nodes
- dungeon depth hierarchy
- dynamic area loading / unloading
- spawn tables bound to area and difficulty

---

### 2.2 Waypoint fast-travel system
**Purpose:** let players unlock permanent travel shortcuts.

**Observed structure from walkthrough:**
- waypoints are discovered in specific areas
- once unlocked, they reduce repeat traversal and support farming

**Implementation concerns:**
- per-character unlock flags
- waypoint UI and act grouping
- interaction rules in safe/combat zones
- travel restrictions based on progression state

---

### 2.3 Town Portal / return-trip mobility system
**Purpose:** allow quick temporary return to town and back.

**Observed structure from walkthrough:**
- players use town portal tactics during dangerous or long runs
- portals support recovery, vendor access, and tactical repositioning

**Implementation concerns:**
- temporary bidirectional portal entity
- owner binding and persistence rules
- invalidation conditions
- anti-exploit rules around boss encounters or scripted states

---

### 2.4 Hub town services system
**Purpose:** centralize non-combat services.

**Observed needs:**
- town as safe area between dungeon runs
- NPC-based service interactions are implied by campaign structure and cube progression

**Implementation concerns:**
- non-combat safe zone rules
- service NPC framework
- vendor, stash, quest NPC, crafting-related NPC interactions
- audio/UI state switch between hub and combat zones

---

## 3. Character progression systems

### 3.1 Multi-class character architecture
**Purpose:** support distinct playable classes.

**Observed structure:**
- Diablo II has multiple classes with distinct skill and combat identities

**Implementation concerns:**
- class definition data model
- base stat templates
- class-specific animation/action sets
- class-specific skill trees and equipment restrictions

---

### 3.2 Attribute allocation system
**Purpose:** allow player-driven stat growth.

**Observed structure from walkthrough:**
- build advice explicitly references attribute distribution
- attributes influence combat and item usage indirectly or directly

**Implementation concerns:**
- level-up point grants
- attribute validation rules
- derived stat recalculation pipeline
- UI for allocation and preview
- respec policy definition (if any)

---

### 3.3 Skill progression / specialization system
**Purpose:** enable class build identity.

**Observed structure from walkthrough:**
- skill distribution is a key part of progression
- build planning is central to character identity

**Implementation concerns:**
- skill tree graph structure
- prerequisites and tier unlock rules
- active vs passive skill handling
- skill rank scaling formulas
- hotbar binding and cast execution

---

### 3.4 Experience and level-up system
**Purpose:** provide long-term progression via combat.

**Observed implication:**
- walkthrough and campaign structure assume leveling through repeated combat and quest completion

**Implementation concerns:**
- XP reward calculation by monster, boss, quest
- level curve tuning
- level-up reward pipeline
- anti-powerlevel constraints if desired

---

## 4. Combat systems

### 4.1 Real-time combat interaction system
**Purpose:** provide action-RPG combat.

**Observed structure:**
- player continuously fights enemies while traversing maps
- bosses and elite enemies create pacing spikes

**Implementation concerns:**
- click-to-move or direct movement layer
- target acquisition rules
- melee vs ranged attack execution
- attack cadence, hit timing, recovery frames
- damage event pipeline

---

### 4.2 Damage typing and mitigation system
**Purpose:** support build diversity and encounter variety.

**Observed implication:**
- Diablo II class and item systems imply multiple damage interactions and resist-style balancing

**Implementation concerns:**
- physical and elemental damage channels
- resistance / vulnerability modifiers
- on-hit status effect hooks
- armor and mitigation order of operations

---

### 4.3 Resource usage system
**Purpose:** constrain skill usage and combat rhythm.

**Observed implication:**
- class/skill design requires consumable or regenerating resources

**Implementation concerns:**
- mana/stamina style resource pools
- costs per skill/action
- regen, leech, potion interactions
- failure feedback for insufficient resource

---

### 4.4 Death, recovery, and risk system
**Purpose:** preserve tension during runs.

**Observed implication:**
- town returns and tactical movement imply meaningful survival pressure

**Implementation concerns:**
- player death flow
- corpse/item recovery policy
- respawn location logic
- penalty tuning

---

## 5. Enemy and encounter systems

### 5.1 Enemy archetype framework
**Purpose:** define reusable monster families and behaviors.

**Observed structure:**
- common enemies, stronger named encounters, and act bosses

**Implementation concerns:**
- monster data templates
- AI archetypes: melee rush, ranged, summoner, evasive, tank
- area-based spawn selection
- difficulty scaling by act/area

---

### 5.2 Elite / champion modifier system
**Purpose:** increase encounter variation and spike difficulty.

**Observed implication:**
- Diablo-style gameplay relies on stronger variants beyond normal mobs

**Implementation concerns:**
- affix/modifier pools
- stat multipliers and behavior overrides
- visual readability for dangerous modifiers
- reward multiplier mapping

---

### 5.3 Boss encounter system
**Purpose:** provide scripted progression gates and memorable fights.

**Observed structure from links:**
- one act boss per act
- act bosses receive special reward treatment
- bosses are major progression checkpoints

**Implementation concerns:**
- boss arena definitions
- unique AI state machines
- multi-phase triggers
- intro / defeat sequences
- lock-and-release encounter flow
- enhanced loot table rules

---

### 5.4 Encounter reward bonus rules for bosses
**Purpose:** make major fights materially different from standard kills.

**Observed structure from Act Boss page:**
- act bosses have special bonuses / differentiated reward treatment compared to regular enemies

**Implementation concerns:**
- boss-specific drop classes
- first-kill vs repeat-kill reward handling
- quest boss reward overrides
- anti-farm exploit balancing

---

## 6. Loot and item systems

### 6.1 Item entity system
**Purpose:** represent dropped, stored, equipped, and transformed items.

**Observed implication:**
- item handling is central across combat, quests, and cube recipes

**Implementation concerns:**
- world drop representation
- inventory item serialization
- stackable vs non-stackable items
- metadata for rarity, quality, affixes, sockets, item level, ownership flags

---

### 6.2 Item quality / rarity system
**Purpose:** produce meaningful reward variance.

**Observed implication:**
- Diablo II identity depends on item quality tiers and build-defining loot

**Implementation concerns:**
- rarity roll pipeline
- quality-dependent stat generation
- color coding and UI representation
- drop weighting by monster class and area level

---

### 6.3 Affix generation system
**Purpose:** create variable item stats and replayability.

**Observed implication:**
- magical transformation and gear optimization rely on randomized item properties

**Implementation concerns:**
- prefix/suffix pools
- item-type restrictions
- level gating for affixes
- deterministic seed support for debugging

---

### 6.4 Equipment slot and character paper-doll system
**Purpose:** let players convert loot into build power.

**Observed implication:**
- gearing is a primary progression layer

**Implementation concerns:**
- slot restrictions
- equip validation against class/attributes/level
- recalculation of derived stats
- weapon set handling if desired

---

### 6.5 Loot table and drop resolver system
**Purpose:** determine what enemies and containers drop.

**Observed implication:**
- farming loop depends on reliable but varied reward generation

**Implementation concerns:**
- monster class drop tables
- quest/boss/chest/area drops
- gold, consumable, equipment, quest item categories
- pity rules or pure RNG policy

---

### 6.6 Inventory grid system
**Purpose:** create spatial inventory management.

**Observed implication:**
- cube and item transport both depend on item storage constraints

**Implementation concerns:**
- grid occupancy checks
- variable item footprint sizes
- drag-and-drop movement
- auto-place behavior
- sorting and filtering support

---

### 6.7 Stash / persistent storage system
**Purpose:** store items outside the active run.

**Observed implication:**
- hub-based item management requires persistent storage beyond inventory

**Implementation concerns:**
- stash capacity rules
- serialization and migration
- shared vs character-specific stash policy
- anti-duplication validation

---

## 7. Crafting and transmutation systems

### 7.1 Horadric Cube container system
**Purpose:** provide a dedicated multi-item transmutation container.

**Observed structure from Horadric Cube page:**
- cube is an inventory object and recipe execution device
- it is introduced through campaign progression in Act II
- it is used for both quest-critical combinations and optional item recipes

**Implementation concerns:**
- dedicated container UI
- capacity constraints
- item insertion/removal rules
- transmute action orchestration
- quest-state integration

---

### 7.2 Recipe-based transmutation engine
**Purpose:** convert specific item combinations into outputs.

**Observed structure from Horadric Cube page:**
- cube supports recipes that transform sets of input items into new items
- recipe examples include conversions and random rerolls

**Implementation concerns:**
- recipe database
- pattern matching over item set + item metadata
- deterministic output resolution rules
- recipe eligibility feedback in UI
- input consumption / output generation

---

### 7.3 Quest-item fusion system
**Purpose:** combine key quest items into progression artifacts.

**Observed structure from Horadric Cube page:**
- cube is used to fuse Staff of Kings + Amulet of the Viper into Horadric Staff
- cube is used to assemble Khalim's body parts and flail into Khalim's Will

**Implementation concerns:**
- quest-specific protected recipes
- fail-safe protection against accidental destruction
- recipe unlock tied to quest stage
- downstream gate triggers after successful fusion

---

### 7.4 Item reroll / upgrade recipe subsystem
**Purpose:** add long-term farming sinks and build refinement.

**Observed structure from Horadric Cube page:**
- cube recipes include random conversions such as magic rings to amulets and vice versa

**Implementation concerns:**
- reroll quality restrictions
- character-level and item-level dependencies
- economy balancing to prevent infinite trivial upgrades

---

## 8. Quest item and key-object systems

### 8.1 Quest item lifecycle management
**Purpose:** manage items needed to unlock areas or complete objectives.

**Observed structure:**
- walkthrough and cube pages show quest items collected, transported, and fused into progression keys

**Implementation concerns:**
- quest-item flags
- drop / despawn / transfer restrictions
- interaction with death and stash rules
- duplication prevention

---

### 8.2 World interaction object system
**Purpose:** let players activate shrines, entrances, objects, and special quest devices.

**Observed implication from walkthrough:**
- campaign progression requires finding and interacting with specific world objects

**Implementation concerns:**
- interactable base class
- context-sensitive actions
- locked/unlocked states driven by quests
- minimap / UI discoverability hooks

---

## 9. User interface systems

### 9.1 HUD and combat status UI
**Purpose:** support moment-to-moment combat readability.

**Observed need:**
- ARPG combat requires visible health, resource, hotbar, buffs/debuffs, and target info

**Implementation concerns:**
- low-latency updates
- boss health overlays
- status icon framework
- damage feedback integration

---

### 9.2 Inventory / equipment / cube UI suite
**Purpose:** support high-frequency item interactions.

**Observed need:**
- player repeatedly manages inventory, equipment, stash, and cube inputs

**Implementation concerns:**
- unified item tooltip system
- drag-drop controller
- compare item view
- context actions (equip, move, store, transmute, drop)

---

### 9.3 Quest journal and progression UI
**Purpose:** display current and historical objective state.

**Observed need from walkthrough:**
- chapter-like quest flow benefits from explicit progress visualization

**Implementation concerns:**
- active/completed/failed states
- act grouping
- hint text and destination cues

---

### 9.4 Waypoint and travel UI
**Purpose:** expose unlocked travel nodes.

**Implementation concerns:**
- act tabs
- disabled/enabled waypoint states
- town-only usage or other restrictions

---

## 10. Persistence and meta systems

### 10.1 Character save-state system
**Purpose:** persist all long-term progression.

**Observed need:**
- campaign, itemization, waypoints, and quests all require robust persistence

**Implementation concerns:**
- character stats, skills, quest states, waypoints, inventory, stash, act progression
- save integrity validation
- versioned migration strategy

---

### 10.2 World reset / rerun system
**Purpose:** enable repeat farming without deleting long-term progression.

**Observed implication:**
- walkthrough tactics and boss progression strongly support replaying zones and farming

**Implementation concerns:**
- regenerate enemy populations
- reset local objects and containers
- preserve permanent unlocks while resetting run-state entities

---

## 11. Economy and service systems

### 11.1 Vendor transaction system
**Purpose:** convert unwanted loot into economic value and supplies.

**Observed implication:**
- town loop requires selling, buying, and run preparation

**Implementation concerns:**
- price formulas
- inventory refresh policy
- buyback behavior if desired
- support for consumables, equipment, quest-adjacent services

---

### 11.2 Item identification / reveal system
**Purpose:** create uncertainty and delayed reward reveal.

**Observed implication:**
- Diablo-style loot evaluation benefits from hidden item properties until identified

**Implementation concerns:**
- unidentified item state
- reveal transaction or consumable use
- tooltip transformation after identification

---

### 11.3 Consumable support system
**Purpose:** sustain combat rhythm and dungeon endurance.

**Observed implication:**
- campaign traversal and boss fights require recoverables and utility items

**Implementation concerns:**
- potion categories
- quick-slot usage
- stack handling
- pickup auto-routing rules

---

## 12. Technical decomposition candidates for Codex

Below is a first-pass breakdown suitable for later conversion into implementation tickets.

### Epic A — Campaign Framework
- build act registry and progression graph
- implement quest schema and objective evaluator
- implement area graph and zone transitions
- implement waypoint discovery and fast travel
- implement temporary town portal system

### Epic B — Character and Combat
- implement class definition framework
- implement attributes and derived stats
- implement skill trees and level-up point spending
- implement combat damage pipeline
- implement death/recovery flow

### Epic C — Enemies and Bosses
- implement monster template system
- implement spawn resolver per area
- implement elite modifier system
- implement boss encounter state machine
- implement boss reward override rules

### Epic D — Loot and Inventory
- implement item data model
- implement rarity and affix generation
- implement world drops and pickup flow
- implement grid inventory and equipment slots
- implement stash persistence

### Epic E — Cube and Crafting
- implement Horadric Cube container UI
- implement recipe matching engine
- implement quest fusion recipes
- implement reroll / conversion recipes
- implement transmute feedback and failure handling

### Epic F — UI and Persistence
- implement HUD and status overlays
- implement inventory/equipment/cube/journal interfaces
- implement save/load layer
- implement world reset / farming loop support

---

## 13. Recommended implementation order

1. campaign framework
2. movement/combat foundation
3. enemy archetypes and area spawning
4. item drops and inventory grid
5. quest progression and boss gating
6. waypoint / town portal travel
7. stash and persistence
8. Horadric Cube and recipe engine
9. vendor/economy layer
10. polish, balance, and content expansion

---

## 14. Notes for adaptation into a Godot project

When converting this document into Godot tasks, split each system into:
- data model
- gameplay logic
- UI layer
- save/load integration
- test cases

Recommended directories:
- `systems/quests`
- `systems/combat`
- `systems/items`
- `systems/cube`
- `systems/world`
- `systems/ui`
- `data/acts`
- `data/items`
- `data/recipes`
- `data/monsters`

Recommended ticket template:
- goal
- inputs / outputs
- required scenes/scripts/resources
- edge cases
- done criteria

