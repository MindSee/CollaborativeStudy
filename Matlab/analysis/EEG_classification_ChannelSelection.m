% Remove channels informative about the blocks for later CSP classification

clearvars -except BTB
disp('Determine EEG channels informative about the blocks using spectral features...')

global BTB

convertBaseEEG;

AUC_channels=cell(1,numel(subdir_list));

for tp=1:numel(subdir_list) % Select one of the test persons
    fprintf('Subject %i\n',tp)
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

            % Determine periods of stimulus presentation
            blk=blk_segmentsFromMarkers(mrk, 'StartMarker','Start','EndMarker','Stop');
            blk.className={[conditions{c} num2str(t)]};
            
            blk.y= ones(1, size(blk.ival,2));
            
            % Add markers every 2000 ms only during stimulus presentation
            mkk= mrk_evenlyInBlocks(blk, 2000);
            mkk.event.blkno = repmat(t, size(mkk.event.blkno));
            
            % Segmentation into epochs
            epo=proc_segmentation(cnt, mkk, [0  2000]);
            %epo=proc_spectrum(epo, [1 80]);
            epo=proc_spectrum(epo, [5 40]);
            
            if (t==1 && c==1)
                epo_all=epo;
            else
                epo_all = proc_appendEpochs(epo_all, epo);
            end
        end
        
    end
    
    %% Classification - predict to which block single epoch belongs:
    all_AUC=nan(2,6,numel(cnt.clab));
    for c=1:2
        fv=proc_selectClasses(epo_all,[conditions{c} '*']);
        for b=1:numel(fv.className)
            other_blocks=find(1:numel(fv.className) ~= b);
            fv_block = proc_combineClasses(fv,fv.className{other_blocks});
            % set all labels to 1 (or 0) - important for sample_KFold:
            fv_block.y(fv_block.y~=0)=1;
            for ch=1:numel(fv_block.clab)
                fv_block_channel=proc_selectChannels(fv_block,ch);
                loss= crossvalidation(fv_block_channel, @train_LDA, ...
                    'SampleFcn',  {@sample_KFold, [1 5]}, ...
                    'LossFcn', @loss_rocArea);
                all_AUC(c,b,ch)=1-loss; % AOC --> AUC
                fprintf('%s - c%i - b%i - ch%i \t %.2f\n',tpcode,c,b,ch,1-loss)
            end
        end
    end    
    
    % Average loss at each channel (average over conditions and blocks)
    AUC_channels{tp}=squeeze(mean(mean(all_AUC,1),2));
    
end

%% Plot results
opt_fig= struct('folder', fullfile(BTB.FigDir,'2015-MindSee-Collaborative'));

fig_set(1)
AUC_channels_mat=cell2mat(AUC_channels)';
boxplot(AUC_channels_mat)
set(gca,'YLim',[.48 1],'XTick',1:numel(cnt.clab), 'XTickLabel',cnt.clab); 
line([0 numel(cnt.clab),],[.5 .5],'Color',[.7 .7 .7]);
ylabel('[AUC]')
xlabel('[Channels]')
fname='EEG-classification-channel-selection';
util_printFigure(fname, [2.2 1]*10, opt_fig);

%% save results
results_dir=fullfile(BTB.DataDir,'results','2015-MindSee-Collaborative');
if not(isdir(results_dir)),mkdir(results_dir);end
results_file=fullfile(results_dir,'EEG-classification-channel-selection');
save(results_file,'AUC_channels_mat')