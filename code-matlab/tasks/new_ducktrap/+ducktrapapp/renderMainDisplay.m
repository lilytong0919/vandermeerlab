function handles = renderMainDisplay(ax, session, selectedEvent)
%RENDERMAINDISPLAY Render the current Ducktrap view into an explicit UIAxes.
%
% This first renderer intentionally favors a small, replaceable interface
% over legacy MultiRaster compatibility. Later display work can optimize or
% replace its internals without changing app callbacks or session actions.

arguments
    ax (1,1) matlab.ui.control.UIAxes
    session (1,1) DucktrapSession
    selectedEvent = []
end

[windowStart, windowEnd] = session.viewLimits();
tvec = double(session.CSC.tvec(:));
lfp = double(session.CSC.data(:));
sampleMask = tvec >= windowStart & tvec <= windowEnd;

cla(ax);
hold(ax, 'on');

handles = struct('Intervals', gobjects(0), 'LFP', gobjects(0), ...
    'Spikes', gobjects(0));

if any(sampleMask)
    visibleLFP = lfp(sampleMask);
    amplitude = max(abs(visibleLFP));
    if amplitude > 0
        visibleLFP = visibleLFP / amplitude;
    end
    handles.LFP = plot(ax, tvec(sampleMask), visibleLFP, ...
        'Color', [0.12 0.12 0.12], 'LineWidth', 0.75, ...
        'DisplayName', 'LFP', 'HitTest', 'off');
end

nUnits = numel(session.Spikes.t);
topY = max(1, nUnits + 1);
intervals = session.SuggestedIntervals;
if isfield(intervals, 'tstart') && isfield(intervals, 'tend')
    for iEvent = 1:min(numel(intervals.tstart), numel(intervals.tend))
        eventStart = double(intervals.tstart(iEvent));
        eventEnd = double(intervals.tend(iEvent));
        if eventEnd >= windowStart && eventStart <= windowEnd
            color = [1.00 0.88 0.45];
            if ismember(iEvent, selectedEvent)
                color = [0.25 0.75 0.40];
            end
            handles.Intervals(end + 1) = patch(ax, ...
                [eventStart eventEnd eventEnd eventStart], ...
                [-1.2 -1.2 topY + 0.5 topY + 0.5], ...
                color, 'FaceAlpha', 0.22, ...
                'EdgeColor', 'none', 'HitTest', 'off', ...
                'DisplayName', 'Suggested event');
        end
    end
end

for iUnit = 1:nUnits
    spikeTimes = double(session.Spikes.t{iUnit}(:));
    spikeTimes = spikeTimes(spikeTimes >= windowStart & spikeTimes <= windowEnd);
    if isempty(spikeTimes)
        continue
    end
    x = reshape([spikeTimes spikeTimes nan(size(spikeTimes))].', [], 1);
    y = reshape(repmat([iUnit - 0.35 iUnit + 0.35 NaN], numel(spikeTimes), 1).', [], 1);
    handles.Spikes(end + 1) = plot(ax, x, y, 'Color', [0.15 0.35 0.75], ...
        'LineWidth', 0.8, 'HitTest', 'off');
end

% Keep the signal and raster visually distinct while sharing a time axis.
if nUnits > 0
    ylim(ax, [-1.2 nUnits + 0.5]);
    yticks(ax, [-1 1:nUnits]);
    yticklabels(ax, ["LFP", string(1:nUnits)]);
else
    ylim(ax, [-1.2 1.2]);
    yticks(ax, 0);
    yticklabels(ax, "LFP");
end
xlim(ax, [windowStart windowEnd]);
hold(ax, 'on');
bounds = session.PendingInterval;
if isempty(bounds)
    bounds = session.FirstBoundary;
end
for boundary = bounds
    xline(ax, boundary, 'Color', [0.9 0.25 0.15], 'LineWidth', 1.5, ...
        'HitTest', 'off', 'PickableParts', 'none');
end
disableDefaultInteractivity(ax);
ax.Toolbar.Visible = 'off';
set(findall(ax, '-property', 'PickableParts'), 'PickableParts', 'none');
ax.PickableParts = 'all';
xlabel(ax, 'Time (s)');
ylabel(ax, 'Signal / unit');
box(ax, 'on');
hold(ax, 'off');

% Put interval patches behind the signal and spike marks.
if ~isempty(handles.Intervals)
    uistack(handles.Intervals, 'bottom');
end
end
