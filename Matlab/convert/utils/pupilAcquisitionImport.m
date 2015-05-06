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
        checkSave = true;
        if nargin < 1
            [inputName, inputPath] = uigetfile({'*.xlsx; *.xls; *.mat'}, 'Pick a Eye Tracker File [.xlsx, .xls, .mat]');
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
        elseif isTXT(fileTXT)
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
