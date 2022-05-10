function success = import_tracking_info(F,handles,val)
% Animal Detection in Video File

% Pointer
handles.MainFigure.Pointer = 'watch';
drawnow;

global DIR_SAVE SEED;
folder_name = fullfile(DIR_SAVE,F.nlab);
video_file = fullfile(SEED,F.parent,F.session,F.recording,F.video);
nev_file = fullfile(SEED,F.parent,F.session,F.recording,F.dir_lfp,F.nev);
output_file = fullfile(DIR_SAVE,F.nlab,'TrackingInfo.mat');
success = false;

% If nargin > 2 batch processing
% val indicates callback origin
% (0 : batch mode - 1 : user mode)
if nargin == 2
    val = 1;
end

% Checking TrackingInfo.mat
if exist(output_file,'file')
    data_tracking = load(output_file,'arena','origin','vertex_x','vertex_y','length_x','length_y','smooth_s'); 
else
    data_tracking = [];
end

% Loading Time Reference
if ~exist(fullfile(folder_name,'Time_Reference.mat'),'file')
    errordlg(sprintf('Missing File Time_Reference.mat [%s].',folder_name));
    return;
else
    data_tr = load(fullfile(folder_name,'Time_Reference.mat'));
    t_ref = data_tr.time_ref.Y;
end

% Loading NEV File
if ~isempty(F.nev) && exist(nev_file,'file') 
    % Loading NEV file
    fprintf('Loading NEV file [%s]...',nev_file);
    S = openNEV(nev_file,'nosave');
    fprintf(' done.\n');
else
    errordlg(sprintf('Cannot load file [%s]',nev_file));
    return;
end
% Testing if Tracking is empty
if isempty(S.Data.Tracking) 
    warning('Tracking Information not found [%s].',nev_file);
    handles.MainFigure.Pointer = 'arrow';
    return;
elseif ~isfield(S.Data.Tracking,'Object1')
    warning('Tracking Object not found [%s].',nev_file);   
    handles.MainFigure.Pointer = 'arrow';
    return;
end

% Getting coordinates
x_pixel = [];
y_pixel = [];
t_pixel = double(S.Data.VideoSync.ElapsedTime)/1000;
% fprintf('Getting tracking coordinates [%s]...','Object1'); 
for i=1:length(S.Data.Tracking.Object1.MarkerCoordinates)
    x_pixel = [x_pixel;S.Data.Tracking.Object1.MarkerCoordinates(i).X];
    y_pixel = [y_pixel;S.Data.Tracking.Object1.MarkerCoordinates(i).Y];
end
% fprintf(' done.\n');

% Loading Video file
if ~exist(video_file,'file') || isempty(F.video)
    errordlg('Video File not found [%s].',video_file);
    handles.MainFigure.Pointer = 'arrow';
    return;
else
    
    % Getting video parameters
    fprintf('Loading Video File [%s]...',video_file); 
    d = dir(video_file);
    v = VideoReader(video_file);
    fprintf(' done.\n');
    
    % Parameters
    t1 = max(t_ref(1),0);
    t2 = min(t_ref(end),v.Duration-1);
    n_frames = 10;
    t_samp = rescale(1:n_frames,t1,t2);
    fprintf('Opening Video - Extracting %d frames [%s] ...',n_frames,F.video);
    
    all_frames = [];
    for i = 1:length(t_samp)
        %fprintf('tsamp = %.2f, i=%d, duration = %.2f \n',t_samp(i),i,v.Duration);
        v.CurrentTime = t_samp(i);
        try
            vidFrame = readFrame(v);
            if strcmp(v.VideoFormat,'RGB24')
                vidFrame = rgb2gray(vidFrame);
                all_frames = cat(3,all_frames,vidFrame);
            end
        catch
            warning('Frame Skipped: Time %.2f. File [%s]',t_samp(i),video_file);
        end
    end
    fprintf(' done.\n');
end

% Correct y_pixel and calculate speed
% t_pixel = double(t_pixel(2:end));

% Removing duplicates
[t_pixel,ia] = unique(t_pixel,'sorted');
x_pixel = double(x_pixel(ia));
y_pixel = double(y_pixel(ia));
% bug fix
% x_pixel = double(x_pixel(:));
% y_pixel = double(y_pixel(:));
y_pixel = v.Height-y_pixel;
sx_pixel = [0;diff(x_pixel)/mean(diff(t_pixel))];
sy_pixel = [0;diff(y_pixel)/mean(diff(t_pixel))];
s_pixel = sqrt(sx_pixel.^2+sy_pixel.^2);

% Building Figure
handles.MainFigure.Pointer = 'arrow';
v_ratio = v.Height/v.Width;
f = figure('Name',sprintf('NEV Tracking Information Importation [%s]',F.nlab),...
    'NumberTitle','off',...
    'Units','normalized',...
    'Tag','TrackingFigure',...
    'Position',[.1 .1 .6 .4]);
% f.UserData.v = v;
colormap(f,'gray');

% Storing Data
f.UserData.v = v;
f.UserData.video_file = video_file;
f.UserData.nev_file = nev_file;
f.UserData.output_file = output_file;
f.UserData.data_tr = data_tr;
f.UserData.folder_name = folder_name;

f.UserData.t_pixel = t_pixel;
f.UserData.x_pixelraw = x_pixel;
f.UserData.y_pixelraw = y_pixel;
f.UserData.s_pixelraw = s_pixel;
f.UserData.x_pixel = [];
f.UserData.y_pixel = [];
f.UserData.s_pixel = [];

% Video Axis
ax = axes('Parent',f,'Tag','AxVideo','Title','',...
    'Position',[.05 .95-(v_ratio*.9) .9 v_ratio*.9]);% 'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','',...
% Adding merged frame
%all_frames = flipud(all_frames);
imagesc(mean(all_frames,3,'omitnan'),'Parent',ax,'Tag','ImageVideo');
%ax.YDir='reverse';
%ax.XTickLabel=[];
%ax.YTickLabel=[];
ax.Tag = 'AxVideo';

% All tracking
line('XData',f.UserData.x_pixelraw,'YData',f.UserData.y_pixelraw,'Parent',ax,'Tag','AllTracking',...
        'LineWidth',.01,'LineStyle','-','Color',[.5 .5 .5],...
        'Marker','o','MarkerSize',1,'MarkerFaceColor',[.5 .5 .5],'Visible','off');
% Adding tracking coordinates    
line('XData',x_pixel,'YData',y_pixel,'Parent',ax,'Tag','RawTracking',...
    'LineWidth',.01,'LineStyle','-','Color','r',...
    'Marker','o','MarkerSize',1,'MarkerFaceColor','r');

% Adding Arena if exist
if ~isempty(data_tracking) && ~isempty(data_tracking.arena)
    patch(data_tracking.arena.XData,data_tracking.arena.YData,'y',...
        'EdgeColor','y',...
        'Tag','Arena',...
        'FaceAlpha',0,...
        'LineWidth',1,...
        'Parent',ax);
end


% Position Axes
% ax2 = axes('Parent',f,'Tag','AxPositionX','Title','X vs time',...
%     'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','');
ax2 = axes('Parent',f,'Tag','AxPositionX','Title','X vs time');
line('XData',t_pixel,'YData',x_pixel,'Color','b','Parent',ax2,'Tag','RawX');
ax2.XLim = [t_pixel(1) t_pixel(end)];
ax2.Title.String = 'X(t)';

% ax3 = axes('Parent',f,'Tag','AxPositionY','Title','Y vs time',...
%     'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','');
ax3 = axes('Parent',f,'Tag','AxPositionY','Title','Y vs time');
line('XData',t_pixel,'YData',y_pixel,'Color','b','Parent',ax3,'Tag','RawY');
ax3.XLim = [t_pixel(1) t_pixel(end)];
ax3.Title.String = 'Y(t)';

% ax4 = axes('Parent',f,'Tag','AxSpeed','Title','Speed vs time',...
%    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','');
ax4 = axes('Parent',f,'Tag','AxSpeed','Title','Speed vs time');
line('XData',t_pixel,'YData',s_pixel,'Color','b','Parent',ax4,'Tag','RawS');
ax4.XLim = [t_pixel(1) t_pixel(end)];
ax4.Title.String = 'V(t)';

% Buttons
arenaButton = uicontrol('Style','togglebutton',... 
    'Units','normalized',...
    'Value',0,...
    'String','Update Arena',...
    'Tag','arenaButton',...
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

% Edits
e1 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String','2.35',...
    'TooltipString','Long Axis (X,m)',...
    'Tag','Edit1',...
    'Parent',f);
f.UserData.length_x = str2double(e1.String);
if ~isempty(data_tracking) && isfield(data_tracking,'length_x') && ~isempty(data_tracking.length_x)
    e1.String = sprintf('%.2f',data_tracking.length_x);
    f.UserData.length_x = data_tracking.length_x;
end
e2 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String','0.20',...
    'TooltipString','Short Axis length (Y,m)',...
    'Tag','Edit2',...
    'Parent',f);
f.UserData.length_y = str2double(e2.String);
if ~isempty(data_tracking) && isfield(data_tracking,'length_y') && ~isempty(data_tracking.length_y)
    e2.String = sprintf('%.2f',data_tracking.length_y);
    f.UserData.length_y = data_tracking.length_y;
end
load('Preferences.mat','GTraces')
e3 = uicontrol('Style','edit',...
    'Units','normalized',...
    'String',GTraces.GaussianSmoothing,...
    'TooltipString','Smoothing constant (s)',...
    'Tag','Edit3',...
    'Parent',f);
f.UserData.smooth_s = str2double(e3.String);
if ~isempty(data_tracking) && isfield(data_tracking,'smooth_s') && ~isempty(data_tracking.smooth_s)
    e3.String = sprintf('%.2f',data_tracking.smooth_s);
    f.UserData.smooth_s = data_tracking.smooth_s;
end

% Postion
e1.Position = [.05 .2 .06 .05];
e2.Position = [.12 .2 .06 .05];
e3.Position = [.19 .2 .06 .05];
arenaButton.Position = [.05 .15 .2 .05];
okButton.Position = [.05 .1 .2 .05];
cancelButton.Position = [.05 .05 .2 .05];
ax2.Position = [.3 .06 .2 .15];
ax3.Position = [.525 .06 .2 .15];
ax4.Position = [.75 .06 .2 .15];

% Interactive Control
handles2 = guihandles(f);

% callbacks
set(e1,'Callback',{@e1_callback,handles2});
set(e2,'Callback',{@e2_callback,handles2});
set(e3,'Callback',{@e3_callback,handles2});
set(arenaButton,'Callback',{@arenaButton_callback,handles2});
set(okButton,'Callback',{@okButton_callback,handles2,handles});
set(cancelButton,'Callback',{@cancelButton_callback,handles2});

% Update tracking
update_tracking(handles2);

% Smoothing
e3_callback(e3,[],handles2);

waitfor(f);
success = true;

end

function cancelButton_callback(~,~,handles)

f = handles.TrackingFigure;
v = f.UserData.v;
%warning('Tracking Importation Cancelled [%s].\n',v.Name)
close(f);

end

function okButton_callback(~,~,handles,old_handles)

ax = handles.AxVideo;
f = ax.Parent;
folder_name = f.UserData.folder_name;

% Arena
hq = findobj(ax,'Tag','Arena');
if ~isempty(hq)
    arena.XData = hq.XData;
    arena.YData = hq.YData;
    t1 = 'X(m)';
    t2 = 'Y(m)';
    t3 = 'SPEED';
else
    arena = [];
    t1 = 'X(pixel)';
    t2 = 'Y(pixel)';
    t3 = 'SPEED(pixel)';
end
% Vertices
V0 = findobj(ax,'Tag','Origin');
if ~isempty(V0)
    origin = [V0.XData,V0.YData];
else
    origin = [];
end
Vx = findobj(ax,'Tag','VertexX');
if ~isempty(Vx)
    vertex_x = [Vx.XData,Vx.YData];
else
    vertex_x = [];
end
Vy = findobj(ax,'Tag','VertexY');
if ~isempty(Vy)
    vertex_y = [Vy.XData,Vy.YData];
else
    vertex_y = [];
end

% Axes
length_x = f.UserData.length_x;
length_y = f.UserData.length_y;
smooth_s = f.UserData.smooth_s;

% Checking TrackingInfo.mat
output_file = f.UserData.output_file;
save(output_file,'arena','origin','vertex_x','vertex_y','length_x','length_y','smooth_s'); 
fprintf('Tracking Information Saved [%s].\n',output_file)

% Getting coordinates
data_tr = f.UserData.data_tr;
x_pixel = f.UserData.x_pixel;
y_pixel = f.UserData.y_pixel;
s_pixel = f.UserData.s_pixel;
t_pixel = f.UserData.t_pixel;

% regular interpolation
xq = t_pixel(1):mean(diff(t_pixel)):t_pixel(end);
x_pixel = interp1(t_pixel,x_pixel,xq);
y_pixel = interp1(t_pixel,y_pixel,xq);
s_pixel = interp1(t_pixel,s_pixel,xq);
t_pixel = xq;

% Converting to traces
traces = struct('fullname',{},'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{});
traces(1).fullname = t1;
traces(1).X = t_pixel;
traces(1).Y = x_pixel;
traces(1).X_ind = data_tr.time_ref.X;
traces(1).X_im = data_tr.time_ref.Y;
traces(1).Y_im = interp1(traces(1).X,traces(1).Y,traces(1).X_im);
traces(2).fullname = t2;
traces(2).X = t_pixel;
traces(2).Y = y_pixel;
traces(2).X_ind = data_tr.time_ref.X;
traces(2).X_im = data_tr.time_ref.Y;
traces(2).Y_im = interp1(traces(2).X,traces(2).Y,traces(2).X_im);
traces(3).fullname = t3;
traces(3).X = t_pixel;
traces(3).Y = s_pixel;
traces(3).X_ind = data_tr.time_ref.X;
traces(3).X_im = data_tr.time_ref.Y;
traces(3).Y_im = interp1(traces(3).X,traces(3).Y,traces(3).X_im);    

% Direct Trace Loading
ind_traces = 1:length(traces);
% getting lines name
lines = findobj(old_handles.RightAxes,'Tag','Trace_Cerep');
lines_name = cell(length(lines),1);
for i =1:length(lines)
    lines_name{i} = lines(i).UserData.Name;
end

for i=1:length(ind_traces)
    
    t = traces(ind_traces(i)).fullname;
    %Adding burst
    Xtemp = traces(ind_traces(i)).X_ind;
    Ytemp = traces(ind_traces(i)).Y_im;
    
    if sum(strcmp(t,lines_name))>0
        %line already exists overwrite
        ind_overwrite = find(strcmp(t,lines_name)==1);
        lines(ind_overwrite).UserData.Y = traces(ind_traces(i)).Y;
        lines(ind_overwrite).XData = Xtemp;
        lines(ind_overwrite).YData = Ytemp;
        % fprintf('External Trace successfully updated (%s)\n',traces(ind_traces(i)).fullname);
        fprintf('External Trace successfully updated (%s)\n',t);
    else
        %line creation
        %str = lower(char(traces(ind_traces(i)).fullname));
        color = rand(1,3);
        
        hl = line('XData',Xtemp,...
            'YData',Ytemp,...
            'Color',color,...
            'LineWidth',1,...
            'Tag','Trace_Cerep',...
            'Visible','off',...
            'HitTest','off',...
            'Parent', old_handles.RightAxes);
        %         if handles.RightPanelPopup.Value==4
        %             set(hl,'Visible','on');
        %         end
        str_rpopup = strtrim(old_handles.RightPanelPopup.String(old_handles.RightPanelPopup.Value,:));
        if strcmp(str_rpopup,'Trace Dynamics')
            set(hl,'Visible','on');
        end
        
        % Line creation
        s.Name = t;
        s.Selected = 0;
        s.X = traces(ind_traces(i)).X;
        s.Y = traces(ind_traces(i)).Y;
        hl.UserData = s;
        fprintf('External Trace successfully loaded (%s)\n',traces(ind_traces(i)).fullname);
    end
end

% Closing
close(f);

% Save Cereplex_Traces.mat
dir_source = fullfile(folder_name,'Sources_LFP');
if ~exist(dir_source,'dir')
    mkdir(dir_source);
end
for i =1:3
    X = traces(i).X;
    Y = traces(i).Y;
    f = X(2)-X(1);
    x_start = X(1);
    x_end = X(end);
    save(fullfile(dir_source,strcat(traces(i).fullname,'.mat')),'Y','f','x_start','x_end','-v7.3');
    fprintf('Trace Saved [%s]\n',fullfile(dir_source,strcat(traces(i).fullname,'.mat')));
end

end

function arenaButton_callback(hObj,~,handles)

f = handles.TrackingFigure;
ax = findobj(f,'Tag','AxVideo');
hq = findobj(ax,'Tag','Arena');
l5 = findobj(ax,'Tag','AllTracking');
    
if hObj.Value == 1
    if ~isempty(hq)
        hq.FaceAlpha = 0.1;
    end
    % interactive control
    set(f,'WindowButtonDownFcn',{@ax_clickFcn1,handles});
    % disable all other buttons
    all_buttons = findobj(handles.TrackingFigure,'Style','togglebutton','-or','Style','pushbutton');
    for i=1:length(all_buttons)
        all_buttons(i).Enable = 'off';
    end
    hObj.Enable = 'on';
    
    % Turn all tracking on
    l5.Visible = 'on';
    
    % Delete objects
    delete(findobj(ax,'Tag','StickerArena'));
    delete(findobj(ax,'Tag','StickerX'));
    delete(findobj(ax,'Tag','StickerY'));
    delete(findobj(ax,'Tag','Origin'));
    delete(findobj(ax,'Tag','VertexX')); 
    delete(findobj(ax,'Tag','VertexY'));
else   
    if ~isempty(hq)
        hq.FaceAlpha = 0;
    end% interactive control
    set(f,'WindowButtonDownFcn','');
    % enable all other buttons
    all_buttons = findobj(handles.TrackingFigure,'Style','togglebutton','-or','Style','pushbutton');
    for i=1:length(all_buttons)
        all_buttons(i).Enable = 'on';
    end
    
    % Turn all tracking off
    l5.Visible = 'off';
    
    % update tracking
    update_tracking(handles);   
end

end

function ax_clickFcn1(hObj,evnt,handles)

f = hObj;
ax = findobj(f,'Tag','AxVideo');
pt_cp = round(ax.CurrentPoint);

% Delete previous objects
delete(findobj(ax,'Tag','Movable_Arena'));
delete(findobj(ax,'Tag','Arena'));
delete(findobj(ax,'Tag','StickerArena'));
% delete origin, vertex_x, vertex_y
delete(findobj(ax,'Tag','Origin'));
delete(findobj(ax,'Tag','VertexX'));
delete(findobj(ax,'Tag','VertexY'));

x = [pt_cp(1,1),pt_cp(1,1),pt_cp(1,1),pt_cp(1,1)];
y = [pt_cp(1,2),pt_cp(1,2),pt_cp(1,2),pt_cp(1,2)];

if pt_cp(1,1)>ax.XLim(1) && pt_cp(1,1)<ax.XLim(2) && pt_cp(1,2)>ax.YLim(1) && pt_cp(1,2)<ax.YLim(2) && strcmp(evnt.Source.SelectionType,'normal') 
    
    f.Pointer = 'crosshair';
    %Patch
    patch(x,y,'y',...
        'EdgeColor','y',...
        'Tag','Movable_Arena',...
        'FaceAlpha',.1,...
        'LineWidth',1,...
        'Parent',ax);
end

set(f,'WindowButtonMotionFcn',{@ax_motionFcn1,handles});
set(f,'WindowButtonUpFcn',{@ax_unclickFcn1,handles});

end

function ax_motionFcn1(hObj,~,handles)
% Called when user moves Pixel in CenterAxes        

f = hObj;
ax = findobj(f,'Tag','AxVideo');
pt2 = round(ax.CurrentPoint);

if(pt2(1,1)>ax.XLim(1) && pt2(1,1)<ax.XLim(2) && pt2(1,2)>ax.YLim(1) && pt2(1,2)<ax.YLim(2))
    reg = findobj(ax,'Tag','Movable_Arena');
    reg.XData(3) = pt2(1,1);
    reg.XData(4) = pt2(1,1);
    reg.YData(2) = pt2(1,2);
    reg.YData(3) = pt2(1,2);
else
    set(hObj,'Pointer','arrow');
end

end

function ax_unclickFcn1(hObj,~,handles)
% Called when user releases Pixel in CenterAxes

f = hObj;
ax = findobj(f,'Tag','AxVideo');

% Converting Movable to Fixed
hq = findobj(ax,'Tag','Movable_Arena');
set(hq,'Tag','Arena');
set(hObj,'Pointer','arrow');
set(hObj,'WindowButtonMotionFcn','');
set(hObj,'WindowButtonUp','');

% Compute smoothed trajectory
[x,y,s,x_,y_] = compute_trajectory(f);

% Finding lines and update
l1 = findobj(ax,'Tag','RawTracking');
l1.XData = x_;
l1.YData = y_;

ax2 = handles.AxPositionX;
l2 = findobj(ax2,'Tag','RawX');
l2.YData = x;

ax3 = handles.AxPositionY;
l3 = findobj(ax3,'Tag','RawY');
l3.YData = y;

ax4 = handles.AxSpeed;
l4 = findobj(ax4,'Tag','RawS');
l4.YData = s;

% Storing
f.UserData.x_pixel = l2.YData;
f.UserData.y_pixel = l3.YData;
f.UserData.s_pixel = l4.YData;

end

function [x_smooth,y_smooth,s_smooth,x_,y_] = compute_trajectory(f)

ax = findobj(f,'Tag','AxVideo');
hq = findobj(ax,'Tag','Arena');

% Raw coordinates
x_pixelraw = f.UserData.x_pixelraw;
y_pixelraw = f.UserData.y_pixelraw;
s_pixelraw = f.UserData.s_pixelraw;
t_pixel = f.UserData.t_pixel;
smooth_s = f.UserData.smooth_s;
length_x = f.UserData.length_x;
length_y = f.UserData.length_y;

if isempty(hq)
    % Raw Tracking
    x_smooth = x_pixelraw;
    y_smooth = y_pixelraw;
    %s_smooth = s_pixelraw;
    % Smoothing
    n = smooth_s*(round(length(t_pixel)/(t_pixel(end)-t_pixel(1))));
    s_smooth = nanconv(s_pixelraw,gausswin(n)/n,'same');
    x_ = x_smooth;
    y_ = y_smooth;
else
    x1 = min(hq.XData);
    x2 = max(hq.XData);
    y1 = min(hq.YData);
    y2 = max(hq.YData);
    
    % Finding dots to remove
    ind_rmx = ((x_pixelraw-x1).*(x_pixelraw-x2))>0;
    ind_rmy = ((y_pixelraw-y1).*(y_pixelraw-y2))>0;
    ind_rm = (ind_rmx+ind_rmy)>0;
    % Remove dots
    x_pixel = x_pixelraw;
    x_pixel(ind_rm) = NaN;
    x_ = x_pixel;
    y_pixel = y_pixelraw;
    y_pixel(ind_rm) = NaN;
    y_ = y_pixel;
    
%     % Smoothing
%     n = smooth_s*(round(length(t_pixel)/(t_pixel(end)-t_pixel(1))));
%     x_pixel = nanconv(x_pixel,gausswin(n)/n,'same');
%     y_pixel = nanconv(y_pixel,gausswin(n)/n,'same');
    
    % Updating Units
    ratio_pixel_x = length_x/(x2-x1);
    ratio_pixel_y = length_y/(y2-y1);
    x_pixel = (x_pixel-x1)*ratio_pixel_x;
    y_pixel = (y_pixel-y1)*ratio_pixel_y;
    
    % Computing speed
    sx_pixel = [0;diff(x_pixel)/mean(diff(t_pixel))];
    sy_pixel = [0;diff(y_pixel)/mean(diff(t_pixel))];
    s_pixel = sqrt(sx_pixel.^2+sy_pixel.^2);
    
    % Smoothing
    n = smooth_s*(round(length(t_pixel)/(t_pixel(end)-t_pixel(1))));
    s_pixel = nanconv(s_pixel,gausswin(n)/n,'same');
    
    % Return output
    x_smooth = x_pixel;
    y_smooth = y_pixel;
    s_smooth = s_pixel;
end

end

function update_tracking(handles)
% Update Tracking Information

ax = handles.AxVideo;
hq = findobj(ax,'Tag','Arena');

if ~isempty(hq)
    
    x1 = min(hq.XData);
    x2 = max(hq.XData);
    y1 = min(hq.YData);
    y2 = max(hq.YData);
    
    % Drawing origin, vertex_x, vertex_y
    line('XData',x1,'YData',y1,'Tag','Origin','Parent',ax,...
        'Marker','o','MarkerSize',5,'MarkerFaceColor','y','MarkerEdgeColor',[.5 .5 .5]);
    line('XData',x2,'YData',y1,'Tag','VertexX','Parent',ax,...
        'Marker','o','MarkerSize',5,'MarkerFaceColor','y','MarkerEdgeColor',[.5 .5 .5]);
    line('XData',x1,'YData',y2,'Tag','VertexY','Parent',ax,...
        'Marker','o','MarkerSize',5,'MarkerFaceColor','y','MarkerEdgeColor',[.5 .5 .5]);
    
    % Adding stickers
    text(mean(hq.XData),mean(hq.YData),'arena',...
        'FontSize',8,...
        'BackgroundColor','y',...
        'EdgeColor','y',...
        'Color','k',...
        'Parent',ax,...
        'Tag','StickerArena',...
        'Visible','on');
     % Adding sticker
    text((x1+x2)/2,y1,sprintf('%.2f',str2double(handles.Edit1.String)),...
        'FontSize',8,'BackgroundColor',[.5 .5 .5],'EdgeColor','y','Color','k','Parent',ax,'Tag','StickerX','Visible','on');
    text(x1,(y1+y2)/2,sprintf('%.2f',str2double(handles.Edit2.String)),...
        'FontSize',8,'BackgroundColor',[.5 .5 .5],'EdgeColor','y','Color','k','Parent',ax,'Tag','StickerY','Visible','on');
end

end

function e1_callback(hObj,~,handles)

ax = handles.AxVideo;
f = ax.Parent;
f.UserData.length_x = str2double(hObj.String);

hq = findobj(ax,'Tag','StickerX');
if ~isempty(hq)
    hq.String = sprintf('%.2f',f.UserData.length_x);
end

% Update units
[x,y,s] = compute_trajectory(f);
ax2 = handles.AxPositionX;
l2 = findobj(ax2,'Tag','RawX');
l2.YData = x;

ax3 = handles.AxPositionY;
l3 = findobj(ax3,'Tag','RawY');
l3.YData = y;

ax4 = handles.AxSpeed;
l4 = findobj(ax4,'Tag','RawS');
l4.YData = s;

% Storing
f.UserData.x_pixel = l2.YData;
f.UserData.y_pixel = l3.YData;
f.UserData.s_pixel = l4.YData;

end

function e2_callback(hObj,~,handles)

ax = handles.AxVideo;
f = ax.Parent;
f.UserData.length_y = str2double(hObj.String);

hq = findobj(ax,'Tag','StickerY');
if ~isempty(hq)
    hq.String = sprintf('%.2f',f.UserData.length_y);
end

% Update units
[x,y,s] = compute_trajectory(f);
ax2 = handles.AxPositionX;
l2 = findobj(ax2,'Tag','RawX');
l2.YData = x;

ax3 = handles.AxPositionY;
l3 = findobj(ax3,'Tag','RawY');
l3.YData = y;

ax4 = handles.AxSpeed;
l4 = findobj(ax4,'Tag','RawS');
l4.YData = s;

% Storing
f.UserData.x_pixel = l2.YData;
f.UserData.y_pixel = l3.YData;
f.UserData.s_pixel = l4.YData;

end

function e3_callback(hObj,~,handles)

ax = handles.AxVideo;
f = ax.Parent;
f.UserData.smooth_s = str2double(hObj.String);

% Update units
[x,y,s] = compute_trajectory(f);
ax2 = handles.AxPositionX;
l2 = findobj(ax2,'Tag','RawX');
l2.YData = x;

ax3 = handles.AxPositionY;
l3 = findobj(ax3,'Tag','RawY');
l3.YData = y;

ax4 = handles.AxSpeed;
l4 = findobj(ax4,'Tag','RawS');
l4.YData = s;

% Storing
f.UserData.x_pixel = l2.YData;
f.UserData.y_pixel = l3.YData;
f.UserData.s_pixel = l4.YData;

end