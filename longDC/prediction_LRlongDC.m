

clearvars;
addpath /commonFunctions

dataDir = '/Users/marleneponcet/Documents/data/LongRangeV2/';
listData = dir([dataDir '*.mat']);
cfg.layout = 'biosemi128.lay';
cfg.channel =  {'all','-EXG1', '-EXG2', '-EXG3','-EXG4','-EXG5','-EXG6','-EXG7','-EXG8', '-Status'};

for ff=1:length(listData)
    clear Axx;
    load([dataDir listData(ff).name]);
    fprintf('Processing sbj %s \n',num2str(ff))
    
    % original LR motion
    sbj(ff,1).data = Axx(1);
    
    % linear prediction
    sbj(ff,2).data = sumAxxWithShift(Axx(3),Axx(2)); %1st is the one to shift, 2nd does not 
    % difference recorded motion - linear prediction
    sbjDiff(ff,1).data = computeDiff(sbj(ff,1).data,sbj(ff,2).data); 
    
    % linear prediction + spatial interaction
    % reconstructed LR simultaneous
    linearSpatial = sumAxx(Axx(3),Axx(2));   
    % original LR simultaneous
    actualSpatial = Axx(4);  
    % difference
    nonLinearSpatial = computeDiff(actualSpatial,linearSpatial); % data1-data2
    interaction(ff,1).data = nonLinearSpatial;
    % get half of the interaction term
    halfNonLinearSpatial = multiplyAxx(nonLinearSpatial,0.5);
    % spatial prediction
    sbj(ff,3).data = sumAxxWithShift(sumAxx(Axx(3),halfNonLinearSpatial),sumAxx(Axx(2),halfNonLinearSpatial));
    % difference recorded motion - linear+spatial prediction
    sbjDiff(ff,2).data = computeDiff(sbj(ff,1).data,sbj(ff,3).data); 
    
    % linear prediction + temporal interaction
    % reconstructed LR flash left
    linearTemp1 = sumAxxWithShift(Axx(2),Axx(2));   
    % original LR flash left
    actualTemp1 = Axx(5);  
    % difference
    nonLinearL = computeDiff(actualTemp1,linearTemp1);
    interaction(ff,2).data = nonLinearL;
     % get half of the interaction term
    halfNonLinearL = multiplyAxx(nonLinearL,0.5);
    % reconstructed LR flash right
    linearTemp2 = sumAxxWithShift(Axx(3),Axx(3));   
    % original LR flash right
    actualTemp2 = Axx(6);  
    % difference and * 0.5
    interaction(ff,3).data = computeDiff(actualTemp2,linearTemp2);
    halfNonLinearR = multiplyAxx(computeDiff(actualTemp2,linearTemp2),0.5);    
    % temporal prediction
    sbj(ff,4).data = sumAxxWithShift(sumAxx(Axx(3),halfNonLinearR),sumAxx(Axx(2),halfNonLinearL));
    % difference recorded motion - linear+temporal prediction
    sbjDiff(ff,3).data = computeDiff(sbj(ff,1).data,sbj(ff,4).data); 
    
    % linear prediction + spatial interaction + temporal interaction 
    poolNonLinearL = sumAxx(halfNonLinearSpatial,halfNonLinearL);
    poolNonLinearR = sumAxx(halfNonLinearSpatial,halfNonLinearR);
    sbj(ff,5).data = sumAxxWithShift(sumAxx(Axx(3),poolNonLinearR),sumAxx(Axx(2),poolNonLinearL));
    % difference recorded motion - full prediction
    sbjDiff(ff,4).data = computeDiff(sbj(ff,1).data,sbj(ff,5).data); 
    
    % original SR motion
    sbj(ff,6).data = Axx(7);
    
    % linear prediction
    sbj(ff,7).data = sumAxxWithShift(Axx(9),Axx(8)); %1st is the one to shift, 2nd does not 
    % difference recorded motion - prediction
    sbjDiff(ff,5).data = computeDiff(sbj(ff,6).data,sbj(ff,7).data); 
    
    % linear prediction + spatial interaction
    % reconstructed SR simultaneous
    linearSpatial = sumAxx(Axx(8),Axx(9));   
    % original SR simultaneous
    actualSpatial = Axx(10);  
    % difference
    nonLinearSpatial = computeDiff(actualSpatial,linearSpatial); % data1-data2
    interaction(ff,4).data = nonLinearSpatial;
    % get half of the interaction term
    halfNonLinearSpatial = multiplyAxx(nonLinearSpatial,0.5);
    % spatial prediction
    sbj(ff,8).data = sumAxxWithShift(sumAxx(Axx(9),halfNonLinearSpatial),sumAxx(Axx(8),halfNonLinearSpatial));
    % difference recorded motion - prediction
    sbjDiff(ff,6).data = computeDiff(sbj(ff,6).data,sbj(ff,8).data); 
    
    % linear prediction + temporal interaction
    % reconstructed SR flash one side (right?)
    linearTemp1 = sumAxxWithShift(Axx(8),Axx(8));   
    % original LR flash right
    actualTemp1 = Axx(11);  
    % difference
    nonLinearL = computeDiff(actualTemp1,linearTemp1);
    interaction(ff,5).data = nonLinearL;
     % get half of the interaction term
    halfNonLinearL = multiplyAxx(nonLinearL,0.5);
    % reconstructed SR flash one side (left?)
    linearTemp2 = sumAxxWithShift(Axx(9),Axx(9));   
    % original LR flash left
    actualTemp2 = Axx(12);  
    % difference and * 0.5
    interaction(ff,6).data = computeDiff(actualTemp2,linearTemp2);
    halfNonLinearR = multiplyAxx(computeDiff(actualTemp2,linearTemp2),0.5);    
    % temporal prediciton
    sbj(ff,9).data = sumAxxWithShift(sumAxx(Axx(9),halfNonLinearR),sumAxx(Axx(8),halfNonLinearL));
    % difference recorded motion - prediction
    sbjDiff(ff,7).data = computeDiff(sbj(ff,6).data,sbj(ff,9).data); 
    
    % linear prediction + spatial interaction + temporal interaction 
    poolNonLinearL = sumAxx(halfNonLinearSpatial,halfNonLinearL);
    poolNonLinearR = sumAxx(halfNonLinearSpatial,halfNonLinearR);
    sbj(ff,10).data = sumAxxWithShift(sumAxx(Axx(9),poolNonLinearR),sumAxx(Axx(8),poolNonLinearL));
    % difference recorded motion - prediction
    sbjDiff(ff,8).data = computeDiff(sbj(ff,6).data,sbj(ff,10).data); 
    
    % non-linear spatio-temporal component
    % long-range
%     sbj(ff,11).data = computeDiff(sbj(ff,1).data, sbj(ff,5).data);
    interaction(ff,7).data = computeDiff(sbj(ff,1).data, sbj(ff,5).data);
    sbj(ff,11).data = interaction(ff,7).data;
    % short range
%     sbj(ff,12).data = computeDiff(sbj(ff,6).data, sbj(ff,10).data);    
    interaction(ff,8).data = computeDiff(sbj(ff,6).data, sbj(ff,10).data);    
    sbj(ff,12).data = interaction(ff,8).data;
end


save([outDir 'sbjprediction'],'sbj','cfg');
save([outDir 'sbjDiff'],'sbjDiff','cfg');
save([outDir 'NLinteraction'],'interaction','cfg');
