function synthesis_fUS_Statistics()

global DIR_SYNT;

d = dir(fullfile(DIR_SYNT,'fUS_Statistics'));
ind_rm = ~(cellfun('isempty',strfind({d(:).name}','.')));
d(ind_rm) = [];
[ind,v] = listdlg('Name','Folder Selection','PromptString','Select Folder',...
    'SelectionMode','single','ListString',{d(:).name}','InitialValue','','ListSize',[300 500]);
if v==0 || isempty(ind)
    return
else
    folder = fullfile(DIR_SYNT,'fUS_Statistics',char(d(ind).name));
end

d = dir(fullfile(folder,'*WHOLE.mat'));
all_files = {d(:).name}';

f2 = figure('Units','normalized',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','Synthesis fUS Statistics');
f2.Position = [.1 .1 .8 .8];
f2.UserData.all_files = all_files;
f2.UserData.folder = folder;
% Colormaps
%colormap('jet');
clrmenu(f2);

D_files = [];
D_group = [];
D_traces = [];
for i = 1:length(all_files)
    data_l =load(fullfile(folder,char(all_files(i))),'recording','label_episodes','label_channels');
    D_files = [D_files;{data_l.recording}];
    D_group = [D_group;data_l.label_episodes];
    D_traces = [D_traces;data_l.label_channels];
end

D = D_files;
D_u = unique(D,'stable');
occurences = NaN(size(D_u));
for i = 1:length(D_u)
    occurences(i) = sum(strcmp(D,D_u(i)));
end
D_files = [D_u,num2cell(occurences)];

D = D_group;
D_u = unique(D,'stable');
occurences = NaN(size(D_u));
for i = 1:length(D_u)
    occurences(i) = sum(strcmp(D,D_u(i)));
end
D_group = [D_u,num2cell(occurences)];

D = D_traces;
D_u = unique(D,'stable');
occurences = NaN(size(D_u));
for i = 1:length(D_u)
    occurences(i) = sum(strcmp(D,D_u(i)));
end
D_traces = [D_u,num2cell(occurences)];

% Information Panel
iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','InfoPanel',...
    'Position',[0 0 1 .1],...
    'Parent',f2);
t1 = uicontrol('Units','normalized','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',f2.Name,'Tag','Text1','FontSize',15);
e1 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String','','Tag','Edit1','Tooltipstring','Edit1');
e2 = uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',iP,...
    'String',4,'Tag','Edit2','Tooltipstring','# Channels');
pu1 = uicontrol('Units','normalized','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','Popup1','Value',1);
pu2 = uicontrol('Units','normalized','Style','popupmenu','Parent',iP,...
    'String','<0>','Tag','Popup2','Value',1);
br = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
bc = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute');
bi = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save Image','Tag','ButtonSaveImage');
bs = uicontrol('Units','normalized','Style','pushbutton','Parent',iP,...
    'String','Save Stats','Tag','ButtonSaveStats');
cbi = uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'TooltipString','Group by','Tag','BoxInvert','Value',0,'String','Groups');
cbl = uicontrol('Units','normalized','Style','checkbox','Parent',iP,...
    'TooltipString','BarLink','Tag','BoxBarLink','Value',0,'String','unlinked');

ipos = [0 0 1 1];
t1.Position = [ipos(3)/50      ipos(4)/10    ipos(3)/4   3*ipos(4)/4];
pu1.Position = [ipos(3)/4     ipos(4)/2    ipos(3)/4   ipos(4)/3];
pu2.Position = [ipos(3)/4     ipos(4)/10             ipos(3)/4   ipos(4)/3];
e1.Position = [6*ipos(3)/10     ipos(4)/2    5*ipos(3)/100   4*ipos(4)/10];
e2.Position = [6*ipos(3)/10     ipos(4)/10             5*ipos(3)/100   4*ipos(4)/10];

br.Position = [7*ipos(3)/10     ipos(4)/2     1.5*ipos(3)/10-.01   ipos(4)/2.5];
bc.Position = [8.5*ipos(3)/10     ipos(4)/2      1.5*ipos(3)/10-.01   ipos(4)/2.5];
bi.Position = [7*ipos(3)/10     ipos(4)/10      1.5*ipos(3)/10-.01   ipos(4)/2.5];
bs.Position = [8.5*ipos(3)/10     ipos(4)/10      1.5*ipos(3)/10-.01   ipos(4)/2.5];

cbi.Position = [5*ipos(3)/10     ipos(4)/10    ipos(3)/10   3*ipos(4)/10];
cbl.Position = [5*ipos(3)/10     5*ipos(4)/10    ipos(3)/10   3*ipos(4)/10];

% Creating uitabgroup
mP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 .1 1 .9],...
    'Parent',f2);
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',mP,...
    'Tag','TabGroup');

%Trace Tab
tab0 = uitab('Parent',tabgp,...
    'Title','Traces & Episodes',...
    'Tag','TraceTab');
filePanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[0 0 1/3 1],...
    'Title','Files',...
    'Tag','TracePanel');
tracePanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[1/3 0 1/3 1],...
    'Title','Traces',...
    'Tag','TracePanel');
groupPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[2/3 0 1/3 1],...
    'Title','Time Groups',...
    'Tag','GroupPanel');

% Table Data
ft = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data',D_files,...
    'Position',[0 0 1 1],...
    'Tag','File_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',filePanel);
ft.UserData.Selection = (1:size(ft.Data,1))';

tt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data',D_traces,...
    'Position',[0 0 1 1],...
    'Tag','Trace_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',tracePanel);
tt.UserData.Selection = (1:size(tt.Data,1))';

gt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char'},...
    'ColumnEditable',false,...
    'ColumnWidth',{120},...
    'Data',D_group,...
    'Position',[0 0 1 1],...
    'Tag','Group_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',groupPanel);
gt.UserData.Selection = (1:size(gt.Data,1))';

% First tab
tab1 = uitab('Parent',tabgp,...
    'Title','Bar graphs',...
    'Units','normalized',...
    'Tag','MainTab');
uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','MainPanel',...
    'Parent',tab1);

% Second tab
tab2 = uitab('Parent',tabgp,...
    'Title','Mean',...
    'Units','normalized',...
    'Tag','SecondTab');
sp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','SecondPanel',...
    'Parent',tab2);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',sp,...
    'TooltipString','Legend Visibility',...
    'Position',[0 0 .04 .04],...
    'Tag','BoxLegend',...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxErrorBar_Callback},...
    'Position',[0 .04 .04 .04],...
    'Parent',sp,...
    'TooltipString','ErrorBar Visibility',...
    'Tag','BoxBar',...
    'Value',0);
axes('Parent',sp,'Position',[.05 .05 .8 .9],...
    'Tag','SecondAxes',...
    'TickLength',[0 0.1]);
axes('Parent',sp,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);

% Third tab
tab3 = uitab('Parent',tabgp,...
    'Title','Median',...
    'Units','normalized',...
    'Tag','ThirdTab');
tp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','ThirdPanel',...
    'Parent',tab3);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',tp,...
    'TooltipString','Legend Visibility',...
    'Position',[0 0 .04 .04],...
    'Tag','BoxLegend',...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxErrorBar_Callback},...
    'Parent',tp,...
    'TooltipString','ErrorBar Visibility',...
    'Position',[0 .04 .04 .04],...
    'Tag','BoxBar',...
    'Value',0);
axes('Parent',tp,'Position',[.05 .05 .8 .9],...
    'Tag','ThirdAxes',...
    'TickLength',[0 0.1]);
axes('Parent',tp,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);

% Fourth tab
tab4 = uitab('Parent',tabgp,...
    'Title','BoxPlot',...
    'Units','normalized',...
    'Tag','FourthTab');
fp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','FourthPanel',...
    'Parent',tab4);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',fp,...
    'TooltipString','Legend Visibility',...
    'Tag','BoxLegend',...
    'Position',[0 0 .04 .04],...
    'Value',1);
axes('Parent',fp,'Position',[.05 .05 .8 .9],...
    'Tag','FourthAxes',...
    'TickLength',[0 0.1]);
axes('Parent',fp,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);

% Fifth tab
tab5 = uitab('Parent',tabgp,...
    'Title','Histograms',...
    'Units','normalized',...
    'Tag','FifthTab');
fip = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','FifthPanel',...
    'Parent',tab5);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',fip,...
    'TooltipString','Legend Visibility',...
    'Tag','BoxLegend',...
    'Position',[0 0 .04 .04],...
    'Value',1);
axes('Parent',fip,'Position',[.05 .05 .8 .9],...
    'Tag','FifthAxes',...
    'TickLength',[0 0.1]);
axes('Parent',fip,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);

% Sixth tab
tab6 = uitab('Parent',tabgp,...
    'Title','Amplification',...
    'Units','normalized',...
    'Tag','SixthTab');
sip = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','SixthPanel',...
    'Parent',tab6);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLegend_Callback},...
    'Parent',sip,...
    'TooltipString','Legend Visibility',...
    'Tag','BoxLegend',...
    'Position',[0 0 .04 .04],...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxErrorBar_Callback},...
    'Position',[0 .04 .04 .04],...
    'Parent',sip,...
    'TooltipString','ErrorBar Visibility',...
    'Tag','BoxBar',...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Position',[0 .08 .04 .04],...
    'Parent',sip,...
    'TooltipString','Group Regions',...
    'Tag','BoxGroup',...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Position',[0 .12 .04 .04],...
    'Parent',sip,...
    'TooltipString','Permute',...
    'Tag','BoxPermute',...
    'Value',0);
ax1 = axes('Parent',sip,'Position',[.05 .05 .8 .9],...
    'Tag','SixthAxes',...
    'TickLength',[0 0.1]);
axes('Parent',sip,'Position',[.05 .05 .8 .9],...
    'Tag','DummyAxes',...
    'Visible','off',...
    'TickLength',[0 0.1]);
uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',sip,...
    'String',0,...
    'Tag','xmin',...
    'Position',[0 .9 .04 .04],...
    'Callback', {@update_yaxis,ax1,1},...
    'Tooltipstring','Xmin');
uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',sip,...
    'String',1,...
    'Tag','xmax',...
    'Position',[0 .95 .04 .04],...
    'Callback', {@update_yaxis,ax1,2},...
    'Tooltipstring','Xmax');

% Seventh Tab
tab7 = uitab('Parent',tabgp,...
    'Title','Connectivity',...
    'Units','normalized',...
    'Tag','SeventhTab');
sup = uipanel('FontSize',12,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Tag','SeventhPanel',...
    'Parent',tab7);
bl = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@boxLabel_Callback},...
    'Parent',sup,...
    'TooltipString','Label Visibility',...
    'Tag','BoxLabel',...
    'Position',[0 .04 .04 .04],...
    'Value',1);
bl.UserData.label_channels = {''};
uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Parent',sup,...
    'TooltipString','Auto/Manual CLimMode',...
    'Tag','BoxCLim',...
    'Position',[0 0 .04 .04],...
    'Value',1);
uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',sup,...
    'String',0,...
    'Tag','cmin',...
    'Position',[0 .9 .04 .04],...
    'Tooltipstring','Cmin');
uicontrol('Units','normalized',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Parent',sup,...
    'String',1,...
    'Tag','cmax',...
    'Position',[0 .95 .04 .04],...
    'Tooltipstring','Cmax');

% reset
handles2 = guihandles(f2);
resetbutton_Callback([],[],handles2);
tabgp.SelectedTab = tab0;

end

function resetbutton_Callback(~,~,handles)

% Initialize
initialize_centerPanel(handles);
handles = guihandles(handles.MainFigure);

%Clear axes
if ~isempty(findobj(handles.SecondPanel,'Tag','SecondAxes'));
    delete(handles.SecondAxes.Children);
end
if ~isempty(findobj(handles.ThirdPanel,'Tag','ThirdAxes'));
    delete(handles.ThirdAxes.Children);
end
if ~isempty(findobj(handles.FourthPanel,'Tag','FourthAxes'));
    delete(handles.FourthAxes.Children);
end
if ~isempty(findobj(handles.FifthPanel,'Tag','FifthAxes'));
    delete(handles.FifthAxes.Children);
end
if ~isempty(findobj(handles.SixthPanel,'Tag','SixthAxes'));
    delete(handles.SixthAxes.Children);
end
if ~isempty(findobj(handles.SeventhPanel,'Tag','SeventhAxes'));
    delete(handles.SeventhAxes.Children);
end

%Clear dummy axes
d_axes = findobj(handles.MainFigure,'Tag','DummyAxes');
for i =1:length(d_axes)
    delete(d_axes(i).Children);
end
% Delete PatchAxes & legends
delete(findobj(handles.MainFigure,'Tag','PatchAxes'));
delete(findobj(handles.MainFigure,'type','legend'));

% Callback function Attribution
set(handles.ButtonReset,'Callback',{@resetbutton_Callback,handles});
set(handles.ButtonCompute,'Callback',{@compute_Callback,handles});
%set(handles.ButtonSaveImage,'Callback',{@saveimage_Callback,handles});
%set(handles.ButtonSaveStats,'Callback',{@savestats_Callback,handles});

set(handles.Popup1,'Callback',{@update_popup_Callback,handles});
set(handles.BoxScale,'Callback',{@rescalebox_Callback,handles});
set(handles.BoxLink,'Callback',{@linkbox_Callback,handles});
set(handles.BoxInvert,'Callback',{@boxInvert_Callback});
set(handles.BoxBarLink,'Callback',{@boxBarLink_Callback,handles});

end

function initialize_centerPanel(handles)

%episodes = str2double(handles.Edit1.String);
channels = str2double(handles.Edit2.String);
delete(handles.MainPanel.Children);
%Position
margin = .03;
button_size =.05;

for i=1:channels
    ax1 = subplot(2,channels,i,'Parent',handles.MainPanel,'Tag',sprintf('Ax%d',i));
    title(ax1,sprintf('Bar %d',i));
    ax2 = subplot(2,channels,i+channels,'Parent',handles.MainPanel,'Tag',sprintf('Ax%d',i+channels));
    title(ax2,sprintf('Histogram %d',i));
    b1 = uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.MainPanel,...
        'String',0,...
        'Tag',sprintf('xmin_%d',i),...
        'Callback', {@update_yaxis,ax1,1},...
        'Tooltipstring',sprintf('Xmin %d',i));
    b2 = uicontrol('Units','normalized',...
        'Style','edit',...
        'HorizontalAlignment','center',...
        'Parent',handles.MainPanel,...
        'String',1,...
        'Tag',sprintf('xmax_%d',i),...
        'Callback', {@update_yaxis,ax1,2},...
        'Tooltipstring',sprintf('Xmax %d',i));
    
    %Position
    ax1.Position = [(i-1)/channels+(1.5*margin) .5+margin  (1/channels)-(1.75*margin) .5-2*margin];
    ax2.Position = [(i-1)/channels+(1.5*margin) margin  (1/channels)-(1.75*margin) .5-3*margin];
    b1.Position = [(i-1)/channels 1-button_size button_size/2  button_size];
    b2.Position = [(i-1)/channels 1-2*button_size  button_size/2 button_size];

end

bs = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@rescalebox_Callback,handles},...
    'Parent',handles.MainPanel,...
    'TooltipString','Vertical Scaling',...
    'Tag','BoxScale',...
    'Value',0);
bl = uicontrol('Units','normalized',...
    'Style','checkbox',...
    'Callback',{@linkbox_Callback,handles},...
    'Parent',handles.MainPanel,...
    'TooltipString','Link/unlink Axes',...
    'Tag','BoxLink',...
    'Value',0);
box_size = .03;
bs.Position = [0 .5 box_size box_size];
bl.Position = [0 .55 box_size box_size];



end

function update_popup_Callback(~,~,handles)

TimeTag_Data_full = handles.Popup1.UserData.TimeTag_Data_full;
str_groups = handles.Popup1.UserData.str_groups;
str_channels = handles.Popup1.UserData.str_channels;

%Params
g_colors = get(groot,'DefaultAxesColorOrder');
val = handles.Popup1.Value;
cmap = handles.MainFigure.Colormap;
ind_colors = 1:63/(length(str_channels)-1):64;

%ind_channels = handles.Trace_table.UserData.Selection;
%n_episodes = size(TimeTag_Data_full,2);
n_channels = length(str_channels);
episodes = size(TimeTag_Data_full,2);
channels = str2double(handles.Edit2.String);

% Clear Axes
h_all = findobj(handles.MainPanel,'Type','Axes');
for i=1:length(h_all)
    cla(h_all(i));
    delete(h_all(i).Title);
end

% Update Axes
ind_start = (val-1)*channels+1;
ind_end = min((val-1)*channels+channels,n_channels);

for i=ind_start:ind_end
    
    ind = mod(i-1,channels)+1;
    data = TimeTag_Data_full(:,:,i);
    val_max = max(data(:),[],'omitnan');
    val_min = min(data(:),[],'omitnan');
    c_reg = cmap(round(ind_colors(i)),:);
    
    str_popup2 = handles.Popup2.String;
    val_popup2 = handles.Popup2.Value;
    switch strtrim(str_popup2(val_popup2,:))
        case {'Mean'}
            m = mean(data,1,'omitnan');
            s = std(data,1,'omitnan');
        case 'Median'
            m = median(data,1,'omitnan');
            s = std(data,1,'omitnan');
    end
    % Standard error mean
    s_sem = s./sqrt(sum(~isnan(data)));
    
    % Bar Graph
    ax1 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',ind));
    hold(ax1,'on');
    b = bar(1:episodes,diag(m),'stacked','Parent',ax1);
    for k=1:episodes
        %b(k).FaceColor = char(GDisp.colors(k));
        b(k).FaceColor = g_colors(mod(k-1,7)+1,:);
    end
    e = errorbar(diag(m),diag(s_sem),'Color','k',...
        'Parent',ax1,'LineStyle','none',...
        'LineWidth',1.5);
    for k=1:length(e)
        if e(k).YData(k)>0
            e(k).LData(k)=0;
        else
            e(k).UData(k)=0;
        end
    end
    
    hold(ax1,'off');
    ax1.Tag = sprintf('Ax%d',ind);
    ax1.XTick = 1:episodes;
    ax1.XTickLabel = str_groups;
    %ax1.XTickLabelRotation = 90;
    ax1.XLim = [.5 episodes+.5];
    title(ax1,char(str_channels(i)));
    axis(ax1,'auto y');
    button3 = findobj(handles.MainPanel,'Tag',sprintf('xmin_%d',ind));
    button3.String = ax1.YLim(1);
    button4 = findobj(handles.MainPanel,'Tag',sprintf('xmax_%d',ind));
    button4.String = ax1.YLim(2);
    
    % Histogram
    ax2 = findobj(handles.MainPanel,'Tag',sprintf('Ax%d',ind+channels));
    hold(ax2,'on');
    for k=1:episodes
        x = TimeTag_Data_full(~isnan(TimeTag_Data_full(:,k,i)),k,i);
        %bin_edges = floor(val_min):(val_max-val_min)/50:ceil(val_max);
        bin_edges = -20:.25:100;
        h = histogram(x,'BinEdges',bin_edges,'EdgeColor','none',...
            'FaceAlpha',.5,'FaceColor',g_colors(mod(k-1,7)+1,:),...
            'Normalization','pdf','Parent',ax2);
        box = findobj(handles.MainPanel,'Tag',sprintf('Box%d',k));
        if ~box.Value
            h.Visible = 'off';
        end
    end
    ax2.XLim = [bin_edges(1) bin_edges(end)];
    title(ax2,char(str_channels(i)));
    hold(ax2,'off');
    ax2.Tag = sprintf('Ax%d',ind+channels);
    
    % Adding Gaussian Interpolation
    x = val_min:0.001:val_max;
    for k=1:episodes
        mu = m(k);
        sigma = s(k);
        y = exp(-(x-mu).^2./(2*sigma^2))./(sigma*sqrt(2*pi));
        l = line(x,y,'Parent',ax2,'Color',g_colors(mod(k-1,7)+1,:),'LineWidth',1.5);
        box = findobj(handles.MainPanel,'Tag',sprintf('Box%d',k));
        if ~box.Value
            l.Visible = 'off';
        end
    end
end


end

function compute_Callback(~,~,handles)

% Parameters
cmap = handles.MainFigure.Colormap;
all_files = handles.MainFigure.UserData.all_files;
folder = handles.MainFigure.UserData.folder;

ft = handles.File_table;
if isempty(ft.UserData.Selection)
    warning('Please Select Files');
    return;
else
    ft_sel = ft.UserData.Selection;
    fprintf('File Selection : \n');
    ft.Data(ft_sel)
    str_files = ft.Data(ft_sel,1);
    %fprintf('\n');
end

tt = handles.Trace_table;
if isempty(tt.UserData.Selection)
    warning('Please Select Traces');
    return;
else
    tt_sel = tt.UserData.Selection;
    fprintf('Trace Selection : \n');
    tt.Data(tt_sel)
    str_channels = tt.Data(tt_sel,1);
    %fprintf('\n');
end

gt = handles.Group_table;
if isempty(handles.Group_table.UserData.Selection)
    warning('Please Select Groups');
    return;
else
    gt_sel = gt.UserData.Selection;
    fprintf('Group Selection : \n');
    gt.Data(gt_sel)
    str_groups = gt.Data(gt_sel,1);
    %fprintf('\n');
end

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;
handles.MainFigure.UserData.success = false;

% Getting variables
%episodes = length(str_groups);

channels = str2double(handles.Edit2.String);
%ind_channels = handles.Trace_table.UserData.Selection;
%label_channels = handles.Trace_table.Data(ind_channels,1);
%ind_groups =  handles.Group_table.UserData.Selection;
%n_groups = length(ind_groups);

% Setting Popup String
n_channels = length(str_channels);
if n_channels <= channels
    str = sprintf('Trace 1 - %d',n_channels);
else
    str = sprintf('Trace 1 - %d',channels);
    for k=2:floor((n_channels-1)/channels)
        str = strcat(str,sprintf('|Trace %d - %d',(k-1)*channels+1,k*channels));
    end
    str = strcat(str,sprintf('|Trace %d - %d',floor((n_channels-1)/channels)*channels+1,n_channels));
end
handles.Popup1.String = str;
handles.Popup1.Value = 1;
handles.Popup2.String = 'Mean|Median';
handles.Popup2.Value = 1;


% Loading data
TimeTag_Data_full = [];
recording_full = [];
str_recordings = [];
RHO = NaN(length(str_channels),length(str_channels),length(str_groups),length(str_files));
%BDATA = NaN(3,length(str_channels),length(str_files));
BDATA = [];
    
for i=1:length(ft_sel)
    ii = ft_sel(i);
    filename = fullfile(folder,char(all_files(ii)));
    data = load(filename,'S','r_length','label_ampli','label_episodes',...
        'label_channels','all_rhos','all_bars','recording');
    
    % TimeTag_Data
    TimeTag_Data = NaN(data.r_length,length(tt_sel),length(gt_sel));
    for j=1:size(data.S,1)
        for k=1:size(data.S,2)
            group = data.S(j,k).group;
            channel = data.S(j,k).channel;
            x_data = data.S(j,k).x_data;
            y_data = data.S(j,k).y_data;
            
            ind_group = find(strcmp(group,str_groups)==1);
            ind_channel = find(strcmp(channel,str_channels)==1);
            if ~isempty(ind_group) && ~isempty(ind_channel)
                TimeTag_Data(x_data,ind_channel,ind_group) = y_data;
            end
        end
    end
    TimeTag_Data_full = cat(1,TimeTag_Data_full,TimeTag_Data);
    recording_full = [recording_full;repmat(data.recording,[size(TimeTag_Data,1),1])];
    str_recordings = [str_recordings;data.recording];
    
    % Keeping relevant indexes
    indexes_in = [];
    indexes_out = [];
    for k =1:length(str_channels)
        pattern = char(str_channels(k));
        ind = find(strcmp(data.label_channels,pattern)==1);
        indexes_in = [indexes_in;ind];
        if length(ind)==1
            indexes_out = [indexes_out;k];
        end
    end
    % all_rhos_Data
    all_rhos_Data = NaN(length(str_channels),length(str_channels),length(str_groups));
    all_rhos = data.all_rhos;
    for k=1:length(str_groups)
        pattern2 = char(str_groups(k));
        ind_group = find(strcmp(data.label_episodes,pattern2)==1);
        if length(ind_group)==1
            rho = all_rhos(indexes_in,indexes_in,ind_group);
            all_rhos_Data(indexes_out,indexes_out,k) = rho;
        end
    end
    RHO(:,:,:,i) = all_rhos_Data;
    % all_bars_Data
    all_bars_Data = NaN(size(data.all_bars,1),length(str_channels));
    all_bars_Data(:,indexes_out) = data.all_bars(:,indexes_in);
    %BDATA(:,:,i) = all_bars_Data;
    BDATA = cat(3,BDATA,all_bars_Data);
    fprintf('Data loaded %s \n',filename);
end
tt_full = TimeTag_Data_full;
TimeTag_Data_full = permute(TimeTag_Data_full,[1,3,2]);


% First Panel
% Initialize boxes
all_boxes = findobj(handles.MainPanel,'Style','checkbox','-not','Tag','BoxScale','-not','Tag','BoxLink');
delete(all_boxes);
box_size = .03;
for i=1:length(str_groups)
    uicontrol('Units','normalized',...
        'Style','checkbox',...
        'Callback',{@histbox_Callback,handles,i},...
        'Parent',handles.MainPanel,...
        'TooltipString',char(str_groups(i)),...
        'Position',[0 .05*(i-1) box_size box_size],...
        'Tag',sprintf('Box%d',i),...
        'Value',1);
end
handles.Popup1.UserData.TimeTag_Data_full = TimeTag_Data_full;
handles.Popup1.UserData.str_groups = str_groups;
handles.Popup1.UserData.str_channels = str_channels;
update_popup_Callback(handles.Popup1,[],handles);

% Second Panel
% Mean
panel = handles.SecondPanel;
ax = handles.SecondAxes;
bar_data = permute(mean(TimeTag_Data_full,1,'omitnan'),[3,2,1]);
ebar_data = permute(std(TimeTag_Data_full,1,'omitnan'),[3,2,1]);
bar_type = 'mean';
% sem
N = permute(sum(~isnan(TimeTag_Data_full)),[3 2 1]);
ebar_data = ebar_data./sqrt(N);

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end
box = findobj(panel,'Tag','BoxBar');
if box.Value
    status_e = 'on';
else
    status_e = 'off';
end

%Getting data
if handles.BoxInvert.Value
    bdata = bar_data;
    edata = ebar_data;
    xtick_labs = str_channels;
    leg_labs = str_groups;
else
    bdata = bar_data';
    edata = ebar_data';
    xtick_labs = str_groups;
    leg_labs = str_channels;
end

%Drawing bar
b= bar(bdata,'Parent',ax);
% Removing bar edges
for i =1:length(b)
    b(i).EdgeColor='k';
    b(i).LineWidth= .1;
end
n_groups = size(bdata,1);
n_bars = size(bdata,2);

% Error bars
hold(ax,'on');
gpwidth = min(.8,n_bars/(n_bars+1.5));
for i = 1:n_bars
    %bar color
    ind_color = round(i*length(cmap)/n_bars-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    % Calculate center of each bar
    factor = gpwidth/2 - (2*(i)-1) *(gpwidth/(2*n_bars));
    x = (1:n_groups) - factor;
    e = errorbar(x,bdata(:,i),edata(:,i),'k',...
        'linewidth',1,'linestyle','none',...
        'Parent',ax,'Visible',status_e,'Tag','ErrorBar');
end
leg = legend(ax,leg_labs,'Visible',status_l);

% Axis limits
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = bar_type;
grid(ax,'on');

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .89*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Tag reasignement
ax.Tag = 'SecondAxes';
ax_dummy.Tag = 'DummyAxes';

% Third Panel
% Median
panel = handles.ThirdPanel;
ax = handles.ThirdAxes;
bar_data = permute(median(TimeTag_Data_full,1,'omitnan'),[3,2,1]);
ebar_data = permute(std(TimeTag_Data_full,1,'omitnan'),[3,2,1]);
bar_type = 'median';
% sem
N = permute(sum(~isnan(TimeTag_Data_full)),[3 2 1]);
ebar_data = ebar_data./sqrt(N);

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end
box = findobj(panel,'Tag','BoxBar');
if box.Value
    status_e = 'on';
else
    status_e = 'off';
end

%Getting data
if handles.BoxInvert.Value
    bdata = bar_data;
    edata = ebar_data;
    xtick_labs = str_channels;
    leg_labs = str_groups;
else
    bdata = bar_data';
    edata = ebar_data';
    xtick_labs = str_groups;
    leg_labs = str_channels;
end

%Drawing bar
b= bar(bdata,'Parent',ax);
% Removing bar edges
for i =1:length(b)
    b(i).EdgeColor='k';
    b(i).LineWidth= .1;
end
n_groups = size(bdata,1);
n_bars = size(bdata,2);

% Error bars
hold(ax,'on');
gpwidth = min(.8,n_bars/(n_bars+1.5));
for i = 1:n_bars
    %bar color
    ind_color = round(i*length(cmap)/n_bars-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    % Calculate center of each bar
    factor = gpwidth/2 - (2*(i)-1) *(gpwidth/(2*n_bars));
    x = (1:n_groups) - factor;
    e = errorbar(x,bdata(:,i),edata(:,i),'k',...
        'linewidth',1,'linestyle','none',...
        'Parent',ax,'Visible',status_e,'Tag','ErrorBar');
end
leg = legend(ax,leg_labs,'Visible',status_l);

% Axis limits
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = bar_type;
grid(ax,'on');

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .89*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Tag reasignement
ax.Tag = 'ThirdAxes';
ax_dummy.Tag = 'DummyAxes';

% Fourth Panel
% Box Plot
panel = handles.FourthPanel;
ax = handles.FourthAxes;
bar_data = TimeTag_Data_full;
bar_type = 'boxplot';

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end

%Getting data
if handles.BoxInvert.Value
    tt_data = bar_data;
    dummy_data = ebar_data;
    xtick_labs = str_channels;
    leg_labs = str_groups;
else
    tt_data = permute(bar_data,[1,3,2]);
    dummy_data = ebar_data';
    xtick_labs = str_groups;
    leg_labs = str_channels;
end

% Box Plot
n_groups = size(tt_data,3);
n_bars = size(tt_data,2);
hold(ax,'on');
%gpwidth = min(.8,n_groups/(n_groups+1.5));
gpwidth = .85;
for i=1:n_groups
    positions = i-gpwidth/2:gpwidth/(n_bars-1):i+gpwidth/2;
    ind_colors = 1:63/(n_bars-1):64;
    colors = cmap(round(ind_colors),:);
    boxplot(tt_data(:,:,i),...
        'MedianStyle','target',...
        'positions',positions,...
        'colors',colors,...
        'OutlierSize',1,...
        'Widths',gpwidth/(n_bars+1),...
        'Parent',ax);

end
hold(ax,'off');
ax.Position = [.05 .05 .8 .9];
grid(ax,'on');

% Dummy axes for legend
b = bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    ind_color = round(i*length(cmap)/n_bars-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible',status_l);
ax_dummy.Position = [2 1 1 1];

% Axis limits
ax.YLim = [min(tt_data(:)) max(tt_data(:))];
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = bar_type;

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .89*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Tag reasignement
ax.Tag = 'FourthAxes';
ax_dummy.Tag = 'DummyAxes';

% Fifth Panel
% Hist Plot
panel = handles.FifthPanel;
ax = handles.FifthAxes;
bar_data = TimeTag_Data_full;
bar_type = 'histplot';

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end

%Getting data
if handles.BoxInvert.Value
    tt_data = bar_data;
    dummy_data = ebar_data;
    xtick_labs = str_channels;
    leg_labs = str_groups;
else
    tt_data = permute(bar_data,[1,3,2]);
    dummy_data = ebar_data';
    xtick_labs = str_groups;
    leg_labs = str_channels;
end

% Hist Plot
n_groups = size(tt_data,3);
n_bars = size(tt_data,2);
hold(ax,'on');
%gpwidth = min(.8,n_groups/(n_groups+1.5));
gpwidth = .85;
val_min = min(tt_data(:),[],'omitnan');
val_max = max(tt_data(:),[],'omitnan');
edges = val_min:(val_max-val_min)/100:val_max;
centers = edges(1:end-1)+.5*(edges(2)-edges(1));

for i=1:n_groups
    positions = i-gpwidth/2:gpwidth/(n_bars-1):i+gpwidth/2;
    ind_colors = 1:63/(n_bars-1):64;
    colors = cmap(round(ind_colors),:);
    delta_p = gpwidth/n_bars;
        
    for j=1:n_bars
        X = tt_data(:,j,i);
        X = X(~isnan(X));
        h_data = histcounts(X,edges);
        h_data = h_data/max(h_data);
        xdata = positions(j)+delta_p*h_data;
        
    patch(xdata,centers,colors(j,:),'FaceAlpha',1,...
            'EdgeColor','none','LineWidth',1,...
            'Tag','Region','Parent',ax);
    end
end
hold(ax,'off');
ax.Position = [.05 .05 .8 .9];
grid(ax,'on');

% Dummy axes for legend
b= bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    ind_color = round(i*length(cmap)/n_bars-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible',status_l);
ax_dummy.Position = [2 1 1 1];

% Axis limits
ax.YLim = [min(tt_data(:)) max(tt_data(:))];
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = bar_type;

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .89*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Tag reasignement
ax.Tag = 'FifthAxes';
ax_dummy.Tag = 'DummyAxes';

% Sixth Panel
% Bar Plot
panel = handles.SixthPanel;
ax = handles.SixthAxes;
%mean_data = permute(mean(TimeTag_Data_full,1,'omitnan'),[2,3,1]);
%median_data = permute(median(TimeTag_Data,1,'omitnan'),[2,3,1]);
%ebar_data = permute(std(TimeTag_Data,1,'omitnan'),[2,3,1]);
bar_type = 'amplification';

%Clearing Axes
delete(findobj(panel,'Type','legend'));
delete(ax.Children);
ax_dummy = findobj(panel,'Tag','DummyAxes');
delete(ax_dummy.Children);

% Getting box status
box = findobj(panel,'Tag','BoxLegend');
if box.Value
    status_l = 'on';
else
    status_l = 'off';
end
box = findobj(panel,'Tag','BoxBar');
if box.Value
    status_e = 'on';
else
    status_e = 'off';
end

%Drawing bar
boxg = findobj(panel,'Tag','BoxGroup');
str_leg = str_channels;
if boxg.Value
    str_leg = unique(regexprep(str_leg,'-R|-L|-A|-P',''),'stable');
    BDATA_GROUP = NaN(size(BDATA,1),length(str_leg),size(BDATA,3));
    for i =1:length(str_leg)
        pattern = char(str_leg(i));
        ind_keep = ~(cellfun('isempty',strfind(str_channels,pattern)));
        BDATA_GROUP(:,i,:) = mean(BDATA(:,ind_keep,:),2);
    end
    BDATA = BDATA_GROUP;
end

% Keeping only specified episodes
%str_ampli = {'QW';'AW';'REM';'REM-PHASIC'};
str_ampli = {'AW';'REM';'REM-PHASIC'};
ind_keep = false(size(data.label_ampli));
for i =1:length(str_ampli)
    ind_keep(strcmp(data.label_ampli,char(str_ampli(i))))=true;
end
BDATA = BDATA(ind_keep,:,:);

boxp = findobj(panel,'Tag','BoxPermute');
if boxp.Value
    BDATA = permute(BDATA,[2,1,3]);
    temp = str_leg;
    str_leg = str_ampli;
    str_ampli = temp;
end
b_data = mean(BDATA,3,'omitnan');
n_groups = size(BDATA,1);
n_bars = size(BDATA,2);    

%Bars
b = bar(b_data,'grouped','Parent',ax);
%leg = legend(ax,str_leg,'Visible',status_l);
ind_colors = 1:63/(n_bars-1):64;
colors = cmap(round(ind_colors),:);
for i =1:length(b)
    b(i).FaceColor = colors(i,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .5;
end
grid(ax,'on');

% Error bars
N = size(BDATA,3);
e_data = std(BDATA,[],3,'omitnan')/sqrt(N);
hold(ax,'on');
gpwidth = min(.8,n_bars/(n_bars+1.5));
for i = 1:n_bars
    % Calculate center of each bar
    factor = gpwidth/2 - (2*(i)-1) *(gpwidth/(2*n_bars));
    x = (1:n_groups) - factor;
    e = errorbar(x,b_data(:,i),e_data(:,i),'k',...
        'linewidth',1,'linestyle','none',...
        'Parent',ax,'Visible',status_e,'Tag','ErrorBar');
end

% Axis limits
ax.YLim = [min(b_data(:)-e_data(:)) max(b_data(:)+e_data(:))];
ax.XLim = [.5 size(BDATA,1)+.5];
ax.XTick = 1:size(BDATA,1);
ax.XTickLabel = str_ampli;


ax.Title.String = bar_type;
b1 = findobj(panel,'Tag','xmin');
b1.String = sprintf('%.1f',ax.YLim(1));
b2 = findobj(panel,'Tag','xmax');
b2.String =  sprintf('%.1f',ax.YLim(2));

% Dummy axes for legend
b = bar(b_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    ind_color = round(i*length(cmap)/length(b)-1)+1;
    b(i).FaceColor = cmap(ind_color,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,str_leg,'Visible',status_l);
ax_dummy.Position = [2 1 1 1];

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .89*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

% Tag reasignement
ax.Tag = 'SixthAxes';
ax_dummy.Tag = 'DummyAxes';


% Seventh Panel
panel = handles.SeventhPanel;
all_sevenax = findobj(panel,'Type','axes');
for i =1:length(all_sevenax)
    delete(all_sevenax(i));
end

% Clearing Axes
% Getting boxes
box1 = findobj(panel,'Tag','BoxLabel');
box2 = findobj(panel,'Tag','BoxCLim');

% Connectivity Plot
n_episodes = length(str_groups);
n_channels = length(str_channels);
all_axes = [];
all_cbars = [];
%all_rhos = NaN(n_channels,n_channels,n_episodes);
rho_mean = mean(RHO,4,'omitnan');
rho_std = std(RHO,[],4,'omitnan');
for i=1:n_episodes
    %data = permute(TimeTag_Data(:,i,:),[1,3,2]);
    %rho = corr(data,'rows','pairwise');
    ax = subplot(2,ceil(n_episodes/2),i,'Parent',panel);
    imagesc(rho_mean(:,:,i),'Parent',ax);
    ax.Tag = sprintf('Ax%d',i);
    
    ax.Title.String = char(str_groups(i));
    ax.YTick = 1:n_channels;
    ax.YTickLabel = str_channels;
    ax.XTick = [];
    ax.XTickLabel = '';
    cbar = colorbar(ax);
    box1.UserData.label_channels = str_channels;
    all_axes = [all_axes;ax];
    all_cbars = [all_cbars;cbar];
end

b1 = findobj(panel,'Tag','cmin');
b1.Callback = {@update_caxis,all_axes,all_cbars,1};
b2 = findobj(panel,'Tag','cmax');
b2.Callback = {@update_caxis,all_axes,all_cbars,2};
if box2.Value
    %auto
    update_caxis([b1,b2],[],all_axes,all_cbars);
end

% Transmitting data to save button
save_data.str_groups = str_groups;
save_data.str_channels = str_channels;
save_data.TimeTag_Data_full = TimeTag_Data_full;
handles.MainFigure.UserData.save_data=save_data;


% Writing data out
% Removing folder
folder = fullfile(handles.MainFigure.UserData.folder,'Data');
if ~exist(folder,'dir')
    mkdir(folder);
else
    rmdir(folder,'s');
    mkdir(folder);
end
% Statistics Separate files
for i = 1:size(tt_full,3)
    filename_out = fullfile(folder,sprintf('Statistics_%s.txt',char(str_groups(i))));
    temp = tt_full(:,:,i);
    fid = fopen(filename_out,'w');
    fwrite(fid,sprintf('Recording \t '));
    fwrite(fid,sprintf('%s \t ', str_channels{:}));
    fwrite(fid,newline);
    for k = 1: size(temp,1)
        if sum(~isnan(temp(k,:)))>0
            fwrite(fid,sprintf('%s \t ', char(recording_full(k,:))));
            fwrite(fid,sprintf('%.3f \t ', temp(k,:)));
            fwrite(fid,newline);
        end
    end  
    fclose(fid);
    fprintf('Data saved in file %s\n',filename_out);
end

% Correlation Separate files
for i = 1:size(rho_mean,3)
    filename_out = fullfile(folder,sprintf('Correlation_%s.txt',char(str_groups(i))));
    fid = fopen(filename_out,'w');
    for k = 1:size(RHO,4)
        fwrite(fid,sprintf('%s \t ', char(str_recordings(k,:))));
        fwrite(fid,sprintf('%s \t ',str_channels{:}));
        fwrite(fid,newline);
        for l = 1: size(RHO,1)
            fwrite(fid,sprintf('%s \t ', char(str_channels(l,:))));
            fwrite(fid,sprintf('%.3f \t ', RHO(l,:,i,k)));
            fwrite(fid,newline);
        end
        fwrite(fid,newline);
    end  
    fclose(fid);
    fprintf('Data saved in file %s\n',filename_out);
end

% Synthesis
filename_synt = fullfile(folder,'Synthesis.txt');
fid2 = fopen(filename_synt,'w');
% Statistics
fwrite(fid2,sprintf('STATISTICS \n'));
fwrite(fid2,sprintf('Group Name \t Variable \t'));
fwrite(fid2,sprintf('%s \t ', str_channels{:}));
fwrite(fid2,newline);
for i = 1:size(tt_full,3)
    %fwrite(fid2,newline);
    temp = tt_full(:,:,i);
    fwrite(fid2,sprintf('%s \t Mean \t ',char(str_groups(i,:))));
    fwrite(fid2,sprintf('%.3f \t ',mean(temp,'omitnan')));
    fwrite(fid2,newline);
    fwrite(fid2,sprintf('%s \t Standard-deviation \t ',char(str_groups(i,:))));
    fwrite(fid2,sprintf('%.3f \t ',std(temp,[],'omitnan')));
    fwrite(fid2,newline);
    fwrite(fid2,sprintf('%s \t Median \t ',char(str_groups(i,:))));
    fwrite(fid2,sprintf('%.3f \t ',median(temp,'omitnan')));
    fwrite(fid2,newline);
    fwrite(fid2,sprintf('%s \t Mode \t ',char(str_groups(i,:))));
    fwrite(fid2,sprintf('%.3f \t ',mode(temp)));
    fwrite(fid2,newline);
    fwrite(fid2,newline);
end
% Amplification
bdata_synt = permute(BDATA,[3,1,2]);
fwrite(fid2,newline);
fwrite(fid2,sprintf('AMPLIFICATION \n'));   
for i = 1:size(bdata_synt,3)
    %fwrite(fid2,newline);
    fwrite(fid2,sprintf('%s \t ',char(str_leg(i,:))));
    fwrite(fid2,sprintf('%s \t ',str_ampli{:}));
    fwrite(fid2,newline);
    for k = 1: size(bdata_synt,1)
        fwrite(fid2,sprintf('%s \t ', char(str_recordings(k,:))));
        fwrite(fid2,sprintf('%.3f \t ', bdata_synt(k,:,i)));
        fwrite(fid2,newline);
    end
    fwrite(fid2,sprintf('%s \t ', 'mean'));
    fwrite(fid2,sprintf('%.3f \t ', b_data(:,i)));
    fwrite(fid2,newline);
    fwrite(fid2,sprintf('%s \t ', 'sem'));
    fwrite(fid2,sprintf('%.3f \t ', e_data(:,i)));
    fwrite(fid2,newline);
    fwrite(fid2,newline);
    
end
% Correlation matrix
fwrite(fid2,newline);
fwrite(fid2,sprintf('CORRELATION \n'));   
for i = 1:size(rho_mean,3)
    %fwrite(fid2,newline);
    fwrite(fid2,sprintf('%s \t ',char(str_groups(i,:))));
    fwrite(fid2,sprintf('%s \t ',str_channels{:}));
    
    fwrite(fid2,sprintf('%s \t ','std'));
    fwrite(fid2,sprintf('%s \t ',str_channels{:}));
    
    fwrite(fid2,newline);
    for k = 1: size(rho_mean,1)
        fwrite(fid2,sprintf('%s \t ', char(str_channels(k,:))));
        fwrite(fid2,sprintf('%.3f \t ', rho_mean(k,:,i)));
        
        fwrite(fid2,sprintf('%s \t ',' '));
        fwrite(fid2,sprintf('%.3f \t ', rho_std(k,:,i)));
        fwrite(fid2,newline);
    end
    fwrite(fid2,newline);
end
fprintf('Data saved in file %s\n',filename_synt);    
fclose(fid2);


% Statistical testing
str_ref = 'QW';
ind_ref = strcmp(str_groups,str_ref);
X_ref = tt_full(~isnan(tt_full(:,1,ind_ref)),:,ind_ref);
Y_test = tt_full(:,:,~ind_ref);
str_test = str_groups(~ind_ref);
p_value = zeros(length(str_test),length(str_channels));
d_cohen = zeros(length(str_test),length(str_channels));
%str_p_value = cell(length(str_test),length(str_channels));
for i =1:size(Y_test,3)
    Y = Y_test(~isnan(Y_test(:,1,i)),:,i);
    %str = str_test(i);
    %m_value(i+1,:) = mean(Y);
    for j=1:size(Y_test,2)
        x = X_ref(:,j);
        y = Y(:,j);
        p_value(i,j) = ranksum(x,y);
        s = sqrt(((length(x)-1)*std(x,[],'omitnan')^2+(length(y)-1)*std(y,[],'omitnan')^2)/(length(x)+length(y)-2));
        d_cohen(i,j) = (mean(y,'omitnan')-mean(x,'omitnan'))/s;
        %str_p_value(i,j) = {sprintf('%s %s/%s',char(str_channels(j)),char(str),char(str_ref))}; 
    end
end

filename_stat = fullfile(folder,'Testing.txt');
fid3 = fopen(filename_stat,'w');
fwrite(fid3,sprintf('%s \t ','Mann - Whitney'));
fwrite(fid3,sprintf('%s \t ',str_channels{:}));
fwrite(fid3,newline);
for k = 1: size(p_value,1)
    fwrite(fid3,sprintf('%s / %s\t ',char(str_test(k,:)),char(str_ref)));
    fwrite(fid3,sprintf('%.30f \t ', p_value(k,:)));
    fwrite(fid3,newline);
end
fwrite(fid3,newline);
fwrite(fid3,sprintf('%s \t ','d-cohen'));
fwrite(fid3,sprintf('%s \t ',str_channels{:}));
fwrite(fid3,newline);
for k = 1: size(d_cohen,1)
    fwrite(fid3,sprintf('%s / %s\t ',char(str_test(k,:)),char(str_ref)));
    fwrite(fid3,sprintf('%.3f \t ',  d_cohen(k,:)));
    fwrite(fid3,newline);
end
fprintf('Data saved in file %s\n',filename_stat);    
fclose(fid3);


%if strcmp(handles.TabGroup.SelectedTab.Title,handles.TraceTab.Title)
handles.TabGroup.SelectedTab = handles.SixthTab;
%end
set(handles.MainFigure, 'pointer', 'arrow');
handles.MainFigure.UserData.success = true;

end

function histbox_Callback(hObj,~,handles,index)

panel = hObj.Parent;
channels = str2double(handles.Edit2.String);
for i=1:channels
    ax = findobj(panel,'Tag',sprintf('Ax%d',i+channels));
    h = flipud(findobj(ax,'Type','histogram'));
    l = flipud(findobj(ax,'Type','line'));
    if ~isempty(h)
        if hObj.Value
            h(index).Visible = 'on';
            l(index).Visible = 'on';
        else
            h(index).Visible = 'off';
            l(index).Visible = 'off';
        end
    end
    %ax.YLim = [0 15];
end


end

function boxErrorBar_Callback(hObj,~)

ebar = findobj(hObj.Parent,'Tag','ErrorBar');
if hObj.Value
    for i=1:length(ebar)
        ebar(i).Visible='on';
    end
else
    for i=1:length(ebar)
        ebar(i).Visible='off';
    end
end

end

function boxLegend_Callback(hObj,~)

l = findobj(hObj.Parent,'Type','legend');
if hObj.Value
    for i =1:length(l)
        l(i).Visible = 'on';
    end
else
    for i =1:length(l)
        l(i).Visible = 'off';
    end
end

end

function boxLabel_Callback(hObj,~)

label_channels = hObj.UserData.label_channels;
ax = findobj(hObj.Parent,'Type','axes');
if hObj.Value
    for i =1:length(ax)
        ax(i).YTick = 1:length(label_channels);
        ax(i).YTickLabel = label_channels;
    end
else
    for i =1:length(ax)
        ax(i).YTick = [];
        ax(i).YTickLabel = '';
    end
end

end

function boxInvert_Callback(hObj,~)

if hObj.Value
    hObj.String = 'Channels';
else
    hObj.String = 'Groups';
end

end

function boxBarLink_Callback(hObj,~,handles)

all_axes = [handles.SecondAxes;handles.ThirdAxes;handles.FourthAxes];

if hObj.Value
    hObj.String = 'linked';
    linkaxes(all_axes,'y');
else
    hObj.String = 'unlinked';
    linkaxes(all_axes,'off');
end

end

function rescalebox_Callback(hObj,~,handles)

val = hObj.Value;
panel = hObj.Parent;
channels = str2double(handles.Edit2.String);

switch val
    case 0,
        for i=1:channels
            ax = findobj(panel,'Tag',sprintf('Ax%d',i));
            axis(ax,'auto y');
        end;
    case 1,
        m = handles.Ax1.YLim(1);
        M = handles.Ax1.YLim(2);
        for i=2:channels
            ax = findobj(panel,'Tag',sprintf('Ax%d',i));
            if ~isempty(ax.Title.String)
                m = min(m,ax.YLim(1));
                M = max(M,ax.YLim(2));
            end
        end
        for i=1:channels
            ax = findobj(panel,'Tag',sprintf('Ax%d',i));
            ax.YLim = [m M];
            button3 = findobj(panel,'Tag',sprintf('xmin_%d',i));
            button3.String = m;
            button4 = findobj(panel,'Tag',sprintf('xmax_%d',i));
            button4.String = M;
        end
end


end

function linkbox_Callback(hObj,~,handles)

panel = hObj.Parent;
channels = str2double(handles.Edit2.String);
all_axes= [];
for i=1:channels
    ax = findobj(panel,'Tag',sprintf('Ax%d',i));
    all_axes= [all_axes;ax];
end
switch hObj.Value
    case 0,
        linkaxes(all_axes,'off')
    case 1,
        linkaxes(all_axes,'y');
end

end

function update_yaxis(hObj,~,ax,value)
switch value
    case 1,
        ax.YLim(1) = str2double(hObj.String);
    case 2,
        ax.YLim(2) = str2double(hObj.String);
end
end

function update_caxis(hObj,~,ax,c,value)

if length(hObj)>1
    clim1 = str2double(hObj(1).String);
    clim2 = str2double(hObj(2).String);
    for i=1:length(ax)
        ax(i).CLim = [clim1,clim2];
        c(i).Limits = [clim1,clim2];
    end
else
    for i=1:length(ax)
        switch value
            case 1,
                ax(i).CLim(1) = str2double(hObj.String);
            case 2,
                ax(i).CLim(2) = str2double(hObj.String);
        end
        c(i).Limits = ax(i).CLim;
    end
end

end