classdef DucktrapApp < matlab.apps.AppBase
    % DUCKTRAPAPP User-interface scaffold for manual interval curation.
    %
    % This initial version defines only the application layout and callback
    % entry points. Data loading, plotting, navigation, interval selection,
    % saving, and spectrogram behavior are intentionally not implemented.

    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        RootGridLayout            matlab.ui.container.GridLayout
        PlotGridLayout            matlab.ui.container.GridLayout
        MainAxes                  matlab.ui.control.UIAxes
        SpectrogramAxes           matlab.ui.control.UIAxes

        ControlPanel              matlab.ui.container.Panel
        ControlGridLayout         matlab.ui.container.GridLayout
        CountLabel                matlab.ui.control.Label
        SaveButton                matlab.ui.control.Button
        QuitButton                matlab.ui.control.Button

        SpectrogramLabel          matlab.ui.control.Label
        SpectrogramButton         matlab.ui.control.Button
        MinFrequencyLabel         matlab.ui.control.Label
        MinFrequencyEditField     matlab.ui.control.NumericEditField
        MaxFrequencyLabel         matlab.ui.control.Label
        MaxFrequencyEditField     matlab.ui.control.NumericEditField
        ScaleLabel                matlab.ui.control.Label
        ScaleDropDown             matlab.ui.control.DropDown

        SegmentLabel              matlab.ui.control.Label
        SegmentNumberLabel        matlab.ui.control.Label
        SegmentNumberDropDown     matlab.ui.control.DropDown
        DestinationLabel          matlab.ui.control.Label
        DestinationDropDown       matlab.ui.control.DropDown
        TeleportButton            matlab.ui.control.Button
    end

    properties (Access = private)
        Session
    end

    methods (Access = private)

        function startupFcn(app, varargin) %#ok<INUSD>
            % TODO: Validate inputs and initialize DucktrapSession.
        end

        function MainAxesButtonDown(app, event) %#ok<INUSD>
            % TODO: Forward an axes click to the session state machine.
        end

        function UIFigureWindowKeyPress(app, event) %#ok<INUSD>
            % TODO: Handle interval confirmation and keyboard navigation.
        end

        function SaveButtonPushed(app, event) %#ok<INUSD>
            % TODO: Build and save the curated interval structure.
        end

        function QuitButtonPushed(app, event) %#ok<INUSD>
            delete(app);
        end

        function UIFigureCloseRequest(app, event) %#ok<INUSD>
            delete(app);
        end

        function SpectrogramButtonPushed(app, event) %#ok<INUSD>
            % TODO: Display a spectrogram for the current time window.
        end

        function TeleportButtonPushed(app, event) %#ok<INUSD>
            % TODO: Move the visible window to the selected segment.
        end

        function createComponents(app)
            app.UIFigure = uifigure("Visible", "off");
            app.UIFigure.Position = [100 100 1200 720];
            app.UIFigure.Name = "Ducktrap";
            app.UIFigure.WindowKeyPressFcn = createCallbackFcn(app, @UIFigureWindowKeyPress, true);
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            app.RootGridLayout = uigridlayout(app.UIFigure, [1 2]);
            app.RootGridLayout.ColumnWidth = {"1x", 250};
            app.RootGridLayout.RowHeight = {"1x"};
            app.RootGridLayout.Padding = [10 10 10 10];
            app.RootGridLayout.ColumnSpacing = 10;

            app.PlotGridLayout = uigridlayout(app.RootGridLayout, [2 1]);
            app.PlotGridLayout.Layout.Row = 1;
            app.PlotGridLayout.Layout.Column = 1;
            app.PlotGridLayout.RowHeight = {"3x", "1x"};
            app.PlotGridLayout.ColumnWidth = {"1x"};
            app.PlotGridLayout.Padding = [0 0 0 0];
            app.PlotGridLayout.RowSpacing = 8;

            app.MainAxes = uiaxes(app.PlotGridLayout);
            app.MainAxes.Layout.Row = 1;
            app.MainAxes.Layout.Column = 1;
            app.MainAxes.Box = "on";
            app.MainAxes.ButtonDownFcn = createCallbackFcn(app, @MainAxesButtonDown, true);
            title(app.MainAxes, "LFP and spike display");
            xlabel(app.MainAxes, "Time (s)");
            ylabel(app.MainAxes, "Signal / units");

            app.SpectrogramAxes = uiaxes(app.PlotGridLayout);
            app.SpectrogramAxes.Layout.Row = 2;
            app.SpectrogramAxes.Layout.Column = 1;
            app.SpectrogramAxes.Box = "on";
            app.SpectrogramAxes.Visible = "off";
            title(app.SpectrogramAxes, "Spectrogram");
            xlabel(app.SpectrogramAxes, "Time (s)");
            ylabel(app.SpectrogramAxes, "Frequency (Hz)");

            app.ControlPanel = uipanel(app.RootGridLayout);
            app.ControlPanel.Layout.Row = 1;
            app.ControlPanel.Layout.Column = 2;
            app.ControlPanel.Title = "Controls";

            app.ControlGridLayout = uigridlayout(app.ControlPanel, [17 2]);
            app.ControlGridLayout.ColumnWidth = {"1x", "1x"};
            app.ControlGridLayout.RowHeight = {32, 32, 12, 24, 32, 24, 32, 24, 32, 24, 32, 12, 24, 32, 24, 32, "1x"};
            app.ControlGridLayout.Padding = [10 10 10 10];
            app.ControlGridLayout.RowSpacing = 6;

            app.CountLabel = uilabel(app.ControlGridLayout);
            app.CountLabel.Layout.Row = 1;
            app.CountLabel.Layout.Column = [1 2];
            app.CountLabel.Text = "Count: 0";
            app.CountLabel.FontSize = 18;
            app.CountLabel.FontWeight = "bold";
            app.CountLabel.HorizontalAlignment = "center";

            app.SaveButton = uibutton(app.ControlGridLayout, "push");
            app.SaveButton.Layout.Row = 2;
            app.SaveButton.Layout.Column = 1;
            app.SaveButton.Text = "Save";
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);

            app.QuitButton = uibutton(app.ControlGridLayout, "push");
            app.QuitButton.Layout.Row = 2;
            app.QuitButton.Layout.Column = 2;
            app.QuitButton.Text = "Quit";
            app.QuitButton.ButtonPushedFcn = createCallbackFcn(app, @QuitButtonPushed, true);

            app.SpectrogramLabel = uilabel(app.ControlGridLayout);
            app.SpectrogramLabel.Layout.Row = 4;
            app.SpectrogramLabel.Layout.Column = [1 2];
            app.SpectrogramLabel.Text = "Spectrogram";
            app.SpectrogramLabel.FontWeight = "bold";

            app.SpectrogramButton = uibutton(app.ControlGridLayout, "push");
            app.SpectrogramButton.Layout.Row = 5;
            app.SpectrogramButton.Layout.Column = [1 2];
            app.SpectrogramButton.Text = "Show Spectrogram";
            app.SpectrogramButton.ButtonPushedFcn = createCallbackFcn(app, @SpectrogramButtonPushed, true);

            app.MinFrequencyLabel = uilabel(app.ControlGridLayout);
            app.MinFrequencyLabel.Layout.Row = 6;
            app.MinFrequencyLabel.Layout.Column = [1 2];
            app.MinFrequencyLabel.Text = "Minimum frequency (Hz)";

            app.MinFrequencyEditField = uieditfield(app.ControlGridLayout, "numeric");
            app.MinFrequencyEditField.Layout.Row = 7;
            app.MinFrequencyEditField.Layout.Column = [1 2];
            app.MinFrequencyEditField.Value = 1;

            app.MaxFrequencyLabel = uilabel(app.ControlGridLayout);
            app.MaxFrequencyLabel.Layout.Row = 8;
            app.MaxFrequencyLabel.Layout.Column = [1 2];
            app.MaxFrequencyLabel.Text = "Maximum frequency (Hz)";

            app.MaxFrequencyEditField = uieditfield(app.ControlGridLayout, "numeric");
            app.MaxFrequencyEditField.Layout.Row = 9;
            app.MaxFrequencyEditField.Layout.Column = [1 2];
            app.MaxFrequencyEditField.Value = 300;

            app.ScaleLabel = uilabel(app.ControlGridLayout);
            app.ScaleLabel.Layout.Row = 10;
            app.ScaleLabel.Layout.Column = [1 2];
            app.ScaleLabel.Text = "Power scale";

            app.ScaleDropDown = uidropdown(app.ControlGridLayout);
            app.ScaleDropDown.Layout.Row = 11;
            app.ScaleDropDown.Layout.Column = [1 2];
            app.ScaleDropDown.Items = {"root", "decibel-watt", "raw"};
            app.ScaleDropDown.Value = "root";

            app.SegmentLabel = uilabel(app.ControlGridLayout);
            app.SegmentLabel.Layout.Row = 13;
            app.SegmentLabel.Layout.Column = [1 2];
            app.SegmentLabel.Text = "Segment navigation";
            app.SegmentLabel.FontWeight = "bold";

            app.SegmentNumberLabel = uilabel(app.ControlGridLayout);
            app.SegmentNumberLabel.Layout.Row = 14;
            app.SegmentNumberLabel.Layout.Column = 1;
            app.SegmentNumberLabel.Text = "Segment";

            app.SegmentNumberDropDown = uidropdown(app.ControlGridLayout);
            app.SegmentNumberDropDown.Layout.Row = 14;
            app.SegmentNumberDropDown.Layout.Column = 2;
            app.SegmentNumberDropDown.Items = {"1"};

            app.DestinationLabel = uilabel(app.ControlGridLayout);
            app.DestinationLabel.Layout.Row = 15;
            app.DestinationLabel.Layout.Column = 1;
            app.DestinationLabel.Text = "Destination";

            app.DestinationDropDown = uidropdown(app.ControlGridLayout);
            app.DestinationDropDown.Layout.Row = 15;
            app.DestinationDropDown.Layout.Column = 2;
            app.DestinationDropDown.Items = {"beginning", "center", "end"};
            app.DestinationDropDown.Value = "beginning";

            app.TeleportButton = uibutton(app.ControlGridLayout, "push");
            app.TeleportButton.Layout.Row = 16;
            app.TeleportButton.Layout.Column = [1 2];
            app.TeleportButton.Text = "Teleport";
            app.TeleportButton.ButtonPushedFcn = createCallbackFcn(app, @TeleportButtonPushed, true);

            app.UIFigure.Visible = "on";
        end
    end

    methods (Access = public)

        function app = DucktrapApp(varargin)
            createComponents(app);
            registerApp(app, app.UIFigure);
            runStartupFcn(app, @(app) startupFcn(app, varargin{:}));

            if nargout == 0
                clear app
            end
        end

        function delete(app)
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
        end
    end
end
