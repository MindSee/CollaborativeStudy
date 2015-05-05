function startup_filippo

global BTB

% Path of the data directory for EEG and log files
DATA_DIR = fullfile('E:', 'data');

% Path of the BBCI public toolbox
BBCI_DIR = fullfile('E:', 'git', 'bbci_public');

% Folder with convert and analysis scripts
BBCI_PRIVATE_DIR = fullfile('E:', 'git', 'CollaborativeStudy');

cd(BBCI_DIR);
startup_bbci_toolbox('DataDir', DATA_DIR, 'PrivateDir', BBCI_PRIVATE_DIR);

addpath(genpath(fullfile(BTB.PrivateDir)));

format compact
format longg