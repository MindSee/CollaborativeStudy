function [eyes] = pupilStructData(input)
% --
%
%   Syntax:
%          [eyes] = pupilStructData(input)
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
        [RAW] = pupilAcquisitionImport();
    else
        % Get RAW
        if isstruct(input)
            [RAW] = input;
        else
            [RAW] = pupilAcquisitionImport(input);
        end
    end
    
    % Parameters
    eyes = struct('info', struct('sampleRate', [], 'version', [], 'file', [], 'date', []), ...
        'events', struct('trial', [], 'number', [], 'start', [], 'description', []), ...
        'left', struct(...
        'blink', struct('number', [], 'start', [], 'end', [], 'duration', []),...
        'saccade', struct('number', [], 'start', [], 'end', [], 'duration', [], 'location', [], 'amplitude', [], 'speed', [], 'acceleration', []),...
        'fixations', struct('number', [], 'start', [], 'end', [], 'duration', [], 'location', [], 'dispersion', [], 'plane', [], 'pupil', [])),...
        'right', struct(...
        'blink', struct('number', [], 'start', [], 'end', [], 'duration', []),...
        'saccade', struct('number', [], 'start', [], 'end', [], 'duration', [], 'location', [], 'amplitude', [], 'speed', [], 'acceleration', []),...
        'fixations', struct('number', [], 'start', [], 'end', [], 'duration', [], 'location', [], 'dispersion', [], 'plane', [], 'pupil', []))...
        );
    
    [rRAW, cRAW] = size(RAW);
    
    % Counters
    iEvents = 0;
    iLeftBlinks = 0;
    iRightBlinks = 0;
    iLeftSaccades = 0;
    iRightSaccades = 0;
    iLeftFixations = 0;
    iRightFixations = 0;
    
    checkEvent = false;
    checkSample = false;
    for irRAW = 1 : rRAW
        if strfind(RAW{irRAW, 1}, 'Version:')
            if strfind(RAW{irRAW, 2}, 'Event')
                checkEvent = true; irRAW = rRAW;
            elseif strfind(RAW{irRAW, 2}, 'Converter')
                checkSample = true; irRAW = rRAW;
            end
        end
    end
    
    if (rRAW ~= 0)
        if checkEvent
            
            % disp('Event')
            
            for irRAW = 1 : rRAW
                if strfind(RAW{irRAW, 1}, 'Sample Rate:')
                    eyes.info.sampleRate = RAW{irRAW, 2};
                elseif strfind(RAW{irRAW, 1}, 'Version:')
                    eyes.info.version = RAW{irRAW, 2};
                elseif strfind(RAW{irRAW, 1}, 'Converted from:')
                    eyes.info.file = RAW{irRAW, 2};
                elseif strfind(RAW{irRAW, 1}, 'Date:')
                    eyes.info.date = RAW{irRAW, 2};
                    
                elseif strfind(RAW{irRAW, 1}, 'UserEvent')                 % Event
                    iEvents = iEvents + 1;
                    eyes.events.trial(iEvents, 1) = iEvents;
                    eyes.events.number(iEvents, 1) = RAW{irRAW, 3};
                    eyes.events.start(iEvents, 1) = RAW{irRAW, 4};
                    eyes.events.description{iEvents, 1} = RAW{irRAW, 5}(12 : end);
                    
                elseif strfind(RAW{irRAW, 1}, 'Blink L')                   % Blink
                    iLeftBlinks = iLeftBlinks + 1;
                    eyes.left.blink.trial(iLeftBlinks, 1) = RAW{irRAW, 2};
                    eyes.left.blink.number(iLeftBlinks, 1) = RAW{irRAW, 3};
                    eyes.left.blink.start(iLeftBlinks, 1) = RAW{irRAW, 4};
                    eyes.left.blink.end(iLeftBlinks, 1) = RAW{irRAW, 5};
                    eyes.left.blink.duration(iLeftBlinks, 1) = RAW{irRAW, 6};
                elseif strfind(RAW{irRAW, 1}, 'Blink R')
                    iRightBlinks = iRightBlinks + 1;
                    eyes.right.blink.trial(iRightBlinks, 1) = RAW{irRAW, 2};
                    eyes.right.blink.number(iRightBlinks, 1) = RAW{irRAW, 3};
                    eyes.right.blink.start(iRightBlinks, 1) = RAW{irRAW, 4};
                    eyes.right.blink.end(iRightBlinks, 1) = RAW{irRAW, 5};
                    eyes.right.blink.duration(iRightBlinks, 1) = RAW{irRAW, 6};
                    
                elseif strfind(RAW{irRAW, 1}, 'Saccade L')                 % Saccade
                    iLeftSaccades = iLeftSaccades + 1;
                    eyes.left.saccade.trial(iLeftSaccades, 1) = RAW{irRAW, 2};
                    eyes.left.saccade.number(iLeftSaccades, 1) = RAW{irRAW, 3};
                    eyes.left.saccade.start(iLeftSaccades, 1) = RAW{irRAW, 4};
                    eyes.left.saccade.end(iLeftSaccades, 1) = RAW{irRAW, 5};
                    eyes.left.saccade.duration(iLeftSaccades, 1) = RAW{irRAW, 6};
                    eyes.left.saccade.location.start.x(iLeftSaccades, 1) = str2double(RAW{irRAW, 7});
                    eyes.left.saccade.location.start.y(iLeftSaccades, 1) = str2double(RAW{irRAW, 8});
                    eyes.left.saccade.location.stop.x(iLeftSaccades, 1) = str2double(RAW{irRAW, 9});
                    eyes.left.saccade.location.stop.y(iLeftSaccades, 1) = str2double(RAW{irRAW, 10});
                    eyes.left.saccade.amplitude(iLeftSaccades, 1) = str2double(RAW{irRAW, 11});
                    eyes.left.saccade.speed.peak.to(iLeftSaccades, 1) = str2double(RAW{irRAW, 12});
                    eyes.left.saccade.speed.peak.from(iLeftSaccades, 1) = str2double(RAW{irRAW, 13});
                    eyes.left.saccade.speed.average(iLeftSaccades, 1) = str2double(RAW{irRAW, 14});
                    eyes.left.saccade.acceleration.peak(iLeftSaccades, 1) = str2double(RAW{irRAW, 15});
                    eyes.left.saccade.deceleration.peak(iLeftSaccades, 1) = str2double(RAW{irRAW, 16});
                    eyes.left.saccade.acceleration.average(iLeftSaccades, 1) = str2double(RAW{irRAW, 17});
                elseif strfind(RAW{irRAW, 1}, 'Saccade R')
                    iRightSaccades = iRightSaccades + 1;
                    eyes.right.saccade.trial(iRightSaccades, 1) = RAW{irRAW, 2};
                    eyes.right.saccade.number(iRightSaccades, 1) = RAW{irRAW, 3};
                    eyes.right.saccade.start(iRightSaccades, 1) = RAW{irRAW, 4};
                    eyes.right.saccade.end(iRightSaccades, 1) = RAW{irRAW, 5};
                    eyes.right.saccade.duration(iRightSaccades, 1) = RAW{irRAW, 6};
                    eyes.right.saccade.location.start.x(iRightSaccades, 1) = str2double(RAW{irRAW, 7});
                    eyes.right.saccade.location.start.y(iRightSaccades, 1) = str2double(RAW{irRAW, 8});
                    eyes.right.saccade.location.stop.x(iRightSaccades, 1) = str2double(RAW{irRAW, 9});
                    eyes.right.saccade.location.stop.y(iRightSaccades, 1) = str2double(RAW{irRAW, 10});
                    eyes.right.saccade.amplitude(iRightSaccades, 1) = str2double(RAW{irRAW, 11});
                    eyes.right.saccade.speed.peak.to(iRightSaccades, 1) = str2double(RAW{irRAW, 12});
                    eyes.right.saccade.speed.peak.from(iRightSaccades, 1) = str2double(RAW{irRAW, 13});
                    eyes.right.saccade.speed.average(iRightSaccades, 1) = str2double(RAW{irRAW, 14});
                    eyes.right.saccade.acceleration.peak(iRightSaccades, 1) = str2double(RAW{irRAW, 15});
                    eyes.right.saccade.deceleration.peak(iRightSaccades, 1) = str2double(RAW{irRAW, 16});
                    eyes.right.saccade.acceleration.average(iRightSaccades, 1) = str2double(RAW{irRAW, 17});
                    
                elseif strfind(RAW{irRAW, 1}, 'Fixation L')                % Fixation
                    iLeftFixations = iLeftFixations + 1;
                    eyes.left.fixations.trial(iLeftFixations, 1) = RAW{irRAW, 2};
                    eyes.left.fixations.number(iLeftFixations, 1) = RAW{irRAW, 3};
                    eyes.left.fixations.start(iLeftFixations, 1) = RAW{irRAW, 4};
                    eyes.left.fixations.end(iLeftFixations, 1) = RAW{irRAW, 5};
                    eyes.left.fixations.duration(iLeftFixations, 1) = RAW{irRAW, 6};
                    eyes.left.fixations.location.x(iLeftFixations, 1) = str2double(RAW{irRAW, 7});
                    eyes.left.fixations.location.y(iLeftFixations, 1) = str2double(RAW{irRAW, 8});
                    eyes.left.fixations.dispersion.x(iLeftFixations, 1) = str2double(RAW{irRAW, 9});
                    eyes.left.fixations.dispersion.y(iLeftFixations, 1) = str2double(RAW{irRAW, 10});
                    eyes.left.fixations.plane(iLeftFixations, 1) = str2double(RAW{irRAW, 11});
                    eyes.left.fixations.pupil.size.x(iLeftFixations, 1) = str2double(RAW{irRAW, 12});
                    eyes.left.fixations.pupil.size.y(iLeftFixations, 1) = str2double(RAW{irRAW, 13});
                elseif strfind(RAW{irRAW, 1}, 'Fixation R')
                    iRightFixations = iRightFixations + 1;
                    eyes.right.fixations.trial(iRightFixations, 1) = RAW{irRAW, 2};
                    eyes.right.fixations.number(iRightFixations, 1) = RAW{irRAW, 3};
                    eyes.right.fixations.start(iRightFixations, 1) = RAW{irRAW, 4};
                    eyes.right.fixations.end(iRightFixations, 1) = RAW{irRAW, 5};
                    eyes.right.fixations.duration(iRightFixations, 1) = RAW{irRAW, 6};
                    eyes.right.fixations.location.x(iRightFixations, 1) = str2double(RAW{irRAW, 7});
                    eyes.right.fixations.location.y(iRightFixations, 1) = str2double(RAW{irRAW, 8});
                    eyes.right.fixations.dispersion.x(iRightFixations, 1) = str2double(RAW{irRAW, 9});
                    eyes.right.fixations.dispersion.y(iRightFixations, 1) = str2double(RAW{irRAW, 10});
                    eyes.right.fixations.plane(iRightFixations, 1) = str2double(RAW{irRAW, 11});
                    eyes.right.fixations.pupil.size.x(iRightFixations, 1) = str2double(RAW{irRAW, 12});
                    eyes.right.fixations.pupil.size.y(iRightFixations, 1) = str2double(RAW{irRAW, 13});
                end
            end
            
            % Trials Control
            nEvents = iEvents;
            
            nLeftBlinks = iLeftBlinks;
            for iLeftBlinks = 1 : nLeftBlinks
                for iEvents = 1 : nEvents
                    if (eyes.left.blink.start(iLeftBlinks, 1) > eyes.events.start(iEvents, 1))
                        eyes.left.blink.trial(iLeftBlinks, 1) = eyes.events.trial(iEvents, 1);
                    end
                end
            end
            
            nRightBlinks = iRightBlinks;
            for iRightBlinks = 1 : nRightBlinks
                for iEvents = 1 : nEvents
                    if (eyes.right.blink.start(iRightBlinks, 1) > eyes.events.start(iEvents, 1))
                        eyes.right.blink.trial(iRightBlinks, 1) = eyes.events.trial(iEvents, 1);
                    end
                end
            end
            
            nLeftSaccades = iLeftSaccades;
            for iLeftSaccades = 1 : nLeftSaccades
                for iEvents = 1 : nEvents
                    if (eyes.left.saccade.start(iLeftSaccades, 1) > eyes.events.start(iEvents, 1))
                        eyes.left.saccade.trial(iLeftSaccades, 1) = eyes.events.trial(iEvents, 1);
                    end
                end
            end
            
            nRightSaccades = iRightSaccades;
            for iRightSaccades = 1 : nRightSaccades
                for iEvents = 1 : nEvents
                    if (eyes.right.saccade.start(iRightSaccades, 1) > eyes.events.start(iEvents, 1))
                        eyes.right.saccade.trial(iRightSaccades, 1) = eyes.events.trial(iEvents, 1);
                    end
                end
            end
            
            nLeftFixations = iLeftFixations;
            for iLeftFixations = 1 : nLeftFixations
                for iEvents = 1 : nEvents
                    if (eyes.left.fixations.start(iLeftFixations, 1) > eyes.events.start(iEvents, 1))
                        eyes.left.fixations.trial(iLeftFixations, 1) = eyes.events.trial(iEvents, 1);
                    end
                end
            end
            
            nRightFixations = iRightFixations;
            for iRightFixations = 1 : nRightFixations
                for iEvents = 1 : nEvents
                    if (eyes.right.fixations.start(iRightFixations, 1) > eyes.events.start(iEvents, 1))
                        eyes.right.fixations.trial(iRightFixations, 1) = eyes.events.trial(iEvents, 1);
                    end
                end
            end
            
        elseif checkSample
            % disp('Sample')
        else
            disp('Can''t read the file, check the file extension.')
        end
    end
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
