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
    data_tracking = load(output_file,'arena','vertices','edges'); 
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
    % t_ref = t_ref(1:60:end);
    if isfield(data_tr,'delay_lfp_video')
        delay_lfp_video = data_tr.delay_lfp_video;
    else
        delay_lfp_video = 0;
    end
end

% Loading NEV File
if ~isempty(F.nev) && exist(nev_file,'file') 
    % Loading NEV file
    fprintf('Loading NEV file [%s]...',nev_file);
    S = openNEV(nev_file,'nosave');
    fprintf(' done.\n');
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
t_pixel = S.Data.VideoSync.ElapsedTime/1000;
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
    t_interp = t_ref;
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
t_pixel = double(t_pixel);
x_pixel = double(x_pixel);
y_pixel = double(y_pixel);
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
f.UserData.t_pixel = t_pixel;
f.UserData.x_pixelraw = t_pixel;
f.UserData.y_pixelraw = t_pixel;
f.UserData.s_pixelraw = t_pixel;
f.UserData.x_pixel = [];
f.UserData.y_pixel = [];
f.UserData.s_pixel = [];

% Video Axis
ax = axes('Parent',f,'Tag','AxVideo','Title','',...
    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','',...
    'Position',[.05 .95-(v_ratio*.9) .9 v_ratio*.9]);
% Adding merged frame
%all_frames = flipud(all_frames);
imagesc(mean(all_frames,3,'omitnan'),'Parent',ax,'Tag','ImageVideo');
%ax.YDir='reverse';
ax.XTickLabel=[];
ax.YTickLabel=[];
ax.Tag = 'AxVideo';

% Adding tracking coordinates
line('XData',x_pixel,'YData',y_pixel,'Parent',ax,'Tag','RawTracking',...
    'LineWidth',.01,'LineStyle','-','Color','r',...
    'Marker','o','MarkerSize',1,'MarkerFaceColor','r');

% Position Axes
ax2 = axes('Parent',f,'Tag','AxPositionX','Title','X vs time',...
    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','');
line('XData',t_pixel,'YData',x_pixel,'Color','b','Parent',ax2,'Tag','RawX');
ax2.XLim = [t_pixel(1) t_pixel(end)];
ax2.Title.String = 'X(t)';

ax3 = axes('Parent',f,'Tag','AxPositionY','Title','Y vs time',...
    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','');
line('XData',t_pixel,'YData',y_pixel,'Color','b','Parent',ax3,'Tag','RawY');
ax3.XLim = [t_pixel(1) t_pixel(end)];
ax3.Title.String = 'Y(t)';

ax4 = axes('Parent',f,'Tag','AxSpeed','Title','Speed vs time',...
    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','');
line('XData',t_pixel,'YData',s_pixel,'Color','b','Parent',ax4,'Tag','RawS');
ax4.XLim = [t_pixel(1) t_pixel(end)];
ax4.Title.String = 'V(t)';


% Buttons
arenaButton = uicontrol('Style','togglebutton',... 
    'Units','normalized',...
    'Value',0,...
    'String','Draw Arena',...
    'Tag','arenaButton',...
    'Parent',f);
axesButton = uicontrol('Style','togglebutton',... 
    'Units','normalized',...
    'Value',0,...
    'String','Draw Axes',...
    'Tag','axesButton',...
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
    'String','0.20',...
    'TooltipString','Short axis length (m)',...
    'Tag','Edit1',...
    'Parent',f);
e2 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String','2.35',...
    'TooltipString','Long axis length (m)',...
    'Tag','Edit1',...
    'Parent',f);

% Postion
e1.Position = [.05 .21 .1 .04];
e2.Position = [.15 .21 .1 .04];
axesButton.Position = [.05 .17 .2 .04];
arenaButton.Position = [.05 .13 .2 .04];
okButton.Position = [.05 .09 .2 .04];
cancelButton.Position = [.05 .05 .2 .04];
ax2.Position = [.3 .06 .2 .15];
ax3.Position = [.525 .06 .2 .15];
ax4.Position = [.75 .06 .2 .15];

% Interactive Control
handles = guihandles(f);

% callbacks
%set(e1,'Callback',{@e1_callback,handles});
set(arenaButton,'Callback',{@arenaButton_callback,handles});
%set(axesButton,'Callback',{@updateButton_callback,handles});
%set(okButton,'Callback',{@okButton_callback,handles});
set(cancelButton,'Callback',{@cancelButton_callback,handles});

% Updating UserData and aspect
% update_imagecrop(handles);
% e1_callback(e1,[],handles)

waitfor(f);
success = true;

end

function cancelButton_callback(~,~,handles)

f = handles.TrackingFigure;
v = f.UserData.v;
%warning('Tracking Importation Cancelled [%s].\n',v.Name)
close(f);

end

function arenaButton_callback(hObj,~,handles)

f = handles.TrackingFigure;
if hObj.Value == 1
    set(f,'WindowButtonDownFcn',{@ax_clickFcn,handles});
else
    set(f,'WindowButtonDownFcn','');
    update_tracking(handles);
end

end

function ax_clickFcn(hObj,~,handles)

f = hObj;
ax = findobj(f,'Tag','AxVideo');
pt_cp = round(ax.CurrentPoint);

% Delete previous objects
delete(findobj(ax,'Tag','Movable_Arena'));
delete(findobj(ax,'Tag','Arena'));

x = [pt_cp(1,1),pt_cp(1,1),pt_cp(1,1),pt_cp(1,1)];
y = [pt_cp(1,2),pt_cp(1,2),pt_cp(1,2),pt_cp(1,2)];

if pt_cp(1,1)>ax.XLim(1) && pt_cp(1,1)<ax.XLim(2) && pt_cp(1,2)>ax.YLim(1) && pt_cp(1,2)<ax.YLim(2)
    f.Pointer = 'crosshair';
    %Patch
    patch(x,y,'y',...
        'EdgeColor','y',...
        'Tag','Movable_Arena',...
        'FaceAlpha',0,...
        'LineWidth',1,...
        'Parent',ax);
end

set(f,'WindowButtonMotionFcn',{@ax_motionFcn,handles});
set(f,'WindowButtonUpFcn',{@ax_unclickFcn,handles});

end

function ax_motionFcn(hObj,~,handles)
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

function ax_unclickFcn(hObj,~,handles)
% Called when user releases Pixel in CenterAxes

f = hObj;
ax = findobj(f,'Tag','AxVideo');

% Converting Movable to Fixed
% hq = findobj(ax,'Tag','Movable_Arena');
% set(hq,'Tag','Arena','HitTest','on','ButtonDownFcn',{@click_Arena,handles});
hq = findobj(ax,'Tag','Movable_Arena');
set(hq,'Tag','Arena');
set(hObj,'Pointer','arrow');
set(hObj,'WindowButtonMotionFcn','');
set(hObj,'WindowButtonUp','');
handles.arenaButton.Value = 0;

set(f,'WindowButtonDownFcn','');
update_tracking(handles);

end

function update_tracking(handles)
% Update Tracking Information

ax = handles.AxVideo;
l1 = findobj(ax,'Tag','RawTracking');
ax2 = handles.AxPositionX;
l2 = findobj(ax2,'Tag','RawX');
ax3 = handles.AxPositionY;
l3 = findobj(ax2,'Tag','RawY');
ax4 = handles.AxSpeed;
l4 = findobj(ax2,'Tag','RawS');

f = handles.TrackingFigure;

% Raw coordinates
x_pixelraw = f.UserData.x_pixelraw;
y_pixelraw = f.UserData.y_pixelraw;
s_pixelraw = f.UserData.s_pixelraw;
t_pixel = f.UserData.t_pixel;

% Getting arena coordinates
hq = findobj(ax,'Tag','Movable_Arena');
if isempty(hq)
    % Raw Tracking
    l1.XData = x_pixelraw;
    l1.XData = x_pixelraw;
    % Position Axes
    l2.YData = x_pixelraw;
    l3.YData = y_pixelraw;
    l4.YData = s_pixelraw;
    
else
    x1 = min(hq.XData);
    x2 = max(hq.XData);
    y1 = min(hq.YData);
    y2 = max(hq.YData);
    
    x_pixel = NaN(size(t_pixel));
    y_pixel = NaN(size(t_pixel));
    s_pixel = NaN(size(t_pixel));
    
    % Raw Tracking
    l1.XData = x_pixel;
    l1.XData = x_pixel;
    % Position Axes
    l2.YData = x_pixel;
    l3.YData = y_pixel;
    l4.YData = s_pixel;
    
end

end