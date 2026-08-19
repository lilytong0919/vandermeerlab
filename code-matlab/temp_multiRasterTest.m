% test multiRaster with single CSC multiple LFP
cd F:\Data\MvdMlab_testdata\M433_2023_09_19_recording1
% Load CSC
LoadExpKeys

please = [];
please.fc = ExpKeys.goodSWR;
please.resample = 2000;
CSC = LoadCSC(please);

% create cfg for MultiRaster
cfg.lfp = CSC;


%% Single LFP trace

% test multiRaster with single CSC multiple LFP
cd F:\Data\MvdMlab_testdata\M433_2023_09_19_recording1
% Load CSC
LoadExpKeys
please = [];
cfg = [];
please.fc = ExpKeys.goodSWR(1);
please.resample = 2000;
CSC = LoadCSC(please);

% create cfg for MultiRaster
cfg.lfp = CSC;

S = ts;
S.t{1}(1,1) = CSC.tvec(1); % make a fake S because MultiRaster requires this as an input in order to work
S.t{1}(2,1) = CSC.tvec(end);
S.label = {'fakeS'};

% other configs
cfg.SpikeHeight = 0.4;
cfg.axisflag = 'tight';
cfg.spkColor = 'k';
cfg.ivColor = 'r';
cfg.lfpColor = 'k';
cfg.lfpHeight = 15;
cfg.lfpMax = 15;
cfg.axislabel = 'on';
cfg.windowSize = 1;

% Run multiRaster
h = MultiRaster(cfg,S);

%% Single LFP with iv

% test multiRaster with single CSC multiple LFP
cd F:\Data\MvdMlab_testdata\M433_2023_09_19_recording1
% Load CSC
LoadExpKeys
please = [];
cfg = [];
please.fc = ExpKeys.goodSWR(1);
please.resample = 2000;
CSC = LoadCSC(please);

% create cfg for MultiRaster
cfg.lfp = CSC;

% Make fake iv
starts = linspace(CSC.tvec(1),CSC.tvec(end));
ends = starts+10;
cfg.evt = iv(starts,ends);

% Make fake S
S = ts;
S.t{1}(1,1) = CSC.tvec(1); % make a fake S because MultiRaster requires this as an input in order to work
S.t{1}(2,1) = CSC.tvec(end);
S.label = {'fakeS'};

% other configs
cfg.SpikeHeight = 0.4;
cfg.axisflag = 'tight';
cfg.spkColor = 'k';
cfg.ivColor = 'r';
cfg.lfpColor = 'k';
cfg.lfpHeight = 15;
cfg.lfpMax = 15;
cfg.axislabel = 'on';
cfg.windowSize = 1;

% Run multiRaster
h = MultiRaster(cfg,S);

%% Single LFP with ts

% test multiRaster with single CSC multiple LFP
cd F:\Data\MvdMlab_testdata\M433_2023_09_19_recording1
% Load CSC
LoadExpKeys
please = [];
cfg = [];
please.fc = ExpKeys.goodSWR(1);
please.resample = 2000;
CSC = LoadCSC(please);

% create cfg for MultiRaster
cfg.lfp = CSC;

% Make fake iv
starts = linspace(CSC.tvec(1),CSC.tvec(end));
cfg.evt = ts({starts'},{'1'});

% Make fake S
S = ts;
S.t{1}(1,1) = CSC.tvec(1); % make a fake S because MultiRaster requires this as an input in order to work
S.t{1}(2,1) = CSC.tvec(end);
S.label = {'fakeS'};

% other configs
cfg.SpikeHeight = 0.4;
cfg.axisflag = 'tight';
cfg.spkColor = 'k';
cfg.ivColor = 'r';
cfg.lfpColor = 'k';
cfg.lfpHeight = 15;
cfg.lfpMax = 15;
cfg.axislabel = 'on';
cfg.windowSize = 1;

% Run multiRaster
h = MultiRaster(cfg,S);
%% Two LFP trace

% test multiRaster with single CSC multiple LFP
cd F:\Data\MvdMlab_testdata\M433_2023_09_19_recording1
% Load CSC
LoadExpKeys
please = [];
cfg = [];
please.fc = ExpKeys.goodSWR(1);
please.resample = 2000;
CSC = LoadCSC(please);
% load 2nd lfp trace
please.fc = ExpKeys.goodSWR(2);
CSC2 = LoadCSC(please);

% create cfg for MultiRaster
cfg.lfp(1) = CSC;
cfg.lfp(2) = CSC;

S = ts;
S.t{1}(1,1) = CSC.tvec(1); % make a fake S because MultiRaster requires this as an input in order to work
S.t{1}(2,1) = CSC.tvec(end);
S.label = {'fakeS'};

% other configs
cfg.SpikeHeight = 0.4;
cfg.axisflag = 'tight';
cfg.spkColor = 'k';
cfg.ivColor = 'r';
% cfg.lfpColor = {'k','k'};
cfg.lfpHeight = 15;
cfg.lfpMax = 15;
cfg.axislabel = 'on';
cfg.windowSize = 1;

% Run multiRaster
h = MultiRaster(cfg,S);