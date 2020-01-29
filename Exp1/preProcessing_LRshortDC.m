function preProcessing_LRshortDC(sbjNb)

ff = sbjNb;

addpath /commonFunctions


% path to the files
dataDir = '/Users/marleneponcet/Documents/data/LRshortDC/V2/originalData/';
dataOut = '/Users/marleneponcet/Documents/data/LRshortDC/V2/cleanData/';
eegFiles = dir([dataDir '*.bdf']);
behavFiles = dir([dataDir '*.mat']);


clear data, clear cfg, clear cleanData;
cfg.dataset   =  [dataDir eegFiles(ff).name];

% read the behavioural file
load([dataDir behavFiles(ff).name])

%%%%%% ONLY variables that are the same in ALL conditions
cfg.trialdef.preStimDuration = experimentData(1).condInfo.preStimDuration;
cfg.trialdef.trialLength = experimentData(1).trialData.trialDuration;

% define trials
cfg.trialdef.bitmask = 2^9-1; %Values to keep.
cfg.trialdef.condRange = [101 165]; % all possible conditions
cfg.trialdef.ssvepTagVal = 1;
cfg.layout = 'biosemi128.lay';
cfg.trialfun = 'defTrial_LRshortDC';
[cfg] = ft_definetrial(cfg);

% pre-processing
cfg.demean        ='no'; % useless with detrend. applies baseline correction to the entire trial by default (or to the specified window in cfg.baselinewindow)
cfg.reref         = 'yes';
cfg.refchannel    = {'A1'}; % A3 = CPz / use Cz = A1
%    cfg.refchannel =  {'all','-EXG1', '-EXG2', '-EXG3','-EXG4','-EXG5','-EXG6','-EXG7','-EXG8', '-Status'};
cfg.lpfilter  = 'yes';
cfg.lpfreq = 85; % 85; % screen 85Hz ...  49 would really clear noise, not 85
cfg.hpfreq = 1;
cfg.hpfilter = 'no'; % does NOT work anyway
cfg.detrend = 'yes';
[data] = ft_preprocessing(cfg);





% resample the data so we have an integer number of samples per cycle
% and define the trials (trl) based on the resampled data
cfg.newFs = 85*6; %Integer number of samples per monitor refresh (~500)
cfg.trialdef.epochLength = 32/85*6; % size of the window for cutting trials (in seconds)
cfg.trialdef.cycleLength = 32/85;
data = resample_ssvep(cfg,data);

%%%%%%%%%%%%%%%%%%%
% artefact rejection
% first check for extrem channels/trials
cfg.layout = 'biosemi128.lay';
cfg.method = 'distance';
cfg.neighbours = ft_prepare_neighbours(cfg, data);

cfg.method = 'summary';
cfg.keepchannel = 'repair'; % had to modify ft_rejectvisual line 343 so that layout was taken into account
[data] = ft_rejectvisual(cfg, data); % if I want to change the way how the channels are interpolated then will have to do channel repair separately (will also not have to change the rejectvisual function)


% do the cleaning on 16 channels cap + 4 electrodes around the eyes
cfg.channel =  {'C28','C29','C30','C16','C17','C18','C4','C21','D4','D23','D19','A1','B22','B26','B4','A19','A7','A15','A23','A28','EXG2', 'EXG3','EXG4'}; % {'fp1','fp2','p4','fz','f3','t7','c3','cz','c4','t8','p4','pz','p3','o1','oz','o2'}
cfg.viewmode = 'vertical';
cfg = ft_databrowser(cfg,data);
cfg.artfctdef.reject = 'complete';
[cleanData] = ft_rejectartifact(cfg, data);

save([dataOut eegFiles(ff).name(1:end-4) '_clean'],'cleanData')

end


