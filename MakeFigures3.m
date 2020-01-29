% Make figures
% waveform predictions (with AM) 
% Waveform Interactions
% (for RMS see plotRMS2)

addpath /commonFunctions


% see pred.labels for details
% first 12 are 1st exp, from 12 is the 2nd exp
clearvars;
cfg.layout = 'biosemi128.lay';
cfg.channel =  {'all','-EXG1', '-EXG2', '-EXG3','-EXG4','-EXG5','-EXG6','-EXG7','-EXG8', '-Status'};

dataPath = {'/Users/marleneponcet/Documents/data/LongRangeV2/', '/Users/marleneponcet/Documents/data/LRshortDC/V2/'};


%%%%%% compute average
for ee=1:2 % which experiment
    clear sbjprediction avPredictions
    load([dataPath{ee} 'sbjprediction.mat'])
    load(['rmseCoefE' num2str(ee) '.mat'])
    
    avPredictions = averageSbj(sbj);
    avPredictions(1).condLabel = 'originalmotion';
    avPredictions(2).condLabel = 'linear';
    avPredictions(3).condLabel = 'spatial';
    avPredictions(4).condLabel = 'temp';
    avPredictions(5).condLabel = 'spatiotemp';
    avPredictions(6).condLabel = 'SR originalmotion';
    avPredictions(7).condLabel = 'SR linearPred';
    avPredictions(8).condLabel = 'SR spatialPred';
    avPredictions(9).condLabel = 'SR tempPred';
    avPredictions(10).condLabel = 'SR spatiotempPred';
    avPredictions(11).condLabel = 'LR STnl';
    avPredictions(12).condLabel = 'SR STnl';
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% plot average predictions
    figure('Renderer', 'painters', 'Position', [10 10 1200 500])
    condRange = {'LR','SR'};
    for ss=1:2
        for chan=1:length(pickElec)
            subplot(2,3,chan+3*(ss-1)); hold on;
            for mm=1:5 % long/short range
                plot(avPredictions(mm+5*(ss-1)).time,avPredictions(mm+5*(ss-1)).filteredWave(pickElec(chan),:),'LineWidth',2);
            end
            title([condRange{ss} num2str(pickElec(chan))])
            line([0 400],[0 0],'Color','k','LineStyle','--')
            legend('AM','linear','spatial','temp','ST','Location','Best')
            if ee==2
                ylim([-4 6])
            elseif ee==1
                ylim([-1.5 2])
            end
        end
    end
    saveas(gcf,['figures' filesep 'E' num2str(ee) 'predictions'],'png')
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%% plot interactions
    figure('Renderer', 'painters', 'Position', [10 10 1200 250])
    for chan=1:length(pickElec)
        subplot(1,3,chan); hold on;
        for mm=3:4 % long/short range
            plot(avPredictions(mm).time,avPredictions(2).filteredWave(pickElec(chan),:) - avPredictions(mm).filteredWave(pickElec(chan),:),'LineWidth',2);
            plot(avPredictions(mm+5).time,avPredictions(2+5).filteredWave(pickElec(chan),:) - avPredictions(mm+5).filteredWave(pickElec(chan),:),'LineWidth',2);
        end
        title(['interaction chan' num2str(pickElec(chan))])
        line([0 400],[0 0],'Color','k','LineStyle','--')
        legend('spatL','spatS','tempL','tempS','Location','Best')
        if ee==2
            ylim([-3 4])
        elseif ee==1
            ylim([-3 4])
        end
    end
    saveas(gcf,['figures' filesep 'E' num2str(ee) 'interactions'],'png')
    

end

