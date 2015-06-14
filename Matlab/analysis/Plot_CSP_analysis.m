disp('Visualization of common spatial patterns...')

global BTB

convertBaseEEG;

PermuteLabels=false; % Check classification and if block effect exist
idx_permuted=reshape(randperm(12),[2,6]);

bands_all={[1 3] [4 7] [8 12] [13 30] [31 50] [60 80]};
bands_names={'Delta' 'Theta' 'Alpha' 'Beta' 'Gamma' 'HighGamma'};
AUC_all=zeros(numel(subdir_list), numel(bands_all));

%for i_band=1:numel(bands_all)
    i_band=1;
    band=bands_all{i_band};
    fprintf('Frequency band "%s": %i Hz - %i Hz\n', bands_names{i_band}, band);
    
   for tp=1:numel(subdir_list) % Select one of the test persons
        
        tpcode=regexp(subdir_list{tp},'_','split'); tpcode=tpcode{1};
        BTB.Tp.Dir=fullfile(BTB.MatDir,subdir_list{tp});
        
        if tpcode=='VPpal', continue, end
        
        % Load the EEG files of the two conditions "high focus" and "low focus"
        epo_all=[];
        conditions={'hf' 'lf'};
        
        for c=1:2
            
            % Get tags of the current condition
            idx=strfind(tags,conditions{c});
            idx= find(not(cellfun('isempty', idx)));
            
            % Check classification and if block effect exist
            if(PermuteLabels), idx=idx_permuted(c,:); end
            
            tags_condition= tags(idx);
            
            % Load files of the current condition
            for t=1:numel(tags_condition)
                file= fullfile(BTB.MatDir, subdir_list{tp},['EEG_' tags_condition{t} '_' tpcode '.mat']);
                [cnt, mrk, mnt] = file_loadMatlab(file);
                
                % Bandpass filter for CSP
                [filt_b,filt_a]= butter(5, band/cnt.fs*2);
                cnt= proc_filt(cnt, filt_b, filt_a);
                
                % Determine periods of stimulus presentation
                blk=blk_segmentsFromMarkersNew(mrk, 'start_marker','Start','end_marker','Stop');
                blk.className={conditions{c}};
                blk.y= ones(1, size(blk.ival,2));
                %blk.fs=cnt.fs;
                
                %New function not complete but not necessary(?):
                %[cnt_new, blk_new, mrk_new]= proc_concatBlocksNew(cnt, blk, mrk);
                
                % Add markers every 2000 ms only during stimulus presentation
                mkk= mrk_evenlyInBlocksNew(blk, 2000);
                
                % Artifact rejection based on variance criterion
                %art_ival=[0 2000];
                %mkk= reject_varEventsAndChannels(cnt, mkk, art_ival);%, 'verbose', 1);
                
                % Channel with large power in grand average spectrum removed
                %cnt=proc_selectChannels(cnt, 'not', 'CP1');
                
                % Segmentation into epochs
                epo=proc_segmentation(cnt, mkk, [0  2000]);
                
                % simple artifact rejection based on max-min criterion
                %crit_maxmin= 150;
                %epo= proc_rejectArtifactsMaxMin(epo, crit_maxmin);
                
                if (t==1 && c==1)
                    epo_all=epo;
                else
                    epo_all = proc_appendEpochs(epo_all, epo);
                end
            end
        end
        
        fv=epo_all;
        [DAT, CSP_W, CSP_EIG, CSP_A]= proc_cspAuto(fv, 3);
        figure
        H= plot_cspAnalysis(DAT, mnt, CSP_W, CSP_A, CSP_EIG);
        
   end
        