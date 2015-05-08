disp('Spectral analysis of EEG data...')

global BTB

convertBaseEEG;

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
            art_ival=[0 2000];
            [mkk rClab]= reject_varEventsAndChannels(cnt, mkk, art_ival);%, 'verbose', 1);
            
            fprintf('Channel rejected: %s\n', rClab{:});
            if ~isempty(rClab)
                rClab_trials{c,t}=rClab{:};
            else
                rClab_trials{c,t}='';
            end
            %cnt=proc_selectChannels(cnt,'not',rClab);
            epo=proc_segmentation(cnt, mkk, [0  2000]);
            crit_maxmin= 150;
            epo= proc_rejectArtifactsMaxMin(epo, crit_maxmin);
            
            
            if (t==1 && c==1)
                epo_all=epo;
            else
                epo_all = proc_appendEpochs(epo_all, epo);
            end
        end
    end
    
    epo_all=proc_selectChannels(epo_all,'not',unique(rClab_trials))
    
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

% fig_set(numel(subdir_list)+1);
% H= grid_plot(spec_ga, mnt, opt_grid_spec,'XUnit', spec_ga.xUnit, 'YUnit', spec_ga.yUnit);
% grid_addBars(spec_r_ga, 'HScale',H.scale);

spec_ga_forVisual=spec_ga;
spec_ga_forVisual.x=spec_ga.x(1:35,:,:);
spec_ga_forVisual.t=spec_ga.t(1:35)

spec_r_ga_forVisual=spec_r_ga;
spec_r_ga_forVisual.x=spec_r_ga.x(1:35,:,:);
spec_r_ga_forVisual.t=spec_r_ga.t(1:35)

clab={'O1','FC1'}
band_list= [4 7; 8 12; 13 15; 18 22; 26 36];
figure
H= plot_scalpEvolutionPlusChannel(spec_ga_forVisual, mnt, clab, band_list, ...
    defopt_scalp_power, ...
    'ColorOrder',colOrder, ...
    'ScalePos','horiz', ...
    'GlobalCLim',0,...
    'XUnit', spec_ga_forVisual.xUnit, 'YUnit', spec_ga_forVisual.yUnit);
grid_addBars(spec_r_ga_forVisual);


BTB.FigDir= '/Volumes/data/CollaborativeStudy/';
opt_fig= struct('folder', fullfile(BTB.FigDir), 'format', 'png');
print('-dbmp',[ opt_fig.folder 'GA_spectra.' opt_fig.format]);



fig_set(4, 'Resize',[1 2/3]);
plot_scalpEvolutionPlusChannel(spec_r_ga_forVisual, mnt, clab, band_list, defopt_scalp_r,...
    'XUnit', spec_r_ga_forVisual.xUnit, 'YUnit', spec_r_ga_forVisual.yUnit);

print('-dbmp',[ opt_fig.folder 'GA_r_spectra.' opt_fig.format]);

