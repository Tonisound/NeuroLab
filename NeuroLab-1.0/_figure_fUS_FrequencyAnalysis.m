 function f2 = figure_fUS_FrequencyAnalysis(handles)
% Time Tag Selection Callback

global DIR_SAVE FILES CUR_FILE START_IM END_IM LAST_IM;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell');
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'time_ref','n_burst','length_burst');
catch
    errordlg(sprintf('Missing File Time_Tags.mat or Time_Reference.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end


f2 = figure('Units','characters',...
    'HandleVisibility','callback',...
    'IntegerHandle','off',...
    'Renderer','painters',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Tag','MainFigure',...
    'PaperPositionMode','auto',...
    'Name','fUS Fourier Analysis');
clrmenu(f2);
colormap(f2,'jet');

% Information Panel
iP = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','InfoPanel',...
    'Position',[0 .1 1 .9],...
    'Parent',f2);

uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('File : %s',FILES(CUR_FILE).gfus),'Tag','Text1');
uicontrol('Units','characters','Style','text','HorizontalAlignment','left','Parent',iP,...
    'String',sprintf('Source : %s',handles.CenterPanelPopup.String(handles.CenterPanelPopup.Value,:)),...
    'Tag','Text2');
%uicontrol('Units','characters','Style','popupmenu','Parent',iP,'String','<0>','Tag','Popup1');

uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','# Channels','Parent',iP,'String',1,'Tag','Edit3');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','# Spectrograms','Parent',iP,'String',1,'Tag','Edit4');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','Upper margin (%)','Parent',iP,'String',.1,'Tag','Edit5');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','Upper button Size (%)','Parent',iP,'String',.05,'Tag','Edit6');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','Lower margin (%)','Parent',iP,'String',.1,'Tag','Edit7');
uicontrol('Units','characters','Style','edit','HorizontalAlignment','center',...
    'Tooltipstring','Lower button Size (%)','Parent',iP,'String',.05,'Tag','Edit8');

e1 = uicontrol('Units','characters',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','Start Time',...
    'String',datestr(0/(24*3600),'HH:MM:SS.FFF'),...
    'Parent',iP,...
    'Tag','Edit1');
e2 = uicontrol('Units','characters',...
    'Style','edit',...
    'HorizontalAlignment','center',...
    'Tooltipstring','End Time',...
    'String',datestr(0,'HH:MM:SS.FFF'),...
    'Parent',iP,...
    'Tag','Edit2');
e1.String = handles.TimeDisplay.UserData(START_IM,:);
e2.String = handles.TimeDisplay.UserData(END_IM,:);

%Copying Buttons from Main Panel
copyobj(handles.PlusButton,iP);
copyobj(handles.MinusButton,iP);
copyobj(handles.SkipButton,iP);
copyobj(handles.BackButton,iP);
copyobj(handles.nextTagButton,iP);
copyobj(handles.prevTagButton,iP);
cp = copyobj(handles.RescaleButton,iP);
cp.UserData.str1 = handles.TimeDisplay.UserData(1,:);
cp.UserData.str2 = handles.TimeDisplay.UserData(end,:);
copyobj(handles.TagButton,iP);

uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Reset','Tag','ButtonReset');
bc = uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Compute','Tag','ButtonCompute');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','AutoScale','Tag','ButtonAutoScale');
uicontrol('Units','characters','Style','pushbutton','Parent',iP,...
    'String','Save','Tag','ButtonSave');

uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'TooltipString','Auto/Manual Scaling','Tag','BoxAuto','Value',1);
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'TooltipString','Hide/show lines','Tag','BoxLine','Value',1);
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'TooltipString','Hide/show spectrum','Tag','BoxSpectrum','Value',0);
uicontrol('Units','characters','Style','checkbox','Parent',iP,...
    'TooltipString','Multiply by n','Tag','BoxMultiply','Value',0);

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
    'Title','Traces',...
    'Tag','TraceTab');

% First tab
tab1 = uitab('Parent',tabgp,...
    'Title','Fourier',...
    'Units','normalized',...
    'Tag','FourierTab');
tfp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','TopFirstPanel',...
    'Parent',tab1);
uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','BotFirstPanel',...
    'Parent',tab1);

% Second tab
tab2 = uitab('Parent',tabgp,...
    'Title','Correlation',...
    'Units','normalized',...
    'Tag','CorrelationTab');
tsp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','TopSecondPanel',...
    'Parent',tab2);
uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','BotSecondPanel',...
    'Parent',tab2);

% Third tab
tab3 = uitab('Parent',tabgp,...
    'Title','Coherence',...
    'Units','normalized',...
    'Tag','CoherenceTab');
ttp = uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','TopThirdPanel',...
    'Parent',tab3);
uipanel('FontSize',12,...
    'Units','normalized',...
    'Tag','BotThirdPanel',...
    'Parent',tab3);

% Lines Array
m = findobj(handles.RightAxes,'Tag','Trace_Mean');
l = flipud(findobj(handles.RightAxes,'Tag','Trace_Region'));
u = flipud(findobj(handles.RightAxes,'Tag','Trace_Pixel'));
v = flipud(findobj(handles.RightAxes,'Tag','Trace_Box'));
t = flipud(findobj(handles.RightAxes,'Tag','Trace_Cerep'));

% Sorting Trace_Cerep
t1 = [];
t2 = [];
for i =1:length(t)
    if strcmp(t(i).UserData.Name(1:min(4,end)),'fUS/')
        t2 = [t2;t(i)];
    else
        t1 = [t1;t(i)];
    end
end

lines_1 = [m;l];
lines_2 = [u;v];
lines_3 = t1;
lines_4 = flipud(t2);
%lines = [lines_1;lines_3];

bc.UserData.lines_1 = lines_1;
bc.UserData.lines_2 = lines_2;
bc.UserData.lines_3 = lines_3;
bc.UserData.lines_4 = lines_4;

%Regions Panel
rPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[0 0 .25 1],...
    'Title','Regions',...
    'Tag','RegionPanel');
% Table Data
D={'Whole', m.Tag};
for i =2:length(lines_1)
    D=[D;{lines_1(i).UserData.Name,lines_1(i).Tag}];
end
rt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data',D,...
    'Position',[0 0 1 1],...
    'Tag','Region_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',rPanel);
rt.UserData.Selection = [];

%Pixel Panel
pPanel = uipanel('FontSize',10,...
    'Units','normalized',...
    'Position',[.25 0 .25 1],...
    'Title','Pixels and Boxes',...
    'Tag','Pixel_Panel',...
    'Parent',tab0);
% Table Data
D={};
for i =1:length(lines_2)
    D=[D;{lines_2(i).UserData.Name, lines_2(i).Tag}];
end
% UiTable
pt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{70 70},...
    'Position',[0 0 1 1],...
    'Data',D,...
    'Tag','Pixel_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',pPanel);
pt.UserData.Selection = [];

%Trace Panel
tPanel = uipanel('Parent',tab0,...
    'Units','normalized',...
    'Position',[.5 0 .25 1],...
    'Title','Traces',...
    'Tag','TracePanel');
% Table Data
D={};
for i =1:length(lines_3)
    D=[D;{lines_3(i).UserData.Name, lines_3(i).Tag}];
end
tt = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char'},...
    'ColumnEditable',[false,false],...
    'ColumnWidth',{120 120},...
    'Data',D,...
    'Position',[0 0 1 1],...
    'Tag','Trace_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',tPanel);
tt.UserData.Selection = [];

%fUS Panel
fPanel = uipanel('FontSize',10,...
    'Units','normalized',...
    'Position',[.75 0 .25 1],...
    'Title','fUS (Spiko)',...
    'Tag','fUS_Panel',...
    'Parent',tab0);
% Table Data
D={};
for i =1:length(lines_4)
    D=[D;{lines_4(i).UserData.Name, lines_4(i).Tag}];
end
% UiTable
ft = uitable('Units','normalized',...
    'ColumnName','',...
    'RowName',{},...
    'ColumnFormat',{'char','char','char'},...
    'ColumnEditable',[false,false,false],...
    'ColumnWidth',{70 70 70},...
    'Position',[0 0 1 1],...
    'Data',D,...
    'Tag','fUS_table',...
    'CellSelectionCallback',@template_uitable_select,...
    'RowStriping','on',...
    'Parent',fPanel);
ft.UserData.Selection = [];

% Loading Time Reference
try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'time_ref','n_burst','length_burst');
    tfp.UserData.time_ref = time_ref;
    tfp.UserData.n_burst = n_burst;
    tfp.UserData.length_burst = length_burst;
    tsp.UserData = tfp.UserData;
    ttp.UserData = tfp.UserData;
catch
    fprintf('(Warning) Missing Reference Time File (%s)\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus));
    tfp.UserData.time_ref = [];
    tfp.UserData.n_burst = 1;
    tfp.UserData.length_burst = LAST_IM;
    tsp.UserData = tfp.UserData;
    ttp.UserData = tfp.UserData;
end

resetbutton_Callback([],[],guihandles(f2),handles);
set(f2,'Position',[30 30 200 60]);
tabgp.SelectedTab = tab0;

end

function resize_Figure(~,~,handles)
% Main Figure resize function

fpos = get(handles.MainFigure,'Position');
channels = str2double(handles.Edit3.String);
spectrum  = str2double(handles.Edit4.String);
N = channels+spectrum;

handles.InfoPanel.Position = [0 0 fpos(3) fpos(4)/10];
handles.TopFirstPanel.Position = [0 spectrum/N 1 channels/N];
handles.BotFirstPanel.Position = [0 0 1 spectrum/N];
handles.TopSecondPanel.Position = [0 spectrum/N 1 channels/N];
handles.BotSecondPanel.Position = [0 0 1 spectrum/N];
handles.TopThirdPanel.Position = [0 spectrum/N 1 channels/N];
handles.BotThirdPanel.Position = [0 0 1 spectrum/N];

end

function resize_InfoPanel(hObj,~,handles)

%box_size = .03;
ipos = get(hObj,'Position');
handles.Text1.Position = [ipos(3)/200     6*ipos(4)/10-.5    ipos(3)/4   ipos(4)/3];
handles.Text2.Position= [ipos(3)/200     .25    ipos(3)/4   ipos(4)/3];
%handles.Popup1.Position= [0     .25    ipos(3)/2   ipos(4)/4];

handles.Edit1.Position = [ipos(3)/4     2.75*ipos(4)/5   ipos(3)/8   ipos(4)/3];
handles.Edit2.Position = [ipos(3)/4     ipos(4)/10           ipos(3)/8   ipos(4)/3];
handles.Edit3.Position = [6.6*ipos(3)/10     2.75*ipos(4)/5   4*ipos(3)/100   ipos(4)/3];
handles.Edit4.Position = [6.6*ipos(3)/10     ipos(4)/10       4*ipos(3)/100   ipos(4)/3];
handles.Edit5.Position = [7*ipos(3)/10       2.75*ipos(4)/5   4*ipos(3)/100   ipos(4)/3];
handles.Edit6.Position = [7.4*ipos(3)/10     2.75*ipos(4)/5     4*ipos(3)/100   ipos(4)/3];
handles.Edit7.Position = [7*ipos(3)/10       ipos(4)/10         4*ipos(3)/100   ipos(4)/3];
handles.Edit8.Position = [7.4*ipos(3)/10     ipos(4)/10         4*ipos(3)/100   ipos(4)/3];

handles.PlusButton.Position = [4*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.MinusButton.Position = [4*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];
handles.SkipButton.Position = [4.5*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.BackButton.Position = [4.5*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];
handles.nextTagButton.Position = [5*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.prevTagButton.Position = [5*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];
handles.RescaleButton.Position = [5.5*ipos(3)/10     ipos(4)/2-.25   ipos(3)/20   ipos(4)/2];
handles.TagButton.Position = [5.5*ipos(3)/10     0   ipos(3)/20   ipos(4)/2];

handles.ButtonReset.Position =      [8*ipos(3)/10+1     ipos(4)/2-.25     ipos(3)/10-1   ipos(4)/2];
handles.ButtonCompute.Position =    [8*ipos(3)/10+1     0                 ipos(3)/10-1   ipos(4)/2];
handles.ButtonSave.Position =      [9*ipos(3)/10     0                 ipos(3)/10-1   ipos(4)/2];
handles.ButtonAutoScale.Position =       [9*ipos(3)/10     ipos(4)/2-.25     ipos(3)/10-1   ipos(4)/2];

handles.BoxLine.Position =          [7.85*ipos(3)/10     3*ipos(4)/4        ipos(3)/60   ipos(4)/4];
handles.BoxSpectrum.Position =      [7.85*ipos(3)/10     2*ipos(4)/4        ipos(3)/60   ipos(4)/4];
handles.BoxMultiply.Position =      [7.85*ipos(3)/10     ipos(4)/4          ipos(3)/60   ipos(4)/4];
handles.BoxAuto.Position =          [7.85*ipos(3)/10     0                ipos(3)/60   ipos(4)/4];

end

function initialize_TopPanel(handles,old_handles)

channels = str2double(handles.Edit3.String);
margin = str2double(handles.Edit5.String);
w_button = str2double(handles.Edit6.String);
lines = findobj(old_handles.RightAxes,'Type','line','-not','Tag','Cursor');
text = findobj(old_handles.RightAxes,'Type','text');
all_obj = flipud([lines;text]);
panels = [handles.TopFirstPanel,handles.TopSecondPanel,handles.TopThirdPanel];

for k=1:length(panels)
    % Adjusting Time Reference
    length_burst = panels(k).UserData.length_burst;
    n_burst = panels(k).UserData.n_burst;
    xdat = [reshape(panels(k).UserData.time_ref.Y,[length_burst,n_burst]);NaN(1,n_burst)];
    
    % Axes
    l = length(findobj(panels(k),'Type','axes'));
    if l>channels
        %delete
        for i=channels+1:l
            delete(findobj(panels(k),'Tag',sprintf('Ax%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('Button%d',i)));
        end
    elseif l<channels
        %create
        for i=l+1:channels
            ax = axes('Parent',panels(k),'Tag',sprintf('Ax%d',i));
            ax.YLabel.String = sprintf('Ax%d',i);
            %ax.YLabel.Rotation = 0;
            ax.XLim = [0 10000];
            % button trace
            for j = 1:length(all_obj)
                l = copyobj(all_obj(j),ax);
                if strcmp(l.Tag,'Trace_Cerep')
                    set(l,'XData',l.UserData.X,'YData',l.UserData.Y)
                elseif strcmp(l.Type,'line')
                    l.XData = xdat(:);
                end
            end
            button = copyobj(old_handles.TracesButton,panels(k));
            button.Units = 'normalized';
            button.Tag = sprintf('Button%d',i);
            button.TooltipString = sprintf('Traces Edition Ax%d',i);
            button.Callback = {@menuTraces_Edition_Callback,ax,old_handles};
        end
    end
    % Axes Position
    all_axes = findobj(panels(k),'Type','axes');
    for i=1:length(all_axes)
        ax = findobj(panels(k),'Tag',sprintf('Ax%d',i));
        button = findobj(panels(k),'Tag',sprintf('Button%d',i));
        ax.Position = [.05 (i-1)/channels+margin .9 1/channels-2*margin];
        button.Position = [0 i/channels-w_button .025 w_button];     
    end
 
end

end

function initialize_BotPanel(handles)

channels = str2double(handles.Edit4.String);
margin = str2double(handles.Edit7.String);
w_button = str2double(handles.Edit8.String);
panels = [handles.BotFirstPanel,handles.BotSecondPanel,handles.BotThirdPanel];

for k=1:length(panels)
    % Axes
    l = length(findobj(panels(k),'Type','axes'));
    if l>channels
        %delete
        for i=channels+1:l
            delete(findobj(panels(k),'Tag',sprintf('Ax%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('Button%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('cmin_%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('cmax_%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('fc_%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('fb_%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('fmin_%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('fstep_%d',i)));
            delete(findobj(panels(k),'Tag',sprintf('fmax_%d',i)));
        end
    elseif l<channels
        %create
        for i=l+1:channels
            ax = axes('Parent',panels(k),'Tag',sprintf('Ax%d',i));
            ax.YLabel.String = sprintf('Ax%d',i);
            ax.XLim = [0 10000];
            set(ax,'Ydir','normal');
            c = colorbar(ax,'Tag',sprintf('Colorbar%d',i));
            uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',panels(k),...
                'String',c.Limits(1),'Tag',sprintf('cmin_%d',i),'Callback', {@update_caxis,ax,c,1},'Tooltipstring',sprintf('Colormin %d',i));
            uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',panels(k),...
                'String',c.Limits(2),'Tag',sprintf('cmax_%d',i),'Callback', {@update_caxis,ax,c,2},'Tooltipstring',sprintf('Colormax %d',i));
            uicontrol('Units','normalized','Style','popupmenu','HorizontalAlignment','center','Parent',panels(k),...
                'String','.','Tag',sprintf('Popup%d',i),'Tooltipstring',sprintf('Trace Selection %d',i));
            uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',panels(k),...
                'String','','Tag',sprintf('fc_%d',i),'Tooltipstring','');
            uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',panels(k),...
                'String','','Tag',sprintf('fb_%d',i),'Tooltipstring','');
            uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',panels(k),...
                'String','','Tag',sprintf('fmin_%d',i),'Tooltipstring','');
            uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',panels(k),...
                'String','','Tag',sprintf('fstep_%d',i),'Tooltipstring','');
            uicontrol('Units','normalized','Style','edit','HorizontalAlignment','center','Parent',panels(k),...
                'String','','Tag',sprintf('fmax_%d',i),'Tooltipstring','');
        end
    end
    
    % Axes Position
    all_axes = findobj(panels(k),'Type','axes');
    
    for i=1:length(all_axes)
        cla(all_axes(i));
        ax = findobj(panels(k),'Tag',sprintf('Ax%d',i));
        c = findobj(panels(k),'Tag',sprintf('Colorbar%d',i));
        b1 = findobj(panels(k),'Tag',sprintf('cmin_%d',i));
        b2 = findobj(panels(k),'Tag',sprintf('cmax_%d',i));
        ax.Position = [.05 (i-1)/channels+margin/2 .9 1/channels-margin];
        c.Position = [.96 (i-1)/channels+w_button+.01 .015 1/channels-2*(w_button+.01)];
        c.Limits= [0 1];
        b1.Position = [.96 (i-1)/channels .03 w_button];
        b2.Position = [.96 i/channels-w_button .03 w_button];
        
        b1 = findobj(panels(k),'Tag',sprintf('fc_%d',i));
        b2 = findobj(panels(k),'Tag',sprintf('fb_%d',i));
        p1 = findobj(panels(k),'Tag',sprintf('Popup%d',i));
        b3 = findobj(panels(k),'Tag',sprintf('fmin_%d',i));
        b4 = findobj(panels(k),'Tag',sprintf('fstep_%d',i));
        b5 = findobj(panels(k),'Tag',sprintf('fmax_%d',i));
        p1.Position = [.03 i/channels-w_button/2 .03 w_button/2];
        b1.Position = [.005 i/channels-w_button .03 w_button];
        b2.Position = [.005 i/channels-2*w_button .03 w_button];
        b3.Position = [.005 (i-1)/channels .03 w_button];
        b4.Position = [.005 (i-1)/channels+w_button .03 w_button];
        b5.Position = [.005 (i-1)/channels+2*w_button .03 w_button];
        
        if panels(k)==handles.BotFirstPanel
            b1.TooltipString = sprintf('Subsampling Factor %d',i);
            b1.String = 2;
            b2.Visible='off';
            b2.TooltipString = sprintf('%d',i);
            b3.String=24;
            b3.TooltipString = sprintf('window %d',i);
            b4.String=23;
            b4.TooltipString = sprintf('noverlap %d',i);
            b5.String=200;
            b5.TooltipString = sprintf('nfft %d',i);
        elseif panels(k)==handles.BotSecondPanel
            b1.TooltipString = sprintf('Subsampling Factor %d',i);
            b1.String = 2;
            b2.TooltipString = sprintf('%d',i);
            b2.Visible='off';
            b3.TooltipString = sprintf('noverlap %d',i);
            b3.String = 24;
            b4.TooltipString = sprintf('nfft %d',i);
            b4.String = 23;
            b5.TooltipString = sprintf('%d',i);
            b5.Visible='off';
        elseif panels(k)==handles.BotThirdPanel
            b1.TooltipString = sprintf('Subsampling Factor %d',i);
            b1.String = 2;
            b2.TooltipString = sprintf('Reference channel %d',i);
            b2.String=i;
            b3.String=24;
            b3.TooltipString = sprintf('window %d',i);
            b4.String=23;
            b4.TooltipString = sprintf('noverlap %d',i);
            b5.String=200;
            b5.TooltipString = sprintf('nfft %d',i);
        end
    end
end

end

function resetbutton_Callback(~,~,handles,old_handles)

initialize_TopPanel(handles,old_handles);
initialize_BotPanel(handles);
handles = guihandles(handles.MainFigure);

% Resize Function Attribution
set(handles.MainFigure,'ResizeFcn',{@resize_Figure,handles});
set(handles.InfoPanel,'ResizeFcn',{@resize_InfoPanel,handles});
% Callback function Attribution
set(handles.ButtonReset,'Callback',{@resetbutton_Callback,handles,old_handles});
set(handles.ButtonCompute,'Callback',{@compute_Callback,handles});
set(handles.ButtonAutoScale,'Callback',{@autoscale_Callback,handles});
set(handles.BoxLine,'Callback',{@boxline_Callback,handles});
set(handles.BoxSpectrum,'Callback',{@boxspectrum_Callback,handles});
% set(handles.ButtonSave,'Callback',{@save_Callback,handles,n_burst,length_burst});

%Interactive Control
all_axes = findobj(handles.MainFigure,'Type','axes');
for k=1:length(all_axes)
    set(all_axes(k),'ButtonDownFcn',{@template_axes_clickFcn,1,[],[handles.Edit1,handles.Edit2]});
end
set(handles.Edit1,'Callback',{@edit_Callback,all_axes});
set(handles.Edit2,'Callback',{@edit_Callback,all_axes});
%edit_Callback(handles.Edit1,[],all_axes);
%edit_Callback(handles.Edit2,[],all_axes);$
edit_Callback([handles.Edit1,handles.Edit2],[],all_axes);

%Interactive Control
edits = [handles.Edit1;handles.Edit2];
% set(handles.MainFigure,'KeyPressFcn',{@cfc_keypressFcn,handles});
set(handles.PlusButton,'Callback',{@template_buttonPlus_Callback,all_axes,edits});
set(handles.MinusButton,'Callback',{@template_buttonMinus_Callback,all_axes,edits});
set(handles.SkipButton,'Callback',{@template_buttonSkip_Callback,all_axes,edits});
set(handles.BackButton,'Callback',{@template_buttonBack_Callback,all_axes,edits});
set(handles.RescaleButton,'Callback',{@buttonRescale_Callback,all_axes,edits});
set(handles.TagButton,'Callback',{@button_TagSelection_Callback,all_axes,edits});
set(handles.prevTagButton,'Callback',{@template_prevTag_Callback,handles.TagButton,all_axes,edits});
set(handles.nextTagButton,'Callback',{@template_nextTag_Callback,handles.TagButton,all_axes,edits});

% Figure Resizing
resize_Figure(0,0,handles);

end

function compute_Callback(hObj,~,handles)

global DIR_SAVE FILES CUR_FILE;
load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Reference.mat'),'time_ref','n_burst','length_burst');

% Pointer Watch
set(handles.MainFigure, 'pointer', 'watch');
drawnow;

lines_1 = hObj.UserData.lines_1;
lines_2 = hObj.UserData.lines_2;
%lines_3 = hObj.UserData.lines_3;
%lines_4 = hObj.UserData.lines_4;

% Time Selection
a = datenum(handles.Edit1.String);
b = datenum(handles.Edit2.String);
Time_indices = [(a-floor(a))*24*3600,(b-floor(b))*24*3600];
str = datestr((Time_indices(2)-Time_indices(1))/(24*3600),'HH:MM:SS.FFF');
Tag_Selection = {'CURRENT',handles.Edit1.String,str};

%Rdata = '';
Rdata = struct('ref_time',[],'f_samp',[],'Ydata',[],'Ydata_norm',[],'labels',[],'Title',[]);
% Region_Table
if ~isempty(handles.Region_table.UserData.Selection)
    % Extracting Regions
    ind_regions = handles.Region_table.UserData.Selection;
    Region_Selection = handles.Region_table.Data(ind_regions,:);
    
    lines = lines_1(ind_regions);
    % Building RData
    X = time_ref.Y;
    f_samp = 1./(X(2)-X(1));
    ind_keep = ((X-(Time_indices(1)-.001)).*(X-(Time_indices(2)+.001)))<0;
    ref_time = X(ind_keep);
    
    Ydata = NaN(length(ind_regions),length(ref_time));
    for k=1:length(ind_regions)
        Y = (lines(k).YData(~isnan(lines(k).YData)))';
        y = Y(ind_keep);
        Ydata(k,:)=y';
    end
    
    % Normalization
    M = repmat(mean(Ydata,2,'omitnan'),[1,length(ref_time)]);
    s = repmat(std(Ydata,[],2,'omitnan'),[1,length(ref_time)]);
    Ydata_norm = (Ydata-M)./s;
    
    % Saving data
    Rdata.Title = char(Tag_Selection(1));
    Rdata.labels = Region_Selection(:,1);
    Rdata.ref_time = ref_time;
    Rdata.f_samp = f_samp;
    Rdata.Ydata = Ydata;
    Rdata.Ydata_norm = Ydata_norm;
    % Storing Rdata
    hObj.UserData.Rdata = Rdata;
end
% Pixel_Table
% Pdata = '';
Pdata = struct('ref_time',[],'f_samp',[],'Ydata',[],'Ydata_norm',[],'labels',[],'Title',[]);   
if ~isempty(handles.Pixel_table.UserData.Selection)
    % Extracting Pixels
    ind_pixels = handles.Pixel_table.UserData.Selection;
    Pixel_Selection = handles.Pixel_table.Data(ind_pixels,:);
    lines = lines_2(ind_pixels);
    % Building RData
    X = time_ref.Y;
    f_samp = 1./(X(2)-X(1));
    ind_keep = ((X-(Time_indices(1)-.001)).*(X-(Time_indices(2)+.001)))<0;
    ref_time = X(ind_keep);
    
    Ydata = NaN(length(ind_pixels),length(ref_time));
    for k=1:length(ind_pixels)
        Y = (lines(k).YData(~isnan(lines(k).YData)))';
        y = Y(ind_keep);
        Ydata(k,:)=y';
    end
    
    % Normalization
    M = repmat(mean(Ydata,2,'omitnan'),[1,length(ref_time)]);
    s = repmat(std(Ydata,[],2,'omitnan'),[1,length(ref_time)]);
    Ydata_norm = (Ydata-M)./s;
    
    % Saving data
    Pdata.Title = char(Tag_Selection(1));
    Pdata.labels = Pixel_Selection(:,1);
    Pdata.ref_time = ref_time;
    Pdata.f_samp = f_samp;
    Pdata.Ydata = Ydata;
    Pdata.Ydata_norm = Ydata_norm;
    % Storing Pdata
    hObj.UserData.Pdata = Pdata;
end

data.Title = char(Tag_Selection(1));
data.labels = [Rdata.labels;Pdata.labels];
data.ref_time = ref_time;
data.f_samp = f_samp;
data.Ydata = [Rdata.Ydata;Pdata.Ydata];
data.Ydata_norm = [Rdata.Ydata_norm;Pdata.Ydata_norm];
hObj.UserData.data = data;


panels = [handles.BotFirstPanel,handles.BotSecondPanel,handles.BotThirdPanel];
for k=1:length(panels)
    % Axes
    N = length(findobj(panels(k),'Style','popupmenu'));
    for i=1:N
        %ax = findobj(panels(k),'Tag',sprintf('Ax%d',i));
        pu = findobj(panels(k),'Tag',sprintf('Popup%d',i));
        b1 = findobj(panels(k),'Tag',sprintf('fc_%d',i));
        b2 = findobj(panels(k),'Tag',sprintf('fb_%d',i));
        b3 = findobj(panels(k),'Tag',sprintf('fmin_%d',i));
        b4 = findobj(panels(k),'Tag',sprintf('fstep_%d',i));
        b5 = findobj(panels(k),'Tag',sprintf('fmax_%d',i));
        % Change Popup Strings
        if ~isempty(setdiff(pu.String,data.labels))
            pu.String = data.labels;
            pu.Value = i;
        end
        pu.UserData.correction = ''; %default
        %pu.UserData.data = data;
        
        switch panels(k)
            case handles.BotFirstPanel
                %Compute Spectrogram  
                nwin = str2double(b3.String);
                nlap = str2double(b4.String);
                nfft = str2double(b5.String);
                factor = str2double(b1.String);
                Cdata = [];
                for j =1:size(data.Ydata,1)
                    y = data.Ydata(j,1:factor:end);
                    %y_resamp = resample(y,round(100*f_int),round(100*f_samp));
                    %x_resamp = ref_time(1):1/f_int:ref_time(end);
                    %y_resamp = y_resamp(1:length(x_resamp));
                    [s,w,t] = spectrogram(y,kaiser(nwin,5),nlap,nfft,'yaxis');
                    im = abs(s);
                    Cdata = cat(3,Cdata,im);
                end
                
                leap = nwin-nlap;
                delta = floor(nwin/2);
                xdata = (1:factor*leap:size(Cdata,2)*factor*leap)+factor*delta;
                pu.UserData.Xdata = data.ref_time(xdata);
                ydata = (1/factor)*fliplr((data.f_samp/2)./(1:round(nfft/2)+1));
                pu.UserData.Ydata = ydata;
                correction = repmat(ydata(:),1,size(Cdata,2));
                pu.UserData.correction = correction/correction(1,1);
                
%                %Compute Wavelet
%                 fc = str2double(b1.String);     % Center Frequency
%                 fb = str2double(b2.String);     % Bandwidth
%                 freqdom = str2double(b3.String):str2double(b4.String):str2double(b5.String); % Frequency domain
%                 fs = data.f_samp;
%                 scales = fc*fs./freqdom;
%                 Cdata = NaN(length(freqdom),length(ref_time),size(data.Ydata,1));
%                 for j =1:size(data.Ydata,1)
%                     coefs_wav   = cmorcwt(data.Ydata(j,:),scales,fb,fc);
%                     Cdata(:,:,j) = log10(abs(coefs_wav)).^2;
%                 end
%                 pu.UserData.Delta = [0 1];

            case handles.BotSecondPanel,
                %Compute Correlation
                Cdata = [];
                factor = str2double(b1.String);
                nwin = str2double(b3.String);
                nlap = str2double(b4.String);
                
                for j =1:size(data.Ydata,1)
                    y = data.Ydata(j,1:factor:end);
                    y_others = [data.Ydata(1:j-1,1:factor:end);data.Ydata(j+1:end,1:factor:end)];
                    Corr=[];
                    for l=1:(nwin-nlap):length(y)-nwin+1
                        col = corr(y(l:l+nwin-1)',y_others(:,l:l+nwin-1)')';
                        Corr = [Corr,col];
                    end
                    Cdata = cat(3,Cdata,Corr);
                end
                leap = nwin-nlap;
                delta = floor(nwin/2);
                xdata = (1:factor*leap:size(Cdata,2)*factor*leap)+factor*delta;
                pu.UserData.Xdata = data.ref_time(xdata);
                pu.UserData.Ydata = 1:size(Cdata,1);
                %Cdata =flipud(Cdata);
                 
            case handles.BotThirdPanel,
                %Compute Coherence
                Cdata = [];
                factor = str2double(b1.String);
                index = str2double(b2.String);
                nwin = str2double(b3.String);
                nlap = str2double(b4.String);
                nfft = str2double(b5.String);

%                 y_ref = data.Ydata(index,1:factor:end);
%                 %y_others = [data.Ydata(1:j-1,1:factor:end);data.Ydata(j+1:end,1:factor:end)];
%                 for j=1:size(data.Ydata,1)
%                     y_others = data.Ydata(j,1:factor:end);
%                     Coher=[];
%                     for l=1:(nwin-nlap):length(y_others)-nwin+1
%                         x = y_ref(l:l+nwin-1)';
%                         y = y_others(l:l+nwin-1)';
%                         Cxy = mscohere(x,y,nwin,nlap,nfft);
%                         Coher = [Coher,Cxy];
%                     end
%                     Cdata = cat(3,Cdata,Coher);
%                 end
%                 leap = nwin-nlap;
%                 delta = floor(nwin/2);
%                 xdata = (1:factor*leap:size(Cdata,2)*factor*leap)+factor*delta;
%                 pu.UserData.Xdata = data.ref_time(xdata);
%                 ydata = (1/factor)*fliplr((data.f_samp/2)./(1:round(nfft/2)+1));
%                 pu.UserData.Ydata = ydata;
        end
        
        pu.UserData.Cdata = Cdata;
        pu.Callback={@update_popup,i,handles};
        update_popup(pu,[],i,handles);
    end
end

% Pointer Watch
if handles.TabGroup.SelectedTab == handles.TraceTab;
    handles.TabGroup.SelectedTab = handles.FourierTab;
end
set(handles.MainFigure, 'pointer', 'arrow');

end

function update_popup(hObj,~,i,handles)

if isempty(hObj.UserData.Cdata)
    return;
end
Cdata = hObj.UserData.Cdata(:,:,hObj.Value);
Xdata = hObj.UserData.Xdata;
Ydata = hObj.UserData.Ydata;
data = handles.ButtonCompute.UserData.data;

panel = hObj.Parent;
ax = findobj(panel,'Tag',sprintf('Ax%d',i));
c = findobj(panel,'Tag',sprintf('Colorbar%d',i));
cla(ax);

% Mutltiply by n if box checked
if handles.BoxMultiply.Value && ~isempty(hObj.UserData.correction)
    Cdata = Cdata.*hObj.UserData.correction;
end

% Main Tab
imagesc('XData',Xdata,...
    'YData',Ydata,...
    'CData',Cdata,...
    'HitTest','off',...
    'Tag','Image',...
    'Parent',ax)
title(ax,char(strtrim(hObj.String(hObj.Value,:))));
ax.YLim = [Ydata(1),Ydata(end)];
c.Limits = ax.CLim;
if hObj.Parent == handles.BotSecondPanel
    ax.YLim = [Ydata(1)-.5,Ydata(end)+.5];
    ax.YLabel.String = '';
    ax.YTick = Ydata;
    ax.YTickLabel = [data.labels(1:hObj.Value-1);data.labels(hObj.Value+1:end)];
    ax.TickLength = [0 0];
    ax.YDir = 'reverse';
end

% plot line
y = data.Ydata_norm(hObj.Value,:);
%ref_time = data.ref_time;
mu = (ax.YLim(2)+ax.YLim(1))/2;
span1 = ax.YLim(2)-mu;
span2 = max(abs(y));
y_rescale = .95*(span1/span2)*y +mu;
line('XData',data.ref_time,...
    'YData',y_rescale,...
    'HitTest','off',...
    'Tag','grayline',...
    'Color',[.5 .5 .5],...
    'LineWidth',2,...
    'Parent',ax)
boxline_Callback(handles.BoxLine,[],handles);

data = log(mean(Cdata,2));
data = (data-min(data))/(max(data)-min(data));
data = (ax.XLim(2)-ax.XLim(1))*data+ax.XLim(1);
if ~isempty(data)
    line('XData',data,...
        'YData',Ydata,...
        'HitTest','off',...
        'Tag','whiteline',...
        'Color','k',...
        'LineWidth',2,...
        'Parent',ax);
end
boxspectrum_Callback(handles.BoxSpectrum,[],handles);

% Adding colorbar to CenterAxes and TopAxes
% colorbar(handles.CenterAxes,'eastoutside','Tag','Colorbar','Visible','off');

b1 = findobj(panel,'Tag',sprintf('cmin_%d',i));
b2 = findobj(panel,'Tag',sprintf('cmax_%d',i));
    
if handles.BoxAuto.Value
    % Auto Scaling
    b1.String = sprintf('%.1f',c.Limits(1));
    b2.String = sprintf('%.1f',c.Limits(2));
else
    % Manual Scaling
    c_min = str2double(b1.String);
    c_max = str2double(b2.String);
    caxis(ax,[c_min c_max]);
    c.Limits = [c_min,c_max];
end

end

% function edit_Callback(hObj,~,ax)
% 
% A = datenum(hObj.String);
% B = (A - floor(A))*24*3600;
% hObj.String = datestr(B/(24*3600),'HH:MM:SS.FFF');
% 
% switch hObj.Tag
%     case 'Edit1',
%         for i=1:length(ax)
%             ax(i).XLim(1) = B;
%         end
%     case 'Edit2',
%         for i=1:length(ax)
%             ax(i).XLim(2) = B;
%         end
% end
% 
% end

function edit_Callback(hObj,~,ax)

if length(hObj)>1
    A = datenum(hObj(1).String);
    B1 = (A - floor(A))*24*3600;
    A = datenum(hObj(2).String);
    B2 = (A - floor(A))*24*3600;
    for i =1:length(ax)
        ax(i).XLim = [B1 B2];
    end
else
    A = datenum(hObj.String);
    B = (A - floor(A))*24*3600;
    hObj.String = datestr(B/(24*3600),'HH:MM:SS.FFF');
    
    switch hObj.Tag
        case 'Edit1',
            for i =1:length(ax)
                ax(i).XLim(1) = B;
            end
        case 'Edit2',
            for i =1:length(ax)
                ax(i).XLim(2) = B;
            end
    end
end

end

function update_caxis(hObj,~,ax,c,value)
switch value
    case 1,
        ax.CLim(1) = str2double(hObj.String);
    case 2,
        ax.CLim(2) = str2double(hObj.String);
end
c.Limits = ax.CLim;
end

function autoscale_Callback(~,~,handles)

spectrum = str2double(handles.Edit4.String);
panels = [handles.BotFirstPanel,handles.BotSecondPanel];
for k=1:length(panels)
    for i = 1:spectrum
        ax = findobj(panels(k),'Tag',sprintf('Ax%d',i));
        if isempty(ax)
            continue
        end
        c = findobj(panels(k),'Tag',sprintf('Colorbar%d',i));
        im = findobj(ax,'Tag','Image');
        
        % Searching local max and min for all images in axes
        % Storing in X (timing) and Y (values)
        X=[];
        Y=[];
        for kk=1:length(im)
            x_ind = max(ax.XLim(1),im(kk).XData(1));
            y_ind = min(ax.XLim(2),im(kk).XData(end));
            if y_ind>x_ind
                X = [X;x_ind y_ind];
                indexes = (im(kk).XData>=x_ind).*(im(kk).XData<=y_ind);
                temp = im(kk).CData(:,indexes==1);
                Y = [Y;min(min(temp,[],'omitnan'),[],'omitnan') max(max(temp,[],'omitnan'),[],'omitnan')];
            end
        end
        m = min(Y(:,1),[],'omitnan');
        M = max(Y(:,2),[],'omitnan');
        if m<M
            button3 = findobj(panels(k),'Tag',sprintf('cmin_%d',i));
            button4 = findobj(panels(k),'Tag',sprintf('cmax_%d',i));
            button3.String = sprintf('%.1f',m);
            button4.String = sprintf('%.1f',M);
            button3.Visible = 'on';
            button4.Visible = 'on';
            c.Limits = [m,M];
            ax.CLim = [m,M];
        end
    end
end

end

function boxspectrum_Callback(hObj,~,handles)

l = findobj(handles.MainFigure,'Tag','whiteline');
if hObj.Value
    for i = 1:length(l)
        l(i).Visible='on';
    end
else
    for i = 1:length(l)
        l(i).Visible='off';
    end
end

end

function boxline_Callback(hObj,~,handles)

l = findobj(handles.MainFigure,'Tag','grayline');
if hObj.Value
    for i = 1:length(l)
        l(i).Visible='on';
    end
else
    for i = 1:length(l)
        l(i).Visible='off';
    end
end

end

function buttonRescale_Callback(hObj,~,ax,edits)

str1 = hObj.UserData.str1;
str2 = hObj.UserData.str2;
A = datenum(str1);
xlim1 = (A - floor(A))*24*3600;
A = datenum(str2);
xlim2 = (A - floor(A))*24*3600;
for i=1:length(ax)
    ax(i).XLim =[xlim1,xlim2];
end
if nargin>3
    edits(1).String = datestr(xlim1/(24*3600),'HH:MM:SS.FFF');
    edits(2).String = datestr(xlim2/(24*3600),'HH:MM:SS.FFF');
end

end

function button_TagSelection_Callback(hObj,~,ax,edits)
% Time Tag Selection Callback

global DIR_SAVE FILES CUR_FILE;

try
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Time_Tags.mat'),'TimeTags_cell');
catch
    errordlg(sprintf('Missing File Time_Tags.mat %s',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus)));
    return;
end

if isempty(hObj.UserData)
    Selected = 1;
else
    Selected = hObj.UserData.Selected;
end

str_tag = arrayfun(@(i) strjoin(TimeTags_cell(i,2:4),' - '), 2:size(TimeTags_cell,1), 'unif', 0)';
[ind_tag,v] = listdlg('Name','Tag Selection','PromptString','Select Time Tags',...
    'SelectionMode','single','ListString',str_tag,...
    'InitialValue',Selected,'ListSize',[300 500]);
if v==0
    return;
elseif isempty(ind_tag)
    hObj.UserData='';
else
    hObj.UserData.Selected = ind_tag;
    min_time = char(TimeTags_cell(ind_tag+1,3));
    t_start = datenum(min_time);
    max_time_dur = char(TimeTags_cell(ind_tag+1,4));
    t_end = datenum(min_time)+datenum(max_time_dur);
    max_time = datestr(t_end,'HH:MM:SS.FFF');
    
    for i=1:length(ax)
        ax(i).XLim = [(t_start - floor(t_start))*24*3600,(t_end - floor(t_end))*24*3600];
        if strcmp(ax(i).Tag(1:3),'Ax1')
            ax(i).Title.String = sprintf('%s (Duration %s)',char(TimeTags_cell(ind_tag+1,2)),char(TimeTags_cell(ind_tag+1,4)));
        end
    end
    if nargin>3
        edits(1).String = min_time;
        edits(2).String = max_time;
    end
end

end