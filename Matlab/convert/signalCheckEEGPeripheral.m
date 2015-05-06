%% Signal check

% Put the following line in your startup file
% addpath(genpath(fullfile(BTB.PrivateDir)));

tp=1; % Select one of the test persons
i=1; % Select one of the twelve files recorded for each person

% Get subdir_list and tags for the experimental conditions
convertBase;

tpcode=regexp(subdir_list{tp},'_','split');tpcode=tpcode{1};
eeg_file=fullfile(subdir_list{tp},['MindSeeCollaborativeStudy2015_' tags{i} '_' tpcode]);
[cnt, mrk]= file_readBV(eeg_file);
bbci= struct;
bbci.source.acquire_fcn= @bbci_acquire_offline;
bbci.source.acquire_param= {cnt, mrk};

clabScalp= cnt.clab(util_scalpChannels(cnt));
clabNonScalp= cnt.clab(util_chanind(cnt, 'not',clabScalp));

% Signal check
monitor_signalCheck(bbci, 'CLab', clabScalp);

% Signal monitor
monitor_signalViewer(bbci, 'CLab',cat(2, clabScalp, clabNonScalp),'Maximize',1);