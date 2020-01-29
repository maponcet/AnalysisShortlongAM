close all;
clearvars;

% to get an approximation of baseline brain activity, get the amount of
% noise in the harmonics compare to sig
% to approximate this baseline noise/activity, get the  average
% amplitude of the neighbouring freq harmonic

addpath /commonFunctions

dataPath = {'/Users/marleneponcet/Documents/data/LongRangeV2/', '/Users/marleneponcet/Documents/data/LRshortDC/V2/'};

for dd=1:2 % which experiment (different duty-cycle used)
    load([dataPath{dd} 'sbjprediction.mat'])
    clear baseAmp previousAmp;
    
    for sbjInd=1:length(sbj)
        
        for condIdx=1:size(sbj,2)            
            % the function used for re-creating the waveform
            % (filterSteadyState) is using other fields in the structure so
            % copy the signal in a temp variable to use the function
            clear modifSig
            modifSig = sbj(sbjInd,condIdx).data;
            
            filtIdx = determineFilterIndices( 'nf1low49', sbj(sbjInd,condIdx).data.freq, sbj(sbjInd,condIdx).data.i1f1 );
            
            %Create a logical matrix selecting frequency components.
            filtMat = false(size(sbj(sbjInd,condIdx).data.amp));
            filtMat(:,filtIdx) = true;
            cfg.activeFreq =  sbj(sbjInd,condIdx).data.activeFreq;
            
            % get the old and new amplitude for the freq considered
            for chan=1:size(sbj(sbjInd,condIdx).data.amp,1)
                baseAmp(chan,:) = mean([sbj(sbjInd,condIdx).data.amp(chan,filtIdx-1); sbj(sbjInd,condIdx).data.amp(chan,filtIdx+1)]);
                previousAmp(chan,:) = sbj(sbjInd,condIdx).data.amp(chan,filtIdx);
            end
            
            % previousAmp / new = scale factor to be applied to cos and sin
            % or can first scale the previous amp to 1 and then scale to
            % the new baseline amplitude
            scaleFactor =  baseAmp ./ previousAmp ;
            modifSig.cos(:,filtIdx) = scaleFactor .* sbj(sbjInd,condIdx).data.cos(:,filtIdx);
            modifSig.sin(:,filtIdx) = scaleFactor .* sbj(sbjInd,condIdx).data.sin(:,filtIdx);
            
            % reconstruct waveform
            % this is actually a WRONG waveform as we cannot know the phase
            % of the signal. However, it can be used to calculate RMS or
            % sumofsquares because the deviation over time will be the same
            % whatever the phase
            [ noiseWave ] = filterSteadyState( cfg, modifSig );
            noiseWave(isnan(noiseWave))=0; % replace NaN by 0
            sbj(sbjInd,condIdx).data.noiseWave = noiseWave;
        end
    end
    
    save([dataPath{dd} 'sbjprediction.mat'],'sbj');
    
end
