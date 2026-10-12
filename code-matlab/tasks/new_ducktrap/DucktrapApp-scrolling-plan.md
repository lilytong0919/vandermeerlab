# Time scrolling

Use UIFigure WindowScrollWheelFcn with live CurrentPoint updates and axes pixel
bounds to limit navigation to the main axes. Session scrollTime moves by 20% of
the unchanged window width and clamps the full window to the recording. Retain
the explicitly selected SWR, even when it leaves the display window.
Share control synchronization with Teleport without calling Teleport on scroll.
Delete acts only on highlighted events in viewing mode. Scrolling cancels
pending boundaries while retaining boundary mode.

References: MATLAB Figure WindowScrollWheelFcn documentation; existing
App Designer plain-text and UIFigure callback editing guides.

Validation: the initial ten session tests and interactive wheel checks passed
in R2026b. Selection behavior has since been superseded by explicit viewing
selection; see DucktrapApp-boundary-mode-plan.md for current validation.
