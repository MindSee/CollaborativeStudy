function extractEEGFeatures
disp('Extracting EEG features...')

global BTB

convertBase;

for tp=1:numel(subdir_list) % Select one of the test persons
    
    tpcode=regexp(subdir_list{tp},'_','split'); tpcode=tpcode{1};
    BTB.Tp.Dir=fullfile(BTB.MatDir,subdir_list{tp});
    
    % Load the EEG files of the two experimental conditions "high focus"
    % and "low focus"
    fv={};
    conditions={'hf' 'lf'};
    for c=1:2        
        file=fullfile(BTB.MatDir, subdir_list{tp},['EEG_' conditions{c} '*']);        
        clear cnt* mrk mnt
        [cnt, mrk, mnt] = file_loadMatlab(file);
        
        % Extract features ...
        fv{c}=[];
    end    
    
    % Save the features of this subjects in a format convient for further analyis...
    
end
