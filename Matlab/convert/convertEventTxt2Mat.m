function [eye, eyes] = convertEventTxt2Mat(input, checkSave)
% Convert the Event idf-converted file into a .mat struct.
%
%   Syntax:
%          [eye, eyes] = convertEventTxt2Mat()
%          [eye, eyes] = convertEventTxt2Mat(input)
%          [eye, eyes] = convertEventTxt2Mat(input, checkSave)
%
%   Parameters:
%           input                   file name of the idf-converted file.
%                                   The file exension allow are:
%                                       - xls
%                                       - xlsx
%                                       - txt
%                                       - mat
%           checkSave               true if you want to save a .mat copy of
%                                   the raw data.
%
%   Return values:
%           eye                     Struct of the event information for
%                                   mean of the left and right eyes.
%
%                              > info:     file, version, sampleRate, date
%                              > events:   trial, number, start, description
%                              > blink:     number, start, end, duration, trial
%                              > saccade:   number, start, end, duration, location, start (x, y), stop (x, y), amplitude, speed (peak (to, from), average), acceleration (peak, average), deceleration (peak, average), trial
%                              > fixations: number, start, end, duration, location, dispersion, plane, pupil, trial
%
%
%           eyes                    Struct of the event information for
%                                   both eyes. The tree of the structure:
%
%                              > info:     file, version, sampleRate, date
%                              > events:   trial, number, start, description
%                              > left:     blink:     number, start, end, duration, trial
%                                          saccade:   number, start, end, duration, location, start (x, y), stop (x, y), amplitude, speed (peak (to, from), average), acceleration (peak, average), deceleration (peak, average), trial
%                                          fixations: number, start, end, duration, location, dispersion, plane, pupil, trial
%                              > right:    blink:     number, start, end, duration, trial
%                                          saccade:   number, start, end, duration, location, start (x, y), stop (x, y), amplitude, speed (peak (to, from), average), acceleration (peak, average), deceleration (peak, average), trial
%                                          fixations: number, start, end, duration, location, dispersion, plane, pupil, trial
%
%	Author: Filippo M.  18/03/2015


try
    % Initialization
    eyes = [];
    eye = [];
    
    % Nargin
    if nargin < 2
        checkSave = false;
    end
    if nargin < 1
        [RAW] = idfEventImport();
    else
        % Get RAW
        if isstruct(input)
            [RAW] = input;
        else
            [RAW] = idfEventImport(input, checkSave);
        end
    end
    
    % Initialization Event Struct
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
                    eyes.info.sampleRate = str2double(RAW{irRAW, 2});
                elseif strfind(RAW{irRAW, 1}, 'Version:')
                    eyes.info.version = RAW{irRAW, 2};
                elseif strfind(RAW{irRAW, 1}, 'Converted from:')
                    eyes.info.file = RAW{irRAW, 2};
                elseif strfind(RAW{irRAW, 1}, 'Date:')
                    eyes.info.date = RAW{irRAW, 2};
                    
                elseif strfind(RAW{irRAW, 1}, 'UserEvent')                 % Event
                    iEvents = iEvents + 1;
                    eyes.events.trial(iEvents, 1) = iEvents;
                    eyes.events.number(iEvents, 1) = str2double(RAW{irRAW, 3});
                    eyes.events.start(iEvents, 1) = str2double(RAW{irRAW, 4});
                    eyes.events.description{iEvents, 1} = RAW{irRAW, 5}(12 : end);
                    
                elseif strfind(RAW{irRAW, 1}, 'Blink L')                   % Blink
                    iLeftBlinks = iLeftBlinks + 1;
                    eyes.left.blink.trial(iLeftBlinks, 1) = str2double(RAW{irRAW, 2});
                    eyes.left.blink.number(iLeftBlinks, 1) = str2double(RAW{irRAW, 3});
                    eyes.left.blink.start(iLeftBlinks, 1) = str2double(RAW{irRAW, 4});
                    eyes.left.blink.end(iLeftBlinks, 1) = str2double(RAW{irRAW, 5});
                    eyes.left.blink.duration(iLeftBlinks, 1) = str2double(RAW{irRAW, 6});
                elseif strfind(RAW{irRAW, 1}, 'Blink R')
                    iRightBlinks = iRightBlinks + 1;
                    eyes.right.blink.trial(iRightBlinks, 1) = str2double(RAW{irRAW, 2});
                    eyes.right.blink.number(iRightBlinks, 1) = str2double(RAW{irRAW, 3});
                    eyes.right.blink.start(iRightBlinks, 1) = str2double(RAW{irRAW, 4});
                    eyes.right.blink.end(iRightBlinks, 1) = str2double(RAW{irRAW, 5});
                    eyes.right.blink.duration(iRightBlinks, 1) = str2double(RAW{irRAW, 6});
                    
                elseif strfind(RAW{irRAW, 1}, 'Saccade L')                 % Saccade
                    iLeftSaccades = iLeftSaccades + 1;
                    eyes.left.saccade.trial(iLeftSaccades, 1) = str2double(RAW{irRAW, 2});
                    eyes.left.saccade.number(iLeftSaccades, 1) = str2double(RAW{irRAW, 3});
                    eyes.left.saccade.start(iLeftSaccades, 1) = str2double(RAW{irRAW, 4});
                    eyes.left.saccade.end(iLeftSaccades, 1) = str2double(RAW{irRAW, 5});
                    eyes.left.saccade.duration(iLeftSaccades, 1) = str2double(RAW{irRAW, 6});
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
                    eyes.right.saccade.trial(iRightSaccades, 1) = str2double(RAW{irRAW, 2});
                    eyes.right.saccade.number(iRightSaccades, 1) = str2double(RAW{irRAW, 3});
                    eyes.right.saccade.start(iRightSaccades, 1) = str2double(RAW{irRAW, 4});
                    eyes.right.saccade.end(iRightSaccades, 1) = str2double(RAW{irRAW, 5});
                    eyes.right.saccade.duration(iRightSaccades, 1) = str2double(RAW{irRAW, 6});
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
                    eyes.left.fixations.trial(iLeftFixations, 1) = str2double(RAW{irRAW, 2});
                    eyes.left.fixations.number(iLeftFixations, 1) = str2double(RAW{irRAW, 3});
                    eyes.left.fixations.start(iLeftFixations, 1) = str2double(RAW{irRAW, 4});
                    eyes.left.fixations.end(iLeftFixations, 1) = str2double(RAW{irRAW, 5});
                    eyes.left.fixations.duration(iLeftFixations, 1) = str2double(RAW{irRAW, 6});
                    eyes.left.fixations.location.x(iLeftFixations, 1) = str2double(RAW{irRAW, 7});
                    eyes.left.fixations.location.y(iLeftFixations, 1) = str2double(RAW{irRAW, 8});
                    eyes.left.fixations.dispersion.x(iLeftFixations, 1) = str2double(RAW{irRAW, 9});
                    eyes.left.fixations.dispersion.y(iLeftFixations, 1) = str2double(RAW{irRAW, 10});
                    eyes.left.fixations.plane(iLeftFixations, 1) = str2double(RAW{irRAW, 11});
                    eyes.left.fixations.pupil.size.x(iLeftFixations, 1) = str2double(RAW{irRAW, 12});
                    eyes.left.fixations.pupil.size.y(iLeftFixations, 1) = str2double(RAW{irRAW, 13});
                elseif strfind(RAW{irRAW, 1}, 'Fixation R')
                    iRightFixations = iRightFixations + 1;
                    eyes.right.fixations.trial(iRightFixations, 1) = str2double(RAW{irRAW, 2});
                    eyes.right.fixations.number(iRightFixations, 1) = str2double(RAW{irRAW, 3});
                    eyes.right.fixations.start(iRightFixations, 1) = str2double(RAW{irRAW, 4});
                    eyes.right.fixations.end(iRightFixations, 1) = str2double(RAW{irRAW, 5});
                    eyes.right.fixations.duration(iRightFixations, 1) = str2double(RAW{irRAW, 6});
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
            
            % Monocular data
            eye = convertEyes2Eye(eyes);
            
        elseif checkSample
            % disp('Sample')
        else
            disp('Can''t read the file, check the file extension.')
        end
    end
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

function [RAW, TABLE] = idfEventImport(input, checkSave)
% Import a eye tracker parameters from eyeAcquisition.
%
%   Syntax:
%          [RAW, TABLE] = idfEventImport()
%          [RAW, TABLE] = idfEventImport(input)
%          [RAW, TABLE] = idfEventImport(input, checkSave)
%
%   Parameters:
%           --              -
%
%   Return values:
%           RAW                         Raw data.
%           TABLE                       Matrix of the raw data.
%
%	Author: Filippo M.  18/03/2015


try
    % Parameters
    RAW = [];
    TABLE = [];
    
    % Nargin
    if nargin < 2
        checkSave = false;
        if nargin < 1
            [inputName, inputPath] = uigetfile({'*.xlsx; *.xls; *.mat; *.txt'}, 'Pick a Eye Tracker File [.xlsx, .xls, .mat, .txt]');
            input = [inputPath, inputName];
        end
    end
    
    % Get Data
    if isempty(input)
        disp('Can''t read the file, check the file extension.')
    else
        if isMAT(input)
            load(input);
            if ~(exist('RAW', 'var')) && ~(exist('TABLE', 'var'))
                disp('Can''t find the RAW TABLE variables.')
            end
        elseif (isXLSX(input) || isXLS(input))
            [TABLE, TXT, RAW] = xlsread(input); clear TXT
            [TABLE, TXT, RAW] = xlsread(input); clear TXT
            
            if checkSave
                if isXLS(input)
                    save([input(1 : (end - 4))], 'RAW')
                elseif isXLSX(input)
                    save([input(1 : (end - 5))], 'RAW')
                end
            else
                disp('Can''t read the file, check the file extension.')
            end
        elseif isTXT(input)
            fid = fopen(input);
            iRow = 0;
            textLine = fgetl(fid);
            while ischar(textLine)
                iRow = iRow + 1;
                line = regexp(textLine, '\t', 'split');
                if iscell(line)
                    nCell = length(line);
                    for iCell = 1 : nCell
                        RAW{iRow, iCell} = line{1, iCell};
                    end
                else
                    RAW{iRow, 1} = line;
                end
                textLine = fgetl(fid);
            end
            fclose(fid);
        else
            disp('Can''t read the file, check the file extension.')
        end
    end
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

function [eye] = convertEyes2Eye(input)
% Convert the eyes structure into a eye structure, that contains the mean
% of the values.
%
%   Syntax:
%          [eye, eyes] = convertEyes2Eye()
%          [eye, eyes] = convertEyes2Eye(input)
%
%   Parameters:
%           input                       Eyes structure.
%
%   Return values:
%           eye                         New monocular structure.
%           eyes                        Original eyes structure.
%
%	Author: Filippo M.  18/03/2015


try
    % Nargin
    if nargin < 1
        [eyes] = convertEventTxt2Mat();
    else
        % Get RAW
        if isstruct(input)
            [eyes] = input;
        else
            [eyes] = convertEventTxt2Mat(input);
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

function [res] = isTXT(fileTXT)
try
    % Variables
    res = false;
    if (exist(fileTXT) == 2)
        % Get file extension
        fileExtension = fileTXT((end - 2) : end);
        if strcmp(fileExtension, 'txt') || strcmp(fileExtension, 'TXT')
            res = true;
        end
    end
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

function [res] = isXLS(fileXLS)
try
    % Variables
    res = false;
    if (exist(fileXLS) == 2)
        % Get file extension
        fileExtension = fileXLS((end - 2) : end);
        if strcmp(fileExtension, 'xls') || strcmp(fileExtension, 'XLS')
            res = true;
        end
    end
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

function [res] = isXLSX(fileXLSX)
try
    % Variables
    res = false;
    if (exist(fileXLSX) == 2)
        % Get file extension
        fileExtension = fileXLSX((end - 3) : end);
        if strcmp(fileExtension, 'xlsx') || strcmp(fileExtension, 'XLSX')
            res = true;
        end
    end
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

function [res] = isMAT(fileMAT)
try
    % Variables
    res = false;
    if (exist(fileMAT) == 2)
        % Get file extension
        fileExtension = fileMAT((end - 2) : end);
        if strcmp(fileExtension, 'mat') || strcmp(fileExtension, 'MAT')
            res = true;
        end
    end
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
