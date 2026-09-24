function initializeApp(app, cfg, S, CSC)
%INITIALIZEAPP Attach runtime data to the unmodified App Designer view.
%
% The .mlapp owns component creation and layout. This adapter deliberately
% uses only public component handles so the binary design file does not need
% code, property, callback, or layout edits for the mock display.

arguments
    app (1,1) DucktrapApp
    cfg (1,1) struct
    S (1,1) struct
    CSC (1,1) struct
end

session = DucktrapSession(cfg, S, CSC);
app.WindowSizeSpinner.Value = session.WindowSize;
displayHandles = ducktrapapp.renderMainDisplay(app.MainAxes, session);

app.UIFigure.UserData = struct( ...
    'Session', session, ...
    'DisplayHandles', displayHandles);
end
