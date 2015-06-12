function [] = convertPeripheralEMG(pathPeripheral)
% Update the .mat file of the peripheral.
%
%   Syntax:
%          [] = csPeripheral(filePeripheral)
%
%   Parameters:
%           --
%
%   Return values:
%           --
%
%	Author: Filippo M.  11/06/2015


try
    path = dir(pathPeripheral);
    nPath = length(path);
    
    for iPath = 1 : nPath
        path(iPath).name
        if ~(isempty(strfind(path(iPath).name, 'VP')))
            tempPath = dir([pathPeripheral, filesep, path(iPath).name]);
            nTempPath = length(tempPath);
            for iTempPath = 1 : nTempPath
                if ~(isempty(strfind(tempPath(iTempPath).name, 'Peripheral_')))
                    file = [pathPeripheral, filesep, path(iPath).name, filesep, tempPath(iTempPath).name];
                    csPeripheral(file)
                end
            end
        end
    end
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end


function [] = csPeripheral(filePeripheral)
% Update the .mat file of the peripheral.
%
%   Syntax:
%          [] = csPeripheral(filePeripheral)
%
%   Parameters:
%           --
%
%   Return values:
%           --
%
%	Author: Filippo M.  11/06/2015


try
    disp(['Elaboration file: ', filePeripheral])
    [pathPeripheral, namePeripheral] = fileparts(filePeripheral);
    pathPeripheral = [pathPeripheral, filesep];
    
    % Load
    load(filePeripheral)
    
    % Data
    fs = nfo.fs;
    nEvents = nfo.nEvents;
    
    mrktime = mrk.time;
    mrky = mrk.y;
    mrkclass = mrk.className;
    
    % Old
    copyfile([pathPeripheral, namePeripheral, '.mat'], [pathPeripheral, namePeripheral, '_old.mat']);
    delete([pathPeripheral, namePeripheral, '.mat'])
    
    % Save
    save([pathPeripheral, namePeripheral], 'fs', 'nEvents', 'mrktime', 'mrky', 'mrkclass', 'ch1', 'ch2', 'ch3');
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end
