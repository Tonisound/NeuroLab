function synthesis_CrossCorrelation()
% Synthesis Cross-correlation
% Opens txt file/ creates corresponding folder
% manuscript NCOMMS revision aug 2018
% Creates Figure to show Cross-Correlation Timing analysis

global DIR_SYNT DIR_STATS DIR_FIG;
folder_synt = fullfile(DIR_SYNT,'Cross_Correlation');

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
    %temp = regexp(pattern,'_Cross_Correlation_|_REM','split');
    temp = regexp(pattern,'_Cross_Correlation_|_R|_W','split');
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
    status = copyfile(fullfile(DIR_STATS,'Cross_Correlation',char(file_list(i)),filename),fullfile(folder_list,filename));
    if ~status
        warning('Problem copying file %s',filename);
    end
end

%Moving figures
for i =1:length(rec_list)
    
    channel = char(channel_list(i));
    episode = char(episode_list(i));
    tag = 'fUS-Synthesis';
    %tag = '';
    d = dir(fullfile(DIR_FIG,'Cross_Correlation',char(file_list(i)),'*.jpg'));
    all_files = {d(:).name}';
    ind_keep = contains(all_files,channel).*contains(all_files,episode).*contains(all_files,tag);
    files_keep = all_files(ind_keep==1);
    
    for ii =1:length(files_keep)
        filename = char(files_keep(ii));
        fprintf('Moving file %s\n',filename);
        status = copyfile(fullfile(DIR_FIG,'Cross_Correlation',char(file_list(i)),filename),fullfile(folder_list,filename));
        if ~status
            warning('Problem copying file %s',filename);
        end
    end
end


% Figure
f2 = figure('Units','normalized',...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'MenuBar','none',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Synthesis Cross Correlation LFP-fUS');
set(f2,'Position',[.1 .1 .6 .6]);
clrmenu(f2);

%Parameters
L = 10;                      % Height top panels
l = 0;                       % Height info panel
g_colors = get(groot,'DefaultAxesColorOrder');

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
    'Title','Cross-Correlation',...
    'Tag','FirstTab');
uitab('Parent',tabgp,...
    'Title','Raster',...
    'Tag','SecondTab');
uitab('Parent',tabgp,...
    'Title','Delays',...
    'Tag','ThirdTab');
uitab('Parent',tabgp,...
    'Title','LFP Synthesis',...
    'Tag','FourthTab');
uitab('Parent',tabgp,...
    'Title','fUS Synthesis',...
    'Tag','FifthTab');

% Main
handles = guihandles(f2);
initialize_panels(handles,4,7)

% plotting
X_CORR_ALL = [];
R_PEAK_ALL = [];
T_PEAK_ALL = [];
for i =1:length(rec_list)
    filename = char(rec_list(i));
    fprintf('Loading file %s\n',filename);
    data = load(fullfile(DIR_STATS,'Cross_Correlation',char(file_list(i)),filename));
    X_CORR_ALL = cat(4,X_CORR_ALL,data.X_corr);
    R_PEAK_ALL = cat(3,R_PEAK_ALL,data.R_peak);
    T_PEAK_ALL = cat(3,T_PEAK_ALL,data.T_peak);
    display_data(data,handles,g_colors);  
end

S.x_corr_mean = mean(X_CORR_ALL,4,'omitnan');
S.x_corr_std = std(X_CORR_ALL,[],4,'omitnan');
S.T_PEAK_ALL = T_PEAK_ALL;
S.t_mean = mean(T_PEAK_ALL,3,'omitnan');
S.t_median = median(T_PEAK_ALL,3,'omitnan');
display_data_mean(data,handles,g_colors,S,rec_list);

end

function initialize_panels(handles,x,y)

%x = 4
%y = 5
tab1 = handles.FirstTab;
tab2 = handles.SecondTab;
tab3 = handles.ThirdTab;
tab4 = handles.FourthTab;
tab5 = handles.FifthTab;
all_tabs = [tab1;tab2;tab3;tab4;tab5];
for i =1:length(all_tabs)
    delete(all_tabs(i).Children);
end

%Cross-correlations
ax_1 = gobjects(x,y);
for ind = 1:x*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_1(i,j) = subplot(x,y,ind,'Parent',tab1,'Tag',sprintf('Ax%d-%d',i,j));
    ax_1(i,j).Title.String = sprintf('Ax%d-%d',i,j);
    ax_1(i,j).YLim = [0 .1];
end

%Raster
ax_2 = gobjects(x,y);
for ind = 1:x*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_2(i,j) = subplot(x,y,ind,'Parent',tab2,'Tag',sprintf('Ax%d-%d',i,j));
    ax_2(i,j).Title.String = sprintf('Ax%d-%d',i,j);
    ax_2(i,j).YLim = [0 .1];
end

%Delays
ax_3 = gobjects(x,y);
for ind = 1:x*y
    i = ceil(ind/y);
    j = mod(ind-1,y)+1;
    ax_3(i,j) = subplot(x,y,ind,'Parent',tab3,'Tag',sprintf('Ax%d-%d',i,j));
    ax_3(i,j).Title.String = sprintf('Ax%d-%d',i,j);
    ax_3(i,j).YLim = [0 .1];
end

%Band Synthesis 
ax_4 = gobjects(y);
for ind = 1:y+1
    %i = ceil(ind/y);
    %j = mod(ind-1,y)+1;
    ax_4(ind) = subplot(2,ceil(y/2),ind,'Parent',tab4,'Tag',sprintf('Ax%d',ind));
    ax_4(ind).Title.String = sprintf('Ax%d',ind);
end

%Band Synthesis 
ax_5 = gobjects(x);
for ind = 1:x+1
    %i = ceil(ind/y);
    %j = mod(ind-1,y)+1;
    ax_5(ind) = subplot(2,ceil((x+1)/2),ind,'Parent',tab5,'Tag',sprintf('Ax%d',ind));
    ax_5(ind).Title.String = sprintf('Ax%d',ind);
end

end

function display_data(data,handles,g_colors)

l_width = .25;
marker_width = .25;
markersize = 3;
markertype = 'o';

r_all = [];
for j =1:length(data.S_fus)
    for i=1:length(data.S_lfp)
       
        lags = data.thresh_inf:data.thresh_step:data.thresh_sup;
        lags = lags(:);
        r = data.X_corr(j,i,:);
        r = r(:);
        r_all = [r_all;r'];
        [rmax,ind_max] = max(r,[],'omitnan');
        tmax = lags(ind_max);
        rmin = min(r,[],'omitnan');
        
        %cross-correlation
        ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',j,i));
        line('XData',lags,'YData',r,'Color',g_colors(j,:),'Tag','XCorr','Parent',ax,'LineWidth',l_width);
        line(tmax,rmax,'Parent',ax,'Marker',markertype,'Tag','Peak','LineWidth',marker_width,...
            'MarkerSize',markersize,'MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor','none');
        ax.XLim = [data.thresh_inf data.thresh_sup];
        % ax.YLim = [rmin,rmax];
        ax.YLim = [-1,1];
        ax.XLabel.String = data.S_lfp(i).name;
        ax.YLabel.String = data.S_fus(j).name;
        hold(ax,'on');
        
        %raster
        ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d-%d',j,i));
        %Marker
        line(tmax,rmax,'Parent',ax,'Marker',markertype,'Tag','Peak',...
            'MarkerSize',markersize,'MarkerEdgeColor',g_colors(j,:),'MarkerFaceColor','none');
        ax.XLim = [data.thresh_inf data.thresh_sup];
        % ax.YLim = [rmin,rmax];
        ax.YLim = [-1,1];
        ax.XLabel.String = data.S_lfp(i).name;
        ax.YLabel.String = data.S_fus(j).name;
        hold(ax,'on');
    end
end
end

function display_data_mean(data,handles,g_colors,S,rec_list)

x_corr_mean = S.x_corr_mean;
x_corr_std = S.x_corr_std;
T_PEAK_ALL = S.T_PEAK_ALL;
t_mean = S.t_mean;
t_median = S.t_median;

l_width = 1.5;
markersize = 15;
markertype = '+';
marker_width = .25;
alpha_value = .3;
visible_status = [{'on','on','off','on','off','off','on'};
    {'on','on','off','on','off','off','on'};
    {'on','on','off','on','off','off','on'};
    {'on','on','on','on','on','on','on'}];
% visible_status = [{'on','on','on','on','on','on','on'};
%     {'on','on','on','on','on','on','on'};
%     {'on','on','on','on','on','on','on'};
%     {'on','on','on','on','on','on','on'}];

% Computing mean
for j =1:length(data.S_fus)
    for i=1:length(data.S_lfp)
        %Compute
        lags = data.thresh_inf:data.thresh_step:data.thresh_sup;
        lags = lags(:);
        r_mean = x_corr_mean(j,i,:);
        r_mean = r_mean(:);
        r_std = x_corr_std(j,i,:);
        r_std = r_std(:);
        r_sem = r_std/sqrt(length(rec_list));
        [rmax,ind_max] = max(r_mean,[],'omitnan');
        tmax = lags(ind_max);
        rmin = min(r_mean,[],'omitnan');
        
        % FirstTab
        ax = findobj(handles.FirstTab,'Tag',sprintf('Ax%d-%d',j,i));
        ax.Title.String = sprintf('r=%.2f t=%.2f',rmax,tmax);
        line([0 0],[-1 1],'Parent',ax,'Color','k');
        % line('XData',lags,'YData',r_mean,'Color',g_colors(j,:),'Tag','XCorr','Parent',ax,'LineWidth',l_width);
        % ax.YLim = [rmin,rmax];
        % line(tmax,rmax,'Parent',ax,'Marker',markertype,...
        %     'MarkerSize',markersize,'MarkerEdgeColor',g_colors(j,:),'MarkerFaceColor',g_colors(j,:));
        
        % SecondTab
        ax = findobj(handles.SecondTab,'Tag',sprintf('Ax%d-%d',j,i));
        ax.Title.String = sprintf('r=%.2f t=%.2f',rmax,tmax);
        line([0 0],[-1 1],'Parent',ax,'Color','k');
        
        % ThirdTab
        ax = findobj(handles.ThirdTab,'Tag',sprintf('Ax%d-%d',j,i));
        t = T_PEAK_ALL(j,i,:);
        t = t(:);
        new_lags = -5:.2:5;
        h = histogram(t,new_lags,'Parent',ax);
        h.FaceColor = g_colors(j,:);
        h.EdgeColor = g_colors(j,:);
        ax.Title.String = sprintf('Mu=%.2f/Med=%.2f',t_mean(j,i),t_median(j,i));
        ax.YLim = [0 1.2*max(h.BinCounts)];
        ax.XLim = [new_lags(1) new_lags(end)];
        ax.XTick = new_lags(1):1:new_lags(end);
        ax.XLabel.String = data.S_lfp(i).name;
        ax.YLabel.String = data.S_fus(j).name;
        delete(findobj(ax,'Tag','Hbar'));
        line([0 0],[0 30],'Parent',ax,'Color','k','Tag','Hbar');
       
        % LFP Synthesis
        ax = findobj(handles.FourthTab,'Tag',sprintf('Ax%d',i));
        hold(ax,'on');
        %Patch
        px_data = [lags;flipud(lags)];
        py_data = [r_mean+r_sem;flipud(r_mean-r_sem)];
        patch('XData',px_data,'YData',py_data,'FaceColor',g_colors(j,:),'EdgeColor','none',...
            'Parent',ax,'Visible',char(visible_status(j,i)),'FaceAlpha',alpha_value);
        %Line
        line('XData',lags,'YData',r_mean,'Color',g_colors(j,:),...
            'Parent',ax,'Visible',char(visible_status(j,i)),'LineWidth',l_width);
        ax.Title.String = data.S_lfp(i).name;
        ax.XLim = [data.thresh_inf data.thresh_sup];
        %ax.YLim = [min(rmin,ax.YLim(1)),max(rmax,ax.YLim(2))];
        ax.YLim = [-.2 .8];
        delete(findobj(ax,'Tag','Hbar'));
        line([0 0],[-1 1],'Parent',ax,'Color','k','Tag','Hbar');
        %Marker
        line(tmax,rmax,'Parent',ax,'Marker',markertype,'Tag','Peak','Visible',char(visible_status(j,i)),...
            'MarkerSize',markersize,'MarkerEdgeColor',g_colors(j,:),'MarkerFaceColor',g_colors(j,:),'LineWidth',marker_width);
        
        % fUS Synthesis
        ax = findobj(handles.FifthTab,'Tag',sprintf('Ax%d',j));
        hold(ax,'on');
        %Patch
        px_data = [lags;flipud(lags)];
        py_data = [r_mean+r_sem;flipud(r_mean-r_sem)];
        patch('XData',px_data,'YData',py_data,'FaceColor',g_colors(i,:),'EdgeColor','none',...
            'Parent',ax,'Visible',char(visible_status(j,i)),'FaceAlpha',alpha_value);    
        %Line
        line('XData',lags,'YData',r_mean,'Color',g_colors(i,:),...
            'Parent',ax,'Visible',char(visible_status(j,i)),'LineWidth',l_width);
        ax.Title.String = data.S_fus(j).name;
        ax.XLim = [data.thresh_inf data.thresh_sup];
        %ax.YLim = [min(rmin,ax.YLim(1)),max(rmax,ax.YLim(2))];
        ax.YLim = [-.2 .8];
        delete(findobj(ax,'Tag','Hbar'));
        line([0 0],[-1 1],'Parent',ax,'Color','k','Tag','Hbar');
        %Marker
        line(tmax,rmax,'Parent',ax,'Marker',markertype,'Tag','Peak','Visible',char(visible_status(j,i)),...
            'MarkerSize',markersize,'MarkerEdgeColor',g_colors(i,:),'MarkerFaceColor',g_colors(i,:),'LineWidth',marker_width);
        hold(ax,'off');
        
        if j==length(data.S_fus) && i==length(data.S_lfp)
            ax = findobj(handles.FourthTab,'Tag',sprintf('Ax%d',1));
            l = flipud(findobj(ax,'Type','line','-not','Tag','Hbar','-not','Tag','Peak'));
            ax = findobj(handles.FourthTab,'Tag',sprintf('Ax%d',i+1));
            set(ax,'XTick','','YTick','','XTickLabel','','YTickLabel','');
            for k =1:length(l)
                copyobj(l(k),ax);
            end
            leg = legend(ax,data.label_fus,'Tag','Legend');
            leg.Position = ax.Position;
            ax.Title.String = '';
            
            ax = findobj(handles.FifthTab,'Tag',sprintf('Ax%d',1));
            l = flipud(findobj(ax,'Type','line','-not','Tag','Hbar','-not','Tag','Peak'));
            ax = findobj(handles.FifthTab,'Tag',sprintf('Ax%d',j+1));
            set(ax,'XTick','','YTick','','XTickLabel','','YTickLabel','');
            for k =1:length(l)
                copyobj(l(k),ax);
            end
            leg = legend(ax,data.label_lfp,'Tag','Legend');
            leg.Position = ax.Position;
            ax.Title.String = '';
        end      
    end
end

%Puttting marker on top
all_markers = findobj([handles.FirstTab;handles.FourthTab;handles.FifthTab],'Tag','Peak');
for k=1:length(all_markers)
    uistack(all_markers(k),'top');
end

end