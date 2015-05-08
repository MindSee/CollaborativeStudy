disp('Extracting EEG features...')

global BTB

convertBase;

% Options
colOrder= [245 159 0; 0 150 200]/255;
opt_grid_spec= defopt_spec('xTickAxes','CPz', 'colorOrder',colOrder);

spec={};
spec_r={};
loss_all={};
            
for tp=1:numel(subdir_list) % Select one of the test persons
    
    tpcode=regexp(subdir_list{tp},'_','split'); tpcode=tpcode{1};
    BTB.Tp.Dir=fullfile(BTB.MatDir,subdir_list{tp});
    
    % Load the EEG files of the two conditions "high focus" and "low focus"
    %fv={};
    epo_all=[];
    conditions={'hf' 'lf'};
    for c=1:2
        
        % Get tags of the current condition
        idx=strfind(tags,conditions{c});
        idx= find(not(cellfun('isempty', idx)));
        tags_condition= tags(idx);
        
        % Load and segment files of the current condition considering only
        % intervals during stimulus presentation
        
        for t=1:numel(tags_condition)
            file= fullfile(BTB.MatDir, subdir_list{tp},['EEG_' tags_condition{t} '_' tpcode '.mat']);
            [cnt, mrk, mnt] = file_loadMatlab(file);
            
            % Bandpass filter for CSP
            [filt_b,filt_a]= butter(5, [9 13]/cnt.fs*2);
            cnt= proc_filt(cnt, filt_b, filt_a);

            % Extract features ..
            blk=blk_segmentsFromMarkers(mrk, 'start_marker','Start','end_marker','Stop');
            blk.className={conditions{c}};
            blk.y= ones(1, size(blk.ival,2));
            blk.fs=cnt.fs; % necessary for function mrk_evenlyInBlocks
            
            %New function not complete but not necessary(?):
            %[cnt_new, blk_new, mrk_new]= proc_concatBlocksNew(cnt, blk, mrk);
            
            mkk= mrk_evenlyInBlocksNew(blk,2000);
            epo=proc_segmentation(cnt, mkk, [0  2000]);
            if (t==1 && c==1)
                epo_all=epo;
            else
                epo_all = proc_appendEpochs(epo_all, epo);
            end
        end
    end
    
    spec{tp}= proc_spectrum(epo_all, [2 60]);
    spec_r{tp}= proc_rSquareSigned(spec{tp});
    
    spec{tp}= proc_average(spec{tp});        
    
     % Plot
    %{
    fig_set(tp);
    H= grid_plot(spec{tp}, mnt, opt_grid_spec,'XUnit', spec{tp}.xUnit, 'YUnit', spec{tp}.yUnit)
    grid_addBars(spec_r{tp}, 'HScale',H.scale);
    %}
     
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
    fprintf('%s %f\n',tpcode,loss);
    %'SampleFcn', {@sample_chronKFold, 8}, ...
              
    loss_all{tp}=loss;
end

loss_all
%disp('Mean loss')
%disp(mean(loss_all{:}))

disp('All losses')
disp(loss_all)

% Compute grand average
spec_ga= proc_grandAverage(spec,'Stats',1);
spec_r_ga= proc_grandAverage(spec_r,'Stats',1);

% Plot
fig_set(tp+1);
H= grid_plot(spec_ga, mnt, opt_grid_spec,'XUnit', spec_ga.xUnit, 'YUnit', spec_ga.yUnit)
grid_addBars(spec_r_ga, 'HScale',H.scale);


% Not possible with file_loadMatlab to specify order of the files (for chronological order)!
%{
        % Files of the current condition in the proper order
        %file=fullfile(BTB.MatDir, subdir_list{tp},['EEG_' conditions{c} '_cr_VPpab.mat']);
        %file=fullfile(BTB.MatDir, subdir_list{tp},['EEG_' conditions{c} '_*.mat']);
        fnames = {};
        for i=1:numel(tags_condition)
            fname = fullfile(BTB.MatDir, subdir_list{tp},['EEG_' tags_condition{i} '.mat']);
            fnames = {fnames{:}, fname};
        end
%}