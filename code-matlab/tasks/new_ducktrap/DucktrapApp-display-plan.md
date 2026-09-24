# DucktrapApp mock-display implementation

- Architecture: App Designer UIFigure explorer with external, explicit-axes rendering helpers.
- Serialization: existing binary `DucktrapApp.mlapp`; edit surgically through `AppDesignerAgentInterface`.
- Scope: initialize app data, show the first LFP window, overlay suggested intervals, and draw a simple spike raster.
- Deferred: spectrogram calculation, display controls, interval editing, navigation actions, and keyboard shortcuts.

## File organization

- `DucktrapApp.mlapp`: unchanged layout and callback scaffold; treated as a frozen view for this branch.
- `DucktrapSession.m`: non-graphical input and view state.
- `+ducktrapapp/initializeApp.m`: attaches runtime state and initializes public UI components without editing the binary.
- `+ducktrapapp/renderMainDisplay.m`: replaceable main-axes renderer using an explicit axes handle.
- `demo_DucktrapApp.m`: deterministic synthetic-data launcher for the App Designer app.

## Implementation sequence

1. Add the minimal session state needed to select an initial time window.
2. Add a renderer that accepts `MainAxes` explicitly and does not read UI controls.
3. Initialize the existing app through its public component handles, leaving `.mlapp` unchanged.
4. Update the demo to launch the `.mlapp` and load its generated structures.
5. Run the demo and inspect the rendered app while confirming `.mlapp` remains byte-for-byte unchanged.

