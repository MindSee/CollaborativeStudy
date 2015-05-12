function [] = findTheCenterOfTarget(simbol, focus, target)
% Find the center of the target.
%
%   Syntax:
%          [] = findTheCenterOfTarget(simbol, focus, target)
%
%   Parameters:
%           simbol                  Simbol of the target (cr, es, tr, do,
%                                   st, sq).
%           focus                   Focus of the target (lf, hf).
%           target                  Number of the target.
%
%   Return values:
%           --
%
%	Author: Filippo M.  07/05/2015


try
    screenSize = get(0, 'ScreenSize');
    fig = figure(1);
    set(fig, 'position', screenSize);
    
    % Trial Properties
    switch simbol
        case {'cr'}; titleSimbol = 'Crossed';
        case {'es'}; titleSimbol = 'Eye-Shaped';
        case {'tr'}; titleSimbol = 'Triangle';
        case {'do'}; titleSimbol = 'Dotted';
        case {'st'}; titleSimbol = 'Striped';
        case {'sq'}; titleSimbol = 'Square';
        otherwise; titleSimbol = simbol;
    end
    
    switch focus
        case {'lf'}; titleFocus = 'Low focus';
        case {'hf'}; titleFocus = 'High focus';
        otherwise; titleFocus = focus;
    end
    
    h = 1050; w = 1680;
    axis([0 w 0 h])
    
    % Plot Stimulus
    imageFileName = which([simbol, '_', focus, '_', target, '.tif']);
    imageFilePath = fileparts(imageFileName);
    imageStimulus = imread(imageFileName);
    
    hold on
    image([0 w], [h 0], imageStimulus);
    
    % Plot Fixations
    nTarget = str2double(target);
    for iTarget = 1 : nTarget
        title(['Find the  ', num2str(iTarget), '  target of ', titleFocus, ' with ', titleSimbol, ' stimuli [', target, ']']);
        [centerTarget(iTarget, 1), centerTarget(iTarget, 2)] = ginput(1);
    end
    
    % Save the center of the target
    if ~(strcmp(imageFilePath(end), filesep)); imageFilePath = [imageFilePath, filesep]; end
    save([imageFilePath, simbol, '_', focus, '_', target], 'centerTarget');
    
    close(fig)
    
    if exist([imageFilePath, simbol, '_', focus, '_', target, '.mat'])
        disp(['The coordinates are saved into: ', imageFilePath, simbol, '_', focus, '_', target, '.mat .']); else disp('Error.');
    end
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
