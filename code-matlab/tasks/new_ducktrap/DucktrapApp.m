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
    end

    properties (Access = private)
        DisplayHandles = struct()
        Session
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
            app.DestinationDropDown.Enable = 'off';
        
            if nSWRs > 0
                app.UITable.Selection = 1;
                app.SegmentNumberSpinner.Value = 1;
                % Flush an intermediate range so the rendered spinner uses
                % the data-dependent maximum rather than its cached range.
                app.SegmentNumberSpinner.Limits = [0 nSWRs];
                drawnow;
                app.SegmentNumberSpinner.Limits = [1 nSWRs];
                app.SegmentNumberSpinner.Step = 1;
                app.SegmentNumberSpinner.Enable = 'on';
                app.TeleportButton.Enable = 'on';
            else
                app.SegmentNumberSpinner.Limits = [0 1];
                app.UITable.Selection = [];
                app.SegmentNumberSpinner.Value = 0;
                app.SegmentNumberSpinner.Enable = 'off';
                app.TeleportButton.Enable = 'off';
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
            app.DisplayHandles = ducktrapapp.renderMainDisplay(app.MainAxes, app.Session);
        end

        function teleportToSuggestedSWR(app, swrNumber)
            app.Session.cancelSelection();
            app.Session.teleportToSuggestedSWR(swrNumber);
            app.SegmentNumberSpinner.Value = swrNumber;
            app.UITable.Selection = swrNumber;
            scroll(app.UITable, 'row', swrNumber);
            refreshMainDisplay(app);
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
            if isempty(app.Session.PendingInterval), return; end
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
            selected = app.SegmentNumberSpinner.Value;
            if selected < 1, return; end
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

    end

    % Callbacks that handle component events
    methods

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
            switch event.Key
                case {'return', 'enter'}
                    confirmInterval(app);
                case {'delete', 'backspace'}
                    deleteViewedEvent(app);
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
                    app.Session.selectBoundary(point(1,1));
                case 'alt'
                    app.Session.cancelSelection();
                otherwise
                    return
            end
            refreshMainDisplay(app);
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            [~, folderName] = fileparts(pwd);
            [filename, folder] = uiputfile('*.mat', 'Save Events', ...
                [folderName '-manualIV.mat']);
            if isequal(filename, 0), return; end
            evt = app.Session.exportEvents(true);
            try
                save(fullfile(folder, filename), 'evt');
                app.Session.markSaved();
            catch err
                uialert(app.UIFigure, err.message, 'Save Failed');
            end
        end

        % Button pushed function: QuitButton
        function QuitButtonPushed(app, event)
            requestClose(app);
        end

        % Button pushed function: SpectrogramButton
        function SpectrogramButtonPushed(app, event)
            % TODO: Display a spectrogram for the current time window.
        end

        % Value changed function: DestinationDropDown
        function DestinationDropDownValueChanged(app, event)
            value = app.DestinationDropDown.Value;
        end

        % Value changed function: WindowSizeSpinner
        function WindowSizeSpinnerValueChanged(app, event)
            changeWindowSize(app, event.Value);
        end

        % Value changed function: SegmentNumberSpinner
        function SegmentNumberSpinnerValueChanged(app, event)
            teleportToSuggestedSWR(app, event.Value);
        end

        % Button pushed function: TeleportButton
        function TeleportButtonPushed(app, event)
            teleportToSuggestedSWR(app, app.SegmentNumberSpinner.Value);
        end

        % Selection changed function: UITable
        function UITableSelectionChanged(app, event)
            if isempty(event.Selection)
                if app.SegmentNumberSpinner.Value > 0
                    app.UITable.Selection = app.SegmentNumberSpinner.Value;
                end
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
