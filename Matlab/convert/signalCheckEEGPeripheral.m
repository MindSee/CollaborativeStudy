%% Signal check

tp=12; % Select one of the test persons
i=12; % Select one of the twelve files recorded for each person

tpdirs={'VPpaa_15_03_04'
    'VPpab_15_03_06'
    'VPpac_15_03_09'
    'VPpah_15_03_12'
    'VPpai_15_03_13'
    'VPpag_15_03_12'
    'VPpaf_15_03_11'
    'VPpae_15_03_11'
    'VPpad_15_03_10'
    'VPpal_15_03_17'
    'VPpak_15_03_16'
    'VPpaj_15_03_16'
    };

tags={'hf_cr' 'hf_sq' 'lf_cr' 'lf_sq' 'hf_do' 'hf_st' 
    'lf_do' 'lf_st' 'hf_es' 'hf_tr' 'lf_es' 'lf_tr'};

tpcode=regexp(tpdirs{tp},'_','split');tpcode=tpcode{1};
eeg_file=fullfile(tpdirs{tp},['MindSeeCollaborativeStudy2015_' tags{i} '_' tpcode]);
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