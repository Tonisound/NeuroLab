function success = detect_locomotion_events(folder_name,handles,val)
% Detect Locomotion Events from SPEED, X(m) and Y(m)

success = false;
load('Preferences.mat','GImport');

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin == 2
    val = 1;
end    

% Loading Time Reference
if exist(fullfile(folder_name,'Time_Reference.mat'),'file')
    data_tr = load(fullfile(folder_name,'Time_Reference.mat'));
else
    errordlg(sprintf('Missing Time Reference file [%s].',F.nlab));
    return;
end

% Loading Time Tags
if exist(fullfile(folder_name,'Time_Tags.mat'),'file')
    data_tt = load(fullfile(folder_name,'Time_Tags.mat'));
else
    warning(sprintf('Missing Time_Tags file [%s].',F.nlab));
    data_tt = [];
end

% Loading Speed and Position
if exist(fullfile(folder_name,'Sources_LFP','SPEED.mat'),'file')
    data_s = load(fullfile(folder_name,'Sources_LFP','SPEED.mat'));
    X_speed = (data_s.x_start:data_s.f:data_s.x_end)';
    Y_speed = data_s.Y(:);
    if length(Y_speed)==(length(X_speed)+1)
        Y_speed = Y_speed(2:end);
    end
else
    errordlg(sprintf('Missing Trace Speed [%s].',folder_name));
    return;
end
if exist(fullfile(folder_name,'Sources_LFP','X(m).mat'),'file')
    data_s = load(fullfile(folder_name,'Sources_LFP','X(m).mat'));
    X_posx = (data_s.x_start:data_s.f:data_s.x_end)';
    Y_posx = data_s.Y(:);
    if length(Y_posx)==(length(X_posx)+1)
        Y_posx = Y_posx(2:end);
    end
else
    warning(sprintf('Missing Trace X(m) [%s].',folder_name));
end
if exist(fullfile(folder_name,'Sources_LFP','Y(m).mat'),'file')
    data_s = load(fullfile(folder_name,'Sources_LFP','Y(m).mat'));
    X_posy = (data_s.x_start:data_s.f:data_s.x_end)';
    Y_posy = data_s.Y(:);
    if length(Y_posy)==(length(X_posy)+1)
        Y_posy = Y_posy(2:end);
    end
else
    errordlg(sprintf('Missing Trace Y(m) [%s].',folder_name));
end

if exist(fullfile(folder_name,'LocomotionInfo.mat'),'file')
    data_loc = load(fullfile(folder_name,'LocomotionInfo.mat'),'threshold_speed','min_path','max_duration');
else
    data_loc = [];
end

f = figure('Name',sprintf('Locomotion Event Detection [%s]',folder_name),...
    'NumberTitle','off',...
    'Units','normalized',...
    'Tag','LocomotionFigure',...
    'Position',[.1 .1 .6 .6]);
temp = regexp(folder_name,filesep,'split');
recording = char(temp(end));

f.UserData.recording = recording;
f.UserData.folder_name = folder_name;
f.UserData.data_tr = data_tr;
f.UserData.data_tt = data_tt;
f.UserData.TimeDisplay = handles.TimeDisplay.UserData;
f.UserData.X_speed = X_speed;
f.UserData.Y_speed = Y_speed;
f.UserData.X_posx = X_posx;
f.UserData.Y_posx = Y_posx;
f.UserData.X_posy = X_posy;
f.UserData.X_posy = X_posy;
colormap(f,'gray');

% Video Axis
ax1 = axes('Parent',f,'Tag','Ax1','Title','','Position',[.05 .75 .9 .2]);
ax2 = axes('Parent',f,'Tag','Ax2','Title','',...'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','',...
    'Position',[.05 .525 .9 .2]);
ax3 = axes('Parent',f,'Tag','Ax3',...'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','',...
    'Position',[.05 .3 .9 .2]);

% Filling axes
line('XData',X_speed,'YData',Y_speed,'Parent',ax1,...
    'Tag','Speed','Color','g','LineStyle','-','LineWidth',2,...
    'Marker','none','MarkerSize',3);
ax1.YLabel.String = 'Speed (m/s)';
ax1.XLim = [X_speed(1) X_speed(end)]; 
% ax1.YLim = [min(diff(trigger)) max(diff(trigger))]; 

% Set Threshold
l_thresh = line('XData',[X_speed(1) X_speed(end)],'YData',[NaN NaN],'Parent',ax1,...
    'Tag','Threshold','Color','k','LineStyle','-','LineWidth',1);

line('XData',X_posx,'YData',Y_posx,'Parent',ax2,...
    'Tag','PositionX','Color',[.5 .5 .5],'LineStyle','-',...
    'Marker','none','MarkerSize',3);
ax2.YLabel.String = 'X(m)';
ax2.XLim = [X_posx(1) X_posx(end)]; 

line('XData',X_posy,'YData',Y_posy,'Parent',ax3,...
    'Tag','PositionY','Color',[.5 .5 .5],'LineStyle','-',...
    'Marker','none','MarkerSize',3);
ax3.YLabel.String = 'Y(m)';
ax3.XLim = [X_posy(1) X_posy(end)]; 

linkaxes([ax1;ax2;ax3],'x');

%buttons
deleteButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','Delete',...
    'Tag','deleteButton',...
    'Parent',f);
okButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','OK',...
    'Tag','okButton',...
    'Parent',f);
cancelButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','Cancel',...
    'Tag','cancelButton',...
    'Parent',f);


e1 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String','.1',...
    'TooltipString','Threshhold Speed (s)',...
    'Tag','Edit1',...
    'Parent',f);
if ~isempty(data_loc)
    e1.String = data_loc.threshold_speed;
end
e2 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String','1.5',...
    'TooltipString','Minimal Path (m)',...
    'Tag','Edit2',...
    'Parent',f);
if ~isempty(data_loc)
    e2.String = data_loc.min_path;
end
e3 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String','10',...
    'TooltipString','Maximal duration (s)',...
    'Tag','Edit3',...
    'Parent',f);
if ~isempty(data_loc)
    e3.String = data_loc.max_duration;
end

sl1 = uicontrol('Style','slider',... 
    'Min',0,'Max',1,...
    'Value',str2double(e1.String),...
    'Units','normalized',...
    'Tag','Slider1',...
    'Parent',f);
sl1.SliderStep = [.01/(sl1.Max-sl1.Min) .1/(sl1.Max-sl1.Min)];

% Text1
t1 = cellstr([{''};{''};{''};{''}]);
text1 = uicontrol('Style','text',... 
    'Units','normalized',...
    'String','',...
    'BackgroundColor','w',...
    'HorizontalAlignment','left',...
    'Tag','Text1',...
    'String',t1,...
    'Parent',f);

% Table 1
w_col = 90;
table1 = uitable('Units','normalized',...
    'ColumnFormat',{'char','char','char','char','char'},...
    'ColumnWidth',{w_col w_col w_col w_col w_col},...
    'ColumnEditable',[false,false,false,false,false],...
    'ColumnName',{'Begin' 'End' 'Cross' 'After_A' 'Before_B'},...
    'Data',[],...
    'RowName','numbered',...
    'Tag','Table1',...
    'RowStriping','on',...
    'Parent',f);

% Position
e1.Position = [.05 .21 .06 .04];
e2.Position = [.12 .21 .06 .04];
e3.Position = [.19 .21 .06 .04];
sl1.Position = [.05 .17 .2 .04];
deleteButton.Position = [.05 .13 .2 .04];
okButton.Position = [.05 .09 .2 .04];
cancelButton.Position = [.05 .05 .2 .04];
text1.Position = [.275 .05 .15 .2];
table1.Position = [.45 .05 .5 .2];

% Interactive Control
handles = guihandles(f);

set(e1,'Callback',{@e1_callback,handles});
set(e2,'Callback',{@detect_events_Callback,handles});
set(e3,'Callback',{@detect_events_Callback,handles});
set(sl1,'Callback',{@sl1_callback,handles});
table1.CellSelectionCallback = {@uitable_select,handles};
set(deleteButton,'Callback',{@deleteButton_callback,handles});
set(okButton,'Callback',{@okButton_callback,handles});
set(cancelButton,'Callback',{@cancelButton_callback,handles});

% Update Detection
detect_events_Callback([],[],handles);

% Wait for d to close before running to completion
% waitfor(f);
success = true;

end

function e1_callback(hObj,~,handles)

val_e1 = str2double(hObj.String);
handles.Slider1.Value = val_e1;
detect_events_Callback([],[],handles);

end

function sl1_callback(hObj,~,handles)

val_e1 = hObj.Value;
handles.Edit1.String = sprintf('%.2f',val_e1);
detect_events_Callback([],[],handles);

end

function detect_events_Callback(~,~,handles)

f = handles.LocomotionFigure;
ax1 = handles.Ax1;
ax2 = handles.Ax2;
ax3 = handles.Ax3;

e1 = handles.Edit1;
val_e1 = str2double(e1.String);
l_thresh = findobj(ax1,'Tag','Threshold');
l_thresh.YData = [val_e1,val_e1];

% Getting Speed Value
l_speed = findobj(ax1,'Tag','Speed');
Y_speed = l_speed.YData;
X_speed = l_speed.XData;
Y_speed_raw = l_speed.YData;
X_speed_raw = l_speed.XData;
Y_speed(Y_speed<val_e1) = NaN;
Y_speed(1)=NaN;
Y_speed(end)=NaN;

l_x = findobj(ax2,'Tag','PositionX');
l_y = findobj(ax3,'Tag','PositionY');
X_posx = l_x.XData;
Y_posx = l_x.YData;
Y_posx(1)=NaN;
Y_posx(end)=NaN;
X_posy = l_y.XData;
Y_posy = l_y.YData;
Y_posy(1)=NaN;
Y_posy(end)=NaN;

% Finding peaks
ind_start = find(diff(isnan(Y_speed))==-1);
ind_end = find(diff(isnan(Y_speed))==1);
all_trials = [ind_start(:)+1,ind_end(:)];

% Minimal path & Maximal duration
all_paths = Y_posx(all_trials(:,1))-Y_posx(all_trials(:,2));
all_durations = X_speed(all_trials(:,2))-X_speed(all_trials(:,1));
ind_rm1 = find(abs(all_paths)<str2double(handles.Edit2.String));
ind_rm2 = find(all_durations>str2double(handles.Edit3.String));
ind_rm = [ind_rm1(:);ind_rm2(:)];
all_trials(ind_rm,:) = [];


all_ps = [];
all_cross = [];
for i =1:size(all_trials,1)
    [ps,ind_temp] = max(Y_speed(all_trials(i,1):all_trials(i,2)));
    all_cross = [all_cross;all_trials(i,1)+ind_temp];
    all_ps = [all_ps ;ps];
end

% Finding A and B
all_ab = [];
for i =1:size(all_trials,1)
    % finding A
    ind_a = all_trials(i,1);
    ind_b = all_trials(i,2);
    ind_c = all_cross(i,1);
    while ~isnan(Y_posx(ind_a)) && abs(Y_posx(ind_a-1)-Y_posx(ind_c))>abs(Y_posx(ind_a)-Y_posx(ind_c))
        ind_a = ind_a-1;
    end
    while ~isnan(Y_posx(ind_b)) && abs(Y_posx(ind_b+1)-Y_posx(ind_c))>abs(Y_posx(ind_b)-Y_posx(ind_c))
        ind_b = ind_b+1;
    end
    all_ab = [all_ab ;ind_a ind_b];
end

% Counting episodes
n_ep = length(all_cross);
if n_ep ==0
    warning('No Locomotion events detected. [%s]',f.UserData.folder_name);
    handles.Table1.UserData.all_ab= [];
    handles.Table1.UserData.all_cross= [];
    handles.Table1.UserData.all_trials= [];
    handles.Text1.String = '';
    handles.Table1.Data = [];
    all_axes = [ax1;ax2;ax3];
    delete(findobj(all_axes,'Tag','Begin'));
    delete(findobj(all_axes,'Tag','End'));
    delete(findobj(all_axes,'Tag','AfterA'));
    delete(findobj(all_axes,'Tag','BeforeB'));
    delete(findobj(all_axes,'Tag','CrossLevel'));
    return;
end

% Update Table1
handles.Table1.Data = cell(n_ep,5);
handles.Table1.Data(:,1) = cellstr(datestr(X_speed(all_ab(:,1))/(24*3600),'HH:MM:SS.FFF'));
handles.Table1.Data(:,2) = cellstr(datestr(X_speed(all_trials(:,1))/(24*3600),'HH:MM:SS.FFF'));
handles.Table1.Data(:,3) = cellstr(datestr(X_speed(all_cross(:))/(24*3600),'HH:MM:SS.FFF'));
handles.Table1.Data(:,4) = cellstr(datestr(X_speed(all_trials(:,2))/(24*3600),'HH:MM:SS.FFF'));
handles.Table1.Data(:,5) = cellstr(datestr(X_speed(all_ab(:,2))/(24*3600),'HH:MM:SS.FFF'));

% Storing
handles.Table1.UserData.ax1 = ax1;
handles.Table1.UserData.ax2 = ax2;
handles.Table1.UserData.ax3 = ax3;
handles.Table1.UserData.all_ab = all_ab;
handles.Table1.UserData.all_cross = all_cross;
handles.Table1.UserData.all_trials = all_trials;
handles.Table1.UserData.all_ps = all_ps;

handles.Table1.UserData.X_speed = X_speed;
handles.Table1.UserData.X_speed_raw = X_speed_raw;
handles.Table1.UserData.Y_speed = Y_speed;
handles.Table1.UserData.Y_speed_raw = Y_speed_raw;
handles.Table1.UserData.X_posx = X_posx;
handles.Table1.UserData.Y_posx = Y_posx;
handles.Table1.UserData.X_posy = X_posy;
handles.Table1.UserData.Y_posy = Y_posy;

% update lines
update_lines(handles);

end

function update_lines(handles)

ax1 = handles.Ax1;
ax2 = handles.Ax2;
ax3 = handles.Ax3;
all_ab = handles.Table1.UserData.all_ab;
all_cross = handles.Table1.UserData.all_cross;
all_trials = handles.Table1.UserData.all_trials;
all_ps = handles.Table1.UserData.all_ps;

X_speed = handles.Table1.UserData.X_speed;
Y_speed = handles.Table1.UserData.Y_speed;
X_speed_raw = handles.Table1.UserData.X_speed_raw;
Y_speed_raw = handles.Table1.UserData.Y_speed_raw;
X_posx = handles.Table1.UserData.X_posx;
Y_posx = handles.Table1.UserData.Y_posx;
X_posy = handles.Table1.UserData.X_posy;
Y_posy = handles.Table1.UserData.Y_posy;

% Recompute all_paths and all_durations
all_paths = Y_posx(all_trials(:,1))-Y_posx(all_trials(:,2));
all_durations = X_speed(all_trials(:,2))-X_speed(all_trials(:,1));

% Plot start and end
delete(findobj(ax1,'Tag','Begin'));
delete(findobj(ax1,'Tag','End'));
delete(findobj(ax1,'Tag','AfterA'));
delete(findobj(ax1,'Tag','BeforeB'));
delete(findobj(ax1,'Tag','CrossLevel'));
line('XData',X_speed_raw(all_ab(:,1)),'YData',Y_speed_raw(all_ab(:,1)),'Parent',ax1,...
    'Tag','Begin','Color',[.5 .5 .5],'LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_speed_raw(all_ab(:,2)),'YData',Y_speed_raw(all_ab(:,2)),'Parent',ax1,...
    'Tag','End','Color',[.5 .5 .5],'LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_speed(all_trials(:,1)),'YData',Y_speed(all_trials(:,1)),'Parent',ax1,...
    'Tag','AfterA','Color','b','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_speed(all_trials(:,2)),'YData',Y_speed(all_trials(:,2)),'Parent',ax1,...
    'Tag','BeforeB','Color','r','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_speed(all_cross),'YData',Y_speed(all_cross),'Parent',ax1,...
    'Tag','CrossLevel','Color','k','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);

delete(findobj(ax2,'Tag','AfterA'));
delete(findobj(ax2,'Tag','BeforeB'));
delete(findobj(ax2,'Tag','CrossLevel'));
delete(findobj(ax2,'Tag','Begin'));
delete(findobj(ax2,'Tag','End'));
line('XData',X_posx(all_ab(:,1)),'YData',Y_posx(all_ab(:,1)),'Parent',ax2,...
    'Tag','Begin','Color',[.5 .5 .5],'LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_posx(all_ab(:,2)),'YData',Y_posx(all_ab(:,2)),'Parent',ax2,...
    'Tag','End','Color',[.5 .5 .5],'LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_posx(all_trials(:,1)),'YData',Y_posx(all_trials(:,1)),'Parent',ax2,...
    'Tag','AfterA','Color','b','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_posx(all_trials(:,2)),'YData',Y_posx(all_trials(:,2)),'Parent',ax2,...
    'Tag','BeforeB','Color','r','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_posx(all_cross),'YData',Y_posx(all_cross),'Parent',ax2,...
    'Tag','CrossLevel','Color','k','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);

delete(findobj(ax3,'Tag','AfterA'));
delete(findobj(ax3,'Tag','BeforeB'));
delete(findobj(ax3,'Tag','CrossLevel'));
delete(findobj(ax3,'Tag','Begin'));
delete(findobj(ax3,'Tag','End'));
line('XData',X_posy(all_ab(:,1)),'YData',Y_posy(all_ab(:,1)),'Parent',ax3,...
    'Tag','Begin','Color',[.5 .5 .5],'LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_posy(all_ab(:,2)),'YData',Y_posy(all_ab(:,2)),'Parent',ax3,...
    'Tag','End','Color',[.5 .5 .5],'LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_posy(all_trials(:,1)),'YData',Y_posy(all_trials(:,1)),'Parent',ax3,...
    'Tag','AfterA','Color','b','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_posy(all_trials(:,2)),'YData',Y_posy(all_trials(:,2)),'Parent',ax3,...
    'Tag','BeforeB','Color','r','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_posy(all_cross),'YData',Y_posy(all_cross),'Parent',ax3,...
    'Tag','CrossLevel','Color','k','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);

% Update Text1
%s1 = sprintf('Recording: %s',f.UserData.recording);
s1a = sprintf('Speed threshold: %s m/s',handles.Edit1.String);
s1b = sprintf('Minimal Path: %.2f m',str2double(handles.Edit2.String));
s1c = sprintf('Maximal Duration: %.2f s',str2double(handles.Edit3.String));
s2 = sprintf('Events Detected: %d',size(all_trials,1));
s3 = sprintf('Average Peak Speed: %.2f m/s',mean(all_ps));
s4 = sprintf('Average Duration: %.2f s',mean(all_durations));
s5 = sprintf('Average Path: %.2f m',mean(all_paths));
handles.Text1.String = cellstr([{s1a};{s1b};{s1c};{s2};{s3};{s4};{s5}]);

end

function uitable_select(hObj,evnt,handles)

ax1 = hObj.UserData.ax1;
ax2 = hObj.UserData.ax2;
ax3 = hObj.UserData.ax3;
X_speed = hObj.UserData.X_speed;
all_trials = hObj.UserData.all_trials;

delete(findobj(ax1,'Tag','PatchEpisode'));
delete(findobj(ax2,'Tag','PatchEpisode'));
delete(findobj(ax3,'Tag','PatchEpisode'));

if ~isempty(evnt.Indices)
    selection = unique(evnt.Indices(:,1));
    hObj.UserData.Selection = selection;
    
    for i = 1:length(selection)
        ii = selection(i);
        xdata = [X_speed(all_trials(ii,1)) X_speed(all_trials(ii,2)) X_speed(all_trials(ii,2)) X_speed(all_trials(ii,1))];
        ydata = [ax1.YLim(1) ax1.YLim(1) ax1.YLim(2) ax1.YLim(2)];
        patch('XData',xdata,'YData',ydata,'Parent',ax1,...
            'Tag','PatchEpisode','FaceColor',[.5 .5 .5],'FaceAlpha',.5,'EdgeColor','none');
        ydata = [ax2.YLim(1) ax2.YLim(1) ax2.YLim(2) ax2.YLim(2)];
        patch('XData',xdata,'YData',ydata,'Parent',ax2,...
            'Tag','PatchEpisode','FaceColor',[.5 .5 .5],'FaceAlpha',.5,'EdgeColor','none');
        ydata = [ax3.YLim(1) ax3.YLim(1) ax3.YLim(2) ax3.YLim(2)];
        patch('XData',xdata,'YData',ydata,'Parent',ax3,...
            'Tag','PatchEpisode','FaceColor',[.5 .5 .5],'FaceAlpha',.5,'EdgeColor','none');
    end
else
    hObj.UserData.Selection = [];
    return;
end
end

function deleteButton_callback(~,~,handles)

if isempty(handles.Table1.UserData.Selection)
    return;
end
selection = handles.Table1.UserData.Selection;

% Storing
handles.Table1.UserData.all_ab(selection,:) = [];
handles.Table1.UserData.all_trials(selection,:) = [];
handles.Table1.UserData.all_cross(selection) = [];
handles.Table1.UserData.all_ps(selection) = [];
handles.Table1.Data(selection,:) = [];
handles.Table1.UserData.Selection = [];

% update lines
update_lines(handles);

end

function cancelButton_callback(~,~,handles)

f = handles.LocomotionFigure;
close(f);

end

function okButton_callback(~,~,handles)

f = handles.LocomotionFigure;
folder_name = f.UserData.folder_name;
all_trials = handles.Table1.UserData.all_trials;
all_ab = handles.Table1.UserData.all_ab;
all_cross = handles.Table1.UserData.all_cross;
n_ep = length(all_cross);
X_speed =  handles.Table1.UserData.X_speed;

if isempty(handles.Table1.Data)
    warning('No Locomotion events to save. [%s]',f.UserData.folder_name);
    close(f);
    return;
end

threshold_speed = str2double(handles.Edit1.String);
min_path = str2double(handles.Edit2.String);
max_duration = str2double(handles.Edit3.String);
save(fullfile(folder_name,'LocomotionInfo.mat'),...
    'threshold_speed','min_path','max_duration','-v7.3');
fprintf('===> Locomotion Information saved at %s.mat\n',fullfile(folder_name,'LocomotionInfo.mat'));

episodes = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

count = 1;
episodes(count).shortname = 'Begin_(s)';
episodes(count).parent = 'CereplexTracking';
episodes(count).fullname = strcat(episodes(count).parent,'/',episodes(count).shortname);
episodes(count).X = (1:n_ep)';
episodes(count).Y = X_speed(all_ab(:,1));
episodes(count).X_ind = episodes(count).X;
episodes(count).X_im = episodes(count).X;
episodes(count).Y_im = episodes(count).Y;
episodes(count).nb_samples = n_ep;
count = 2;
episodes(count).shortname = 'AfterA_(s)';
episodes(count).parent = 'CereplexTracking';
episodes(count).fullname = strcat(episodes(count).parent,'/',episodes(count).shortname);
episodes(count).X = (1:n_ep)';
episodes(count).Y = X_speed(all_trials(:,1));
episodes(count).X_ind = episodes(count).X;
episodes(count).X_im = episodes(count).X;
episodes(count).Y_im = episodes(count).Y;
episodes(count).nb_samples = n_ep;
count = 3;
episodes(count).shortname = 'Cross level_(s)';
episodes(count).parent = 'CereplexTracking';
episodes(count).fullname = strcat(episodes(count).parent,'/',episodes(count).shortname);
episodes(count).X = (1:n_ep)';
episodes(count).Y = X_speed(all_cross(:));
episodes(count).X_ind = episodes(count).X;
episodes(count).X_im = episodes(count).X;
episodes(count).Y_im = episodes(count).Y;
episodes(count).nb_samples = n_ep;
count = 4;
episodes(count).shortname = 'BeforeB_(s)';
episodes(count).parent = 'CereplexTracking';
episodes(count).fullname = strcat(episodes(count).parent,'/',episodes(count).shortname);
episodes(count).X = (1:n_ep)';
episodes(count).Y = X_speed(all_trials(:,2));
episodes(count).X_ind = episodes(count).X;
episodes(count).X_im = episodes(count).X;
episodes(count).Y_im = episodes(count).Y;
episodes(count).nb_samples = n_ep;
count = 5;
episodes(count).shortname = 'End_(s)';
episodes(count).parent = 'CereplexTracking';
episodes(count).fullname = strcat(episodes(count).parent,'/',episodes(count).shortname);
episodes(count).X = (1:n_ep)';
episodes(count).Y = X_speed(all_ab(:,2));
episodes(count).X_ind = episodes(count).X;
episodes(count).X_im = episodes(count).X;
episodes(count).Y_im = episodes(count).Y;
episodes(count).nb_samples = n_ep;
count = 6;
episodes(count).shortname = 'Mid Amplitude_(s)';
episodes(count).parent = 'CereplexTracking';
episodes(count).fullname = strcat(episodes(count).parent,'/',episodes(count).shortname);
episodes(count).X = (1:n_ep)';
episodes(count).Y = X_speed(round(mean(all_trials,2)));
episodes(count).X_ind = episodes(count).X;
episodes(count).X_im = episodes(count).X;
episodes(count).Y_im = episodes(count).Y;
episodes(count).nb_samples = n_ep;

% Save NeuroLab_Episodes.mat
fprintf('===> Locomotion Events saved at %s.mat\n',fullfile(folder_name,'NeuroLab_Episodes.mat'));
save(fullfile(folder_name,'NeuroLab_Episodes.mat'),'episodes','-v7.3');

% Building TimeTags from all_times
% TimeTags_strings
TimeTags_strings = [handles.Table1.Data(:,1),handles.Table1.Data(:,5)];
tts1 = datenum(TimeTags_strings(:,1));
tts2 = datenum(TimeTags_strings(:,2));
TimeTags_seconds = [(tts1-floor(tts1)),(tts2-floor(tts2))]*24*3600;

% Adding seconds before and after
t_before = 2;
t_after = 5;
TimeTags_seconds(:,1) = TimeTags_seconds(:,1)-t_before;
TimeTags_seconds(:,2) = TimeTags_seconds(:,2)+t_after;
TimeTags_strings = [cellstr(datestr(TimeTags_seconds(:,1)/(24*3600),'HH:MM:SS.FFF')),cellstr(datestr(TimeTags_seconds(:,2)/(24*3600),'HH:MM:SS.FFF'))];

TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
% TimeTags_cell & TimeTags
TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
TimeTags_cell = cell(n_ep+1,6);
TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'};
for k=1:n_ep
    TimeTags_cell(k+1,:) = {'',sprintf('RUN-%03d',k),char(TimeTags_strings(k,1)),char(TimeTags_dur(k,:)),char(TimeTags_strings(k,1)),''};
    TimeTags(k,1).Episode = '';
    TimeTags(k,1).Tag = sprintf('RUN-%03d',k);
    TimeTags(k,1).Onset = char(TimeTags_strings(k,1));
    TimeTags(k,1).Duration = char(TimeTags_dur(k,:));
    TimeTags(k,1).Reference = char(TimeTags_strings(k,1));
    TimeTags(k,1).Tokens = '';
end
% TimeTags_images
TimeTags_images = zeros(n_ep,2);
tts = datenum(f.UserData.TimeDisplay);
for k=1:size(TimeTags_strings,1)
    min_time = tts1(k);
    max_time = tts2(k);
    [~, ind_min_time] = min(abs(tts-datenum(min_time)));
    [~, ind_max_time] = min(abs(tts-datenum(max_time)));
    %TimeTags_strings(k,:) = {min_time,max_time};
    TimeTags_images(k,:) = [ind_min_time,ind_max_time];
end

% Loading Time Tags
tt_data = f.UserData.data_tt;
if isempty(tt_data)
    save(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    fprintf('===> Time Tags saved at %s.\n',fullfile(folder_name,'Time_Tags.mat'));
else
    % Overwrite        
    all_strings = {'RUN-'};
    temp ={tt_data.TimeTags(:).Tag}';
    ind_keep = ~contains(temp,all_strings);
    tt_data.TimeTags_images = tt_data.TimeTags_images(ind_keep,:);
    tt_data.TimeTags_strings = tt_data.TimeTags_strings(ind_keep,:);
    tt_data.TimeTags_cell = [tt_data.TimeTags_cell(1,:);tt_data.TimeTags_cell(find(ind_keep==1)+1,:)];
    tt_data.TimeTags = tt_data.TimeTags(ind_keep);
    
    % Concatenate
    TimeTags_images = [tt_data.TimeTags_images;TimeTags_images];
    TimeTags_strings = [tt_data.TimeTags_strings;TimeTags_strings];
    TimeTags_cell = [TimeTags_cell(1,:);tt_data.TimeTags_cell(2:end,:);TimeTags_cell(2:end,:)];
    TimeTags = [tt_data.TimeTags;TimeTags];
    save(fullfile(folder_name,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    fprintf('===> Time Tags overwritten [%s].\n',fullfile(folder_name,'Time_Tags.mat'));
    
end

% close figure
close(f);

end