function [] = readMException()
% Read a MException from mat file.
%
%   Syntax:
%           [] = mcReadMException()
%
%   Parameters:
%           --
%
%   Return values:
%           --
%
%	Author: Filippo M.  23/12/2014


% Command Window
clc

% Exception file name
nameFileException = 'MException';
fileException = [nameFileException, '.mat'];
fileException = which(fileException);

% Load fileException
nException = 0;
if exist(fileException)
    load(fileException);
    nException = length(exception);
    % Report
    if nException > 0
        for iException = 1 : nException
            disp(['EXCEPTION n° ', num2str(iException), ' (', exception(1, iException).date, ')']);
            getReport(exception(1, iException).ME)
            disp(' ')
        end
    end
end
