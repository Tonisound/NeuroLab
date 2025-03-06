function synthesis_PeakCount()
% Synthesis Peak-count
% Opens txt file/ creates corresponding folder
% manuscript NCOMMS revision aug 2018
% Creates figure to show co-occurence analysis

global DIR_SYNT DIR_STATS;
folder_synt = fullfile(DIR_SYNT,'Peak_Count');

str_list = dir(fullfile(folder_synt,'*.txt'));
[ind_list,v] = listdlg('Name','List Selection','PromptString','Select recording list',...
    'SelectionMode','single','ListString',{str_list(:).name},'InitialValue','','ListSize',[300 500]);

if isempty(ind_list)||v==0
    return;
else
    list_name_txt = char(str_list(ind_list).name);
    list_name = strrep(list_name_txt,'.txt','');
end

% Selection recording list via listdlg
% list_name = 'CORONAL_SORTED';
% list_name_txt = strcat(list_name,'.txt');

% Open file
filename = fullfile(folder_synt,list_name_txt);
fileID = fopen(filename);
rec_list = [];
while ~feof(fileID)
    hline = fgetl(fileID);
    rec_list = [rec_list;{hline}];
end
fclose(fileID);

%Extracting file channel and episode from rec_list
file_list = [];
channel_list = [];
episode_list = [];
for i =1:length(rec_list)
    pattern = strrep(char(rec_list(i)),'.mat','');
    temp = regexp(pattern,'_Peak_Detection_|_REM','split');
    file_list = [file_list;temp(1)];
    channel_list = [channel_list;temp(2)];
    episode_list = [episode_list;{strcat('REM',char(temp(3)))}];
end

%Clearing folder synthesis
folder_list = fullfile(folder_synt,list_name);
if exist(folder_list,'dir')
    fprintf('Clearing folder %s\n',folder_list);
    rmdir(folder_list,'s');
end
mkdir(folder_list);

%Moving stats 
for i =1:length(rec_list)
    fprintf('Moving file %s\n',filename);
    filename = char(rec_list(i));
    status = copyfile(fullfile(DIR_STATS,'Peak_Detection',char(file_list(i)),filename),fullfile(folder_list,filename));
    if ~status
        warning('Problem copying file %s',filename);
    end
end

% Figure
f2 = figure('Units','normalized',...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name',sprintf('Synthesis Peak Count - %s',list_name));
set(f2,'Position',[.1 .1 .6 .6]);

%Parameters
L = 10;                      % Height top panels
l = 0;                       % Height info panel
g_colors = get(groot,'DefaultAxesColorOrder');
thresh_inf = -4;
thresh_sup = 1; 

% Top Panel
tP = uipanel('Units','normalized',...
    'bordertype','etchedin',...
    'Tag','TopPanel',...
    'Parent',f2);
tP.Position = [0 l/L 1 (L-l)/L];

tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',tP,...
    'Tag','TabGroup');
uitab('Parent',tabgp,...
    'Title','Detecting VS -  Counting LFP',...
    'Tag','FirstTab');
uitab('Parent',tabgp,...
    'Title','Detecting LFP -  Counting VS',...
    'Tag','SecondTab');

% Main
handles = guihandles(f2);
initialize_panels(handles,4,7)

% counting
% TIMING_WHOLE = struct('recording',[],'episode',[],'timing',[]);
% TIMING_HPC = struct('recording',[],'episode',[],'timing',[]);
% TIMING_THAL = struct('recording',[],'episode',[],'timing',[]);
% TIMING_CORTEX = struct('recording',[],'episode',[],'timing',[]);
% TIMING_THETA = struct('recording',[],'episode',[],'timing',[]);
% TIMING_LOWGAMMA = struct('recording',[],'episode',[],'timing',[]);
% TIMING_MIDGAMMA = struct('recording',[],'episode',[],'timing',[]);
% TIMING_HIGHGAMMA = struct('recording',[],'episode',[],'timing',[]);

TIMING_CORTEX = [];
DELTA_T_CORTEX = [];
METADATA_CORTEX = [];
TIMING_HPC = [];
DELTA_T_HPC = [];
METADATA_HPC = [];
TIMING_THAL = [];
DELTA_T_THAL = [];
METADATA_THAL = [];
TIMING_WHOLE = [];
DELTA_T_WHOLE = [];
METADATA_WHOLE = [];

TIMING_GLOW = [];
DELTA_T_GLOW = [];
METADATA_GLOW = [];
TIMING_GMID = [];
DELTA_T_GMID = [];
METADATA_GMID = [];
TIMING_GMIDUP = [];
DELTA_T_GMIDUP = [];
METADATA_GMIDUP = [];
TIMING_GHIGH= [];
DELTA_T_GHIGH= [];
METADATA_GHIGH= [];
TIMING_GHIGHUP = [];
DELTA_T_GHIGHUP = [];
METADATA_GHIGHUP = [];
TIMING_RIPPLE = [];
DELTA_T_RIPPLE = [];
METADATA_RIPPLE = [];
TIMING_THETA = [];
DELTA_T_THETA = [];
METADATA_THETA = [];

for i =1:length(rec_list)
    filename = char(rec_list(i));
    fprintf('Loading file %s\n',filename);
    data = load(fullfile(DIR_STATS,'Peak_Detection',char(file_list(i)),filename),'S_fus','S_lfp');
    recording = char(file_list(i));
    episode = char(episode_list(i));
    channel = char(channel_list(i));
    info = [{recording},{episode},{channel}];
    
    for j=1:length(data.S_fus)
        x = data.S_fus(j).x;
        name = data.S_fus(j).name;
        [timings,delta_t] = extract_peaks(x,data.S_lfp,thresh_inf,thresh_sup);
        switch name
            case 'cortex'
                TIMING_CORTEX = [TIMING_CORTEX;timings];
                DELTA_T_CORTEX = [DELTA_T_CORTEX;delta_t];
                METADATA_CORTEX = [METADATA_CORTEX;repmat(info,[size(timings,1),1])];
            case 'hpc'
                TIMING_HPC = [TIMING_HPC;timings];
                DELTA_T_HPC = [DELTA_T_HPC;delta_t];
                METADATA_HPC = [METADATA_HPC;repmat(info,[size(timings,1),1])];
            case 'thal'
                TIMING_THAL = [TIMING_THAL;timings];
                DELTA_T_THAL = [DELTA_T_THAL;delta_t];
                METADATA_THAL = [METADATA_THAL;repmat(info,[size(timings,1),1])];
            case 'whole'
                TIMING_WHOLE = [TIMING_WHOLE;timings];
                DELTA_T_WHOLE = [DELTA_T_WHOLE;delta_t];
                METADATA_WHOLE = [METADATA_WHOLE;repmat(info,[size(timings,1),1])];
        end
    end
    
    for j=1:length(data.S_lfp)
        x = data.S_lfp(j).x;
        name = data.S_lfp(j).name;
        [timings,delta_t] = extract_peaks(x,data.S_fus,-thresh_sup,-thresh_inf);
        switch name
            case 'gamma-low'
                TIMING_GLOW = [TIMING_GLOW;timings];
                DELTA_T_GLOW = [DELTA_T_GLOW;delta_t];
                METADATA_GLOW = [METADATA_GLOW;repmat(info,[size(timings,1),1])];
            case 'gamma-mid'
                TIMING_GMID = [TIMING_GMID;timings];
                DELTA_T_GMID = [DELTA_T_GMID;delta_t];
                METADATA_GMID = [METADATA_GMID;repmat(info,[size(timings,1),1])];
            case 'gamma-midup'
                TIMING_GMIDUP = [TIMING_GMIDUP;timings];
                DELTA_T_GMIDUP = [DELTA_T_GMIDUP;delta_t];
                METADATA_GMIDUP = [METADATA_GMIDUP;repmat(info,[size(timings,1),1])];
            case 'gamma-high'
                TIMING_GHIGH = [TIMING_GHIGH;timings];
                DELTA_T_GHIGH = [DELTA_T_GHIGH;delta_t];
                METADATA_GHIGH = [METADATA_GHIGH;repmat(info,[size(timings,1),1])];
            case 'gamma-highup'
                TIMING_GHIGHUP = [TIMING_GHIGHUP;timings];
                DELTA_T_GHIGHUP = [DELTA_T_GHIGHUP;delta_t];
                METADATA_GHIGHUP = [METADATA_GHIGHUP;repmat(info,[size(timings,1),1])];
            case 'ripple'
                TIMING_RIPPLE = [TIMING_RIPPLE;timings];
                DELTA_T_RIPPLE = [DELTA_T_RIPPLE;delta_t];
                METADATA_RIPPLE = [METADATA_RIPPLE;repmat(info,[size(timings,1),1])];
            case 'theta'
                TIMING_THETA = [TIMING_THETA;timings];
                DELTA_T_THETA = [DELTA_T_THETA;delta_t];
                METADATA_THETA = [METADATA_THETA;repmat(info,[size(timings,1),1])];
        end
    end    
end

S.thresh_inf = thresh_inf;
S.thresh_sup = thresh_sup;
S.label_fus = {data.S_fus(:).name}';
S.label_lfp = {data.S_lfp(:).name}';

S.TIMING_CORTEX = TIMING_CORTEX ;
S.DELTA_T_CORTEX = DELTA_T_CORTEX;
S.METADATA_CORTEX = METADATA_CORTEX;
S.TIMING_HPC = TIMING_HPC;
S.DELTA_T_HPC = DELTA_T_HPC;
S.METADATA_HPC = METADATA_HPC;
S.TIMING_THAL = TIMING_THAL;
S.DELTA_T_THAL = DELTA_T_THAL;
S.METADATA_THAL = METADATA_THAL;
S.TIMING_WHOLE = TIMING_WHOLE;
S.DELTA_T_WHOLE = DELTA_T_WHOLE;
S.METADATA_WHOLE = METADATA_WHOLE;

S.TIMING_GLOW = TIMING_GLOW;
S.DELTA_T_GLOW = DELTA_T_GLOW;
S.METADATA_GLOW = METADATA_GLOW;
S.TIMING_GMID = TIMING_GMID;
S.DELTA_T_GMID = DELTA_T_GMID;
S.METADATA_GMID = METADATA_GMID;
S.TIMING_GMIDUP = TIMING_GMIDUP;
S.DELTA_T_GMIDUP = DELTA_T_GMIDUP;
S.METADATA_GMIDUP = METADATA_GMIDUP;
S.TIMING_GHIGH= TIMING_GHIGH;
S.DELTA_T_GHIGH= DELTA_T_GHIGH;
S.METADATA_GHIGH= METADATA_GHIGH;
S.TIMING_GHIGHUP = TIMING_GHIGHUP;
S.DELTA_T_GHIGHUP = DELTA_T_GHIGHUP;
S.METADATA_GHIGHUP = METADATA_GHIGHUP;
S.TIMING_RIPPLE = TIMING_RIPPLE;
S.DELTA_T_RIPPLE = DELTA_T_RIPPLE;
S.METADATA_RIPPLE = METADATA_RIPPLE;
S.TIMING_THETA = TIMING_THETA;
S.DELTA_T_THETA = DELTA_T_THETA;
S.METADATA_THETA = METADATA_THETA;
display_data(S,handles,g_colors);  

end

function initialize_panels(handles,x,y)

%x = 4
%y = 5
tab1 = handles.FirstTab;
tab2 = handles.SecondTab;
all_tabs = [tab1;tab2];
for i =1:length(all_tabs)
    delete(all_tabs(i).Children);
end

ax_1 = gobjects(x,2);
for i = 1:x
    ind = 2*(i-1)+1;
    ax_1(i,1) = subplot(x,2,ind,'Parent',tab1,'Tag',sprintf('Ax%d-%d',i,1));
    ax_1(i,1).Title.String = sprintf('Ax%d-%d',i,1);
    ax_1(i,1).YLim = [0 .1];
    ax_1(i,2) = subplot(x,2,ind+1,'Parent',tab1,'Tag',sprintf('Ax%d-%d',i,2));
    ax_1(i,2).Title.String = sprintf('Ax%d-%d',i,2);
    ax_1(i,2).YLim = [0 .1];
end

ax_2 = gobjects(y,2);
for j= 1:y
    ind = 2*(j-1)+1;
    ax_2(j,1) = subplot(y,2,ind,'Parent',tab2,'Tag',sprintf('Ax%d-%d',j,1));
    ax_2(j,1).Title.String = sprintf('Ax%d-%d',j,1);
    ax_2(j,1).YLim = [0 .1];
    ax_2(j,2) = subplot(y,2,ind+1,'Parent',tab2,'Tag',sprintf('Ax%d-%d',j,2));
    ax_2(j,2).Title.String = sprintf('Ax%d-%d',j,2);
    ax_2(j,2).YLim = [0 .1];
end

end

function [timings,delta_t] = extract_peaks(x,S,thresh_inf,thresh_sup)

timings = NaN(length(x),length(S)+1);
delta_t = NaN(length(x),length(S));

for i=1:length(x)
    
    timings(i,1) = x(i); 
    for j=1:length(S)
        xj = S(j).x;
        % finding closest peak to xj in x
        [~,ind] = min((xj-x(i)).^2);
        delta_j = xj(ind)-x(i);
        
        try
            if delta_j > thresh_sup || delta_j < thresh_inf
                delta_j = NaN;
                val_j = NaN;
            else
                val_j = xj(ind);
            end
        catch
            delta_j = NaN;
            val_j = NaN;
        end
        
        timings(i,j+1) = val_j;
        delta_t(i,j) = delta_j;
    end

end

end

function display_data(S,handles,g_colors)

thresh_inf = S.thresh_inf;
thresh_sup = S.thresh_sup;
label_fus = S.label_fus;
label_lfp = S.label_lfp;
DELTA_T_CORTEX = S.DELTA_T_CORTEX ;
DELTA_T_HPC = S.DELTA_T_HPC;
DELTA_T_THAL = S.DELTA_T_THAL;
DELTA_T_WHOLE = S.DELTA_T_WHOLE;
DELTA_T_GLOW = S.DELTA_T_GLOW;
DELTA_T_GMID = S.DELTA_T_GMID;
DELTA_T_GMIDUP = S.DELTA_T_GMIDUP;
DELTA_T_GHIGH= S.DELTA_T_GHIGH;
DELTA_T_GHIGHUP = S.DELTA_T_GHIGHUP;
DELTA_T_RIPPLE = S.DELTA_T_RIPPLE;
DELTA_T_THETA = S.DELTA_T_THETA;

l_width = 2;
margin = .15;
marker_width = .25;
markersize = 2;
markertype = '.';
lab_lfp = {'glow';'gmid';'gmidup';'ghigh';'ghighup';'rip';'thet'};

% panel 1
for i =1:length(label_fus)
    name = char(label_fus(i));
    switch name
        case 'cortex'
            delta_t = DELTA_T_CORTEX;
        case 'hpc' 
            delta_t = DELTA_T_HPC;
        case 'thal'
            delta_t = DELTA_T_THAL;
        case 'whole'
            delta_t = DELTA_T_WHOLE;
    end
    
    % bar
    ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',i,1));
    bar_data = size(delta_t,1)-sum(isnan(delta_t));
    bar(diag(bar_data),'stacked','Parent',ax,'BarWidth',.65);
    ax.Tag = sprintf('Ax%d-%d',i,1);
    %text
    for j=1:length(label_lfp)
        text(j-.5+2.5*margin,bar_data(j)+60,sprintf('%d',bar_data(j)),'Parent',ax);
    end
    ax.XLim = [.5 length(label_lfp)+.5];
    ax.XTickLabel = lab_lfp;
    % ax.XTickLabelRotation = 45;
    ax.YLim = [0 size(delta_t,1)];
    ax.YTick = [0 .25*size(delta_t,1) .5*size(delta_t,1) .75*size(delta_t,1) size(delta_t,1)];
    ax.YTickLabel = {'0';'25';'50';'75';'100'};
    %ax.YLabel.String = name;
    ax.Title.String = sprintf('[%s] %d peaks detected',name,size(delta_t,1));
    grid(ax,'on');

    % delta_t
    ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',i,2));
%     m_data = mean(delta_t,'omitnan');
%     for j=1:length(label_lfp)
%         line('XData',[j-.5+margin j+.5-margin],'YData',[m_data(j) m_data(j)],...
%             'parent',ax,'LineWidth',l_width,'Color',g_colors(j,:));
%         ddata = delta_t(:,j);
%         line('XData',j*ones(size(ddata)),'YData',ddata,...
%             'parent',ax,'LineStyle','none','Color',g_colors(j,:),...
%             'Marker',markertype,'MarkerSize',markersize,'LineWidth',marker_width);
%     end
    boxplot(delta_t,...
        'MedianStyle','target',...
        'colors',g_colors(1:size(delta_t,2),:),...
        'OutlierSize',1,...
        'Width',.5,...
        'PlotStyle','compact',...
        'Parent',ax);
    ax.XLim = [.5 length(label_lfp)+.5];
    ax.XTickLabel = lab_lfp;
    ax.YLim = [thresh_inf,thresh_sup];
    ax.YLabel.String = name;
    ax.Title.String = sprintf('[%s] %d peaks detected',name,size(delta_t,1));
    grid(ax,'on');
end

% panel 2
for i =1:length(label_lfp)
    name = char(label_lfp(i));
    switch name
        case 'gamma-low'
            delta_t = DELTA_T_GLOW;
        case 'gamma-mid'
            delta_t = DELTA_T_GMID;
        case 'gamma-midup'
            delta_t = DELTA_T_GMIDUP;
        case 'gamma-high'
            delta_t = DELTA_T_GHIGH;
        case 'gamma-highup'
            delta_t = DELTA_T_GHIGHUP;
        case 'ripple'
            delta_t = DELTA_T_RIPPLE;
        case 'theta'
            delta_t = DELTA_T_THETA;
    end
    
    % bar
    ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d-%d',i,1));
    bar_data = size(delta_t,1)-sum(isnan(delta_t));
    bar(diag(bar_data),'stacked','Parent',ax,'BarWidth',.65);
    ax.Tag = sprintf('Ax%d-%d',i,1);
    %text
    for j=1:length(label_fus)
        text(j-.5+2.5*margin,bar_data(j)+100,sprintf('%d',bar_data(j)),'Parent',ax);
    end
    ax.XLim = [.5 length(label_fus)+.5];
    ax.XTickLabel = label_fus;
    % ax.XTickLabelRotation = 45;
    ax.YLim = [0 size(delta_t,1)];
    ax.YTick = [0 .25*size(delta_t,1) .5*size(delta_t,1) .75*size(delta_t,1) size(delta_t,1)];
    ax.YTickLabel = {'0';'25';'50';'75';'100'};
    %ax.YLabel.String = name;
    ax.Title.String = sprintf('[%s] %d peaks detected',name,size(delta_t,1));
    grid(ax,'on');
    
    % delta_t
    ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d-%d',i,2));
    boxplot(delta_t,...
        'MedianStyle','target',...
        'colors',g_colors(1:size(delta_t,2),:),...
        'OutlierSize',1,...
        'Width',.5,...
        'PlotStyle','compact',...
        'Parent',ax);
    ax.XLim = [.5 length(label_fus)+.5];
    ax.XTickLabel = label_fus;
    ax.YLim = [-thresh_sup,-thresh_inf];
    ax.YLabel.String = name;
    ax.Title.String = sprintf('[%s] %d peaks detected',name,size(delta_t,1));
    grid(ax,'on');
end

end