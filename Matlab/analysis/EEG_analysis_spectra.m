disp('Spectral analysis of EEG data...')

global BTB

convertBase;

spec={};
spec_r={};
spec_avg={};

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
            
            % Determine periods of stimulus presentation
            blk=blk_segmentsFromMarkersNew(mrk, 'start_marker','Start','end_marker','Stop');
            blk.className={conditions{c}};
            blk.y= ones(1, size(blk.ival,2));
            blk.fs=cnt.fs;
            
            %Not necessary(?) because of segmentation:
            %[cnt_new, blk_new, mrk_new]= proc_concatBlocks(cnt, blk, mrk);
            
            % Add markers every 2000 ms only during stimulus presentation
            mkk= mrk_evenlyInBlocksNew(blk, 2000);
            epo=proc_segmentation(cnt, mkk, [0  2000]);
            if (t==1 && c==1)
                epo_all=epo;
            else
                epo_all = proc_appendEpochs(epo_all, epo);
            end
        end
    end
    
    spec{tp}= proc_spectrum(epo_all, [2 60]);
    spec_r{tp}= proc_rSquareSigned(spec{tp},'Stats',1);    
    spec_avg{tp}= proc_average(spec{tp},'Stats',1);                   
end
%%
% Compute grand average
spec_ga= proc_grandAverage(spec_avg{2:end},'Stats',1);
spec_r_ga= proc_grandAverage(spec_r{2:end},'Stats',1);


% Plot
colOrder= [245 159 0; 0 150 200]/255;
opt_grid_spec= defopt_spec('xTickAxes','CPz', 'colorOrder',colOrder);

%{
for tp=1:numel(subdir_list)
    fig_set(tp);
    H= grid_plot(spec{tp}, mnt, opt_grid_spec,'XUnit', spec{tp}.xUnit, 'YUnit', spec{tp}.yUnit)
    grid_addBars(spec_r{tp}, 'HScale',H.scale);
end
%}

fig_set(numel(subdir_list)+1);
H= grid_plot(spec_ga, mnt, opt_grid_spec,'XUnit', spec_ga.xUnit, 'YUnit', spec_ga.yUnit);
grid_addBars(spec_r_ga, 'HScale',H.scale);


clab={'O1','Cz'}
band_list= [7 11; 11 14; 20 24; 26 36];
figure
H= plot_scalpEvolutionPlusChannel(spec_ga, mnt, clab, band_list, ...
    defopt_scalp_power, ...
    'ColorOrder',colOrder, ...
    'ScalePos','horiz', ...
    'GlobalCLim',0,...
    'XUnit', spec_ga.xUnit, 'YUnit', spec_ga.yUnit);
grid_addBars(spec_r_ga);


