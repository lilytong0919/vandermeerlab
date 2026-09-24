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
            if numel(CSC.tvec) < 2 || any(diff(double(CSC.tvec(:))) <= 0)
                error('DucktrapSession:InvalidTimeVector', ...
                    'CSC.tvec must contain at least two strictly increasing samples.');
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
            requestedWindowSize = localField(cfg, 'windowSize', 2);
            validateattributes(requestedWindowSize, {'numeric'}, ...
                {'scalar', 'real', 'finite', 'positive'});
            recordingDuration = double(CSC.tvec(end) - CSC.tvec(1));
            obj.WindowSize = min(requestedWindowSize, recordingDuration);

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

        function changeWindowSize(obj, newSize)
            arguments
                obj (1,1) DucktrapSession
                newSize (1,1) double {mustBeFinite, mustBePositive}
            end

            recordingDuration = double(obj.CSC.tvec(end) - obj.CSC.tvec(1));
            obj.WindowSize = min(newSize, recordingDuration);
            obj.CurrentTime = obj.clampCenter(obj.CurrentTime);
        end

        function teleportToSegment(obj, segmentNumber, destination)
            arguments
                obj (1,1) DucktrapSession
                segmentNumber (1,1) double {mustBeInteger, mustBePositive}
                destination (1,1) string {mustBeMember(destination, ["beginning", "center", "end"])}
            end

            nSegments = min(numel(obj.Segments.tstart), numel(obj.Segments.tend));
            if segmentNumber > nSegments
                error('DucktrapSession:InvalidSegment', ...
                    'Segment number %d exceeds the %d available segments.', ...
                    segmentNumber, nSegments);
            end

            segmentStart = double(obj.Segments.tstart(segmentNumber));
            segmentEnd = double(obj.Segments.tend(segmentNumber));
            switch destination
                case "beginning"
                    targetTime = segmentStart;
                case "center"
                    targetTime = mean([segmentStart segmentEnd]);
                case "end"
                    targetTime = segmentEnd;
            end
            obj.CurrentTime = obj.clampCenter(targetTime);
        end

        function [windowStart, windowEnd] = viewLimits(obj)
            dataStart = double(obj.CSC.tvec(1));
            dataEnd = double(obj.CSC.tvec(end));
            if obj.WindowSize >= dataEnd - dataStart
                windowStart = dataStart;
                windowEnd = dataEnd;
                return
            end

            windowStart = obj.CurrentTime - obj.WindowSize / 2;
            windowEnd = obj.CurrentTime + obj.WindowSize / 2;
            if windowStart < dataStart
                windowStart = dataStart;
                windowEnd = dataStart + obj.WindowSize;
            elseif windowEnd > dataEnd
                windowEnd = dataEnd;
                windowStart = dataEnd - obj.WindowSize;
            end
        end
    end

    methods (Access = private)
        function center = clampCenter(obj, center)
            dataStart = double(obj.CSC.tvec(1));
            dataEnd = double(obj.CSC.tvec(end));
            halfWindow = min(obj.WindowSize, dataEnd - dataStart) / 2;
            center = min(max(double(center), dataStart + halfWindow), dataEnd - halfWindow);
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
