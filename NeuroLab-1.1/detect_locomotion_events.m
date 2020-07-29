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
    'Tag','PositionX','Color',[.5 .5 .5],'LineStyle','-',...
    'Marker','none','MarkerSize',3);
ax3.YLabel.String = 'Y(m)';
ax3.XLim = [X_posy(1) X_posy(end)]; 

linkaxes([ax1;ax2;ax3],'x');

%buttons
% autosetButton = uicontrol('Style','pushbutton',... 
%     'Units','normalized',...
%     'String','Autoset',...
%     'Tag','autosetButton',...
%     'Parent',f);
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
e2 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String','1',...
    'TooltipString','Minimal Path (m)',...
    'Tag','Edit2',...
    'Parent',f);
e3 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String','5',...
    'TooltipString','Maximal duration (s)',...
    'Tag','Edit3',...
    'Parent',f);

sl1 = uicontrol('Style','slider',... 
    'Min',0,'Max',1,...
    'Value',str2double(e1.String),...
    'Units','normalized',...
    'Tag','Slider1',...
    'Parent',f);
sl1.SliderStep = [.01/(sl1.Max-sl1.Min) .1/(sl1.Max-sl1.Min)];

% Text1
% s1 = sprintf('Input File: %s',file_txt);
% s2 = sprintf('Recording Mode: %s',rec_mode);
% s3 = sprintf('Reference: %s - Padding: %s',reference,padding);
% s4 = sprintf('Total Frames: %d - Mean Interval: %.4f s',length(trigger),mean(diff(trigger)));
% t1 = cellstr([{s1};{s2};{s3};{s4}]);
t1 = cellstr([{''};{''};{''};{''}]);
text1 = uicontrol('Style','text',... 
    'Units','normalized',...
    'String','',...
    'BackgroundColor','w',...
    'HorizontalAlignment','left',...
    'Tag','Text1',...
    'String',t1,...
    'Parent',f);

% Table 2
w_col = 80;
table1 = uitable('Units','normalized',...
    'ColumnFormat',{'char','char','char','char','char','char'},...
    'ColumnWidth',{w_col w_col w_col w_col w_col w_col},...
    'ColumnEditable',[false,false,false,false,false,false],...
    'ColumnName',{'Event' 'Begin' 'End' 'Cross' 'After_A' 'Before_B'},...
    'Data',[],...
    'RowName','',...
    'Tag','Table1',...
    'RowStriping','on',...
    'Parent',f);
% % Adjust Columns
% table1.Units = 'pixels';
% table1.ColumnWidth ={.35*(table1.Position(3)-w_margin),.35*(table1.Position(3)-w_margin),.1*(table1.Position(3)-w_margin),.1*(table1.Position(3)-w_margin),.1*(table1.Position(3)-w_margin)};
% table1.Units = 'normalized';


e1.Position = [.05 .2 .06 .05];
e2.Position = [.12 .2 .06 .05];
e3.Position = [.19 .2 .06 .05];
sl1.Position = [.05 .15 .2 .05];
% autosetButton.Position = [.05 .15 .2 .05];
okButton.Position = [.05 .1 .2 .05];
cancelButton.Position = [.05 .05 .2 .05];
text1.Position = [.275 .05 .15 .2];
table1.Position = [.45 .05 .5 .2];

% Interactive Control
handles = guihandles(f);

set(e1,'Callback',{@e1_callback,handles});
set(e2,'Callback',{@detect_events_Callback,handles});
set(e3,'Callback',{@detect_events_Callback,handles});
set(sl1,'Callback',{@sl1_callback,handles});

set(okButton,'Callback',{@okButton_callback,handles});
set(cancelButton,'Callback',{@cancelButton_callback,handles});

% Update Detection
detect_events_Callback([],[],handles);

% Wait for d to close before running to completion
%waitfor(f);
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

e1 = handles.Edit1;
val_e1 = str2double(e1.String);
l_thresh = findobj(ax1,'Tag','Threshold');
delete(findobj(ax1,'Tag','AfterA'));
delete(findobj(ax1,'Tag','BeforeB'));
delete(findobj(ax1,'Tag','CrossLevel'));
l_thresh.YData = [val_e1,val_e1];

% Getting Speed Value
l_speed = findobj(ax1,'Tag','Speed');
Y_speed = l_speed.YData;
X_speed = l_speed.XData;
Y_speed(Y_speed<val_e1) = NaN;
Y_speed(1)=NaN;
Y_speed(end)=NaN;

% Finding peaks
ind_start = find(diff(isnan(Y_speed))==-1);
ind_end = find(diff(isnan(Y_speed))==1);
all_trials = [ind_start(:)+1,ind_end(:)];
all_ps = [];
all_cross = [];
for i =1:size(all_trials,1)
    [ps,ind_temp] = max(Y_speed(all_trials(i,1):all_trials(i,2)));
    all_cross = [all_cross;all_trials(i,1)+ind_temp];
    all_ps = [all_ps ;ps];
end

% Plot start and end
line('XData',X_speed(all_trials(:,1)),'YData',Y_speed(all_trials(:,1)),'Parent',ax1,...
    'Tag','AfterA','Color','b','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_speed(all_trials(:,2)),'YData',Y_speed(all_trials(:,2)),'Parent',ax1,...
    'Tag','BeforeB','Color','r','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);
line('XData',X_speed(all_cross),'YData',Y_speed(all_cross),'Parent',ax1,...
    'Tag','CrossLevel','Color','k','LineStyle','none','LineWidth',1,...
    'Marker','o','MarkerSize',3);

% Edit Text1

s1 = sprintf('Recording: %s',f.UserData.recording);
s2 = sprintf('Paramters: [%s - %s - %s]',handles.Edit1.String,handles.Edit2.String,handles.Edit3.String);
s3 = sprintf('Events Detected: %d',size(all_trials,1));
s4 = sprintf('Average Peak Speed: %.2f',mean(all_ps));
handles.Text1.String = cellstr([{s1};{s2};{s3};{s4}]);

end