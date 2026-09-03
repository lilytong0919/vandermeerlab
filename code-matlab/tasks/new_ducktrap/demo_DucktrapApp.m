function app = demo_DucktrapApp()
%DEMO_DUCKTRAPAPP Launch legacy ducktrap with reproducible synthetic data.
%
%   APP = DEMO_DUCKTRAPAPP() creates 25 seconds of synthetic LFP and spike
%   data, including several ripple-like events, and opens the legacy
%   ducktrap interface. APP is the legacy figure handle.
%
%   The generated inputs follow the data contract intended for DucktrapApp:
%   CSC contains tvec, data, and label; S contains cell arrays t and label;
%   and CFG contains suggested events and recording segments. The random
%   seed is fixed so that every run produces the same data.

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

CSC.tvec = tvec;
CSC.data = lfp';
CSC.label = {"synthetic LFP"};
CSC.type = "tsd";
CSC.units = "a.u.";

% Generate inhomogeneous Poisson-like spike trains. Each unit has a stable
% background rate and a transient firing-rate increase around ripples.
nUnits = 5;
S.type = "ts";
S.t = cell(1, nUnits);
S.label = cell(1, nUnits);
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
cfg.evt.tstart = rippleCenters - eventHalfWidth;
cfg.evt.tend = rippleCenters + eventHalfWidth;

cfg.segments.tstart = [0.5; 9.0; 17.0];
cfg.segments.tend = [8.0; 16.0; 24.5];
cfg.mode = "fixed";
cfg.trapwin = 2 * eventHalfWidth;
cfg.windowSize = 2;
cfg.EnableRobot = 0;

% Resolve repository paths relative to this file; do not change pwd.
demoFolder = fileparts(mfilename("fullpath"));
codeFolder = fileparts(fileparts(demoFolder));
sharedFolder = fullfile(codeFolder, "shared");
legacyFolder = fullfile(codeFolder, "tasks", "Alyssa_Tmaze", "beta");
addpath(genpath(sharedFolder));
addpath(legacyFolder);

ducktrap(cfg, S, CSC);
app = gcf;

end
