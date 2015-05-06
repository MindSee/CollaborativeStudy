function [eyes, inputPath, inputName] = pupilCollaborativeEyeAnalize(threesholdTrials, eyes, inputPath, inputName)
% --
%
%   Syntax:
%          [] = pupilCollaborativeEyeAnalize(threesholdTrials)
%
%   Parameters:
%           --
%
%   Return values:
%           --
%
%	Author: Filippo M.  20/03/2015


try
    % Nargin
    if nargin < 2
        % Get Data File
        [inputName, inputPath] = uigetfile({'*.xlsx; *.xls; *.mat; *.txt'}, 'Pick a Eye Tracker File [.xlsx, .xls, .mat, .txt]');
        if nargin < 1
            threesholdTrials = 1;
        end
    end
    
    disp(['The number of the trials is set to ', num2str(threesholdTrials), ' value.'])
    index_ = strfind(inputName, '_');
    
    % % Event
    iEvent = 0;
    if ~exist('eyes', 'var')
        focus = 'hf';
        iEvent = iEvent + 1; simbol = 'sq'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'tr'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'es'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'do'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'st'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'cr'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        
        focus = 'lf';
        iEvent = iEvent + 1; simbol = 'sq'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'tr'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'es'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'do'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'st'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
        iEvent = iEvent + 1; simbol = 'cr'; eyes(iEvent, 1).eye = pupilCollaborativeEyeMovements([inputPath, inputName(1 : (index_(1))), focus, inputName(index_(2)), simbol, inputName(index_(3) : end)]);
    end
    
    % Save Eye Data
    file = [inputPath, inputName(1 : (index_(1))), inputName((index_(3) + 1) : ((index_(3) + 1) + 5)), '_Result_Trials', num2str(threesholdTrials)];
    pupilCollaborativeEyeSaveData(file, eyes, threesholdTrials, true);
    disp(['File generated: ', file, '.xlsx'])
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end