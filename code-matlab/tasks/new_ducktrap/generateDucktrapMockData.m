function [cfg, S, CSC] = generateDucktrapMockData()
%GENERATEDUCKTRAPMOCKDATA Create reproducible Ducktrap development inputs.
%
%   [CFG, S, CSC] = GENERATEDUCKTRAPMOCKDATA() returns deterministic LFP,
%   spike, suggested-event, and recording-segment structures. The function
%   does not modify the MATLAB path, current folder, graphics state, or
%   application state.

previousRandomState = rng;
restoreRandomState = onCleanup(@() rng(previousRandomState));
rng(271828, "twister");

sampleRate = 2000;
duration = 25;
tvec = (0:1 / sampleRate:duration - 1 / sampleRate)';

% Combine low-frequency background activity, broadband noise, and
% Gaussian-windowed high-frequency ripple bursts.
lfp = 0.35 * sin(2 * pi * 7 * tvec) ...
    + 0.15 * sin(2 * pi * 32 * tvec + 0.4) ...
    + 0.25 * randn(size(tvec));

rippleCenters = [3.2; 6.8; 10.7; 14.9; 18.4; 22.1];
rippleFrequencies = [155; 170; 185; 160; 195; 175];
rippleAmplitudes = [2.2; 2.8; 2.4; 3.0; 2.5; 2.9];
rippleSigma = 0.030;

for iRipple = 1:numel(rippleCenters)
    relativeTime = tvec - rippleCenters(iRipple);
    envelope = exp(-0.5 * (relativeTime / rippleSigma).^2);
    lfp = lfp + rippleAmplitudes(iRipple) * envelope ...
        .* sin(2 * pi * rippleFrequencies(iRipple) * relativeTime);
end

% Store volts in the row-oriented representation used by the legacy tsd.
CSC.data = (1e-4 * lfp)';
CSC.units = "V";
CSC.tvec = tvec;
CSC.label = {"synthetic LFP"};
CSC.type = "tsd";
CSC.cfg.history.mfun{1} = mfilename;
CSC.cfg.history.cfg{1} = [];

% Generate inhomogeneous Poisson-like spike trains. Each unit has a stable
% background rate and a transient firing-rate increase around ripples.
nUnits = 5;
S.type = "ts";
S.t = cell(1, nUnits);
S.label = cell(1, nUnits);
S.cfg.history.mfun{1} = mfilename;
S.cfg.history.cfg{1} = [];
spikeSigma = 0.070;

eventDrive = zeros(size(tvec));
for iRipple = 1:numel(rippleCenters)
    eventDrive = eventDrive ...
        + exp(-0.5 * ((tvec - rippleCenters(iRipple)) / spikeSigma).^2);
end

for iUnit = 1:nUnits
    backgroundRate = 3 + 1.5 * iUnit;
    eventRate = (12 + 3 * iUnit) * eventDrive;
    instantaneousRate = backgroundRate + eventRate;
    spikeMask = rand(size(tvec)) < instantaneousRate / sampleRate;
    S.t{iUnit} = tvec(spikeMask);
    S.label{iUnit} = sprintf("synthetic unit %d", iUnit);
end

eventHalfWidth = 0.060;
cfg.evt = iv(rippleCenters - eventHalfWidth, rippleCenters + eventHalfWidth);
cfg.segments = cfg.evt;
cfg.mode = "unfixed";
cfg.trapwin = 2 * eventHalfWidth;
cfg.windowSize = 2;
cfg.EnableRobot = 0;
end
