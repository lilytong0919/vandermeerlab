function teleportToSegment(app, segmentNumber, destination)
%TELEPORTTOSEGMENT Shared segment-navigation action.

arguments
    app (1,1) DucktrapApp
    segmentNumber (1,1) double {mustBeInteger, mustBePositive}
    destination (1,1) string
end

state = app.UIFigure.UserData;
state.Session.teleportToSegment(segmentNumber, destination);
app.SegmentNumberSpinner.Value = segmentNumber;
app.DestinationDropDown.Value = char(destination);
ducktrapapp.refreshMainDisplay(app);
end
