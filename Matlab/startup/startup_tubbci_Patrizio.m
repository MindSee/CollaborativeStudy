% function [] = startup_tubbci_Patrizio()

% WorkSpace
clear all
close all
clc

global BTB

% Path of the data directory for EEG and log files
DATA_DIR= fullfile('/Users/patrikpluchino/Desktop/', 'data');

% Path of the BBCI public toolbox
BBCI_DIR= fullfile('/Users/patrikpluchino/Desktop/', 'bbci_public');

% Folder with convert and analysis scripts
BBCI_PRIVATE_DIR = fullfile('/Users/patrikpluchino/Desktop/', 'CollaborativeStudy');

cd(BBCI_DIR);
startup_bbci_toolbox('DataDir', DATA_DIR,...
    'PrivateDir', BBCI_PRIVATE_DIR);

addpath(genpath(fullfile(BTB.PrivateDir)));

my_dir=fullfile(BTB.PrivateDir,'Matlab','convert');
addpath(genpath(my_dir));
cd(my_dir);


format compact
format longg
