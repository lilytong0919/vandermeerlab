# DucktrapApp plain-text integration

- Architecture: App Designer UIFigure app with `DucktrapApp.m` as the view/controller and `DucktrapSession.m` as the non-graphical state model.
- Serialization: App Designer plain text (`DucktrapApp.m` + `DucktrapApp.xml`) for MATLAB R2026b.
- Layout: preserve the existing grid hierarchy and every component layout/property value.

## Behaviors in this migration

- Accept `cfg`, `S`, and `CSC` as app input arguments.
- Construct and retain `DucktrapSession` in the app's private state.
- Configure window-size and suggested-SWR controls during startup.
- Route spinner and Teleport callbacks through shared private app actions.
- Refresh the main axes through the replaceable external renderer.
- Remove the former runtime callback adapters after equivalent app-owned behavior is verified.
- Leave interval editing, Save, spectrogram, and keyboard behavior as TODO callbacks.

## File boundaries

- `DucktrapApp.m`: startup, component callbacks, UI synchronization, and shared controller actions.
- `DucktrapApp.xml`: existing component tree/layout plus callback wiring only.
- `DucktrapSession.m`: validated data, navigation state, and state transitions.
- `+ducktrapapp/renderMainDisplay.m`: isolated display renderer for future optimization.
- Demo/data helpers remain independent of the app class.

## Validation

1. Inspect and update the existing app through `AppDesignerAgentInterface`.
2. Validate and save the plain-text pair with MATLAB R2026b.
3. Launch `demo_DucktrapApp`, exercise both implemented controls, and verify the axes refresh.
4. Open the completed app in App Designer for inspection without changing the layout.

## References

- `references/editing-guide.md`: existing plain-text app workflow.
- `references/app-designer/agent-guide-shared.md`: inspect, code verbs, validation, and save lifecycle.
- `references/app-designer/agent-guide-plaintext.md`: split ownership of `.m` and `.xml`.
- `references/uifigure/callbacks.md`: committed-value callbacks and shared actions.
