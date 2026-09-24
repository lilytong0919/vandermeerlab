classdef DucktrapSession < handle
    % DUCKTRAPSESSION State-model scaffold for DucktrapApp.
    %
    % This class owns non-graphical data and view state. UI callbacks and
    % renderers should operate through this state instead of legacy globals.

    properties (SetAccess = private)
        Mode
        TrapWindow
        State
        FirstBoundary
        PendingInterval
        ConfirmedIntervals
        ResumeIntervals
        SuggestedIntervals
        Segments
        Label
        Header
        ConfigForHistory
        CSC
        Spikes
        CurrentTime
        WindowSize
    end

    methods
        function obj = DucktrapSession(cfg, S, CSC)
            arguments
                cfg (1,1) struct
                S (1,1) struct
                CSC (1,1) struct
            end

            validateattributes(CSC.tvec, {'numeric'}, {'vector', 'real', 'finite', 'nonempty'});
            validateattributes(CSC.data, {'numeric'}, {'vector', 'real', 'finite', 'nonempty'});
            if numel(CSC.tvec) ~= numel(CSC.data)
                error('DucktrapSession:DataSizeMismatch', ...
                    'CSC.tvec and CSC.data must contain the same number of samples.');
            end
            if ~isfield(S, 't') || ~iscell(S.t)
                error('DucktrapSession:InvalidSpikes', 'S.t must be a cell array of spike times.');
            end

            obj.CSC = CSC;
            obj.Spikes = S;
            obj.SuggestedIntervals = localField(cfg, 'evt', struct('tstart', [], 'tend', []));
            obj.Segments = localField(cfg, 'segments', struct('tstart', [], 'tend', []));
            obj.Mode = localField(cfg, 'mode', "unfixed");
            obj.TrapWindow = localField(cfg, 'trapwin', []);
            obj.WindowSize = localField(cfg, 'windowSize', 2);
            validateattributes(obj.WindowSize, {'numeric'}, {'scalar', 'real', 'finite', 'positive'});

            firstSample = double(CSC.tvec(1));
            if ~isempty(obj.Segments.tstart)
                firstSample = max(firstSample, double(obj.Segments.tstart(1)));
            end
            obj.CurrentTime = firstSample + obj.WindowSize / 2;
            if ~isempty(obj.SuggestedIntervals.tstart)
                firstStart = double(obj.SuggestedIntervals.tstart(1));
                firstEnd = double(obj.SuggestedIntervals.tend(1));
                obj.CurrentTime = mean([firstStart firstEnd]);
            end
            obj.State = "ready";
            obj.FirstBoundary = [];
            obj.PendingInterval = [];
            obj.ConfirmedIntervals = struct('tstart', [], 'tend', []);
            obj.ResumeIntervals = struct('tstart', [], 'tend', []);
            obj.Label = localField(cfg, 'label', "");
            obj.Header = struct();
            obj.ConfigForHistory = cfg;
        end
    end
end

function value = localField(input, name, fallback)
if isfield(input, name)
    value = input.(name);
else
    value = fallback;
end
end
