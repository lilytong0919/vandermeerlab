# DucktrapApp control/action implementation

- Architecture: retain the existing App Designer view and bind controls at runtime from reviewable MATLAB source.
- Serialization: `DucktrapApp.mlapp` remains byte-for-byte unchanged.
- Layout: existing Explorer layout with segment list, main display, and right-side controls.

## Behaviors in this branch

- Changing `WindowSizeSpinner` updates session state and refreshes `MainAxes`.
- `SegmentNumberSpinner` is configured from `cfg.segments`.
- Pressing `TeleportButton` moves the view to the selected segment beginning, center, or end.
- Shared action functions are callable by both controls now and keyboard shortcuts later.
- Spectrogram, interval editing, saving, and keyboard bindings remain deferred.
- Mock data generation is isolated so DucktrapApp and MultiRaster can be
  compared with identical inputs while debugging navigation.

## Files

- `DucktrapSession.m`: validated state transitions and bounded view limits.
- `+ducktrapapp/changeWindowSize.m`: shared window-size action.
- `+ducktrapapp/teleportToSegment.m`: shared segment navigation action.
- `+ducktrapapp/refreshMainDisplay.m`: display synchronization boundary.
- `+ducktrapapp/initializeApp.m`: runtime control configuration and callback binding.

## References

- `references/uifigure/callbacks.md`: `ValueChangedFcn` and centralized `UserData` state.
- `references/uifigure/mvvm-guide.md`: keep state transitions out of the view layer.
- `matlab-build-chart`: explicit axes and replaceable refresh boundary.
