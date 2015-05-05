function mrk=mrk_matchClasses(mrk, ET_mrk)
% Translate EEG markers (numbers only) into meaningful names
% Initial EEG marker class names are only numbers with unequal
% To learn about the meaning of the markers, the corresponding ET markers
% have to be inspected.

mrk.y=zeros(4,length(mrk.className));
for ii=1:length(mrk.className)
    tmp=regexp(mrk.className{ii},'S','split'); tmp=str2num(tmp{end});
    
    % Check that marker count (1,2,3,...) of EEG and ET match
    if tmp==ET_mrk.number(ii)
        class=regexp(ET_mrk.desc{ii},'_','split','once');class=class{1};
        switch class
            case 'BeginBlock'
                mrk.y(1,ii)=1;
            case 'Start'
                mrk.y(2,ii)=1;
            case 'Stop'
                mrk.y(3,ii)=1;
            case 'StopBlock'
                mrk.y(4,ii)=1;
            otherwise
                error('Unexpected class!!')
        end
    else
        error('EEG and ET marker number is not matching!')
    end
end
mrk.className={'BeginBlock','Start','Stop','StopBlock'};