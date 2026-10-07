# Interval editing and save

Preserve the original fixed/unfixed selection state machine and iv MAT-file
output. Use explicit axes callbacks and session-owned state.

- Left click starts a pending interval; a second click completes unfixed bounds.
- Right click cancels. Enter confirms completed bounds.
- Confirm overlap replacement before removing any existing interval; declining
  keeps the pending selection and all existing intervals intact.
- Delete/Backspace requests confirmation for the event selected in the table.
- Keep table rows, spinner, current view, and confirmed flags synchronized after
  replacement or deletion. Navigation cancels pending boundaries.
- Save all remaining table events as sorted iv output named evt, with label,
  hdr, and configuration history (user-selected behavior).
- Verify state transitions, overlap replacement, deletion, output metadata, and
  app callback wiring in MATLAB R2026b.

References: matlab-build-app/references/uifigure/callbacks.md and
references/app-designer/agent-guide-plaintext.md; legacy ducktrap.m clickstuff,
keystuff, and saveme.

Validation: seven session tests pass. An interactive matlab.uitest test case in
R2026b verified actual two-click selection, Enter confirmation, right-click
cancellation, overlap Cancel/Replace, Delete/Backspace Cancel/Delete, Save MAT
output, and table/spinner synchronization. Class-based UI tests are provided;
their batch runner stalled during setup, so the equivalent interaction sequence
was verified outside that runner.
