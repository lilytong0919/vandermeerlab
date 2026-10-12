# Legacy event keyboard navigation

Migrate A/D only; the user deferred F/C/L. From an event center, plain A/D select
the previous/next index. From between events, choose the closest center on the
requested side. Shift jumps ten indices from the nearest center, Ctrl fifty;
Shift takes priority when both are held. Clamp at the first/last event. Use
existing Teleport action to synchronize table, spinner, and view without changing
temporary zoom. Empty inputs and boundary mode remain inert.

H opens a read-only in-app shortcut popup in either mode, documenting only
implemented bindings. Preserve editable-control guards and modified-S/Q guards.
References: legacy shared/util/navigate.m and nearval3.m.

Midpoint ties choose the later event, matching nearest_idx3.c. Validation:
twenty-six session tests pass in R2026b. Interactive checks pass for A/D,
Shift/Ctrl jumps, modifier precedence on eighty events, table/spinner sync,
width preservation, unassigned F/C/L, H dialogs in both modes, and unchanged
boundary state/data when event shortcuts or help are invoked during editing.
