# Temporary zoom and editing shortcuts

User chose Ctrl+scroll after comparing modifier conventions. Keep WindowSize
as the configured baseline and DisplayWindowSize as the current time span.
Ctrl+wheel scales the displayed span by 1.25 per step around the current center,
bounded by the minimum window and recording duration. Pan uses displayed width.
R resets to baseline at the current center. Space centers the selected event in
viewing mode or the pending boundaries in boundary mode, preserving zoom.
Changing the spinner resets temporary zoom.

Move mode status into MainAxes.Title and remove the old status label. S enters
boundary mode from viewing and confirms completed bounds while editing. Q exits
without confirmation. Enter and Delete/Backspace no longer curate intervals.
Right click in viewing mode requests deletion of the selected event; in boundary
mode it still undoes the last boundary. Preserve overlap/delete confirmations,
selection colors, left-click deselection, and editable-control shortcut guards.

References: MathWorks Zoom and Change Desktop Fonts (Ctrl+Mouse Scroll),
Figure.CurrentModifier, and existing app callback/editing guides.

Validation: sixteen session tests pass in R2026b, covering temporary zoom,
baseline preservation, reset with/without selection, pan using displayed span,
zoom limits, and preservation of pending boundaries. Interactive app checks pass
for Space selected/unselected, plot title states, S confirmation, Q exit,
inactive Enter/Backspace, and right-click Cancel/Delete. Actual Ctrl+wheel chord
is not simulated by the MATLAB UI test driver's scroll gesture.
