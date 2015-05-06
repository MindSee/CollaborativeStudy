function [eyes] = convertEventTxt2Mat(input, checkSave)
% Convert the Event idf-converted file into a .mat struct.
%
%   Syntax:
%          [eyes] = convertEventTxt2Mat()
%          [eyes] = convertEventTxt2Mat(input)
%          [eyes] = convertEventTxt2Mat(input, checkSave)
%
%   Parameters:
%           input                   file name of the idf-converted file.
%                                   The file exension allow are:
%                                       - xls
%                                       - xlsx
%                                       - txt
%                                       - mat
%           checkSave               true if you want to save a .mat copy of
%                                   the raw data
%
%   Return values:
%           eyes                    Struct of the event information. The
%                                   tree of the structure:
%
%        eyes
%           > info
%                  > file
%                  > version
%                  > sampleRate
%                  > date
%           > events
%                  > trial
%                  > number
%                  > start
%                  > description
%           > left
%                  > blink
%                          > number
%                          > start
%                          > end
%                          > duration
%                          > trial
%                  > saccade
%                          > number
%                          > start
%                          > end
%                          > duration
%                          > location
%                                      > start
%                                              > x 
%                                              > y
%                                      > stop
%                                              > x 
%                                              > y
%                          > amplitude
%                          > speed
%                                      > peak
%                                              > to
%                                              > from
%                                      > average
%                          > acceleration
%                                      > peak
%                                      > average
%                          > deceleration
%                                      > peak
%                                      > average
%                          > trial
%                  > fixations
%           > right (equal of left)
%
%
%	Author: Filippo M.  18/03/2015


try
    % Nargin
    if nargin < 2
        checkSave = false;
    end
    if nargin < 1
        [RAW] = pupilAcquisitionImport();
    else
        % Get RAW
        if isstruct(input)
            [RAW] = input;
        else
            [RAW] = pupilAcquisitionImport(input, checkSave);
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
            
        elseif checkSample
            % disp('Sample')
        else
            disp('Can''t read the file, check the file extension.')
        end
    end
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end

function [RAW, TABLE] = pupilAcquisitionImport(input, checkSave)
% Import a eye tracker parameters from eyeAcquisition.
%
%   Syntax:
%          [RAW, TABLE] = pupilAcquisitionImport(input)
%
%   Parameters:
%           --              -
%
%   Return values:
%           --              -
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

function res = isTXT(fileTXT)
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

function res = isXLS(fileXLS)
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

function res = isXLSX(fileXLSX)
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

function res = isMAT(fileMAT)
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
