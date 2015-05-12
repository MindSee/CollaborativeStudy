function [] = convertEYES(diameterTarget, threesholdFixations, checkPlot)
disp('Converting eye tracking signals...')

% Nargin
if nargin < 3
    checkPlot = false;
    if nargin < 2
        % Threeshold of Fixations in micro-second
        threesholdFixations = 150000;
        if nargin < 1
            % Diameter of the Target in pixels
            diameterTarget = 60;
        end
    end
end

global BTB

convertBase;

for tp=1:numel(subdir_list) % Select one of the test persons
    
    tpcode=regexp(subdir_list{tp},'_','split');tpcode=tpcode{1};
    BTB.Tp.Dir=fullfile(BTB.RawDir,subdir_list{tp});
    for i=1:12; % Select one of the twelve files recorded for each person
        
        % EEG file
        file=fullfile(BTB.RawDir, subdir_list{tp},['MindSeeCollaborativeStudy2015_' tags{i} '_' tpcode]);
        mrk = file_readBVmarkers(file);
        
        % Select stimulus markers only and delete stop markers
        mrk=mrk_selectClasses(mrk,'S*');
        mrk=mrk_selectClasses(mrk,'not','S255');
        
        % Load eye tracking marker
        file=fullfile(subdir_list{tp},['MindSeeCollaborativeStudy2015_' tags{i} '_' tpcode]);
        [ET_mrk] = readETMarkers(file);
        
        % Warning if ET and EEG marker numbers do not match
        try MarkerMismatch = not(mrk.event.desc'==ET_mrk.number);
        catch, MarkerMismatch = 1; % Unequal number of markers
        end
        
        if MarkerMismatch
            error(['EEG and ET markers do not match for ' file '. Skipped this file.'])
        end
        
        % Load eye tracking data
        file=fullfile(BTB.RawDir, subdir_list{tp},['MindSeeCollaborativeStudy2015_' tags{i} '_' tpcode ' Events.txt']);
        eye = analyseEventFixations(file, checkPlot, threesholdFixations, diameterTarget); % eye = convertEventTxt2Mat(file);
        
        % save in matlab format
        matfilename = fullfile(BTB.MatDir, subdir_list{tp},['EyeEvent_' tags{i} '_' tpcode]);
        
        [pathstr, name, ext] = fileparts(matfilename);
        if not(isdir(pathstr)), mkdir(pathstr), end
        
        fprintf('Saving %s\n', matfilename)
        save(matfilename,'eye');
        
        % Clear all unnecessary variables
        clearvars -except BTB subdir_list tp tpcode tags i checkPlot threesholdFixations diameterTarget
        close all
        
    end
end
