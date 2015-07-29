disp('EDA analysis using LEDALAB for computing phasic and tonic components...')

global BTB

BTB.LedalabDir = fullfile(BTB.DataDir, 'ledalabMat');
LEDALAB_DIR = fullfile('/Users/eugstem1/Workspace/MindSee/3rdParty/Ledalab');

convertBase;


for tp=1:numel(subdir_list) % Select one of the test persons
    
    tpcode=regexp(subdir_list{tp},'_','split'); tpcode=tpcode{1};
    BTB.Tp.Dir=fullfile(BTB.MatDir,subdir_list{tp});
    
    % Load the EEG files of the two conditions "high focus" and "low focus"    
    epo_all=[];
    conditions={'hf' 'lf'};
    for c=1:2
        % Get tags of the current condition
        idx=strfind(tags,conditions{c});
        idx= find(not(cellfun('isempty', idx)));
        tags_condition= tags(idx);
        
        % Load files of the current condition
        for t=1:numel(tags_condition)
            file= fullfile(BTB.MatDir, subdir_list{tp},['Peripheral_' tags_condition{t} '_' tpcode '.mat']);
           
            disp(file);
            
            [cnt, mrk, mnt] = file_loadMatlab(file);
            
            % Determine periods of stimulus presentation
            blk=blk_segmentsFromMarkersNew(mrk, 'start_marker','Start','end_marker','Stop');
            blk.className={conditions{c}};
            blk.y= ones(1, size(blk.ival,2));
            blk.fs=cnt.fs;
            
            start_ms = min(blk.ival(:));
            stop_ms = max(blk.ival(:));
            
            start_ms = start_ms - (1 * 1000);  % add one second at the beginning
            %stop_ms = stop_ms + (1 * 1000);    % ... and end

            start_idx = round(start_ms / (1000 / blk.fs));
            stop_idx = round(stop_ms / (1000 / blk.fs));
            
            % Ledalab structure:
            data = struct();
            data.conductance = cnt.x(start_idx:stop_idx, find(ismember(cnt.clab, 'EDA')));
            data.conductance = abs(data.conductance);
            data.conductance = data.conductance - min(data.conductance);
            data.time = linspace(0, length(data.conductance)/blk.fs, length(data.conductance)); % seconds
            data.timeoff = 0;
            data.event = [];
            
            % Additional trial information:
            data.trials = blk.ival - start_ms;
            data.fs = blk.fs;
            
            filename = fullfile(BTB.LedalabDir, [subdir_list{tp}, '_EDA_' tags_condition{t} '_' tpcode '.mat']);
            
            save(filename, 'data');
        end
    end
end

% Execute Ledalab batch job:
%copyfile(BTB.LedalabDir, [BTB.LedalabDir, '_orig']);
%cd(LEDALAB_DIR);
%Ledalab(BTB.LedalabDir, 'open', 'mat', 'analyze', 'CDA', 'optimize', 4);



