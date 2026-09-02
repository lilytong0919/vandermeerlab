classdef DucktrapSession < handle
    % DUCKTRAPSESSION State-model scaffold for DucktrapApp.
    %
    % This initial class declares the state that will eventually replace the
    % shared variables in the legacy ducktrap nested callbacks. State
    % transitions and output construction are intentionally not implemented.

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
    end

    methods
        function obj = DucktrapSession(varargin) %#ok<INUSD>
            % TODO: Validate configuration and initialize session state.
        end
    end
end
