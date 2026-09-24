function [h, fig] = plotMockData()
%PLOTMOCKDATA Plot the Ducktrap mock data with MultiRaster.
%
%   [H, FIG] = PLOTMOCKDATA() provides a legacy display and
%   navigation baseline using the same deterministic inputs as
%   DEMO_DUCKTRAPAPP. It does not change the current working directory.

[cfg, S, CSC] = generateDucktrapMockData();

% Resolve shared legacy functions relative to this file. Keep them on the
% path because MultiRaster's figure callbacks use navigate after return.
demoFolder = fileparts(mfilename('fullpath'));
codeFolder = fileparts(fileparts(demoFolder));
sharedFolder = fullfile(codeFolder, 'shared');
addpath( ...
    fullfile(sharedFolder, 'viz'), ...
    fullfile(sharedFolder, 'viz', 'matlab-plot-big'), ...
    fullfile(sharedFolder, 'io'), ...
    fullfile(sharedFolder, 'util'), ...
    fullfile(sharedFolder, 'datatypes', 'ts'), ...
    fullfile(sharedFolder, 'datatypes', 'tsd'), ...
    fullfile(sharedFolder, 'datatypes', 'iv'));

plotCfg.lfp = CSC;
plotCfg.evt = cfg.evt;
plotCfg.windowSize = cfg.windowSize;
plotCfg.openNewFig = 1;
plotCfg.axisflag = 'spandex';

h = MultiRaster(plotCfg, S);
fig = gcf;

% Match DucktrapApp's initial view around the first suggested event so the
% two navigation implementations start from the same visible interval.
firstEventCenter = mean([cfg.evt.tstart(1), cfg.evt.tend(1)]);
xlim(fig.CurrentAxes, firstEventCenter + cfg.windowSize * [-0.5 0.5]);
end
