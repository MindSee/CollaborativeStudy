function [] = startup_Patrizio()
%
% global BTB
%
% % Path of the data directory for EEG and log files
% DATA_DIR= fullfile('/Users/patrikpluchino/Desktop/', 'data');
%
% % Path of the BBCI public toolbox
% BBCI_DIR= fullfile('/Users/patrikpluchino/Desktop/', 'bbci_public');
%
% % Folder with convert and analysis scripts
% BBCI_PRIVATE_DIR = fullfile('/Users/patrikpluchino/Desktop/', 'CollaborativeStudy');
%
% cd(BBCI_DIR);
% startup_bbci_toolbox('DataDir', DATA_DIR,...
%     'PrivateDir', BBCI_PRIVATE_DIR);
%
% addpath(genpath(fullfile(BTB.PrivateDir)));
%
% my_dir=fullfile(BTB.PrivateDir,'Matlab','convert');
% addpath(genpath(my_dir));
% cd(my_dir);
%
%
% format compact
% format longg
% end

% WorkSpace
clear all
close all
clc

% Paths
pathBBCI = fileparts(which('startup_bbci_toolbox.m'));
sep = strfind(pathBBCI, filesep);
pathMindSee = pathBBCI(1 : sep(end));

addpath(genpath(pathMindSee));
cd(pathMindSee)
clc

simbol = 'cr';
focus = 'hf';
target = '06';

findTheCenterOfTarget(simbol, focus, target);

function [] = findTheCenterOfTarget(simbol, focus, target)
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
    screenSize = get(0, 'ScreenSize');
    
    nTrials = 1;
    
    for iTrial = 1 : nTrials
        
        fig = figure(iTrial);
        set(fig, 'position', screenSize);
        
        % Trial Properties
        switch simbol
            case {'cr'}
                titleSimbol = 'Crossed';
            case {'es'}
                titleSimbol = 'Eye-Shaped';
            case {'tr'}
                titleSimbol = 'Triangle';
            case {'do'}
                titleSimbol = 'Dotted';
            case {'st'}
                titleSimbol = 'Striped';
            case {'sq'}
                titleSimbol = 'Square';
            otherwise
                titleSimbol = simbol;
        end
        
        switch focus
            case {'lf'}
                titleFocus = 'Low focus';
            case {'hf'}
                titleFocus = 'High focus';
            otherwise
                titleFocus = focus;
        end
        
        hold on
        
        h = 1050; w = 1680;
        axis([0 w 0 h])
        
        % Plot Stimulus
        imageStimulus = imread(which([simbol, '_', focus, '_', target, '.tif']));
        
        image([0 w], [0 h], imageStimulus);
        
        % Plot Fixations
        nTarget = str2double(target);
        for iTarget = 1 : nTarget
            title(['Find the ', num2str(iTarget), '° target of ', titleFocus, ' with ', titleSimbol, ' stimuli [', target, ']']);
            [x, y] = ginput(1);
            centerTarget(iTarget, 1) = x;
            centerTarget(iTarget, 2) = y;
        end
        
        % Save the center of the target
        pathStimulus = fileparts(which([simbol, '_', focus, '_', target, '.tif']));
        if ~(strcmp(pathStimulus(end), filesep))
            pathStimulus = [pathStimulus, filesep];
        end
        save([pathStimulus, simbol, '_', focus, '_', target], 'centerTarget');
        
        close(fig)
        
    end
    
    disp('ok')
    
catch ME; if (exist('saveMException.m', 'file')); saveMException(ME); end; end


