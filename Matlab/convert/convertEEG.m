addpath(genpath(fullfile(BTB.PrivateDir, 'studies', '2015-MindSee-Collaborative')));

convertBase;

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
        
        clabScalp= hdr.clab(util_scalpChannels(hdr.clab));
        clabNonScalp= hdr.clab(util_chanind(hdr.clab, 'not',clabScalp));
        
        % load raw data, downsampling is done while loading
        Fs = 250; % new sampling rate
        [cnt, mrk] = file_readBV(file, 'Fs',Fs, 'Filt',filt ,'Clab', clabScalp);
        
        % Load eye tracking data
        [ET_mrk] = readETMarkers(file);
        
        % Subtract corresponding bipolar electrodes of electrodes for facial EMG and electrodermal activity
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
        
        %% save in matlab format        
        matfilename = fullfile(BTB.MatDir,file);
        eegfilename = regexprep(matfilename, 'MindSeeCollaborativeStudy2015', 'EEG');
        fprintf('Saving %s\n', eegfilename)
        warning('off', 'MATLAB:save:versionWithAppend')
        file_saveMatlab(eegfilename, cnt, mrk, mnt);
        
                                 
        %% Clear all unnecessary variables
        clearvars -except BTB subdir_list tp tpcode tags i
        
    end
end