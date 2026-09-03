# Implementation Plan: DucktrapApp

**Architecture:** UIFigure app
**Serialization:** App Designer binary `.mlapp`
**Layout:** Responsive nested-grid plot workspace — a dominant two-row plotting area fills the flexible left column, with a fixed-width control panel in the right column.

## Structure

- Root `UIFigure` named **Ducktrap**, sized 1200×720.
- `RootGridLayout`: one flexible plotting column and one fixed 250 px control column.
- `PlotGridLayout`: `MainAxes` in a 3x-weight upper row and hidden `SpectrogramAxes` in a 1x-weight lower row.
- `ControlPanel` and `ControlGridLayout`: count, save/quit, spectrogram settings, and segment navigation controls in the same 17-row arrangement as the source scaffold.

## Key behaviors

- Preserve the `startupFcn`, axes click, key press, save, quit, close request, spectrogram, and teleport callback framework.
- Keep data loading, plotting, navigation, interval selection, saving, and spectrogram functionality unimplemented.
- Preserve the existing active close behavior in the Quit and close-request callbacks.
- Preserve the private `Session` app property without assigning a runtime value.

## Internal references

| Reference | Role |
|---|---|
| `references/editing-guide.md` | Identifies the source as a programmatic UIFigure app. |
| `references/archetypes/canvas.md` | Establishes that the plot is the primary workspace while implementation remains entirely grid-based. |
| `references/uifigure/guide.md` | Governs UIFigure and responsive grid construction. |
| `references/uifigure/grid-layout.md` | Governs weighted rows, fixed sidebar width, padding, and component spans. |
| `references/uifigure/containers.md` | Governs nested grids and the titled control panel. |
| `references/uifigure/components.md` | Governs buttons, labels, numeric fields, dropdowns, and UI axes. |
| `references/uifigure/callbacks.md` | Governs callback wiring and app-state access. |
| `references/uifigure/layout-patterns.md` | Provides the sidebar-plus-content layout pattern. |
| `references/app-designer/agent-guide-shared.md` | Defines the interface verbs, inspection, validation, saving, and completion sequence. |
| `references/app-designer/agent-guide-mlapp.md` | Defines binary `.mlapp` ownership, native property values, atomic save, and App Designer opening. |

## External skills

- `matlab-build-chart` — preserve the two `uiaxes` components, their labels/titles, and app-compatible interaction wiring without adding plot content.

## File organization

```text
code-matlab/tasks/new_ducktrap/
├── DucktrapApp.m       # retained source scaffold
├── DucktrapApp.mlapp   # generated App Designer app
├── DucktrapSession.m
├── demo_DucktrapApp.m
└── README.md
```

## Implementation sequence

1. Add the bundled `scripts` directory to the MATLAB path and create `DucktrapApp.mlapp` through `AppDesignerAgentInterface`.
2. Recreate the component tree top-down with the exact code names, grid hierarchy, layout values, labels, defaults, and visibility settings.
3. Add the private `Session` property and wire all callbacks with placeholder bodies matching the source intent.
4. Inspect the in-memory model and compare its node, property, and callback names against the source scaffold.
5. Run `validate()` and require an empty result.
6. Call `save()` once and require the product loadability gate to pass.
7. Re-read the generated MATLAB code and verify the expected component/property/callback names while confirming `DucktrapApp.m` remains unchanged.
8. Open and save the completed app through App Designer, leaving it open for inspection.
