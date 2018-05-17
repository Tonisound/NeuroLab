% NeuroLab Analysis Software
% Version 1.0
% Project EEG-EMG-fUS-VIDEO
% User : Antoine BERGEL antoine.bergel@espci.fr
% User : Marta MATEI marta.matei@hotmail.fr
% GUI opening function
clear;
close;

% Addpath
%addpath(genpath('NeuroLab-1.0/'));
%addpath('NPMK-4.5.2.0/');
d = dir('NeuroLab*');
for i = 1:length(d)
    addpath(genpath(char(d(i).name)));
end
d = dir('NPMK*');
for i = 1:length(d)
    addpath(genpath(char(d(i).name)));
end

% Initializing Preferences.mat if Preferences file is missing
output=true;
if ~exist('Preferences.mat','file')
    output = initialize_Preferences();
end
if ~output
    return;
end

% Initializing Files.mat if Preferences file is missing
if ~exist('Files.mat','file')
    initialize_Files();
end

% Setting Global Variables from Preferences.mat and Files.mat
global SEED;                    % String : Main Directory
global SEED_SWL;                % String : Recording List Directory
global SEED_REGION;             % String : Spikoscope Regions Directory
global DIR_SAVE;                % String : Saving Directory
global DIR_FIG;                 % String : Figure Directory
global DIR_STATS;               % String : Statistics Directory
global DIR_SYNT;                % String : Synthesis Directory
global FILES;                   % Structure Array : List of files and content
global CUR_FILE;                % int : Current file
global IM;                      % 3d matrix : Image movie
global CUR_IM;                  % int : Current image
global START_IM;                % int : Start Image to display
global END_IM;                  % int : End Image to Display
global LAST_IM;                 % int : Index of Last Image

load('Preferences.mat', 'GParams','GDisp');
load('Files.mat','FILES','CUR_FILE','str','UiValues');
SEED =          GParams.SEED;
SEED_SWL =      GParams.SEED_SWL;
SEED_REGION =   GParams.SEED_REGION;
DIR_SAVE =      GParams.DIR_SAVE;
DIR_FIG =       GParams.DIR_FIG;
DIR_STATS =     GParams.DIR_STATS;
DIR_SYNT =      GParams.DIR_SYNT;

if isempty(FILES)
    IM = zeros(88,169,2);
    LAST_IM = 2;
    START_IM = 1;
    END_IM = 2;
    CUR_IM = 1;
else
    if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'),'file')
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.mat'),'CUR_IM','LAST_IM','START_IM','END_IM','UiValues');
        if ~exist('IM','var')
            load_global_image(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab),UiValues.CenterPanelPopup);
        end
    else
        errordlg('Missing File Config.mat.\nTry reloading files.\n');
        return ;
    end
end

% Initializing NeuroLab if main_NeuroLab.fig is missing
[f,myhandles] = initialize_NeuroLab(str,UiValues);
fprintf('NeuroLab successfully reinitialized.\n');


% Adding graphic data if Config.fig is found
if ~isempty(FILES)
    if exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Trace_light.mat'),'file')
        load_graphicdata(fullfile(DIR_SAVE,[FILES(CUR_FILE).nlab]),myhandles);
    elseif exist(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Config.fig'),'file')
        load_graphicfigure(fullfile(DIR_SAVE,[FILES(CUR_FILE).nlab]),myhandles);
    else
        warning('Missing Graphic Objects. File %s.',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab));
    end
    
    % Loading Video file
    import_video(fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).video),myhandles);
end

actualize_plot(myhandles);
myhandles.Cursor.XData = [CUR_IM, CUR_IM];
myhandles.Cursor.YData = ylim(myhandles.RightAxes);
if ~isempty(FILES)
    buttonAutoScale_Callback([],[],myhandles);
end

% Resetting CLimBox
%boxCLim_Callback(myhandles.CLimBox,[],myhandles);

% Success
fprintf(' Welcome to NeuroLab! \n');