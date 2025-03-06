function synthesis_Global_Display()
% Global Episode Display and Averaging

global DIR_SYNT;
filename = fullfile(DIR_SYNT,'Wavelet_Extraction','REM');
d = dir(fullfile(filename,'*.mat'));
%fprintf('Loading Data ...\n');

%Parameters
w_filePanel =.2;
h_infoPanel = .25;
w_col = 80;
w_margin = 3;

f2 = figure('Units','normalized',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'Position',[0.1 0.1 .8 .8],...
    'PaperPositionMode','auto',...
    'Name','Synthesis Episode Display');
f2.UserData.filename = filename;
colormap(f2,'jet');

% File Panel
fP = uipanel('Units','normalized',...
    'Position',[0 h_infoPanel w_filePanel 1-h_infoPanel],...
    'bordertype','etchedin',...
    'Tag','FilePanel',...
    'Parent',f2);
ft = uitable('Units','normalized',...
    'Position',[0 0 1 1],...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{w_col},...
    'ColumnEditable',false,...
    'ColumnName',{'File'},...
    'Data',[],...
    'RowName','',...
    'Tag','File_table',...
    'RowStriping','on',...
    'Parent',fP);
ft.Data = {d.name}';
ft.UserData.files = d;
% Adjust Columns
ft.Units = 'pixels';
ft.ColumnWidth ={ft.Position(3)-w_margin};
ft.Units = 'normalized';
%ft.Data = cellstr(sprintf('Test1\nTest2'));

% Display Panel
dP = uipanel('Units','normalized',...
    'Position',[w_filePanel 0 1-w_filePanel 1],...
    'bordertype','etchedin',...
    'Tag','DisplayPanel',...
    'Parent',f2);
% Info Panel
iP = uipanel('Units','normalized',...
    'Position',[0 0 w_filePanel h_infoPanel],...
    'bordertype','etchedin',...
    'Tag','InfoPanel',...
    'Parent',f2);
gText = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0 .5 1 .5],...
    'Style','text',...
    'Parent',iP,...
    'String','Info',...
    'Tag','gText');
cb1 = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0 0 .5 .1],...
    'Style','checkbox',...
    'Parent',iP,...
    'String','Raw Trace',...
    'Tag','Checkbox1');
cb2 = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0 .1 .5 .1],...
    'Style','checkbox',...
    'Parent',iP,...
    'String','LFP filtered',...
    'Value',1,...
    'Tag','Checkbox2');
cb3 = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0 .2 .5 .1],...
    'Style','checkbox',...
    'Parent',iP,...
    'String','Ydata',...
    'Value',0,...
    'Tag','Checkbox3');
cb4 = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0 .3 .5 .1],...
    'Style','checkbox',...
    'Parent',iP,...
    'String','Log Correction',...
    'Value',1,...
    'Tag','Checkbox4');
cb5 = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0 .4 .5 .1],...
    'Style','checkbox',...
    'Parent',iP,...
    'Value',0,...
    'String','Log Display',...
    'Tag','Checkbox5');
e0 = uicontrol('Units','normalized',...
    'HorizontalAlignment','center',...
    'Position',[.4 .4 .2 .1],...
    'Style','edit',...
    'Parent',iP,...
    'String','3',...
    'TooltipString','Autoscale_factor',...
    'Tag','EditAutoscale');
e1 = uicontrol('Units','normalized',...
    'HorizontalAlignment','center',...
    'Position',[.6 .4 .2 .1],...
    'Style','edit',...
    'Parent',iP,...
    'String','1',...
    'Tag','Edit1');
e2 = uicontrol('Units','normalized',...
    'HorizontalAlignment','center',...
    'Position',[.8 .4 .2 .1],...
    'Style','edit',...
    'Parent',iP,...
    'String','150',...
    'Tag','Edit2');
e3 = uicontrol('Units','normalized',...
    'HorizontalAlignment','center',...
    'Position',[.4 .3 .3 .1],...
    'Style','edit',...
    'Enable','off',...
    'Parent',iP,...
    'String','',...
    'Tag','Edit3');
e4 = uicontrol('Units','normalized',...
    'HorizontalAlignment','center',...
    'Position',[.7 .3 .3 .1],...
    'Enable','off',...
    'Style','edit',...
    'Parent',iP,...
    'String','',...
    'Tag','Edit4');

ba = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[.5 .2 .5 .1],...
    'Style','pushbutton',...
    'Enable','off',...
    'Parent',iP,...
    'String','Autoscale',...
    'Tag','ButtonCompute');
be = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[.5 .1 .5 .1],...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Export',...
    'Tag','ButtonExport');
bc = uicontrol('Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[.5 0 .5 .1],...
    'Style','pushbutton',...
    'Parent',iP,...
    'String','Compute',...
    'Tag','ButtonCompute');

handles = guihandles(f2);
ft.CellSelectionCallback = {@filetable_uitable_select,handles};
cb1.Callback = {@checkbox1_Callback,handles};
cb2.Callback = {@checkbox2_Callback,handles};
cb3.Callback = {@checkbox3_Callback,handles};
bc.Callback = {@compute_Callback,handles};
be.Callback = {@export_Callback,handles};

end

function update_yaxis(hObj,~,ax,value)

if length(hObj)>1
    ax.YLim = [str2double(hObj(1).String) str2double(hObj(2).String)];
else
    switch value
        case 1,
            ax.YLim(1) = str2double(hObj.String);
        case 2,
            ax.YLim(2) = str2double(hObj.String);
    end
end

end

function export_Callback(~,~,handles)

global DIR_SYNT;
load('Preferences.mat','GTraces');
save_dir = fullfile(DIR_SYNT,'Export');
if ~isdir(save_dir)
    mkdir(save_dir);
end

fprintf('Export data Synthesis Display.\n');
whole_sel = handles.File_table.UserData.WholeSelection;
for i=1:length(whole_sel);
    ii = whole_sel(i);
    handles.File_table.UserData.Selection = ii;
    compute_Callback([],[],handles);
    % Saving Image
    pic_name = sprintf('%s%s',char(regexprep(handles.File_table.Data(ii),'.mat','')),GTraces.ImageSaveExtension);
    saveas(handles.MainFigure,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
    fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
end
fprintf('End Export.\n');

end

function filetable_uitable_select(hObj,evnt,handles)

%global DIR_SYNT;
%filename = fullfile(DIR_SYNT,'Wavelet_Analysis');

hObj.UserData.WholeSelection = unique(evnt.Indices(:,1));
if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(1,1));
    %hObj.UserData.Selection = unique(evnt.Indices(:,1));
else
    hObj.UserData.WholeSelection = [];
    return;
end

if length(hObj.UserData.WholeSelection)==1
    compute_Callback([],[],handles);
end

end

function compute_Callback(~,~,handles)

global DIR_SAVE;
files = handles.File_table.UserData.files;
selection = handles.File_table.UserData.Selection;
filename = handles.MainFigure.UserData.filename;
handles.gText.String = 'Loading...';
drawnow;
data =load(fullfile(filename,files(selection).name),'parent','Ydata','labels','ref_time','tag','name','x_end','x_start','s');   
t_start = datestr(data.x_start/(24*3600),'HH:MM:SS.FFF');
t_end = datestr(data.x_end/(24*3600),'HH:MM:SS.FFF');
handles.Edit3.String = t_start;
handles.Edit4.String = t_end;
x_dur = data.x_end - data.x_start;
t_dur = datestr(x_dur/(24*3600),'HH:MM:SS.FFF');
handles.gText.String = sprintf('Parent : %s\nTag : %s\nEpisode : %s\nStart : %s      (%.1f s)\nEnd : %s      (%.1f s)\nDuration : %s      (%.1f s)',...
    data.parent,data.tag,data.name,t_start,data.x_start,t_end,data.x_end,t_dur,x_dur);

% Initialize
delete(handles.DisplayPanel.Children);
margin_up = .01;
margin_down = .02;
margin =.01;
ratio_main_ax = 2;
ax1_margin = .05;
ax1_length = .75;
ax2_margin = .85;
ax2_length = .1;
w_colorbar = .015;

% Drawing image
n = size(data.s,2);
N =2*n+ratio_main_ax;
ax = axes('Parent',handles.DisplayPanel,'Position',[ax1_margin margin_up+1-ratio_main_ax/N+margin ax1_length ratio_main_ax/N-2*margin-margin_down]);
im = imagesc(data.Ydata,'Xdata',data.ref_time,'Ydata',1:length(data.labels),'Parent',ax,'Tag','Image','Visible','off');
im.UserData.labels = data.labels;
im.UserData.Ydata = data.Ydata;
ax.Title.String = char(regexprep(handles.File_table.Data(selection),'_','-'));
ax.Tag = 'Ax';
ax.TickLength=[0 0];

% Drawing lines
max_l = length(handles.MainFigure.Colormap);
ind_whole = 0;
lines_even = [];
lines_odd = [];
labels_even = [];
labels_odd = [];
for i =1:size(data.Ydata,1)
    if strcmp(char(data.labels(i)),'Whole')
        ind_whole = i;
    else
        l = line('Xdata',data.ref_time,'Ydata',data.Ydata(i,:),'Parent',ax,'Tag','line_region',...
            'Color',handles.MainFigure.Colormap(min(2*i,max_l),:),'Visible','on');
        if mod(i,2)==0
            lines_even = [lines_even;l];
            labels_even = [labels_even;data.labels(i)];
        else
            lines_odd = [lines_odd;l];
            labels_odd = [labels_odd;data.labels(i)];
        end
    end

end

%Legend
if ~isempty(lines_odd) && ~isempty(lines_even)
    leg1 = legend(ax,lines_odd,labels_odd,'Visible','on','Tag','Legend','Units','characters','Box','off');
    ah = axes('Parent',handles.DisplayPanel,'Position',ax.Position,'Visible','off');
    leg2 = legend(ah,lines_even,labels_even,'Visible','on','Tag','Legend','Units','characters','Box','off');
    %Legend Position
    handles.DisplayPanel.Units = 'characters';
    ax.Units ='characters';
    pos1 = handles.DisplayPanel.Position;
    pos2 = ax.Position;
    leg1.Position = [pos2(1)+pos2(3)+.5*(pos1(3)-pos2(1)-pos2(3)) pos2(2)+.1*pos2(4) .5*(pos1(3)-pos2(1)-pos2(3)) .8*pos2(4)];
    leg2.Position = [pos2(1)+pos2(3) pos2(2)+.1*pos2(4) .5*(pos1(3)-pos2(1)-pos2(3)) .8*pos2(4)];
    handles.DisplayPanel.Units = 'normalized';
    ax.Units ='normalized';
    leg1.Units = 'normalized';
    leg2.Units ='normalized';
end

% Whole trace
if ind_whole >0
    %uistack(l(ind_whole),'top');
    line('Xdata',data.ref_time,'Ydata',data.Ydata(ind_whole,:),'Parent',ax,...
        'Tag','line_region','Color','k','LineWidth',2);
end
%limits
if ~isempty(data.ref_time)
    ax.XLim = [data.ref_time(1),data.ref_time(end)];
    m = min(min(data.Ydata,[],1,'omitnan'),[],2,'omitnan');
    M =  max(max(data.Ydata,[],1,'omitnan'),[],2,'omitnan');
    ax.YLim = [m M];
else 
    m=0;
    M=1;
end

%Surges
if exist(fullfile(DIR_SAVE,data.parent,'Time_Surges.mat'),'file')
    t_surges = load(fullfile(DIR_SAVE,data.parent,'Time_Surges.mat'),'T_whole_strings');
    s_start = datenum(t_surges.T_whole_strings(:,1));
    s_start = (s_start-floor(s_start))*24*3600;
    s_end = datenum(t_surges.T_whole_strings(:,2));
    s_end = (s_end-floor(s_end))*24*3600;
    for i =1:size(t_surges.T_whole_strings)
        line('XData',[s_start(i) s_end(i)],'YData',.95*[M M],'Parent',ax,...
            'Linewidth',1,'Color','k','Tag','S_bar');
    end
end

% test if data.s is empty;
ind_keep = [];
for k=1:size(data.s,2);
    if ~isempty(data.s(k).Y_trace)
        ind_keep = [ind_keep;k];
    end
end
n = length(ind_keep);
data.s = data.s(ind_keep);
% return if n ==0;
if n==0
    return
end

% Traces
for i =1:n
    ax = axes('Parent',handles.DisplayPanel,'Position',[ax1_margin margin_up+1-ratio_main_ax/N+1/N-2*i/N+margin ax1_length 1/N-2*margin],'Tag','Ax_Trace');
    ax.YLabel.String = data.s(i).trace_name;
    line('XData',data.s(i).X_trace,'YData',data.s(i).Y_trace,'Parent',ax,...
        'HitTest','off','Tag','Trace','Color','k');
    line('XData',data.s(i).X_phase,'YData',data.s(i).Y_phase,'Parent',ax,...
        'HitTest','off','Tag','Phase','Color',[.5 .5 .5]);
    ax.XLim = [data.s(i).X_trace(1) data.s(i).X_trace(end)];
    ax.YLim = [min(data.s(i).Y_trace) max(data.s(i).Y_trace)];
end

% Spectro
for i =1:n
    ax = axes('Parent',handles.DisplayPanel,'Position',[ax2_margin margin_up+1-ratio_main_ax/N+1/N-2*i/N+margin ax2_length 1/N-2*margin],'Tag','Ax_Spectro');
    l = line('XData',mean(data.s(i).Cdata_sub,2),'YData',data.s(i).freqdom,'Parent',ax,...
        'HitTest','off','Tag','Spectro','Color','k');
    ax.XLim = [0, 1.1*max(l.XData)];
    ax.YLim = [data.s(i).freqdom(1) data.s(i).freqdom(end)];
end

% Wavelet Cdata_sub
for i =1:n
    ax = axes('Parent',handles.DisplayPanel,'Position',[ax1_margin margin_up+1-ratio_main_ax/N-2*i/N+margin ax1_length 1/N-2*margin]);
    ax.YLabel.String = data.s(i).trace_name;
    correction = repmat(data.s(i).freqdom(:),1,size(data.s(i).Cdata_sub,2));
    %Gaussian smoothing
    step = round(.5/(data.s(i).Xdata_sub(2)-data.s(i).Xdata_sub(1)));
    Cdata_smooth = imgaussfilt(data.s(i).Cdata_sub,[1 step]);
    % Log correction
    if handles.Checkbox4.Value
        im = imagesc(Cdata_smooth.*correction,'XData',data.s(i).Xdata_sub,'YData',data.s(i).freqdom,...
            'Parent',ax,'HitTest','off','Tag','Image');
    else
        im = imagesc(Cdata_smooth,'XData',data.s(i).Xdata_sub,'YData',data.s(i).freqdom,...
            'Parent',ax,'HitTest','off','Tag','Image');
    end
    ax.Tag = 'Ax_Wavelet';
    % Ax limits
    factor = str2double(handles.EditAutoscale.String);
    ax.XLim = [data.s(i).X_trace(1) data.s(i).X_trace(end)];
    ax.YLim = [data.s(i).freqdom(1) data.s(i).freqdom(end)];
    ax.CLim = [0 factor*mean(mean(im.CData,1),2)];
    ax.YDir = 'normal';
    c =colorbar(ax,'Tag',sprintf('Colorbar%d',i));
    c.Position = [ax1_margin+ax1_length+margin margin_up+1-ratio_main_ax/N-2*i/N+margin w_colorbar 1/N-2*margin];
    
    % Log scale
    if handles.Checkbox5.Value
        ax.YScale = 'log';
        C = im.CData;
        [X2,Y2] = meshgrid(data.s(i).Xdata_sub,data.s(i).freqdom);
        C_log = interp2(X2,Y2,flipud(C),X2,log(Y2)*max(data.s(i).freqdom)/log(max(data.s(i).freqdom)));
        im.CData = flipud(C_log);
    end
end

% Wavelet Cdata_phase
for i =1:n
    ax = axes('Parent',handles.DisplayPanel,'Position',[ax2_margin margin_up+1-ratio_main_ax/N-2*i/N+margin ax2_length 1/N-2*margin]);
    Cdata_phase = data.s(i).Cdata_phase_ascend;
    %Cdata_phase = data.s(i).Cdata_phase_descend;
    correction = repmat(data.s(i).freqdom(:),1,size(Cdata_phase,2));
    if handles.Checkbox4.Value
        im = imagesc(Cdata_phase.*correction,'XData',data.s(i).bins(1:end-1)+0.5*data.s(i).delta_d,...
            'YData',data.s(i).freqdom,'Parent',ax,'HitTest','off','Tag','Image');
    else
        im = imagesc(Cdata_phase,'XData',data.s(i).bins(1:end-1)+0.5*data.s(i).delta_d,...
            'YData',data.s(i).freqdom,'Parent',ax,'HitTest','off','Tag','Image');
    end
    ax.Tag = 'Ax_Phase';
    ax.CLim = [min(min(im.CData)) max(max(im.CData))];
    ax.XLim = [data.s(i).bins(1) data.s(i).bins(end)];
    ax.YLim = [data.s(i).freqdom(1) data.s(i).freqdom(end)];
    ax.YTickLabel ='';
    ax.YDir = 'normal';
    c =colorbar(ax,'Tag',sprintf('Colorbar%d',i));
    c.Position = [.96 margin_up+1-ratio_main_ax/N-2*i/N+margin w_colorbar 1/N-2*margin];
end

checkbox1_Callback(handles.Checkbox1,[],handles);
checkbox2_Callback(handles.Checkbox2,[],handles);
checkbox3_Callback(handles.Checkbox3,[],handles);

% Linkaxes
all_axes_x = findobj(handles.MainFigure,'Tag','Ax','-or','Tag','Ax_Wavelet','-or','Tag','Ax_Trace');
linkaxes(all_axes_x,'x');
all_axes_y = findobj(handles.MainFigure,'Tag','Ax_Wavelet','-or','Tag','Ax_Phase','-or','Tag','Ax_Spectro');
linkaxes(all_axes_y,'y');

%Axis control
ax = findobj(handles.MainFigure,'Tag','Ax_Wavelet');
ax=ax(1);
handles.Edit1.Callback = {@update_yaxis,ax,1};
handles.Edit2.Callback = {@update_yaxis,ax,2};
update_yaxis([handles.Edit1,handles.Edit2],[],ax);

end

function checkbox1_Callback(hObj,~,handles)
% Display trace

t = findobj(handles.MainFigure,'Tag','Trace');
if hObj.Value
    for i =1:length(t)
        t(i).Visible ='on';
    end
else
    for i =1:length(t)
        t(i).Visible ='off';
    end
end

end

function checkbox2_Callback(hObj,~,handles)
% Display filtered signal

t = findobj(handles.MainFigure,'Tag','Phase');
if hObj.Value
    for i =1:length(t)
        t(i).Visible ='on';
    end
else
    for i =1:length(t)
        t(i).Visible ='off';
    end
end
end

function checkbox3_Callback(hObj,~,handles)

ax = findobj(handles.MainFigure,'Tag','Ax');
im = findobj(ax,'Tag','Image');
labels = im.UserData.labels;
Ydata = im.UserData.Ydata;
l = findobj(ax,'Tag','line_region');
leg = findobj(handles.MainFigure,'Type','legend');

if hObj.Value
    % Image Display
    im.Visible = 'on';
    for i=1:length(l)
        l(i).Visible = 'off';
    end
    %Labels
    ax.YTick = 1:length(labels);
    ax.YTickLabel = labels;
    %limits
    ax.YDir = 'reverse';
    ax.XLim = [im.XData(1),im.XData(end)];
    ax.YLim = [im.YData(1)-.5,im.YData(end)+.5];
    ax.CLim = [min(min(Ydata,[],1,'omitnan'),[],2,'omitnan') max(max(Ydata,[],1,'omitnan'),[],2,'omitnan')];
    %legends
    for i=1:length(leg)
        leg(i).Visible = 'off';
    end
else
    % Line Display
    im.Visible = 'off';
    m = [];
    for i=1:length(l)
        l(i).Visible = 'on';
        m = [m;min(l(i).YData),max(l(i).YData)];
    end
    %Labels
    ax.YTickLabelMode = 'auto';
    %limits
    ax.YDir = 'normal';
    ax.XLim = [l(1).XData(1),l(1).XData(end)];
    ax.YLim = [min(min(m)), max(max(m))];
    %legends
    for i=1:length(leg)
        leg(i).Visible = 'on';
    end
end

end
