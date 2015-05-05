addpath(genpath(fullfile(BTB.PrivateDir, 'studies', '2015-MindSee-Collaborative')));

subdir_list={%'VPpaa_15_03_04'    
    'VPpab_15_03_06'    
    %'VPpac_15_03_09'
    'VPpad_15_03_10'
    'VPpae_15_03_11'
    'VPpaf_15_03_11'
    'VPpag_15_03_12'
    'VPpah_15_03_12'
    'VPpai_15_03_13'
    'VPpaj_15_03_16'     
    'VPpak_15_03_16'
    'VPpal_15_03_17'    
    };

% TEST WITH THREE SUBJECTS
subdir_list=subdir_list(1:3,:);

tags={'hf_cr' 'hf_sq' 'lf_cr' 'lf_sq' 'hf_do' 'hf_st'
    'lf_do' 'lf_st' 'hf_es' 'hf_tr' 'lf_es' 'lf_tr'};

for tp=1:numel(subdir_list) % Select one of the test persons
    
    tpcode=regexp(subdir_list{tp},'_','split');tpcode=tpcode{1};
    BTB.Tp.Dir=fullfile(BTB.RawDir,subdir_list{tp});    
    for i=1:12; % Select one of the twelve files recorded for each person
        
        % EEG and corresponding ET file
        file=fullfile(subdir_list{tp},['MindSeeCollaborativeStudy2015_' tags{i} '_' tpcode]);
        disp(file)
        
        % load file header
        hdr= file_readBVheader(file);
        fs_orig=hdr.fs;
        
        % low-pass filter for anti-aliasing
        Wps = [100 120]/hdr.fs*2; % for Fs=250
        [n, Ws] = cheb2ord(Wps(1), Wps(2), 3, 40);
        [filt.b, filt.a]= cheby2(n, 50, Ws);
        %  freqz(filt.b,filt.a,512,hdr.fs)
        
        % load raw data, downsampling is done while loading
        Fs = 250; % new sampling rate
        [cnt, mrk] = file_readBV(file, 'Fs',Fs, 'Filt',filt);
        
        % Load eye tracking data
        [ET_mrk] = readETMarkers(file);
        
        % Subtract corresponding bipolar electrodes of electrodes for facial EMG and electrodermal activity
        i_fEMG1 = util_chanind(cnt.clab, 'fEMG1');
        i_fEMG2 = util_chanind(cnt.clab, 'fEMG2');
        i_fEMG3 = util_chanind(cnt.clab, 'fEMG3');
        i_fEMG4 = util_chanind(cnt.clab, 'fEMG4');
        i_fEDA1 = util_chanind(cnt.clab, 'EDA1');
        i_fEDA2 = util_chanind(cnt.clab, 'EDA2');
        cnt = proc_appendChannels(cnt, cnt.x(:,i_fEMG1) - cnt.x(:,i_fEMG2), {'EMGa'});
        cnt = proc_appendChannels(cnt, cnt.x(:,i_fEMG3) - cnt.x(:,i_fEMG4), {'EMGb'});
        cnt = proc_appendChannels(cnt, cnt.x(:,i_fEDA1) - cnt.x(:,i_fEDA2), {'EDA'});
        cnt = proc_selectChannels(cnt,'not',{'fEMG1' 'fEMG2' 'fEMG3' 'fEMG4' 'EDA1' 'EDA2'});
        
        
        % Select stimulus markers only and delete stop markers
        mrk=mrk_selectClasses(mrk,'S*');
        mrk=mrk_selectClasses(mrk,'not','S255');
        
        % Warning if ET and EEG marker numbers do not match
        try MarkerMismatch = not(mrk.event.desc'==ET_mrk.number);
        catch, MarkerMismatch = 1; % Unequal number of markers
        end
        
        if MarkerMismatch
            error(['EEG and ET markers do not match for ' file '. Skipped this file.'])            
        end
        
        % Translate EEG markers (numbers only) into meaningful names
        mrk=mrk_matchClasses(mrk, ET_mrk);
        
        % electrode montage
        mnt = mnt_setElectrodePositions(cnt.clab);
        
        % arrangement for grid plots
        grd = sprintf(['scale,F7,Fpz,F8,legend\n'...
            'FC5,FC1,Fz,FC2,FC6\n'...
            'T6,C3,Cz,C4,T8\n'...
            'CP5,CP1,_,CP2,CP6\n'...
            'P7,P3,Pz,P4,P8\n'...
            'PO1,O1,_,O2,PO2\n'...
            'EMGa,EMGb,_,_,EDA']);
        mnt = mnt_setGrid(mnt, grd);
        
        %% Behavioural data        
        
        % load behavioral responses                
        if isunix % Linux / Mac
            answerfile=strtrim(ls(fullfile(BTB.Tp.Dir, '*_response_session1.mat'))); load(answerfile);
            answerfile=strtrim(ls(fullfile(BTB.Tp.Dir, '*_response_session2.mat'))); load(answerfile);
            answerfile=strtrim(ls(fullfile(BTB.Tp.Dir, '*_response_session3.mat'))); load(answerfile);
        else % Windows
            answerfile=fullfile(BTB.Tp.Dir, ls(fullfile(BTB.Tp.Dir, '*_response_session1.mat'))); load(answerfile);
            answerfile=fullfile(BTB.Tp.Dir, ls(fullfile(BTB.Tp.Dir, '*_response_session2.mat'))); load(answerfile);
            answerfile=fullfile(BTB.Tp.Dir, ls(fullfile(BTB.Tp.Dir, '*_response_session3.mat'))); load(answerfile);
        end
        
        cmd=['Answers = response_' tags{i}(4:5) '_' tags{i}(1:2) ';']; eval(cmd);
        
        % Extract the number of targets, i.e. the correct answer
        kk=1;
        for ii=1:length(ET_mrk.desc)
            if strncmp(ET_mrk.desc{ii},'Start',5)
                tmp=regexp(ET_mrk.desc{ii},'_','split');
                NumberOfTargets(kk)=str2num(tmp{end});
                kk=kk+1;
            end
        end
        
        behaviour=struct('Answers',Answers ,'NumberOfTargets',NumberOfTargets);
        
        %% save in matlab format        
        matfilename = fullfile(BTB.MatDir,file);
        fprintf('Saving %s\n', matfilename)
        warning('off', 'MATLAB:save:versionWithAppend')
        file_saveMatlab(matfilename, cnt, mrk, mnt);
        behaviourfilename = regexprep(matfilename, 'MindSeeCollaborativeStudy2015', 'Behaviour');
        save(behaviourfilename,'behaviour');
        %% Clear all unnecessary variables
        clearvars -except BTB subdir_list tp tpcode tags i
        
    end
end