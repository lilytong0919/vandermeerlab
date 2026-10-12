# Explicit interval mode

Use a StateButton and unmodified S to enter/exit boundary mode. S is unused in
legacy navigate.m; preserve its E end-of-recording shortcut. Suppress shortcuts
in editable controls. Place the toggle in control row 4 and state label in row
18 without moving existing controls.

Viewing: left click selects an intersecting event, right click clears selection.
Selection persists during time scrolling, including off-screen events.
Boundary mode: hover shows a faint vertical patch, two clicks set boundaries,
right click undoes the latest boundary, Enter confirms and exits. Declining
overlap replacement retains mode/bounds. Toggle exit clears pending bounds.
Scrolling clears pending bounds but keeps the mode. Delete is viewing-only.

References: existing MATLAB app editing and callback guides, legacy navigate.m
and ducktrap.m. Verify session transitions and real app gestures in R2026b.

Validation: thirteen session tests pass in R2026b. Interactive app checks pass
for viewing click selection/clearing, persistent off-screen selection, S and
button toggling, faint hover preview, right-click undo, Enter confirmation/exit,
boundary-mode deletion suppression, modified-S and editable-control guards,
overlap Cancel preserving mode/bounds, and toggle exit clearing pending bounds.
