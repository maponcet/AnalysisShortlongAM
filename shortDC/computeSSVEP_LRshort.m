% create Axx files (1 per participant)
% compute steady state and the predictions

clearvars;
addpath /commonFunctions

dataDir = '/Users/marleneponcet/Documents/data/LRshortDC/V2/cleanData/';
listData = dir([dataDir '*.mat']);
dataOut = '/Users/marleneponcet/Documents/data/LRshortDC/V2/Axx/';

for ff=1:length(listData)
    
    clear cleanData; clear Axx; clear cfg;
    load([dataDir listData(ff).name]);
    
    
    % compute steady state
    cleanData=rmfield(cleanData,'cfg'); % clear cfg so that the data does not become too heavy

    % 1 Axx per sbj
    cfg.channel =  {'all','-EXG1', '-EXG2', '-EXG3','-EXG4','-EXG5','-EXG6','-EXG7','-EXG8', '-Status'};
    cfg.layout = 'biosemi128.lay';
    allcond = unique(cleanData.trialinfo(:,1));
    
    
    for cond=1:length(allcond)
        cfg.trials = find(cleanData.trialinfo(:,1) == allcond(cond));
        [Axx(cond)] = ft_steadystateanalysis(cfg, cleanData); % the field elec is present only if a channel has been replaced
    end
        
    
    % get the condition labels
    aa = {'Long','Short'}; bb=[0 6];
    for tt=1:2
    Axx(1+bb(tt)).condLabel = [aa{tt} 'Motion'];
    Axx(2+bb(tt)).condLabel = [aa{tt} 'Left'];
    Axx(3+bb(tt)).condLabel = [aa{tt} 'Right'];
    Axx(4+bb(tt)).condLabel = [aa{tt} 'Simult'];
    Axx(5+bb(tt)).condLabel = [aa{tt} 'HalfLeft'];
    Axx(6+bb(tt)).condLabel = [aa{tt} 'HalfRight'];
    end
    
    save([dataOut 'Axx_' listData(ff).name(1:15)],'Axx')
    
end
