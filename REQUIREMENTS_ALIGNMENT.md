# Requirements Alignment

This project was reviewed against the scope in `Confirmation.docx`.

## Core Scope Coverage

- First-person FPS gameplay is implemented.
- Enemy AI includes patrol, chase, attack, and death behaviours.
- Score, timer, enemy elimination, and win/lose scene flow are implemented.
- UI includes health, ammo/grenade count, score, timer, and crosshair.
- Two gameplay levels are configured in build settings.

## Alignment Changes Added

- Enemy AI controllers now use an explicit finite state machine:
  - `Idle`
  - `Patrol`
  - `Chase`
  - `Attack`
  - `Dead`
- FSM state is exposed in each controller through `currentStateName` for debugging and presentation.
- Enemy attack logic no longer depends on player keyboard input.
- End-of-level transitions now avoid repeated `Invoke` scheduling.
- Main menu script now includes direct scene-loading methods for cleaner scene flow setup.

## Files Updated For Scope Alignment

- `Assets/game scripts/zombie_enemyController.cs`
- `Assets/game scripts/soldier_enemyController.cs`
- `Assets/game scripts/fly_enemyrobo_controller.cs`
- `Assets/game scripts/main_menu.cs`
- `Assets/game scripts/player_dead_loadscene.cs`
- `Assets/game scripts/player_dead_loadscene2.cs`

## Remaining Submission Tasks

- Open the project in Unity and test both gameplay modes.
- Produce a Windows build from Unity for the final deliverable.
- Capture screenshots/video for the final report and viva.
- Document the FSM diagram in the academic report.
