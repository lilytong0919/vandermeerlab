# New Ducktrap

This directory contains the initial scaffold for migrating the legacy
`ducktrap.m` interface to a MATLAB app.

## Current scope

The scaffold currently provides:

- A programmatic MATLAB app based on `matlab.apps.AppBase`.
- Main and spectrogram axes.
- Save, Quit, Spectrogram, and Teleport controls.
- Empty callback entry points for mouse, keyboard, Save, Spectrogram, and
  Teleport interactions.
- A placeholder `DucktrapSession` state class.
- A demonstration entry point that opens the empty interface.

Only the app-closing behavior is active. Data loading, synthetic data,
plotting, navigation, interval selection, session-state transitions, saving,
and spectrogram calculation are intentionally not implemented.

## Preview

Add this directory to the MATLAB path, then run:

```matlab
app = demo_DucktrapApp();
```

## Files

- `DucktrapApp.m`: UI layout and callback scaffold.
- `DucktrapSession.m`: placeholder for non-graphical annotation state.
- `demo_DucktrapApp.m`: opens the interface without loading data.

The legacy implementation remains at
`code-matlab/tasks/Alyssa_Tmaze/beta/ducktrap.m` and is not modified by
this scaffold.
