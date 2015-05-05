function [ET_mrk] = readETMarkers(file)
% readETMarkers reads the markers from the eye tracker event file saved in
% the BTB.RawDir. Use function like "file_readBV".
% To make sense of the meaning of the EEG markers we need to match the
% marker number with the description present in the corresponding eye
% tracker event file. This file contains infromation about the markers in
% the lines starting with "UserEvent", e.g.:
% UserEvent	1	2	12649562197	# Message: mkr028_Start_tr_lf_07
% The structure "ET_mrk" contains information about the marker number and
% the corresponding description.

global BTB

number=[];
desc={};
fid = fopen(fullfile(BTB.RawDir, [file ' Events.txt']));
tline = fgetl(fid);
i=1;
while ischar(tline)
    if any(regexp(tline, 'UserEvent'))
        tmp=regexp(tline,'\t','split');
        tmp=tmp{end};
        ind=regexpi(tmp,'mkr');
        tmp=tmp(ind+3:end);
        tmp=regexp(tmp,'_','split','once');
        number(i) = str2num(tmp{1});
        desc{i}=tmp{2};
        i=i+1;
    end
    tline = fgetl(fid);
end
fclose(fid);

ET_mrk.number=number;
ET_mrk.desc=desc;

end