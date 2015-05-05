function [eye, eyes] = pupilBinocularData(input)
% --
%
%   Syntax:
%          [eye, eyes] = pupilBinocularData(input)
%
%   Parameters:
%           --
%
%   Return values:
%           --
%
%	Author: Filippo M.  18/03/2015


try
    % Nargin
    if nargin < 1
        [eyes] = pupilStructData();
    else
        % Get RAW
        if isstruct(input)
            [eyes] = input;
        else
            [eyes] = pupilStructData(input);
        end
    end
    
    % Info
    eye.info.sampleRate = eyes.info.sampleRate;
    eye.info.version = eyes.info.version;
    eye.info.file = eyes.info.file;
    eye.info.date = eyes.info.date;
    
    % Event
    eye.events.trial = eyes.events.trial;
    eye.events.number = eyes.events.number;
    eye.events.start = eyes.events.start;
    eye.events.description = eyes.events.description;
    
    % Blink
    nLeftBlinks = length(eyes.left.blink.trial);
    nRightBlinks = length(eyes.right.blink.trial);
    
    if (nLeftBlinks > nRightBlinks)
        for iLeftBlinks = 1 : nLeftBlinks
            for iRightBlinks = 1 : nRightBlinks
                eye.blink.trial(iLeftBlinks, 1)         = eyes.left.blink.trial(iLeftBlinks, 1);
                eye.blink.number(iLeftBlinks, 1)        = eyes.left.blink.number(iLeftBlinks, 1);
                eye.blink.start(iLeftBlinks, 1)         = eyes.left.blink.start(iLeftBlinks, 1);
                if (eyes.left.blink.start(iLeftBlinks, 1) == eyes.right.blink.start(iRightBlinks, 1))
                    eye.blink.end(iLeftBlinks, 1)       = mean([eyes.left.blink.end(iLeftBlinks, 1), eyes.right.blink.end(iRightBlinks, 1)]);
                    eye.blink.duration(iLeftBlinks, 1)  = mean([eyes.left.blink.duration(iLeftBlinks, 1), eyes.right.blink.duration(iRightBlinks, 1)]);
                else
                    eye.blink.end(iLeftBlinks, 1)       = eyes.left.blink.end(iLeftBlinks, 1);
                    eye.blink.duration(iLeftBlinks, 1)  = eyes.left.blink.duration(iLeftBlinks, 1);
                end
            end
        end
    else
        for iRightBlinks = 1 : nRightBlinks
            for iLeftBlinks = 1 : nLeftBlinks
                eye.blink.trial(iRightBlinks, 1)        = eyes.right.blink.trial(iRightBlinks, 1);
                eye.blink.number(iRightBlinks, 1)       = eyes.right.blink.number(iRightBlinks, 1);
                eye.blink.start(iRightBlinks, 1)        = eyes.right.blink.start(iRightBlinks, 1);
                if (eyes.left.blink.start(iLeftBlinks, 1) == eyes.right.blink.start(iRightBlinks, 1))
                    eye.blink.end(iRightBlinks, 1)      = mean([eyes.left.blink.end(iLeftBlinks, 1), eyes.right.blink.end(iRightBlinks, 1)]);
                    eye.blink.duration(iRightBlinks, 1) = mean([eyes.left.blink.duration(iLeftBlinks, 1), eyes.right.blink.duration(iRightBlinks, 1)]);
                else
                    eye.blink.end(iRightBlinks, 1)      = eyes.right.blink.end(iRightBlinks, 1);
                    eye.blink.duration(iRightBlinks, 1) = eyes.right.blink.duration(iRightBlinks, 1);
                end
            end
        end
    end
    
    % Saccade
    nLeftSaccades = length(eyes.left.saccade.trial);
    nRightSaccades = length(eyes.right.saccade.trial);
    
    if (nLeftSaccades > nRightSaccades)
        for iLeftSaccades = 1 : nLeftSaccades
            for iRightSaccades = 1 : nRightSaccades
                eye.saccade.trial(iLeftSaccades, 1)                     = eyes.left.saccade.trial(iLeftSaccades, 1);
                eye.saccade.number(iLeftSaccades, 1)                    = eyes.left.saccade.number(iLeftSaccades, 1);
                eye.saccade.start(iLeftSaccades, 1)                     = eyes.left.saccade.start(iLeftSaccades, 1);
                if (eyes.left.saccade.start(iLeftSaccades, 1) == eyes.right.saccade.start(iRightSaccades, 1))
                    eye.saccade.end(iLeftSaccades, 1)                   = mean([eyes.left.saccade.end(iLeftSaccades, 1), eyes.right.saccade.end(iRightSaccades, 1)]);
                    eye.saccade.duration(iLeftSaccades, 1)              = mean([eyes.left.saccade.duration(iLeftSaccades, 1), eyes.right.saccade.duration(iRightSaccades, 1)]);
                    eye.saccade.location.start.x(iLeftSaccades, 1)      = mean([eyes.left.saccade.location.start.x(iLeftSaccades, 1), eyes.right.saccade.location.start.x(iRightSaccades, 1)]);
                    eye.saccade.location.start.y(iLeftSaccades, 1)      = mean([eyes.left.saccade.location.start.y(iLeftSaccades, 1), eyes.right.saccade.location.start.y(iRightSaccades, 1)]);
                    eye.saccade.location.stop.x(iLeftSaccades, 1)       = mean([eyes.left.saccade.location.stop.x(iLeftSaccades, 1), eyes.right.saccade.location.stop.x(iRightSaccades, 1)]);
                    eye.saccade.location.stop.y(iLeftSaccades, 1)       = mean([eyes.left.saccade.location.stop.y(iLeftSaccades, 1), eyes.right.saccade.location.stop.y(iRightSaccades, 1)]);
                    eye.saccade.amplitude(iLeftSaccades, 1)             = mean([eyes.left.saccade.amplitude(iLeftSaccades, 1), eyes.right.saccade.amplitude(iRightSaccades, 1)]);
                    eye.saccade.speed.peak.to(iLeftSaccades, 1)         = mean([eyes.left.saccade.speed.peak.to(iLeftSaccades, 1), eyes.right.saccade.speed.peak.to(iRightSaccades, 1)]);
                    eye.saccade.speed.peak.from(iLeftSaccades, 1)       = mean([eyes.left.saccade.speed.peak.from(iLeftSaccades, 1), eyes.right.saccade.speed.peak.from(iRightSaccades, 1)]);
                    eye.saccade.speed.average(iLeftSaccades, 1)         = mean([eyes.left.saccade.speed.average(iLeftSaccades, 1), eyes.right.saccade.speed.average(iRightSaccades, 1)]);
                    eye.saccade.acceleration.peak(iLeftSaccades, 1)     = mean([eyes.left.saccade.acceleration.peak(iLeftSaccades, 1), eyes.right.saccade.acceleration.peak(iRightSaccades, 1)]);
                    eye.saccade.deceleration.peak(iLeftSaccades, 1)     = mean([eyes.left.saccade.deceleration.peak(iLeftSaccades, 1), eyes.right.saccade.deceleration.peak(iRightSaccades, 1)]);
                    eye.saccade.acceleration.average(iLeftSaccades, 1)  = mean([eyes.left.saccade.acceleration.average(iLeftSaccades, 1), eyes.right.saccade.acceleration.average(iRightSaccades, 1)]);
                else
                    eye.saccade.end(iLeftSaccades, 1)                   = eyes.left.saccade.end(iLeftSaccades, 1);
                    eye.saccade.duration(iLeftSaccades, 1)              = eyes.left.saccade.duration(iLeftSaccades, 1);
                    eye.saccade.location.start.x(iLeftSaccades, 1)      = eyes.left.saccade.location.start.x(iLeftSaccades, 1);
                    eye.saccade.location.start.y(iLeftSaccades, 1)      = eyes.left.saccade.location.start.y(iLeftSaccades, 1);
                    eye.saccade.location.stop.x(iLeftSaccades, 1)       = eyes.left.saccade.location.stop.x(iLeftSaccades, 1);
                    eye.saccade.location.stop.y(iLeftSaccades, 1)       = eyes.left.saccade.location.stop.y(iLeftSaccades, 1);
                    eye.saccade.amplitude(iLeftSaccades, 1)             = eyes.left.saccade.amplitude(iLeftSaccades, 1);
                    eye.saccade.speed.peak.to(iLeftSaccades, 1)         = eyes.left.saccade.speed.peak.to(iLeftSaccades, 1);
                    eye.saccade.speed.peak.from(iLeftSaccades, 1)       = eyes.left.saccade.speed.peak.from(iLeftSaccades, 1);
                    eye.saccade.speed.average(iLeftSaccades, 1)         = eyes.left.saccade.speed.average(iLeftSaccades, 1);
                    eye.saccade.acceleration.peak(iLeftSaccades, 1)     = eyes.left.saccade.acceleration.peak(iLeftSaccades, 1);
                    eye.saccade.deceleration.peak(iLeftSaccades, 1)     = eyes.left.saccade.deceleration.peak(iLeftSaccades, 1);
                    eye.saccade.acceleration.average(iLeftSaccades, 1)  = eyes.left.saccade.acceleration.average(iLeftSaccades, 1);
                end
            end
        end
    else
        for iRightSaccades = 1 : nRightSaccades
            for iLeftSaccades = 1 : nLeftSaccades
                eye.saccade.trial(iRightSaccades, 1)                     = eyes.right.saccade.trial(iRightSaccades, 1);
                eye.saccade.number(iRightSaccades, 1)                    = eyes.right.saccade.number(iRightSaccades, 1);
                eye.saccade.start(iRightSaccades, 1)                    = eyes.right.saccade.start(iRightSaccades, 1);
                if (eyes.left.saccade.start(iLeftSaccades, 1) == eyes.right.saccade.start(iRightSaccades, 1))
                    eye.saccade.end(iRightSaccades, 1)                   = mean([eyes.right.saccade.end(iRightSaccades, 1), eyes.left.saccade.end(iLeftSaccades, 1)]);
                    eye.saccade.duration(iRightSaccades, 1)              = mean([eyes.right.saccade.duration(iRightSaccades, 1), eyes.left.saccade.duration(iLeftSaccades, 1)]);
                    eye.saccade.location.start.x(iRightSaccades, 1)      = mean([eyes.right.saccade.location.start.x(iRightSaccades, 1), eyes.left.saccade.location.start.x(iLeftSaccades, 1)]);
                    eye.saccade.location.start.y(iRightSaccades, 1)      = mean([eyes.right.saccade.location.start.y(iRightSaccades, 1), eyes.left.saccade.location.start.y(iLeftSaccades, 1)]);
                    eye.saccade.location.stop.x(iRightSaccades, 1)       = mean([eyes.right.saccade.location.stop.x(iRightSaccades, 1), eyes.left.saccade.location.stop.x(iLeftSaccades, 1)]);
                    eye.saccade.location.stop.y(iRightSaccades, 1)       = mean([eyes.right.saccade.location.stop.y(iRightSaccades, 1), eyes.left.saccade.location.stop.y(iLeftSaccades, 1)]);
                    eye.saccade.amplitude(iRightSaccades, 1)             = mean([eyes.right.saccade.amplitude(iRightSaccades, 1), eyes.left.saccade.amplitude(iLeftSaccades, 1)]);
                    eye.saccade.speed.peak.to(iRightSaccades, 1)         = mean([eyes.right.saccade.speed.peak.to(iRightSaccades, 1), eyes.left.saccade.speed.peak.to(iLeftSaccades, 1)]);
                    eye.saccade.speed.peak.from(iRightSaccades, 1)       = mean([eyes.right.saccade.speed.peak.from(iRightSaccades, 1), eyes.left.saccade.speed.peak.from(iLeftSaccades, 1)]);
                    eye.saccade.speed.average(iRightSaccades, 1)         = mean([eyes.right.saccade.speed.average(iRightSaccades, 1), eyes.left.saccade.speed.average(iLeftSaccades, 1)]);
                    eye.saccade.acceleration.peak(iRightSaccades, 1)     = mean([eyes.right.saccade.acceleration.peak(iRightSaccades, 1), eyes.left.saccade.acceleration.peak(iLeftSaccades, 1)]);
                    eye.saccade.deceleration.peak(iRightSaccades, 1)     = mean([eyes.right.saccade.deceleration.peak(iRightSaccades, 1), eyes.left.saccade.deceleration.peak(iLeftSaccades, 1)]);
                    eye.saccade.acceleration.average(iRightSaccades, 1)  = mean([eyes.right.saccade.acceleration.average(iRightSaccades, 1), eyes.left.saccade.acceleration.average(iLeftSaccades, 1)]);
                else
                    eye.saccade.end(iRightSaccades, 1)                   = eyes.right.saccade.end(iRightSaccades, 1);
                    eye.saccade.duration(iRightSaccades, 1)              = eyes.right.saccade.duration(iRightSaccades, 1);
                    eye.saccade.location.start.x(iRightSaccades, 1)      = eyes.right.saccade.location.start.x(iRightSaccades, 1);
                    eye.saccade.location.start.y(iRightSaccades, 1)      = eyes.right.saccade.location.start.y(iRightSaccades, 1);
                    eye.saccade.location.stop.x(iRightSaccades, 1)       = eyes.right.saccade.location.stop.x(iRightSaccades, 1);
                    eye.saccade.location.stop.y(iRightSaccades, 1)       = eyes.right.saccade.location.stop.y(iRightSaccades, 1);
                    eye.saccade.amplitude(iRightSaccades, 1)             = eyes.right.saccade.amplitude(iRightSaccades, 1);
                    eye.saccade.speed.peak.to(iRightSaccades, 1)         = eyes.right.saccade.speed.peak.to(iRightSaccades, 1);
                    eye.saccade.speed.peak.from(iRightSaccades, 1)       = eyes.right.saccade.speed.peak.from(iRightSaccades, 1);
                    eye.saccade.speed.average(iRightSaccades, 1)         = eyes.right.saccade.speed.average(iRightSaccades, 1);
                    eye.saccade.acceleration.peak(iRightSaccades, 1)     = eyes.right.saccade.acceleration.peak(iRightSaccades, 1);
                    eye.saccade.deceleration.peak(iRightSaccades, 1)     = eyes.right.saccade.deceleration.peak(iRightSaccades, 1);
                    eye.saccade.acceleration.average(iRightSaccades, 1)  = eyes.right.saccade.acceleration.average(iRightSaccades, 1);
                end
            end
        end
    end
    
    % Fixations
    nLeftFixations = length(eyes.left.fixations.trial);
    nRightFixations = length(eyes.right.fixations.trial);
    
    if (nLeftFixations > nRightFixations)
        for iLeftFixations = 1 : nLeftFixations
            for iRightFixations = 1 : nRightFixations
                eye.fixations.trial(iLeftFixations, 1)            = eyes.left.fixations.trial(iLeftFixations, 1);
                eye.fixations.number(iLeftFixations, 1)           = eyes.left.fixations.number(iLeftFixations, 1);
                eye.fixations.start(iLeftFixations, 1)            = eyes.left.fixations.start(iLeftFixations, 1);
                if (eyes.left.fixations.start(iLeftFixations, 1) == eyes.right.fixations.start(iRightFixations, 1))
                    eye.fixations.end(iLeftFixations, 1)          = mean([eyes.left.fixations.end(iLeftFixations, 1), eyes.right.fixations.end(iRightFixations, 1)]);
                    eye.fixations.duration(iLeftFixations, 1)     = mean([eyes.left.fixations.duration(iLeftFixations, 1), eyes.right.fixations.duration(iRightFixations, 1)]);
                    eye.fixations.location.x(iLeftFixations, 1)   = mean([eyes.left.fixations.location.x(iLeftFixations, 1), eyes.right.fixations.location.x(iRightFixations, 1)]);
                    eye.fixations.location.y(iLeftFixations, 1)   = mean([eyes.left.fixations.location.y(iLeftFixations, 1), eyes.right.fixations.location.y(iRightFixations, 1)]);
                    eye.fixations.dispersion.x(iLeftFixations, 1) = mean([eyes.left.fixations.dispersion.x(iLeftFixations, 1), eyes.right.fixations.dispersion.x(iRightFixations, 1)]);
                    eye.fixations.dispersion.y(iLeftFixations, 1) = mean([eyes.left.fixations.dispersion.y(iLeftFixations, 1), eyes.right.fixations.dispersion.y(iRightFixations, 1)]);
                    eye.fixations.plane(iLeftFixations, 1)        = mean([eyes.left.fixations.plane(iLeftFixations, 1), eyes.right.fixations.plane(iRightFixations, 1)]);
                    eye.fixations.pupil.size.x(iLeftFixations, 1) = mean([eyes.left.fixations.pupil.size.x(iLeftFixations, 1), eyes.right.fixations.pupil.size.x(iRightFixations, 1)]);
                    eye.fixations.pupil.size.y(iLeftFixations, 1) = mean([eyes.left.fixations.pupil.size.y(iLeftFixations, 1), eyes.right.fixations.pupil.size.y(iRightFixations, 1)]);
                else
                    eye.fixations.end(iLeftFixations, 1)          = eyes.left.fixations.end(iLeftFixations, 1);
                    eye.fixations.duration(iLeftFixations, 1)     = eyes.left.fixations.duration(iLeftFixations, 1);
                    eye.fixations.location.x(iLeftFixations, 1)   = eyes.left.fixations.location.x(iLeftFixations, 1);
                    eye.fixations.location.y(iLeftFixations, 1)   = eyes.left.fixations.location.y(iLeftFixations, 1);
                    eye.fixations.dispersion.x(iLeftFixations, 1) = eyes.left.fixations.dispersion.x(iLeftFixations, 1);
                    eye.fixations.dispersion.y(iLeftFixations, 1) = eyes.left.fixations.dispersion.y(iLeftFixations, 1);
                    eye.fixations.plane(iLeftFixations, 1)        = eyes.left.fixations.plane(iLeftFixations, 1);
                    eye.fixations.pupil.size.x(iLeftFixations, 1) = eyes.left.fixations.pupil.size.x(iLeftFixations, 1);
                    eye.fixations.pupil.size.y(iLeftFixations, 1) = eyes.left.fixations.pupil.size.y(iLeftFixations, 1);
                end
            end
        end
    else
        for iRightFixations = 1 : nRightFixations
            for iLeftFixations = 1 : nLeftFixations
                eye.fixations.trial(iRightFixations, 1)            = eyes.right.fixations.trial(iRightFixations, 1);
                eye.fixations.number(iRightFixations, 1)           = eyes.right.fixations.number(iRightFixations, 1);
                eye.fixations.start(iRightFixations, 1)            = eyes.right.fixations.start(iRightFixations, 1);
                if (eyes.left.fixations.start(iLeftFixations, 1) == eyes.right.fixations.start(iRightFixations, 1))
                    eye.fixations.end(iRightFixations, 1)          = mean([eyes.right.fixations.end(iRightFixations, 1), eyes.left.fixations.end(iLeftFixations, 1)]);
                    eye.fixations.duration(iRightFixations, 1)     = mean([eyes.right.fixations.duration(iRightFixations, 1), eyes.left.fixations.duration(iLeftFixations, 1)]);
                    eye.fixations.location.x(iRightFixations, 1)   = mean([eyes.right.fixations.location.x(iRightFixations, 1), eyes.left.fixations.location.x(iLeftFixations, 1)]);
                    eye.fixations.location.y(iRightFixations, 1)   = mean([eyes.right.fixations.location.y(iRightFixations, 1), eyes.left.fixations.location.y(iLeftFixations, 1)]);
                    eye.fixations.dispersion.x(iRightFixations, 1) = mean([eyes.right.fixations.dispersion.x(iRightFixations, 1), eyes.left.fixations.dispersion.x(iLeftFixations, 1)]);
                    eye.fixations.dispersion.y(iRightFixations, 1) = mean([eyes.right.fixations.dispersion.y(iRightFixations, 1), eyes.left.fixations.dispersion.y(iLeftFixations, 1)]);
                    eye.fixations.plane(iRightFixations, 1)        = mean([eyes.right.fixations.plane(iRightFixations, 1), eyes.left.fixations.plane(iLeftFixations, 1)]);
                    eye.fixations.pupil.size.x(iRightFixations, 1) = mean([eyes.right.fixations.pupil.size.x(iRightFixations, 1), eyes.left.fixations.pupil.size.x(iLeftFixations, 1)]);
                    eye.fixations.pupil.size.y(iRightFixations, 1) = mean([eyes.right.fixations.pupil.size.y(iRightFixations, 1), eyes.left.fixations.pupil.size.y(iLeftFixations, 1)]);
                else
                    eye.fixations.end(iRightFixations, 1)          = eyes.right.fixations.end(iRightFixations, 1);
                    eye.fixations.duration(iRightFixations, 1)     = eyes.right.fixations.duration(iRightFixations, 1);
                    eye.fixations.location.x(iRightFixations, 1)   = eyes.right.fixations.location.x(iRightFixations, 1);
                    eye.fixations.location.y(iRightFixations, 1)   = eyes.right.fixations.location.y(iRightFixations, 1);
                    eye.fixations.dispersion.x(iRightFixations, 1) = eyes.right.fixations.dispersion.x(iRightFixations, 1);
                    eye.fixations.dispersion.y(iRightFixations, 1) = eyes.right.fixations.dispersion.y(iRightFixations, 1);
                    eye.fixations.plane(iRightFixations, 1)        = eyes.right.fixations.plane(iRightFixations, 1);
                    eye.fixations.pupil.size.x(iRightFixations, 1) = eyes.right.fixations.pupil.size.x(iRightFixations, 1);
                    eye.fixations.pupil.size.y(iRightFixations, 1) = eyes.right.fixations.pupil.size.y(iRightFixations, 1);
                end
            end
        end
    end
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
