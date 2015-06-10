clearvars -except BTB
disp('EEG classification using common spatial patterns...')

global BTB

convertBaseEEG;

% Permute blocks/trials to check classification and if block effect exist
PermuteBlocks=true;
PermuteStyle=4;
switch PermuteStyle
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

% crossvalidation leaving blocks out (1) or sample_KFold (0)
BlockWiseValidation=1; 

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
                
                blk.y= ones(1, size(blk.ival,2));                
                                
                % Add markers every 2000 ms only during stimulus presentation
                mkk= mrk_evenlyInBlocksNew(blk, 2000);
                mkk.event.blkno = repmat(t, size(mkk.event.blkno));
                
                % Segmentation into epochs
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
        
        if tpcode=='VPpal', continue, end       
        % (Error using eig, Input to EIG must not contain NaN or Inf)

        % Check whether xval works
        %fv.y=fv.y(:,randperm(size(fv.y,2)) );
        
        if BlockWiseValidation
            loss= crossvalidation(fv, {@train_RLDAshrink, 'Gamma',0}, ...
                'SampleFcn',  {@sample_leaveOneBlockOut, fv.event.blkno},...
                'Proc', proc, 'LossFcn', @loss_rocArea);
        else
            loss= crossvalidation(fv, {@train_RLDAshrink, 'Gamma',0}, ...
                'SampleFcn',  {@sample_KFold, [1 5]},...
                'Proc', proc, 'LossFcn', @loss_rocArea);
        end
        
        AUC_all(tp, i_band)=1-loss; % AOC --> AUC
        fprintf('%s %f [AUC]\n', tpcode, AUC_all(tp, i_band) );
    end
    
    fprintf('*** Mean *** %f [AUC]\n\n',nanmean(AUC_all(:,i_band)) );
    
end

%% Plot classification results
close all
fig_set(1,'gridsize',[2 3]);
boxplot(AUC_all, 'labels', bands_names, 'orientation','vertical');
ylabel('[AUC]','Color',[0 0 0]); % Area under roc curve
set(gca,'YLim',[0 1],'TickLength',[0.03 0.03]);
hold on

% Statistical assessment
m=0.5;alpha=0.05 / numel(bands_all); % Correction for multiple comparisons
tail='right';dim=1;
for i_band=1:numel(bands_all)
    [p_value, h] = signrank(AUC_all(:,i_band),m,'alpha',alpha,'tail',tail);
    if h, plot(i_band,0.5,'*k'); end
end

opt_fig= struct('folder', fullfile(BTB.FigDir,'2015-MindSee-Collaborative'));
fname='EEG-classification-CSP';
if(PermuteBlocks), fname=[fname '-PermutedLabels']; end
if(BlockWiseValidation), fname=[fname '-BlockWiseValidation']; end
util_printFigure(fname, [1.3 1]*10, opt_fig);
