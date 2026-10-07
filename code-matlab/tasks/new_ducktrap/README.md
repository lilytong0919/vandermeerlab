# New Ducktrap

This directory contains the in-progress migration of the legacy
`ducktrap.m` interface to a MATLAB app.

## Current scope

The app currently provides:

- An R2026b App Designer app stored as the plain-text
  `DucktrapApp.m`/`DucktrapApp.xml` pair.
- Main and spectrogram axes.
- Save, Quit, Spectrogram, and Teleport controls.
- Empty callback entry points for mouse, keyboard, Save, and Spectrogram
  interactions.
- A `DucktrapSession` class that owns input and view state.
- A replaceable explicit-axes renderer for LFP, spike trains, and suggested
  interval overlays.
- App-owned startup, window-size, and suggested-SWR teleport callbacks backed by
  shared private action methods.
- The existing segment spinner numbers the suggested SWRs in `cfg.evt`, and
  the left table lists every suggested SWR interval.
- Changing the segment spinner immediately centers the display on the selected
  suggested SWR.
- The selected SWR is highlighted in the left table; selecting a table row
  teleports to that SWR and updates the segment spinner.
- Teleport centers the display on the selected SWR while preserving the
  exact window width selected by `WindowSizeSpinner`.
- A separate `DucktrapSession` model so app callbacks and future keyboard
  shortcuts can share state transitions without duplicating them.
- A reproducible synthetic-data demonstration entry point.
- A MultiRaster comparison entry point using exactly the same mock dataset.

Interval selection, saving, keyboard shortcuts, and spectrogram calculation
are intentionally not implemented yet.

## Preview

Add this directory to the MATLAB path, then run:

```matlab
app = demo_DucktrapApp();
```

For a legacy MultiRaster navigation baseline using the same data:

```matlab
[h, fig] = plotMockData();
```

## Files

- `DucktrapApp.m`: App Designer callbacks, UI synchronization, and shared
  controller actions.
- `DucktrapApp.xml`: App Designer component tree, grid layout, properties, and
  callback wiring.
- `DucktrapSession.m`: non-graphical data and annotation state.
- `+ducktrapapp/renderMainDisplay.m`: mock main-display renderer.
- `generateDucktrapMockData.m`: deterministic, side-effect-free mock input generation.
- `demo_DucktrapApp.m`: launches the app with deterministic synthetic data.
- `plotMockData.m`: launches MultiRaster with the same generated inputs.

The legacy implementation remains at
`code-matlab/tasks/Alyssa_Tmaze/beta/ducktrap.m` and is not modified by
this scaffold.
