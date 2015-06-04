% function [] = startup_tubbci_Patrizio()

% WorkSpace
clear all
close all
clc

% Cambio Path
pathBBCI = [fileparts(which('startup_tubbci_Patrizio.m')), filesep];
index = strfind(pathBBCI, filesep);
pathMindSee = pathBBCI(1 : index(end-3));
addpath(genpath(pathMindSee));

cd([pathMindSee]);

global BTB

% Path of the data directory for EEG and log files
DATA_DIR = fullfile(pathMindSee, 'data')

% Path of the BBCI public toolbox
BBCI_DIR = fullfile(pathMindSee, 'bbci_public')

% Folder with convert and analysis scripts
BBCI_PRIVATE_DIR = fullfile(pathMindSee, 'CollaborativeStudy')

cd(BBCI_DIR);
startup_bbci_toolbox('DataDir', DATA_DIR,...
    'PrivateDir', BBCI_PRIVATE_DIR);

addpath(genpath(fullfile(BTB.PrivateDir)));

my_dir=fullfile(BTB.PrivateDir,'Matlab','convert');
addpath(genpath(my_dir));
cd(my_dir);


format compact
format longg

convertPeripheral

disp('Finish')
disp('If you want then to reload the converted data, you can have a look at the first 28 lines of "EEG_analysis_spectra.m".')
