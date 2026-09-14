# Sweet Rift

Mobile game: Match-3 + adventure + reconstruction + collection.

## Development rule

**Free-first:** use free/open-source software, assets and services whenever they are suitable. Do not add code merely because it can be written. Prefer existing capabilities, data-driven content and small validated changes.

## Current vertical slice

**Valle Verde** is the first playable region.

Core loop:

1. Play a short Match-3 level.
2. Earn reconstruction resources.
3. Rebuild a damaged part of the settlement.
4. Unlock progression and story.

## Technical direction

- Engine: Godot 4.6
- Android first
- Renderer: GL Compatibility
- Source control/CI: GitHub
- Levels: data-driven JSON
- Gameplay systems: modular GDScript components

## Milestones

- [x] Godot project foundation
- [x] Initial Match-3 prototype
- [x] CI validation workflow
- [x] Data-driven level definition foundation
- [x] Modular board engine foundation
- [ ] Valle Verde presentation screen
- [ ] Level map
- [ ] Objectives and rewards
- [ ] Reconstruction system
- [ ] Save/load
- [ ] First 5 polished levels
- [ ] Android export validation

The first release target is deliberately small: a polished 15–20 level experience before scaling content.
