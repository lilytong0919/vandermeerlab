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
            if numel(CSC.tvec) < 2 || any(diff(double(CSC.tvec(:))) <= 0)
                error('DucktrapSession:InvalidTimeVector', ...
                    'CSC.tvec must contain at least two strictly increasing samples.');
            end
            if ~isfield(S, 't') || ~iscell(S.t)
                error('DucktrapSession:InvalidSpikes', 'S.t must be a cell array of spike times.');
            end

            obj.CSC = CSC;
            obj.Spikes = S;
            obj.SuggestedIntervals = localSuggestedIntervals(cfg);
            obj.Mode = localField(cfg, 'mode', "unfixed");
            obj.TrapWindow = localField(cfg, 'trapwin', []);
            requestedWindowSize = localField(cfg, 'windowSize', 2);
            validateattributes(requestedWindowSize, {'numeric'}, ...
                {'scalar', 'real', 'finite', 'positive'});
            recordingDuration = double(CSC.tvec(end) - CSC.tvec(1));
            obj.WindowSize = min(requestedWindowSize, recordingDuration);

            firstSample = double(CSC.tvec(1));
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

        function changeWindowSize(obj, newSize)
            arguments
                obj (1,1) DucktrapSession
                newSize (1,1) double {mustBeFinite, mustBePositive}
            end

            recordingDuration = double(obj.CSC.tvec(end) - obj.CSC.tvec(1));
            obj.WindowSize = min(newSize, recordingDuration);
        end

        function teleportToSuggestedSWR(obj, swrNumber)
            arguments
                obj (1,1) DucktrapSession
                swrNumber (1,1) double {mustBeInteger, mustBePositive}
            end

            nSWRs = numel(obj.SuggestedIntervals.tstart);
            if swrNumber > nSWRs
                error('DucktrapSession:InvalidSuggestedSWR', ...
                    'Suggested SWR number %d exceeds the %d available events.', ...
                    swrNumber, nSWRs);
            end

            swrStart = double(obj.SuggestedIntervals.tstart(swrNumber));
            swrEnd = double(obj.SuggestedIntervals.tend(swrNumber));
            obj.CurrentTime = mean([swrStart swrEnd]);
        end

        function [windowStart, windowEnd] = viewLimits(obj)
            windowStart = obj.CurrentTime - obj.WindowSize / 2;
            windowEnd = obj.CurrentTime + obj.WindowSize / 2;
        end
    end
end

function intervals = localSuggestedIntervals(cfg)
if ~isfield(cfg, 'evt') || isempty(cfg.evt)
    intervals = iv([], []);
    return
end

evt = cfg.evt;
if ~isstruct(evt) || ~isfield(evt, 'tstart') || ~isfield(evt, 'tend')
    error('DucktrapSession:InvalidSuggestedSWRs', ...
        'cfg.evt must contain tstart and tend fields.');
end

tstart = double(evt.tstart(:));
tend = double(evt.tend(:));
if numel(tstart) ~= numel(tend)
    error('DucktrapSession:InvalidSuggestedSWRs', ...
        'cfg.evt.tstart and cfg.evt.tend must contain the same number of values.');
end
if any(~isfinite(tstart)) || any(~isfinite(tend)) || any(tstart > tend)
    error('DucktrapSession:InvalidSuggestedSWRs', ...
        'Suggested SWR times must be finite and each start must not exceed its end.');
end

intervals = iv(tstart, tend);
end

function value = localField(input, name, fallback)
if isfield(input, name)
    value = input.(name);
else
    value = fallback;
end
end
