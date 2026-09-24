function refreshMainDisplay(app)
%REFRESHMAINDISPLAY Synchronize MainAxes with the current session state.

arguments
    app (1,1) DucktrapApp
end

state = app.UIFigure.UserData;
if ~isstruct(state) || ~isfield(state, 'Session')
    error('ducktrapapp:AppNotInitialized', ...
        'Initialize DucktrapApp before requesting a display refresh.');
end

state.DisplayHandles = ducktrapapp.renderMainDisplay(app.MainAxes, state.Session);
app.UIFigure.UserData = state;
end
