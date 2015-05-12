% % % % function [] = startup_filippo()
% % % % startup_filippo

% % % % WorkSpace
% % % clear all
% % % close all
clc

% Paths
pathBBCI = fileparts(which('startup_bbci_toolbox.m'));
sep = strfind(pathBBCI, filesep);
pathMindSee = pathBBCI(1 : sep(end));

addpath(genpath(pathMindSee));

% Globa Variables
global BTB

% Path of the data directory for EEG and log files
DATA_DIR = fullfile(pathMindSee, 'data');

% Path of the BBCI public toolbox
BBCI_DIR = pathBBCI;

% Folder with convert and analysis scripts
BBCI_PRIVATE_DIR = fullfile(pathMindSee, 'git', 'CollaborativeStudy');

cd(BBCI_DIR);
startup_bbci_toolbox('DataDir', DATA_DIR, 'PrivateDir', BBCI_PRIVATE_DIR);

addpath(genpath(fullfile(BTB.PrivateDir)));

format compact
format longg

% Fixations Parameters
diameterTarget = 60;
threesholdFixations = 150000;
checkPlot = false;

tic
convertEYES(diameterTarget, threesholdFixations, checkPlot);
toc
