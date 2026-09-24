function changeWindowSize(app, newSize)
%CHANGEWINDOWSIZE Shared action for control and future keyboard callbacks.

arguments
    app (1,1) DucktrapApp
    newSize (1,1) double {mustBeFinite, mustBePositive}
end

state = app.UIFigure.UserData;
state.Session.changeWindowSize(newSize);
app.WindowSizeSpinner.Value = state.Session.WindowSize;
ducktrapapp.refreshMainDisplay(app);
end
