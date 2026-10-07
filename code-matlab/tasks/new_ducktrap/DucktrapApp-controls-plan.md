# DucktrapApp control/action implementation (superseded integration notes)

- Architecture: originally retained the binary App Designer view and bound
  controls at runtime. The runtime adapters have now been migrated into the
  plain-text App Designer code file.
- Serialization: superseded by `DucktrapApp.m` + `DucktrapApp.xml`; see
  `DucktrapApp-plaintext-integration-plan.md`.
- Layout: existing Explorer layout with segment list, main display, and right-side controls.

## Behaviors in this branch

- Changing `WindowSizeSpinner` updates session state and refreshes `MainAxes`.
- `SegmentNumberSpinner` is configured from the suggested SWRs in `cfg.evt`.
- Pressing `TeleportButton` centers the view on the selected suggested SWR.
- Shared action functions are callable by both controls now and keyboard shortcuts later.
- Spectrogram, interval editing, saving, and keyboard bindings remain deferred.
- Mock data generation is isolated so DucktrapApp and MultiRaster can be
  compared with identical inputs while debugging navigation.

## Original files

- `DucktrapSession.m`: validated state transitions and bounded view limits.
- `+ducktrapapp/changeWindowSize.m`: shared window-size action.
- `+ducktrapapp/teleportToSegment.m`: shared segment navigation action.
- `+ducktrapapp/refreshMainDisplay.m`: display synchronization boundary.
- `+ducktrapapp/initializeApp.m`: runtime control configuration and callback binding.

These four `+ducktrapapp` control/initialization adapters were removed after
equivalent app-owned callbacks were validated in MATLAB R2026b. The external
renderer remains intentionally separate.

## References

- `references/uifigure/callbacks.md`: `ValueChangedFcn` and centralized `UserData` state.
- `references/uifigure/mvvm-guide.md`: keep state transitions out of the view layer.
- `matlab-build-chart`: explicit axes and replaceable refresh boundary.
