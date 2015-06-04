clearvars -except BTB
disp('EEG classification using common spatial patterns...')

global BTB

convertBaseEEG;

% Check classification and if block effect exist

% NEW PERMUTE EACH BLOCK!
PermuteEachSingleBlock=0; % Overwrites PermuteBlocks in the following line!
PermuteBlocks=0;
switch 4
    case 1% Unbalanced permutation
        idx_permuted=reshape(randperm(12),[2,6]);
    case 2 % Balanced permutation
        idx_permuted=[ 1 2 5 6 9 10; 3 4 7 8 11 12];
    case 3 % First half against second half
        idx_permuted=[ 1:6; 7:12 ];
    case 4 % Balanced and symmetric permutation
        idx_permuted=[1 12 3 10 5 8; 2 11 4 9 6 7];
    case 5 % Take just two random blocks (both either hf or lf!) and compare them
        idx_permuted=[5; 7];
end
    
bands_all={[1 3] [4 7] [8 12] [13 30] [31 50] [60 80]};
bands_names={'Delta' 'Theta' 'Alpha' 'Beta' 'Gamma' 'HighGamma'};
AUC_all=nan(numel(subdir_list), numel(bands_all));

for i_band=1:numel(bands_all)
    
    band=bands_all{i_band};
    fprintf('Frequency band "%s": %i Hz - %i Hz\n', bands_names{i_band}, band);
    
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
            
            % Check classification and if block effect exist
            if(PermuteBlocks), idx=idx_permuted(c,:); end
            
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
                
                % NEW PERMUTE EACH BLOCK!
                if PermuteEachSingleBlock
                    blk.className={conditions{1+(rand>.5)}};
                end
                
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
        
        % Remove field "event" because proc_appendEpochs does not append it
        epo_all=rmfield(epo_all,'event');
        
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
        
        if tpcode=='VPpal', continue, end
        
        % For VPpal:
        % Error using eig
        % Input to EIG must not contain NaN or Inf.
        % Error in proc_cspAuto (line 90)
        % [W,D]= eig(R(:,:,2),R(:,:,1)+R(:,:,2));
        % Error in xvalutil_proc (line 18)
        % [fv, vals{:}]= cmd{1}(fv, cmd{2:end});
        % Error in crossvalidation (line 89)
        % [fvTr, memo]= xvalutil_proc(fvTr, opt.Proc.train);
        
        % Check whether xval works
        %fv.y=fv.y(:,randperm(size(fv.y,2)) );
        
        loss= crossvalidation(fv, {@train_RLDAshrink, 'Gamma',0}, ...
            'SampleFcn',  {@sample_KFold, [1 5]},...
            'Proc', proc, 'LossFcn', @loss_rocArea);
        %'SampleFcn', {@sample_chronKFold, 8}, ...
        
        AUC_all(tp, i_band)=1-loss; % AOC --> AUC
        fprintf('%s %f [AUC]\n', tpcode, AUC_all(tp, i_band) );
    end
    
    fprintf('*** Mean *** %f [AUC]\n\n',nanmean(AUC_all(:,i_band)) );
    
end

%% Plot classification results
close all
fig_set(1,'gridsize',[2 3]);
boxplot(AUC_all, 'labels', bands_names, 'orientation','vertical');
%ax=title('EEG classification with CSP','FontWeight','bold');
ylabel('[AUC]','Color',[0 0 0]);%,'FontSize',8); % Area under roc curve
set(gca,'YLim',[0.48 1],'TickLength',[0.03 0.03]);
hold on

% Statistical assessment
m=0.5;alpha=0.05 / numel(bands_all); % Correction for multiple comparisons
tail='right';dim=1;
for i_band=1:numel(bands_all)
    [p_value, h] = signrank(AUC_all(:,i_band),m,'alpha',alpha,'tail',tail);
    if h, plot(i_band,0.5,'*k'); end
end

opt_fig= struct('folder', fullfile(BTB.FigDir));
% Check classification and if block effect exist
fname='EEG-classification-CSP';
if(PermuteBlocks), fname=[fname '-Permuted-Labels']; end
util_printFigure(fname, [1 1]*7, opt_fig);
