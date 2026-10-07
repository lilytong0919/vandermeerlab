# DucktrapApp suggested-SWR navigation

- Architecture: retain the plain-text App Designer UIFigure view/controller and the separate `DucktrapSession` state model.
- Serialization: `DucktrapApp.m` + `DucktrapApp.xml` for MATLAB R2026b.
- Layout: preserve the existing grid hierarchy and component names without adding, deleting, or moving components.

## Corrected semantics

- In this app, each numbered segment is one suggested SWR from `cfg.evt`.
- Normalize `cfg.evt.tstart` and `cfg.evt.tend` into the repository's `iv` datatype and store it as `SuggestedIntervals`.
- Populate the existing left table with every suggested SWR: ID, start time, and end time.
- Configure `SegmentNumberSpinner` from the suggested-SWR count.
- Changing `SegmentNumberSpinner` immediately invokes the shared SWR teleport
  action using the callback event value.
- Use native single-row table selection and route `SelectionChangedFcn` through
  the same teleport action. Synchronize the table highlight and spinner on every
  navigation action, select the first row at startup, and clear empty selections.
- Teleport always centers on the selected SWR midpoint; the destination dropdown is fixed to `center` and disabled.
- Preserve `WindowSizeSpinner.Value` as the exact displayed time span, with limits equal to `eventCenter ± WindowSize/2`.
- Keep rendering in `+ducktrapapp/renderMainDisplay.m`.

## Implementation sequence

1. Update `DucktrapSession` to normalize and validate the IV and expose SWR-centered navigation.
2. Update app startup/control synchronization and the existing Teleport callback.
   Force the App Designer spinner client to synchronize its data-dependent
   limits during startup before applying the final `[1 nSWRs]` range.
   Route the spinner's `ValueChangedFcn` to the same private action used by
   the Teleport button.
3. Update deterministic demo data so `cfg.evt` and the compatibility `cfg.segments` value describe the same SWRs.
4. Validate the plain-text app pair and exercise table population, SWR selection, Teleport, and window resizing in MATLAB R2026b.

## References

- `references/editing-guide.md`: existing App Designer plain-text edit workflow.
- `references/app-designer/agent-guide-shared.md`: inspect and validate lifecycle.
- `references/app-designer/agent-guide-plaintext.md`: split ownership of `.m` and `.xml`.
- `references/uifigure/callbacks.md`: shared callback/action pattern.
