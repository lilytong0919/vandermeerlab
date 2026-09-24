# New Ducktrap

This directory contains the in-progress migration of the legacy
`ducktrap.m` interface to a MATLAB app.

## Current scope

The app currently provides:

- An App Designer app based on `matlab.apps.AppBase`.
- Main and spectrogram axes.
- Save, Quit, Spectrogram, and Teleport controls.
- Empty callback entry points for mouse, keyboard, Save, Spectrogram, and
  Teleport interactions.
- A `DucktrapSession` class that owns input and view state.
- A replaceable explicit-axes renderer for LFP, spike trains, and suggested
  interval overlays.
- An external runtime initializer that leaves the binary App Designer layout
  untouched.
- Runtime-bound window-size and segment-teleport controls backed by shared
  action functions.
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

- `DucktrapApp.mlapp`: App Designer UI and thin app integration layer.
- `DucktrapSession.m`: non-graphical data and annotation state.
- `+ducktrapapp/initializeApp.m`: runtime state and display initialization.
- `+ducktrapapp/renderMainDisplay.m`: mock main-display renderer.
- `+ducktrapapp/changeWindowSize.m`: shared window-size action.
- `+ducktrapapp/teleportToSegment.m`: shared segment-navigation action.
- `+ducktrapapp/refreshMainDisplay.m`: main-display synchronization boundary.
- `generateDucktrapMockData.m`: deterministic, side-effect-free mock input generation.
- `demo_DucktrapApp.m`: launches the app with deterministic synthetic data.
- `plotMockData.m`: launches MultiRaster with the same generated inputs.

The legacy implementation remains at
`code-matlab/tasks/Alyssa_Tmaze/beta/ducktrap.m` and is not modified by
this scaffold.
