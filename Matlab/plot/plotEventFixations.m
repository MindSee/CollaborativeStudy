function [] = plotEventFixations(input, threesholdFixations)
% --
%
%   Syntax:
%          [] = plotEvent(input)
%
%   Parameters:
%           eye                         Eye monocular structure.
%
%   Return values:
%           --
%
%	Author: Filippo M.  06/05/2015


try
    close all
    clc
    
    % Nargin
    if nargin < 1
        [eye] = convertEventTxt2Mat();
    else
        % Get RAW
        if isstruct(input)
            [eye] = input;
        else
            [eye] = convertEventTxt2Mat(input);
        end
    end
    if nargin < 2
        threesholdFixations = 150000;  % threesholdFixations = 0;
    end
    
    nFixations = length(eye.fixations.trial);
    nTrials = max(eye.fixations.trial);
    
    iOldTrial = 0;
    
    for iFixations = 1 : nFixations
        
        iTrial = eye.fixations.trial(iFixations, 1);
        if (iTrial ~= iOldTrial)
            counterFixations = 1;
        else
            counterFixations = counterFixations + 1;
        end
        
        % Fixation
        if ((eye.fixations.duration(iFixations, 1) > threesholdFixations) == true)
            fixations(iTrial).duration(counterFixations) = eye.fixations.duration(iFixations, 1);
            fixations(iTrial).duration(counterFixations) = eye.fixations.duration(iFixations, 1);
            fixations(iTrial).location.x(counterFixations) = eye.fixations.location.x(iFixations, 1);
            fixations(iTrial).location.y(counterFixations) = eye.fixations.location.y(iFixations, 1);
            fixations(iTrial).pupil.size.x(counterFixations) = eye.fixations.pupil.size.x(iFixations, 1);
            fixations(iTrial).pupil.size.y(counterFixations) = eye.fixations.pupil.size.y(iFixations, 1);
        end
        
        iOldTrial = iTrial;
    end
    
    for iTrial = 1 : nTrials
        
        if (strfind(eye.events.description{iTrial, 1}, '_Start_'))
            
            figure(iTrial);
            
            % Trial Properties
            separator = strfind(eye.events.description{4, 1}, '_');
            simbol = eye.events.description{iTrial, 1}((separator(1, 2) + 1) : separator(1, 2) + 2);
            focus = eye.events.description{iTrial, 1}((separator(1, 3) + 1) : separator(1, 3) + 2);
            target = eye.events.description{iTrial, 1}((separator(1, 4) + 1) : separator(1, 4) + 2);
            
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
            
            title(['Fixations of ', titleFocus, ' with ', titleSimbol, ' stimuli [', target, ']']);
            
            hold on
            diameterTarget = 60;
            h = 1050; w = 1680;
            axis([0 w 0 h])
            
            % Plot Stimulus
            imageStimulus = imread(which([simbol, '_', focus, '_', target, '.tif']));
            image([0 w], [0 h], imageStimulus);
            
            % Plot Fixations
            load(which([simbol, '_', focus, '_', target, '.mat']));
            nTrialFixations = length(fixations(iTrial).location.x);
            for iTrialFixations = 1 : nTrialFixations
                centerFixation = [fixations(iTrial).location.x(iTrialFixations), fixations(iTrial).location.y(iTrialFixations)];
                [checkOnTarget, colourFixations] = checkFixationOnTarget(centerFixation, centerTarget, diameterTarget);
                plotFixation(centerFixation, (fixations(iTrial).duration(iTrialFixations)/100000), 1000, colourFixations);
            end
            
            % Plot Target
            nTarget = size(centerTarget, 1);
            for iTarget = 1 : nTarget
                % plot(centerTarget(iTarget, 1), centerTarget(iTarget, 2), '*r', 'MarkerSize', 8);
                plotTarget(centerTarget(iTarget, :), 30, 'k');
            end
            
            hold off
        end
    end
    
    disp('ok')
    
catch ME; if (exist('saveMException.p', 'file')); saveMException(ME); end; end

function [checkOnTarget, colourFixations] = checkFixationOnTarget(centerFixation, centerTarget, diameterTarget)
% --
%
%   Syntax:
%          --
%
%   Parameters:
%           centerFixation
%           centerTarget
%           diameterTarget
%
%   Return values:
%           checkOnTarget
%           colourFixations
%
%	Author: Filippo M.  06/05/2015


try
    checkOnTarget = false;
    colourFixations = 'k';
    
    xCenterFixation = centerFixation(1);
    yCenterFixation = centerFixation(2);
    
    nTarget = size(centerTarget, 1);
    
    for iTarget = 1 : nTarget
        
        xCenterTarget = centerTarget(iTarget, 1);
        yCenterTarget = centerTarget(iTarget, 2);
        
        if (xCenterFixation <= (xCenterTarget + (diameterTarget/2))) && ...
                (xCenterFixation >= (xCenterTarget - (diameterTarget/2))) && ...
                (yCenterFixation <= (yCenterTarget + (diameterTarget/2))) && ...
                (yCenterFixation >= (yCenterTarget - (diameterTarget/2)))
            checkOnTarget = true;
            colourFixations = 'g';
        else
            % disp([num2str(fix(xCenterFixation)), ' ', num2str(fix(yCenterFixation))]);
        end
    end
    
catch ME; if (exist('saveMException.p', 'file')); saveMException(ME); end; end

function [h] = plotFixation(center, r, N, color)
% Draws a circle filled with COLOR that has CENTER as its center and R as
% its radius, by using N points on the periphery.
%
%   Syntax:
%          [] = plotEvent(input)
%
%   Parameters:
%           center                      Center of the circle
%           r                           Radius of the circle
%           N                           Number of
%           color                       Color of the circle
%
%   Return values:
%           h                           Plot header
%
%	Author: Filippo M.  06/05/2015


try
    theta = linspace(0, (2 * pi), N);
    rho = ones(1,N) * r;
    [x, y] = pol2cart(theta, rho);
    x = x + center(1);
    y = y + center(2);
    h = fill(x, y, color);
    axis square;
    plot(x, y, color);
    
catch ME; if (exist('saveMException.p', 'file')); saveMException(ME); end; end

function [] = plotTarget(center, r, color)
% Draws a circle with COLOR that has CENTER as its center and R as
% its radius.
%
%   Syntax:
%          [] = plotTarget(center, r, color)
%
%   Parameters:
%           center                      Center of the circle
%           r                           Radius of the circle
%           color                       Color of the circle
%
%   Return values:
%           --
%
%	Author: Filippo M.  06/05/2015


try
    x = center(1);
    y = center(2);
    
    ang = [0 : 0.01 : (2 * pi)];
    xp = r * cos(ang);
    yp = r * sin(ang);
    plot(x + xp, y + yp, color);
    
catch ME; if (exist('saveMException.p', 'file')); saveMException(ME); end; end
