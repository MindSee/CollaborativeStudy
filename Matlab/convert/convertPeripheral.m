function convertPeripheral
disp('Converting peripheral physiological signals...')

global BTB

convertBaseEEG; % Selected subjects

for tp=1:numel(subdir_list) % Select one of the test persons
    
    tpcode=regexp(subdir_list{tp},'_','split');tpcode=tpcode{1};
    BTB.Tp.Dir=fullfile(BTB.RawDir,subdir_list{tp});    
    for i=1:12; % Select one of the twelve files recorded for each person
        
        % EEG and corresponding ET file
        file=fullfile(subdir_list{tp},['MindSeeCollaborativeStudy2015_' tags{i} '_' tpcode]);        
        
        % Load file header
        hdr= file_readBVheader(file);
        fs_orig=hdr.fs;
        
        %{
        % Low-pass filter for anti-aliasing
        Wps = [100 120]/hdr.fs*2; % for Fs=250
        [n, Ws] = cheb2ord(Wps(1), Wps(2), 3, 40);
        [filt.b, filt.a]= cheby2(n, 50, Ws);
        %  freqz(filt.b,filt.a,512,hdr.fs)
        %}
        filt=[];
        
        clabScalp= hdr.clab(util_scalpChannels(hdr.clab));
        clabNonScalp= hdr.clab(util_chanind(hdr.clab, 'not',clabScalp));
        
        % Load raw data, downsampling is done while loading
        %Fs = 250; % new sampling rate
        Fs = 'raw';
        [cnt, mrk] = file_readBV(file, 'Fs',Fs, 'Filt',filt, 'CLab',clabNonScalp);
        
        % (Re-referencing of bipolar peripheral channels not necessary - in contrast to EEG)                     
        
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
        grd = sprintf(['scale,EMGa,EMGb,EDA,legend']);        
        mnt = mnt_setGrid(mnt, grd);
        
        %% save in matlab format        
        matfilename = fullfile(BTB.MatDir,file);
        eegfilename = regexprep(matfilename, 'MindSeeCollaborativeStudy2015', 'Peripheral');
        fprintf('Saving %s\n', eegfilename)
        warning('off', 'MATLAB:save:versionWithAppend')
        file_saveMatlab(eegfilename, cnt, mrk, mnt);
        %% Clear all unnecessary variables
        clearvars -except BTB subdir_list tp tpcode tags i
        
    end
end