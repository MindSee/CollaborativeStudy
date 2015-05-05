function [inputUpdated] = pupilDataControl(input)
% --
%
%   Syntax:
%          [inputUpdated] = pupilDataControl(input)
%
%   Parameters:
%           --
%
%   Return values:
%           --
%
%	Author: Filippo M.  24/03/2015


try
    if ~(isempty(input)) || ~(input == 0) || ~(isnan(isempty(input)))
        inputUpdated = input;
    else
        disp(['Data Control: ']);
        input
        inputUpdated = 0;
    end
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
