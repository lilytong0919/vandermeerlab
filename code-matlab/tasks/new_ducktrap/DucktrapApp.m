classdef DucktrapApp < matlab.apps.App

    % Used to locate and load the app's XML configuration file
    properties (Access = public, Constant)
        AppConfigFilename = './DucktrapApp.xml'; % File path to the app configuration file containing component layout and settings
    end

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        RootGridLayout                  matlab.ui.container.GridLayout
        SegmentGridLayout               matlab.ui.container.GridLayout
        CountLabel                      matlab.ui.control.Label
        UITable                         matlab.ui.control.Table
        ControlPanel                    matlab.ui.container.Panel
        ControlGridLayout               matlab.ui.container.GridLayout
        TeleportButton                  matlab.ui.control.Button
        DestinationLabel                matlab.ui.control.Label
        SegmentNumberSpinner            matlab.ui.control.Spinner
        SegmentNumberSpinnerLabel       matlab.ui.control.Label
        WindowSizeSpinner               matlab.ui.control.Spinner
        WindowSizeSpinnerLabel          matlab.ui.control.Label
        DisplayLabel                    matlab.ui.control.Label
        DestinationDropDown             matlab.ui.control.DropDown
        SegmentLabel                    matlab.ui.control.Label
        ScaleDropDown                   matlab.ui.control.DropDown
        ScaleLabel                      matlab.ui.control.Label
        MaxFrequencyEditField           matlab.ui.control.NumericEditField
        MaxFrequencyLabel               matlab.ui.control.Label
        MinFrequencyEditField           matlab.ui.control.NumericEditField
        MinFrequencyLabel               matlab.ui.control.Label
        SpectrogramButton               matlab.ui.control.Button
        SpectrogramLabel                matlab.ui.control.Label
        QuitButton                      matlab.ui.control.Button
        SaveButton                      matlab.ui.control.Button
        PlotGridLayout                  matlab.ui.container.GridLayout
        SpectrogramAxes                 matlab.ui.control.UIAxes
        MainAxes                        matlab.ui.control.UIAxes
        BoundaryModeButton              matlab.ui.control.StateButton
    end

    properties (Access = private)
        DisplayHandles = struct()
        Session
        HoverLine = gobjects(0)
    end

    methods (Access = private)

        function changeWindowSize(app, newSize)
            app.Session.changeWindowSize(newSize);
            app.WindowSizeSpinner.Value = app.Session.WindowSize;
            refreshMainDisplay(app);
        end

        function configureControls(app)
            recordingDuration = double(app.Session.CSC.tvec(end) - app.Session.CSC.tvec(1));
            minimumWindow = min([0.001, recordingDuration / 100, app.Session.WindowSize]);
            app.WindowSizeSpinner.Limits = [minimumWindow recordingDuration];
            app.WindowSizeSpinner.Step = min(0.1, recordingDuration / 10);
            app.WindowSizeSpinner.Value = app.Session.WindowSize;
        
            intervals = app.Session.SuggestedIntervals;
            nSWRs = numel(intervals.tstart);
            app.UITable.Data = [(1:nSWRs)', ...
                double(intervals.tstart(:)), double(intervals.tend(:))];
            app.CountLabel.Text = sprintf('Count: %d', nSWRs);
            app.DestinationDropDown.Value = 'center';
        
            if nSWRs > 0
                app.UITable.Selection = 1;
                app.SegmentNumberSpinner.Value = 1;
                % Flush an intermediate range so the rendered spinner uses
                % the data-dependent maximum rather than its cached range.
                app.SegmentNumberSpinner.Limits = [0 nSWRs];
                drawnow;
                app.SegmentNumberSpinner.Limits = [1 nSWRs];
                app.SegmentNumberSpinner.Step = 1;
            else
                app.SegmentNumberSpinner.Limits = [0 1];
                app.UITable.Selection = [];
                app.SegmentNumberSpinner.Value = 0;
            end
        end

        function initializeSession(app, cfg, S, CSC)
            app.Session = DucktrapSession(cfg, S, CSC);
            configureControls(app);
            refreshMainDisplay(app);
        end

        function refreshMainDisplay(app)
            if isempty(app.Session)
                error('DucktrapApp:NotInitialized', ...
                    'DucktrapApp must be initialized before refreshing the display.');
            end
            synchronizeInteractionState(app);
            app.DisplayHandles = ducktrapapp.renderMainDisplay(app.MainAxes, ...
                app.Session, app.UITable.Selection);
            if ~app.Session.BoundaryMode
                state = 'Viewing';
            elseif ~isempty(app.Session.PendingInterval)
                state = 'Set Boundaries: Ready to Confirm';
            elseif ~isempty(app.Session.FirstBoundary)
                state = 'Set Boundaries: Select End';
            else
                state = 'Set Boundaries: Select Start';
            end
            title(app.MainAxes, state);
        end

        function synchronizeInteractionState(app)
            % All mode-dependent control availability belongs here.
            viewing = ~app.Session.BoundaryMode;
            viewingEnable = 'off';
            if viewing, viewingEnable = 'on'; end
            viewingControls = {app.UITable, app.SaveButton, app.QuitButton, ...
                app.SpectrogramButton, app.MinFrequencyEditField, ...
                app.MaxFrequencyEditField, app.ScaleDropDown};
            for i = 1:numel(viewingControls)
                viewingControls{i}.Enable = viewingEnable;
            end
            hasEvents = ~isempty(app.Session.SuggestedIntervals.tstart);
            eventEnable = 'off';
            if viewing && hasEvents, eventEnable = 'on'; end
            eventControls = {app.SegmentNumberSpinner, app.TeleportButton};
            for i = 1:numel(eventControls)
                eventControls{i}.Enable = eventEnable;
            end
            app.DestinationDropDown.Enable = 'off';
            app.WindowSizeSpinner.Enable = 'on';
            app.BoundaryModeButton.Enable = 'on';
            app.BoundaryModeButton.Value = app.Session.BoundaryMode;
        end

        function setBoundaryMode(app, enabled)
            app.Session.setBoundaryMode(enabled);
            if enabled, synchronizeViewingSelection(app, []); end
            refreshMainDisplay(app);
        end

        function handleViewingKey(app, key, modifiers)
            if any(~ismember(modifiers, {'shift', 'control'})), return; end
            if any(strcmp(key, {'a', 'd'}))
                step = 1;
                if ismember('shift', modifiers)
                    step = 10;
                elseif ismember('control', modifiers)
                    step = 50;
                end
                direction = 1;
                if strcmp(key, 'a'), direction = -1; end
                selected = app.Session.eventNavigationTarget(direction, step);
                if ~isempty(selected), teleportToSuggestedSWR(app, selected); end
                return
            end
            if ~isempty(modifiers), return; end
            switch key
                case 's'
                    setBoundaryMode(app, true);
                case 'space'
                    selected = app.UITable.Selection;
                    if ~isempty(selected), teleportToSuggestedSWR(app, selected); end
                case 'r'
                    app.Session.resetZoom();
                    refreshMainDisplay(app);
                case 'h'
                    showShortcutHelp(app);
            end
        end

        function handleBoundaryKey(app, key)
            switch key
                case 's'
                    app.Session.cancelSelection();
                    refreshMainDisplay(app);
                case 'q'
                    setBoundaryMode(app, false);
                case 'space'
                    app.Session.centerBoundaries();
                    refreshMainDisplay(app);
                case 'r'
                    app.Session.resetZoom();
                    refreshMainDisplay(app);
                case 'h'
                    showShortcutHelp(app);
            end
        end

        function showShortcutHelp(app)
            message = strjoin({ ...
                'VIEWING', ...
                'A / D: previous / next event relative to the window center', ...
                'Shift+A / Shift+D: jump 10 events from the nearest event', ...
                'Ctrl+A / Ctrl+D: jump 50 events from the nearest event', ...
                'Space: center selected event without changing zoom', ...
                'S: enter boundary setting and clear event selection', ...
                'Left click: select event; click outside events to clear', ...
                'Right click: delete selected event after confirmation', ...
                '', ...
                'BOUNDARY SETTING', ...
                'Two left clicks: set interval boundaries', ...
                'Right click: confirm interval; overlaps require approval', ...
                'S: clear boundaries and restart', ...
                'Q: discard boundaries and return to viewing', ...
                'Space: center one boundary or midpoint of two', ...
                '', ...
                'BOTH MODES', ...
                'Wheel: move through time', ...
                'Ctrl+wheel: temporary zoom (up in, down out)', ...
                'R: reset zoom to Window Size at the current center', ...
                'H: keyboard shortcut help', ...
                '', ...
                'Event jumps stop at the first/last event. Shift takes priority', ...
                'over Ctrl. Shortcuts are inactive while editing text or numbers.'}, newline);
            uialert(app.UIFigure, message, 'Keyboard Shortcuts', 'Icon', 'info');
        end

        function teleportToSuggestedSWR(app, swrNumber)
            if app.Session.BoundaryMode, return; end
            app.Session.cancelSelection();
            app.Session.teleportToSuggestedSWR(swrNumber);
            synchronizeViewingSelection(app, swrNumber);
            refreshMainDisplay(app);
        end

        function synchronizeViewingSelection(app, selected)
            if app.Session.BoundaryMode && ~isempty(selected), return; end
            app.UITable.Selection = selected;
            if ~isempty(selected)
                app.SegmentNumberSpinner.Value = selected;
                scroll(app.UITable, 'row', selected);
            end
        end

        function synchronizeEvents(app, selected)
            configureControls(app);
            count = numel(app.Session.SuggestedIntervals.tstart);
            if count > 0
                teleportToSuggestedSWR(app, min(max(1, selected), count));
            else
                refreshMainDisplay(app);
            end
        end

        function confirmInterval(app)
            if ~app.Session.BoundaryMode || isempty(app.Session.PendingInterval), return; end
            overlaps = app.Session.pendingOverlaps();
            if ~isempty(overlaps)
                choice = uiconfirm(app.UIFigure, sprintf( ...
                    'Replace %d overlapping event(s) with the selected boundaries?', numel(overlaps)), ...
                    'Overwrite Events', 'Options', {'Replace', 'Cancel'}, ...
                    'DefaultOption', 2, 'CancelOption', 2, 'Icon', 'warning');
                if ~strcmp(choice, 'Replace'), return; end
            end
            selected = app.Session.confirmPending(true);
            synchronizeEvents(app, selected);
        end

        function deleteViewedEvent(app)
            if app.Session.BoundaryMode, return; end
            selected = app.UITable.Selection;
            if isempty(selected), return; end
            intervals = app.Session.SuggestedIntervals;
            choice = uiconfirm(app.UIFigure, sprintf( ...
                'Delete event %d (%.6g to %.6g s)?', selected, ...
                intervals.tstart(selected), intervals.tend(selected)), ...
                'Delete Event', 'Options', {'Delete', 'Cancel'}, ...
                'DefaultOption', 2, 'CancelOption', 2, 'Icon', 'warning');
            if ~strcmp(choice, 'Delete'), return; end
            app.Session.deleteEvent(selected);
            synchronizeEvents(app, selected);
        end

        function requestClose(app)
            if app.Session.HasUnsavedChanges
                choice = uiconfirm(app.UIFigure, 'Close without saving your changes?', ...
                    'Unsaved Changes', 'Options', {'Close', 'Cancel'}, ...
                    'DefaultOption', 2, 'CancelOption', 2, 'Icon', 'warning');
                if ~strcmp(choice, 'Close'), return; end
            end
            delete(app);
        end

        function saved = saveEvents(app)
            saved = false;
            if app.Session.BoundaryMode, return; end
            [~, folderName] = fileparts(pwd);
            [filename, folder] = uiputfile('*.mat', 'Save Events', ...
                [folderName '-manualIV.mat']);
            focus(app.UIFigure);
            if isequal(filename, 0), return; end
            try
                evt = app.Session.exportEvents(true);
                save(fullfile(folder, filename), 'evt');
                app.Session.markSaved();
                saved = true;
            catch err
                uialert(app.UIFigure, err.message, 'Save Failed');
            end
        end

    end

    % Callbacks that handle component events
    methods

        function UIFigureWindowButtonMotion(app, event)
            if isempty(app.Session), return; end
            point = app.MainAxes.CurrentPoint;
            cursor = app.UIFigure.CurrentPoint;
            bounds = getpixelposition(app.MainAxes, true);
            inAxes = cursor(1) >= bounds(1) && cursor(1) <= bounds(1)+bounds(3) && ...
                cursor(2) >= bounds(2) && cursor(2) <= bounds(2)+bounds(4) && ...
                point(1,1) >= app.MainAxes.XLim(1) && point(1,1) <= app.MainAxes.XLim(2) && ...
                point(1,2) >= app.MainAxes.YLim(1) && point(1,2) <= app.MainAxes.YLim(2);
            if ~app.Session.BoundaryMode || ~inAxes
                if isgraphics(app.HoverLine), app.HoverLine.Visible = 'off'; end
                return
            end
            x = point(1,1);
            width = diff(app.MainAxes.XLim)/max(1, bounds(3));
            y = app.MainAxes.YLim;
            if isempty(app.HoverLine) || ~isgraphics(app.HoverLine)
                hold(app.MainAxes, 'on');
                app.HoverLine = patch(app.MainAxes, [x x+width x+width x], ...
                    [y(1) y(1) y(2) y(2)], [0.9 0.25 0.15], ...
                    'FaceAlpha', 0.25, 'EdgeColor', 'none', ...
                    'HitTest', 'off', 'PickableParts', 'none');
                hold(app.MainAxes, 'off');
            else
                app.HoverLine.XData = [x x+width x+width x];
                app.HoverLine.YData = [y(1) y(1) y(2) y(2)];
                app.HoverLine.Visible = 'on';
            end
        end

        function BoundaryModeButtonValueChanged(app, event)
            setBoundaryMode(app, app.BoundaryModeButton.Value);
            focus(app.UIFigure);
        end

        function UIFigureWindowScrollWheel(app, event)
            if isempty(app.Session) || event.VerticalScrollCount == 0, return; end
            point = app.UIFigure.CurrentPoint;
            bounds = getpixelposition(app.MainAxes, true);
            if point(1) < bounds(1) || point(1) > bounds(1)+bounds(3) || ...
                    point(2) < bounds(2) || point(2) > bounds(2)+bounds(4)
                return
            end
            if ismember('control', app.UIFigure.CurrentModifier)
                app.Session.zoomTime(event.VerticalScrollCount);
            else
                app.Session.scrollTime(event.VerticalScrollCount);
            end
            refreshMainDisplay(app);
        end

        % Code that executes after component creation
        function startupFcn(app, cfg, S, CSC)
            initializeSession(app, cfg, S, CSC);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            requestClose(app);
        end

        % Window key press function: UIFigure
        function UIFigureWindowKeyPress(app, event)
            target = app.UIFigure.CurrentObject;
            if isa(target, 'matlab.ui.control.EditField') || ...
                    isa(target, 'matlab.ui.control.NumericEditField') || ...
                    isa(target, 'matlab.ui.control.Spinner') || ...
                    isa(target, 'matlab.ui.control.TextArea')
                return
            end
            modifiers = {};
            if isprop(event, 'Modifier') || ...
                    (isstruct(event) && isfield(event, 'Modifier'))
                modifiers = event.Modifier;
            end
            if app.Session.BoundaryMode
                if ~isempty(modifiers), return; end
                handleBoundaryKey(app, event.Key);
            else
                handleViewingKey(app, event.Key, modifiers);
            end
        end

        % Button down function: MainAxes
        function MainAxesButtonDown(app, event)
            point = app.MainAxes.CurrentPoint;
            if point(1,1) < app.MainAxes.XLim(1) || point(1,1) > app.MainAxes.XLim(2) || ...
                    point(1,2) < app.MainAxes.YLim(1) || point(1,2) > app.MainAxes.YLim(2)
                return
            end
            switch app.UIFigure.SelectionType
                case 'normal'
                    if app.Session.BoundaryMode
                        app.Session.selectBoundary(point(1,1));
                    else
                        selected = app.Session.eventAtTime(point(1,1));
                        synchronizeViewingSelection(app, selected);
                    end
                case 'alt'
                    if app.Session.BoundaryMode
                        confirmInterval(app);
                    else
                        deleteViewedEvent(app);
                    end
                    return
                otherwise
                    return
            end
            refreshMainDisplay(app);
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            saveEvents(app);
        end

        % Button pushed function: QuitButton
        function QuitButtonPushed(app, event)
            if saveEvents(app)
                delete(app);
            end
        end

        % Button pushed function: SpectrogramButton
        function SpectrogramButtonPushed(app, event)
            % TODO: Display a spectrogram for the current time window.
        end

        % Value changed function: DestinationDropDown
        function DestinationDropDownValueChanged(app, event)
            % TODO: Support destinations other than the event center.
        end

        % Value changed function: WindowSizeSpinner
        function WindowSizeSpinnerValueChanged(app, event)
            changeWindowSize(app, event.Value);
        end

        % Value changed function: SegmentNumberSpinner
        function SegmentNumberSpinnerValueChanged(app, event)
            if app.Session.BoundaryMode, return; end
            teleportToSuggestedSWR(app, event.Value);
        end

        % Button pushed function: TeleportButton
        function TeleportButtonPushed(app, event)
            if app.Session.BoundaryMode, return; end
            teleportToSuggestedSWR(app, app.SegmentNumberSpinner.Value);
        end

        % Selection changed function: UITable
        function UITableSelectionChanged(app, event)
            if app.Session.BoundaryMode
                app.UITable.Selection = [];
                return
            end
            if isempty(event.Selection)
                synchronizeViewingSelection(app, []);
                refreshMainDisplay(app);
                return
            end
            teleportToSuggestedSWR(app, event.Selection(1));
        end
    end

    % App creation
    methods (Access = public)

        % Construct app
        function app = DucktrapApp(varargin)
            app = app@matlab.apps.App(varargin{:});

            if nargout == 0
                clear app
            end
        end
    end
end
