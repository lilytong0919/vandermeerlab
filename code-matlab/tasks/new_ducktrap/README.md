# New Ducktrap

This directory contains the in-progress migration of the legacy
`ducktrap.m` interface to a MATLAB app.

## Current scope

The app currently provides:

- An R2026b App Designer app stored as the plain-text
  `DucktrapApp.m`/`DucktrapApp.xml` pair.
- Main and spectrogram axes.
- Save, Save & Quit, Spectrogram, and Teleport controls. Save & Quit closes only
  after a successful save; canceling or failing to save leaves the app open.
- Explicit boundary mode entered with Set Boundaries or unmodified S.
  A faint cursor line and main plot title show the state. Two left clicks set
  boundaries; right click confirms the interval and returns to viewing mode.
  S clears pending boundaries and restarts setting; Q exits without confirming.
  The toggle button can also exit. Overlap
  cancellation keeps the pending boundaries. S is ignored in editable controls.
- Boundary entry clears event selection. Event table/spinner/Teleport, Save,
  Save & Quit, and spectrogram controls are disabled until exit; window sizing
  stays available. Mode-dependent availability is centralized in
  `synchronizeInteractionState`, and keyboard dispatch is separate for each mode.
- In viewing mode, left click inside an event selects it without teleporting;
  left click outside events clears selection. Right click deletes the selected
  event after confirmation. Selected events
  are shaded green and all other events yellow, regardless of confirmation.
  Delete/Backspace is disabled in boundary mode.
- Confirmation dialogs before replacing overlapping events or right-click
  deletion. Enter, Delete, and Backspace have no interval action.
- Save exports every remaining table event as `evt` in a MAT file, including
  channel label, header, and configuration history; quitting warns about edits
  that have not been saved.
- A `DucktrapSession` class that owns input and view state.
- A replaceable explicit-axes renderer for LFP, spike trains, and suggested
  interval overlays.
- App-owned startup, window-size, and suggested-SWR teleport callbacks backed by
  shared private action methods.
- The existing segment spinner numbers the suggested SWRs in `cfg.evt`, and
  the left table lists every suggested SWR interval.
- Changing the segment spinner immediately centers the display on the selected
  suggested SWR.
- Viewing-mode A/D navigate to the previous/next event relative to the window
  center. Shift+A/D jump 10 events; Ctrl+A/D jump 50, using the nearest event as
  the starting index. Shift takes priority if both modifiers are pressed.
  Jumps clamp at the first/last event and preserve the displayed width. F/C/L
  remain unassigned. H opens shortcut help in either mode.
- The selected SWR is highlighted in the left table; selecting a table row
  teleports to that SWR and updates the segment spinner.
- Mouse-wheel scrolling over the main axes shifts time by 20% of the window
  width (down: later, up: earlier), bounded by the recording. Selection persists
  even off-screen; Teleport returns to the spinner's selected event. Scrolling
  preserves pending boundaries and boundary mode when active.
- Ctrl+scroll temporarily zooms the time axis (up: in, down: out) without changing
  the Window Size setting. Ordinary scrolling uses the currently displayed span.
  R restores Window Size around the current center. Space centers the selected
  event in viewing mode without changing zoom. In boundary mode, Space centers
  one pending boundary or the midpoint of two; with none it does nothing.
  Pan, zoom, reset, and boundary centering preserve pending bounds and event data.
- Teleport centers the display on the selected SWR while preserving the current
  displayed width; R independently resets temporary zoom.
- A separate `DucktrapSession` model so app callbacks and future keyboard
  shortcuts can share state transitions without duplicating them.
- A reproducible synthetic-data demonstration entry point.
- A MultiRaster comparison entry point using exactly the same mock dataset.

Spectrogram calculation and additional keyboard navigation remain deferred.

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
