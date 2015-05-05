addpath(genpath(fullfile(BTB.PrivateDir, 'studies', '2015-MindSee-Collaborative')));

convertBase;

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