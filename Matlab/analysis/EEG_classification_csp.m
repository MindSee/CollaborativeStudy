disp('EEG classification using CSP...')

global BTB

convertBase;
bands_all={[9 13]};
band=bands_all{1};

fprintf('Frequency band: %i Hz - %i Hz\n', band);
loss_all=[];
            
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
            file= fullfile(BTB.MatDir, subdir_list{tp},['EEG_' tags_condition{t} '_' tpcode '.mat']);
            [cnt, mrk, mnt] = file_loadMatlab(file);
            
            % Bandpass filter for CSP
            [filt_b,filt_a]= butter(5, band/cnt.fs*2);
            cnt= proc_filt(cnt, filt_b, filt_a);

            % Determine periods of stimulus presentation
            blk=blk_segmentsFromMarkersNew(mrk, 'start_marker','Start','end_marker','Stop');
            blk.className={conditions{c}};
            blk.y= ones(1, size(blk.ival,2));
            blk.fs=cnt.fs;
            
            %New function not complete but not necessary(?):
            %[cnt_new, blk_new, mrk_new]= proc_concatBlocksNew(cnt, blk, mrk);
            
            % Add markers every 2000 ms only during stimulus presentation
            mkk= mrk_evenlyInBlocksNew(blk,2000);
            epo=proc_segmentation(cnt, mkk, [0  2000]);
            if (t==1 && c==1)
                epo_all=epo;
            else
                epo_all = proc_appendEpochs(epo_all, epo);
            end
        end
    end
    
     
    %% Classification
    fv= epo_all;
    
    proc.train= {{'CSPW', @proc_cspAuto, 3}
        @proc_variance
        @proc_logarithm
        };
    proc.apply= {{@proc_linearDerivation, '$CSPW'}
        @proc_variance
        @proc_logarithm
        };
    
    loss= crossvalidation(fv, {@train_RLDAshrink, 'Gamma',0}, ... 
       'SampleFcn',  {@sample_KFold, [10 10]},...
        'Proc', proc, 'LossFcn', @loss_rocArea);
    fprintf('%s %f\n', tpcode, loss);
    %'SampleFcn', {@sample_chronKFold, 8}, ...
              
    loss_all(tp)=loss;
end

disp('Mean loss')
disp(mean(loss_all))

disp('All losses')
disp(loss_all)