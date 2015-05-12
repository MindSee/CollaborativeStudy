function [] = saveMException(ME)
% Saving a MException into mat file. The file is saved in the folder
% mcSaveMException.m
%
%   Syntax:
%           [] = saveMException(ME)
%
%   Parameters:
%           ME          MException (capture error information) to save.
%
%   Return values:
%           --
%
%	Author: Filippo M.  23/12/2014


% Report
getReport(ME)

% Exception file name
nameFileException = 'MException';
fileException = [nameFileException, '.mat'];
fileException = which(fileException);

% Load fileException
clockInfo = clock;
nException = 0;
if exist(fileException)
    load(fileException);
    nException = length(exception);
else
    pathSaveMException = which('saveMException.m');
    sep = strfind(pathSaveMException, filesep);
    pathSaveMException = pathSaveMException(1 : sep(end));
    fileException = [pathSaveMException, nameFileException];
end

% Update info exception
chechExceptionExist = false;
if nException > 0
    for iException = 1 : nException
        if strcmp(exception(1, iException).ME.message, ME.message)
            chechExceptionExist = true;
        end
    end
    if chechExceptionExist == false
        iException = nException + 1;
        exception(1, iException).date = [date, ' ', num2str(clockInfo(4)), ':', num2str(clockInfo(5)), '.', num2str(fix(clockInfo(6)))];
        exception(1, iException).computer = computer;
        exception(1, iException).ME = ME;
    end
else
    iException = nException + 1;
    exception(1, iException).date = [date, ' ', num2str(clockInfo(4)), ':', num2str(clockInfo(5)), '.', num2str(fix(clockInfo(6)))];
    exception(1, iException).computer = computer;
    exception(1, iException).ME = ME;
end

% Save exception
save([fileException], 'exception');
