clearvars -except BTB
disp('Spectral analysis of EEG data...')

global BTB

convertBaseEEG;

spec={};
spec_r={};
spec_avg={};

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
            %blk.className={conditions{c}};
            blk.className={tags_condition{t}};
            blk.y= ones(1, size(blk.ival,2));
            blk.fs=cnt.fs;

            % Add markers every 2000 ms only during stimulus presentation
            mkk= mrk_evenlyInBlocks(blk, 2000);
            epo=proc_segmentation(cnt, mkk, [0  2000]);            
            if (t==1 && c==1)
                epo_all=epo;
            else
                epo_all = proc_appendEpochs(epo_all, epo);                
            end
        end
    end    
    
    spec{tp}= proc_spectrum(epo_all, [1 80]);           
end

%% One exemplary subject and channel
opt_fig= struct('folder', fullfile(BTB.FigDir,'2015-MindSee-Collaborative'));

tp=1
hf= proc_selectClasses(spec{tp}, 1:6);
lf= proc_selectClasses(spec{tp}, [12 11 10 7 8 9] ); % Match colors for same block types (sq, ...)
hf.className=strrep(hf.className,'_',' ');
lf.className=strrep(lf.className,'_',' ');

fig_set(1, 'gridSize',[1 1])
subplot(1,2,1)
h1=plot_channel(lf,'Cz')
subplot(1,2,2)
h2=plot_channel(hf,'Cz')

set(h1.leg,'Location', 'NorthEast')
set(h2.leg,'Location', 'NorthEast')
set(h1.title,'String','Low focus')
set(h2.title,'String','High focus')

util_printFigure(['EEG-spectra-one-subject-Cz'], [2 1]*10, opt_fig);
%% Grid plots for all single subjects
for tp=1:numel(subdir_list)    
    hf_opt_grid_spec= defopt_spec('xTickAxes','CPz', 'colorOrder',cmap_hsvFade(6,[0 2/6],1,1));
    lf_opt_grid_spec= defopt_spec('xTickAxes','CPz', 'colorOrder',cmap_hsvFade(6,[3/6 5/6],1,1));
    hf= proc_selectClasses(spec{tp}, 1:6);
    lf= proc_selectClasses(spec{tp}, 7:12);
    
    fig_set(1, 'gridSize',[1 2])
    grid_plot(lf, mnt, lf_opt_grid_spec)
    fig_set(2, 'gridSize',[1 2])
    grid_plot(hf, mnt, hf_opt_grid_spec)

    %{
    colOrder= [245 159 0; 0 150 200]/255;
    opt_grid_spec= defopt_spec('xTickAxes','CPz', 'colorOrder',colOrder);
    opt_fig= struct('folder', fullfile(BTB.FigDir,'2015-MindSee-Collaborative'));
    
    H= grid_plot(spec{tp}, mnt, opt_grid_spec,'XUnit', spec{tp}.xUnit, 'YUnit', spec{tp}.yUnit)
    grid_addBars(spec_r{tp}, 'HScale',H.scale);
    %}
end