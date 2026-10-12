# Mode isolation

Centralize control availability in synchronizeInteractionState. Viewing-only:
event table, segment spinner, Teleport, Save, Save & Quit, and spectrogram controls.
Event controls also require a nonempty event list. Window Size and mode toggle
remain available. Callback guards enforce the same restrictions for queued or
directly invoked actions. Destination remains disabled in both modes.

setBoundaryMode owns transitions and clears selection on entry. Keyboard input
passes editable-control/modifier guards, then dispatches exclusively through
handleViewingKey or handleBoundaryKey. Viewing: S enters; Space centers selection;
R resets zoom. Boundary: S clears pending lines and restarts; Q exits;
right click confirms completed boundaries; Space centers pending boundaries;
R resets zoom. No boundaries makes Space inert; one centers that line; two center
their midpoint. Centering preserves zoom. Pan/zoom/reset preserve boundaries.

Validation: eighteen session tests pass in R2026b. Interactive checks pass for
control availability and restoration, guarded table/spinner/Teleport/Save/Save &
Quit callbacks, cleared selection, no-boundary/one-boundary/two-boundary centering,
preserved boundaries during scroll/reset, confirmation, and Q exit. Actual
Ctrl+wheel simulation remains unsupported by the UI test driver.

Right-click confirmation validation: R2026b interactive checks pass for no action
with incomplete bounds, S restart, creation, overlap Cancel/Replace, and deletion
after returning to viewing. Successful confirmation exits boundary mode.

Review cleanup: removed obsolete undo/nearest-visible-event navigation code and
updated its tests to cover restart and preservation of event data. Right-click
actions refresh through their action methods only; the app owns the plot title.
The disabled destination callback remains an explicit TODO placeholder.
All eighteen session tests pass. Interactive R2026b checks pass for restart,
scroll preservation, creation, overlap Cancel/Replace, deletion Cancel/Delete,
and title/display refresh. The class-based UI runner still stalls during setup;
equivalent affected interaction paths were verified outside that runner.
