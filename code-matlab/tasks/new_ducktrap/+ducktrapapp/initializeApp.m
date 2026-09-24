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
recordingDuration = double(CSC.tvec(end) - CSC.tvec(1));
minimumWindow = min([0.001, recordingDuration / 100, session.WindowSize]);
app.WindowSizeSpinner.Limits = [minimumWindow recordingDuration];
app.WindowSizeSpinner.Step = min(0.1, recordingDuration / 10);
app.WindowSizeSpinner.Value = session.WindowSize;

nSegments = min(numel(session.Segments.tstart), numel(session.Segments.tend));
if nSegments > 0
    app.SegmentNumberSpinner.Limits = [1 nSegments];
    app.SegmentNumberSpinner.Step = 1;
    app.SegmentNumberSpinner.Value = 1;
    app.SegmentNumberSpinner.Enable = 'on';
    app.DestinationDropDown.Enable = 'on';
    app.TeleportButton.Enable = 'on';
else
    app.SegmentNumberSpinner.Limits = [0 1];
    app.SegmentNumberSpinner.Value = 0;
    app.SegmentNumberSpinner.Enable = 'off';
    app.DestinationDropDown.Enable = 'off';
    app.TeleportButton.Enable = 'off';
end

app.UIFigure.UserData = struct( ...
    'Session', session, ...
    'DisplayHandles', struct());

app.WindowSizeSpinner.ValueChangedFcn = ...
    @(~, event) ducktrapapp.changeWindowSize(app, event.Value);
app.TeleportButton.ButtonPushedFcn = ...
    @(~, ~) ducktrapapp.teleportToSegment(app, ...
        app.SegmentNumberSpinner.Value, string(app.DestinationDropDown.Value));

ducktrapapp.refreshMainDisplay(app);
end
