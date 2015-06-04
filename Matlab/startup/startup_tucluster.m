function startup_tucluster

global BTB

% Path of the data directory for EEG and log files
DATA_DIR= fullfile('/home/bbci/data/');

% Determine user name on the TU-Berlin cluster
[ret, username] = system('whoami');
username=deblank(username);
fprintf('User: %s\n', username)

% Path of the BBCI public toolbox
BBCI_DIR= fullfile('/home',  username, 'git','bbci_public');

% Folder with convert and analysis scripts
BBCI_PRIVATE_DIR = fullfile('/home',  username, 'git', 'CollaborativeStudy');

% Folder for figures 
BBCI_FIG_DIR = fullfile('/home',  username, 'Pictures');

cd(BBCI_DIR);
startup_bbci_toolbox('DataDir', DATA_DIR, ...
    'PrivateDir', BBCI_PRIVATE_DIR,'FigDir', BBCI_FIG_DIR);
cd(BBCI_PRIVATE_DIR);

addpath(genpath(fullfile(BTB.PrivateDir)));
format compact
format longg
