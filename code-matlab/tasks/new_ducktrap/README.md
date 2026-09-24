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
- A reproducible synthetic-data demonstration entry point.

Navigation, interval selection, saving, panel actions, keyboard shortcuts,
and spectrogram calculation are intentionally not implemented yet.

## Preview

Add this directory to the MATLAB path, then run:

```matlab
app = demo_DucktrapApp();
```

## Files

- `DucktrapApp.mlapp`: App Designer UI and thin app integration layer.
- `DucktrapSession.m`: non-graphical data and annotation state.
- `+ducktrapapp/initializeApp.m`: runtime state and display initialization.
- `+ducktrapapp/renderMainDisplay.m`: mock main-display renderer.
- `demo_DucktrapApp.m`: launches the app with deterministic synthetic data.

The legacy implementation remains at
`code-matlab/tasks/Alyssa_Tmaze/beta/ducktrap.m` and is not modified by
this scaffold.
