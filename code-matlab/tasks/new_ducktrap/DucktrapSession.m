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
        ConfirmedMask
        HasUnsavedChanges = false
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
            obj.ConfirmedMask = false(numel(obj.SuggestedIntervals.tstart), 1);
            obj.Mode = localField(cfg, 'mode', "unfixed");
            if ~any(strcmp(obj.Mode, {'fixed', 'unfixed'}))
                error('DucktrapSession:InvalidMode', 'Mode must be fixed or unfixed.');
            end
            obj.TrapWindow = localField(cfg, 'trapwin', 0.06);
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
            obj.Label = localField(CSC, 'label', localField(cfg, 'label', ""));
            obj.Header = localField(cfg, 'hdr', []);
            obj.ConfigForHistory = cfg;
            if isfield(obj.ConfigForHistory, 'lfp')
                obj.ConfigForHistory = rmfield(obj.ConfigForHistory, 'lfp');
            end
            resume = localField(cfg, 'resume', []);
            if ~isempty(resume)
                resumed = localSuggestedIntervals(struct('evt', resume));
                for i = 1:numel(resumed.tstart)
                    obj.PendingInterval = [resumed.tstart(i), resumed.tend(i)];
                    obj.confirmPending(true);
                end
                obj.HasUnsavedChanges = false;
            end
        end

        function selectBoundary(obj, time)
            validateattributes(time, {'numeric'}, {'scalar', 'real', 'finite'});
            if time < obj.CSC.tvec(1) || time > obj.CSC.tvec(end)
                return
            end
            if strcmp(obj.Mode, 'fixed')
                validateattributes(obj.TrapWindow, {'numeric'}, {'scalar', 'positive', 'finite'});
                obj.PendingInterval = time + [-1 1] * obj.TrapWindow/2;
                obj.PendingInterval = max(double(obj.CSC.tvec(1)), ...
                    min(double(obj.CSC.tvec(end)), obj.PendingInterval));
                obj.State = "twice";
            elseif isempty(obj.FirstBoundary) || ~isempty(obj.PendingInterval)
                obj.FirstBoundary = time;
                obj.PendingInterval = [];
                obj.State = "once";
            elseif time ~= obj.FirstBoundary
                obj.PendingInterval = sort([obj.FirstBoundary time]);
                obj.State = "twice";
            end
        end

        function cancelSelection(obj)
            obj.FirstBoundary = [];
            obj.PendingInterval = [];
            obj.State = "ready";
        end

        function indices = pendingOverlaps(obj)
            indices = [];
            if isempty(obj.PendingInterval), return; end
            indices = find(obj.SuggestedIntervals.tstart < obj.PendingInterval(2) & ...
                obj.SuggestedIntervals.tend > obj.PendingInterval(1));
        end

        function index = confirmPending(obj, replaceOverlaps)
            index = [];
            if isempty(obj.PendingInterval), return; end
            overlaps = obj.pendingOverlaps();
            if ~isempty(overlaps) && ~replaceOverlaps, return; end
            keep = true(numel(obj.ConfirmedMask), 1);
            keep(overlaps) = false;
            bounds = obj.PendingInterval;
            starts = [obj.SuggestedIntervals.tstart(keep); bounds(1)];
            ends = [obj.SuggestedIntervals.tend(keep); bounds(2)];
            confirmed = [obj.ConfirmedMask(keep); true];
            [starts, order] = sort(starts);
            obj.SuggestedIntervals = iv(starts, ends(order));
            obj.ConfirmedMask = confirmed(order);
            index = find(order == numel(order));
            obj.ConfirmedIntervals = iv(starts(obj.ConfirmedMask), ...
                obj.SuggestedIntervals.tend(obj.ConfirmedMask));
            obj.HasUnsavedChanges = true;
            obj.cancelSelection();
        end

        function deleteEvent(obj, index)
            validateattributes(index, {'numeric'}, {'scalar', 'integer', 'positive', ...
                '<=', numel(obj.ConfirmedMask)});
            obj.SuggestedIntervals.tstart(index) = [];
            obj.SuggestedIntervals.tend(index) = [];
            obj.ConfirmedMask(index) = [];
            obj.ConfirmedIntervals = iv(obj.SuggestedIntervals.tstart(obj.ConfirmedMask), ...
                obj.SuggestedIntervals.tend(obj.ConfirmedMask));
            obj.HasUnsavedChanges = true;
            obj.cancelSelection();
        end

        function evt = exportEvents(obj, includeSuggestions)
            mask = obj.ConfirmedMask | includeSuggestions;
            starts = obj.SuggestedIntervals.tstart(mask);
            ends = obj.SuggestedIntervals.tend(mask);
            [starts, order] = sort(starts);
            evt = iv(starts, ends(order));
            evt.label = obj.Label;
            evt.hdr = obj.Header;
            evt = History(evt, 'DucktrapApp', obj.ConfigForHistory);
        end

        function markSaved(obj)
            obj.HasUnsavedChanges = false;
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
