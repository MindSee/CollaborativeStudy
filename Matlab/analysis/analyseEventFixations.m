function [eyeUpdate, eyeWithoutThreesholdedFixations] = analyseEventFixations(input, checkPlot, threesholdFixations, diameterTarget)
% Update and plot the Fixations.
%
%   Syntax:
%          [eyeUpdate, eyeWithoutThreesholdedFixations] = analyseEventFixations(input)
%          [eyeUpdate, eyeWithoutThreesholdedFixations] = analyseEventFixations(input, threesholdFixations)
%          [eyeUpdate, eyeWithoutThreesholdedFixations] = analyseEventFixations(input, threesholdFixations, diameterTarget)
%
%   Parameters:
%           eye                         Eye monocular structure.
%           threesholdFixations         Threeshold of Fixations in
%                                       micro-second.
%           diameterTarget              Diameter of the target in px.
%
%   Return values:
%           eyeUpdate                           Eye struct updated
%           eyeWithoutThreesholdedFixations     Eye struct without the
%                                       fixations with the duratione under
%                                       the threeshold.
%
%	Author: Filippo M.  06/05/2015


try
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
    
    if nargin < 4
        % Diameter of the Target in pixels
        diameterTarget = 60;
        if nargin < 3
            % Threeshold of Fixations in micro-second
            threesholdFixations = 0;
            if nargin < 2
                checkPlot = false;
            end
        end
    end
    
    eyeWithoutThreesholdedFixations = eye;
    eyeWithoutThreesholdedFixations.fixations = [];
    
    nFixations = length(eye.fixations.trial);
    nTrials = max(eye.fixations.trial);
    
    iOldTrial = 0;
    iUpdateFixations = 0;
    for iFixations = 1 : nFixations
        
        iTrial = eye.fixations.trial(iFixations, 1);
        if (iTrial ~= iOldTrial)
            counterFixations = 0;
        end
        
        % Threeshold Fixation
        if ((eye.fixations.duration(iFixations, 1) > threesholdFixations) == true)
            counterFixations = counterFixations + 1;
            fixations(iTrial).duration(counterFixations) = eye.fixations.duration(iFixations, 1);
            fixations(iTrial).duration(counterFixations) = eye.fixations.duration(iFixations, 1);
            fixations(iTrial).location.x(counterFixations) = eye.fixations.location.x(iFixations, 1);
            fixations(iTrial).location.y(counterFixations) = eye.fixations.location.y(iFixations, 1);
            fixations(iTrial).pupil.size.x(counterFixations) = eye.fixations.pupil.size.x(iFixations, 1);
            fixations(iTrial).pupil.size.y(counterFixations) = eye.fixations.pupil.size.y(iFixations, 1);
            fixations(iTrial).number(counterFixations) = eye.fixations.number(iFixations, 1);
            
            % eyeWithoutThreesholdedFixations
            iUpdateFixations = iUpdateFixations + 1;
            eyeWithoutThreesholdedFixations.fixations.trial(iUpdateFixations, 1) = eye.fixations.trial(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.number(iUpdateFixations, 1) = eye.fixations.number(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.start(iUpdateFixations, 1) = eye.fixations.start(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.end(iUpdateFixations, 1) = eye.fixations.end(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.duration(iUpdateFixations, 1) = eye.fixations.duration(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.location.x(iUpdateFixations, 1) = eye.fixations.location.x(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.location.y(iUpdateFixations, 1) = eye.fixations.location.y(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.dispersion.x(iUpdateFixations, 1) = eye.fixations.dispersion.x(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.dispersion.y(iUpdateFixations, 1) = eye.fixations.dispersion.y(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.pupil.size.x(iUpdateFixations, 1) = eye.fixations.pupil.size.x(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.pupil.size.y(iUpdateFixations, 1) = eye.fixations.pupil.size.y(iFixations, 1);
            eyeWithoutThreesholdedFixations.fixations.plane(iUpdateFixations, 1) = eye.fixations.plane(iFixations, 1);
            
            eyeWithoutThreesholdedFixations.fixations.isOnTarget(iUpdateFixations, 1) = false;
        end
        eye.fixations.isOnTarget(iFixations, 1) = false;
        
        iOldTrial = iTrial;
    end
    
    for iTrial = 1 : nTrials
        
        if (strfind(eye.events.description{iTrial, 1}, '_Start_'))
            
            if checkPlot
                figure(iTrial);
            end
            
            % Trial Properties
            separator = strfind(eye.events.description{4, 1}, '_');
            simbol = eye.events.description{iTrial, 1}((separator(1, 2) + 1) : separator(1, 2) + 2);
            focus = eye.events.description{iTrial, 1}((separator(1, 3) + 1) : separator(1, 3) + 2);
            target = eye.events.description{iTrial, 1}((separator(1, 4) + 1) : separator(1, 4) + 2);
            
            fileTarget = which([simbol, '_', focus, '_', target, '.mat']);
            
            if (exist(fileTarget) ~= 0)
                load(fileTarget);
                
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
                
                
                hold on
                h = 1050; w = 1680; axis([0 w 0 h]);
                
                % Plot Stimulus
                if checkPlot
                    title(['Fixations of ', titleFocus, ' with ', titleSimbol, ' stimuli [', target, ']']);
                    imageStimulus = imread(which([simbol, '_', focus, '_', target, '.tif']));
                    image([0 w], [h 0], imageStimulus);
                end
                % Plot Fixations
                nTrialFixations = length(fixations(iTrial).location.x);
                for iTrialFixations = 1 : nTrialFixations
                    centerFixation = [fixations(iTrial).location.x(iTrialFixations), fixations(iTrial).location.y(iTrialFixations)];
                    [checkOnTarget, colourFixations] = checkFixationOnTarget(centerFixation, centerTarget, diameterTarget);
                    if checkPlot
                        plotFixation(centerFixation, (fixations(iTrial).duration(iTrialFixations)/100000), 1000, colourFixations);
                        % x = centerFixation(1); y = centerFixation(2); text(x, y, [num2str(iTrialFixations), ' [x: ', num2str(x), ', y: ', num2str(y), ']'])
                    end
                    if checkOnTarget
                        eyeWithoutThreesholdedFixations.fixations.isOnTarget(find(eyeWithoutThreesholdedFixations.fixations.number == fixations(iTrial).number(iTrialFixations)), 1) = true;
                        eye.fixations.isOnTarget(find(eye.fixations.number == fixations(iTrial).number(iTrialFixations)), 1) = true;
                    end
                end
                
                if checkPlot
                    plot(fixations(iTrial).location.x, fixations(iTrial).location.y, '-b')
                    
                    % Plot Target
                    nTarget = size(centerTarget, 1);
                    for iTarget = 1 : nTarget
                        plotTarget(centerTarget(iTarget, :), diameterTarget/2, 'k');
                    end
                end
                hold off
                
            end
        end
    end
    
    eyeUpdate = eye;
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

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
    colourFixations = 'b';
    
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
            colourFixations = 'k';
        end
    end
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

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
    h = fill(x, y, color); axis square;
    plot(x, y, color);
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

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
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
