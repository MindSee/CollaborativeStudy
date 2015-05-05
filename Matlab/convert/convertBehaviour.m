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
        % Load eye tracking data
        
        [ET_mrk] = readETMarkers(file);

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
        behaviourfilename = regexprep(matfilename, 'MindSeeCollaborativeStudy2015', 'Behaviour');
        
        [pathstr,name,ext] = fileparts(behaviourfilename);
        if not(isdir(pathstr)), mkdir(pathstr), end
        
        save(behaviourfilename,'behaviour');
        %% Clear all unnecessary variables
        clearvars -except BTB subdir_list tp tpcode tags i
        
    end
end