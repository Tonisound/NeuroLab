function success = import_crop_video(F,handles,flag)
% Opens Video file with Video Reader
% Enables Video cropping + synchronisation LFP-VIDEO
% Saves Cropped video in .mat format in nlab folder
% flag 0 - first import
% flag 1 - reimport

success = false;

% global SEED DIR_SAVE FILES CUR_FILE;
% F = FILES(CUR_FILE);
% t_ref = 61:60:1860;
% delay_lfp_video = 0;

global SEED DIR_SAVE ;
video_file = fullfile(SEED,F.parent,F.session,F.recording,F.video);
output_file = fullfile(DIR_SAVE,F.nlab,'Video.mat');
crop_file = fullfile(DIR_SAVE,F.nlab,'CroppingInfo.mat');

% Loading Time_Reference.mat
if exist(fullfile(DIR_SAVE,F.nlab,'Time_Reference.mat'),'file')
    data_tr = load(fullfile(DIR_SAVE,F.nlab,'Time_Reference.mat'));
    t_ref = data_tr.time_ref.Y;
    % t_ref = t_ref(1:60:end);
    if isfield(data_tr,'delay_lfp_video')
        delay_lfp_video = data_tr.delay_lfp_video;
    else
        delay_lfp_video = 0;
    end
else
    warning('Missing File Time_Reference.mat. Unable to import video [%s].\n',fullfile(DIR_SAVE,F.nlab));
    return;
end

% Checking Doppler
if flag == 1 && exist(output_file,'file')
    % re-import
    data_video = load(output_file,'delay_lfp_video','x_crop','y_crop','video_quality'); 
    delay_lfp_video = data_video.delay_lfp_video;
else
    data_video = [];
end

% Loading Video file
if ~exist(video_file,'file')
    warning('Video File not found [%s].',video_file);
else
    % Getting video parameters
    d = dir(video_file);
    
    fprintf('Opening Video - Extracting frames [%s] ...',F.video);
    v = VideoReader(video_file);
    % Parameters
    t1 = max(t_ref(1),0);
    t2 = min(t_ref(end),v.Duration-1);
    n_frames = 10;
    t_samp = rescale(1:n_frames,t1,t2);
    t_interp = t_ref;
    
    all_frames = [];
    for i = 1:length(t_samp)
        %fprintf('tsamp = %.2f, i=%d, duration = %.2f \n',t_samp(i),i,v.Duration);
        v.CurrentTime = t_samp(i);
        vidFrame = readFrame(v);
        if strcmp(v.VideoFormat,'RGB24')
            vidFrame = rgb2gray(vidFrame);
            all_frames = cat(3,all_frames,vidFrame);
        end
    end
    fprintf(' done.\n');
end


% Direct Processing if CroppingInfo.mat is found
if exist(crop_file,'file')
    fprintf('Cropping Information Loaded [%s].\n',crop_file);
    data_crop  = load(crop_file);
    t_corrected = data_crop.t_video;
    %t_ref = data_crop.t_interp;
    %index_frames = data_crop.index_frames;
    
    if isfield(data_crop,'video_quality')
        video_quality = data_crop.video_quality;
    else
        video_quality = 'Medium';
    end
    
    x_crop = data_crop.x_crop;
    y_crop = data_crop.y_crop;
    
    % Getting video quality
    switch video_quality
        case 'High'
            step_quality = 1;
        case 'Medium'
            step_quality = 2;
        case 'Low'
            step_quality = 3;
    end
    
    % reading frames
    all_frames = [];
    % fprintf('Extracting cropped video frames [%s] ...',v.Name);
    h = waitbar(0,'Extracting cropped frames: 0.0 % completed [].');
    for i = 1:length(t_corrected)
        v.CurrentTime = t_corrected(i);
        try
            % Pulling Video Frame
            vidFrame = readFrame(v);
            if strcmp(v.VideoFormat,'RGB24')
                vidFrame = rgb2gray(vidFrame);
                vidFrame = vidFrame(x_crop(1):step_quality:x_crop(2),y_crop(1):step_quality:y_crop(2));
                all_frames = cat(3,all_frames,vidFrame);
            end
        catch
            % Empty Image Padding
            all_frames = cat(3,all_frames,NaN(size(vidFrame)));
            warning('Missing frame. Time: %.2f. Video Length: %.2f. File [%s]\n',t_corrected(i),v.Duration,F.video);
        end
        waitbar(i/length(t_corrected),h,sprintf('Extracting Video [%s Quality]\n %.1f %% completed [Frame %d/%d].',video_quality,100*i/length(t_corrected),i,length(t_corrected)))
    end
    close(h);
    % fprintf(' done.\n');
    
    % Saving file
    % save(output_file,'all_frames','index_frames','t_ref','t_video','delay_lfp_video','x_crop','y_crop','-v7.3');
    fprintf('Cropping Information Saved and Renamed [%s].\n==> [%s]...',crop_file,output_file);
    save(crop_file,'all_frames','-append');
    movefile(crop_file,output_file)
    fprintf(' done.\n');
    success = true;
    return;
end

v_ratio = v.Height/v.Width;
f = figure('Name',sprintf('Video Importation [%s]',F.video),...
    'NumberTitle','off',...
    'Units','normalized',...
    'Tag','VideoFigure',...
    'Position',[.1 .1 .4 .4]);
f.Position(4) = 1.2*f.Position(3)/v_ratio;
f.UserData.v = v;
f.UserData.t_interp = t_interp;
f.UserData.output_file = output_file;
colormap(f,'gray');

% Video Axis
ax = axes('Parent',f,'Tag','AxVideo','Title','',...
    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','',...
    'Position',[.05 .95-(v_ratio*.9) .9 v_ratio*.9]);

imagesc(mean(all_frames,3,'omitnan'),'Parent',ax,'Tag','ImageVideo');
ax.XTickLabel=[];
ax.YTickLabel=[];
ax.Tag = 'AxVideo';

% Crop Axis
ax2 = axes('Parent',f,'Tag','AxCrop','Title','Preview',...
    'TickLength',[0 0],'XTick',[],'XTickLabel','','YTick',[],'YTickLabel','');
%axis(ax2,'equal');
% Add uncropped image
imagesc(mean(all_frames,3,'omitnan'),'Parent',ax2,'Tag','ImageCrop');
ax2.XTickLabel=[];
ax2.YTickLabel=[];
ax2.Tag = 'AxCrop';

% RE-drawing patch
video_quality = 'Medium';
if ~isempty(data_video)
    x1 = data_video.x_crop(1);
    x2 = data_video.x_crop(2);
    y1 = data_video.y_crop(1);
    y2 = data_video.y_crop(2);    
    p=patch([y1 y1 y2 y2],[x1 x2 x2 x1],'w',...
        'EdgeColor','w',...
        'Tag','BoxCrop',...
        'FaceAlpha',.1,...
        'LineWidth',1,...
        'Parent',ax);
    
    if isfield(data_video,'video_quality')
        video_quality = data_video.video_quality;
    end   
end

%buttons
cropButton = uicontrol('Style','pushbutton',... 
    'Units','normalized',...
    'String','Crop Only',...
    'Tag','cropButton',...
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

% Text1
s1 = sprintf('Input File: %s',v.Name);
s2 = sprintf('Total Duration: %s',datestr(datenum(v.Duration/(24*3600)),'HH:MM:SS.FFF'));
%s3 = sprintf('Frame Rate: %.1f',v.FrameRate);
%s4 = sprintf('Format: %s',v.VideoFormat);
%s5 = sprintf('Pixels per frame: %.d',v.Width*v.Height);
%s6 = sprintf('Size: %.1f Mb',d.bytes/(1024^2));
s6 = sprintf('Creation date: %s',d.date);
s7 = sprintf('Size: %.1f Mb',d.bytes/1e6);
% t1 = cellstr([{s1};{s2};{s3};{s4};{s5};{s6};{s7}]);
t1 = cellstr([{s1};{s2};{s6};{s7}]);
text1 = uicontrol('Style','text',... 
    'Units','normalized',...
    'String','',...
    'BackgroundColor','w',...
    'HorizontalAlignment','left',...
    'Tag','Text1',...
    'String',t1,...
    'Parent',f);

% Text2
% s0 = 'Video Information';
s1 = sprintf('Output File: %s','video.mat');
s2 = sprintf('Time Interval: %s - %s',datestr(datenum(t_interp(1)/(24*3600)),'HH:MM:SS.FFF'),datestr(datenum(t_interp(end)/(24*3600)),'HH:MM:SS.FFF'));
s3 = sprintf('Total Frames: %d',length(t_interp));
esize = (v.Width*v.Height*length(t_interp)/1e6);
s7 = sprintf('Expected Size: %.1f / %.1f / %.1f Mb',esize,esize/4,esize/9);


t2 = cellstr([{s1};{s2};{s3};{s7}]);
text2 = uicontrol('Style','text',... 
    'Units','normalized',...
    'String','',...
    'BackgroundColor','w',...
    'HorizontalAlignment','left',...
    'Tag','Text2',...
    'String',t2,...
    'Parent',f);

% Delay LFP-VIDEO
e1 = uicontrol('Style','edit',... 
    'Units','normalized',...
    'String',datestr(datenum(delay_lfp_video/(24*3600)),'HH:MM:SS.FFF'),...
    'TooltipString','LFP-Video Delay (s)',...
    'Tag','Edit1',...
    'Parent',f);
e1.UserData.delay_lfp_video = delay_lfp_video;

% Button Group
bg = uibuttongroup('Visible','on',...
    'Units','normalized',...
    'Tag','ButtonGroup');
% Create three radio buttons in the button group.
bg1 = uicontrol(bg,'Style','radiobutton',...
    'Units','normalized',...
    'String','x1',...
    'Position',[0 0 .33 1],...
    'Tag','High',...
    'TooltipString','High quality video',...
    'HandleVisibility','off');
bg2 = uicontrol(bg,'Style','radiobutton',...
    'Units','normalized',...
    'String','/4',...
    'Position',[.335 0 .33 1],...
    'TooltipString','Medium quality video',...
    'Tag','Medium',...
    'HandleVisibility','off');
bg3 = uicontrol(bg,'Style','radiobutton',...
    'Units','normalized',...
    'String','/9',...
    'TooltipString','Low quality video',...
    'Tag','Low',...
    'Position',[.67 0 .33 1],...
    'HandleVisibility','off');
switch video_quality
    case 'High'
        bg.SelectedObject = bg1;
    case 'Medium'
        bg.SelectedObject = bg2;
    case 'Low'
        bg.SelectedObject = bg3;
end


% removeButton.Position = [.05 .2 .2 .05];
% updateButton.Position = [.05 .15 .2 .05];
% enlargeButton.Position = [.05 .15 .2 .05];
% reduceButton.Position = [.25 .15 .2 .05];

% t3.Position = [.05 .2 .2 .05];
e1.Position = [.05 .21 .2 .04];
bg.Position = [.05 .17 .2 .04];
cropButton.Position = [.05 .13 .2 .04];
okButton.Position = [.05 .09 .2 .04];
cancelButton.Position = [.05 .05 .2 .04];
ax2.Position = [.75 .05 .2 .2];
text1.Position = [.275 .15 .45 .095];
text2.Position = [.275 .05 .45 .095];

% Interactive Control
handles = guihandles(f);
if isempty(data_video)
    set(f,'WindowButtonDownFcn',{@ax_clickFcn,handles});
else
    set(p,'ButtonDownFcn',{@click_CropPatchFcn,handles});
end
set(e1,'Callback',{@e1_callback,handles});

%set(bg,'SelectionChangedFcn',{@bg_Callback,handles})
set(cropButton,'Callback',{@cropButton_callback,handles});
set(okButton,'Callback',{@okButton_callback,handles});
set(cancelButton,'Callback',{@cancelButton_callback,handles});

% Updating UserData and aspect
update_imagecrop(handles);
e1_callback(e1,[],handles)

waitfor(f);
success = true;

end

function ax_clickFcn(hObj,~,handles)
% User click Axes

f = hObj;
ax = findobj(f,'Tag','AxVideo');
pt_cp = round(ax.CurrentPoint);

% Delete previous objects
delete(findobj(ax,'Tag','Movable_BoxCrop'));
delete(findobj(ax,'Tag','BoxCrop'));

x = [pt_cp(1,1),pt_cp(1,1),pt_cp(1,1),pt_cp(1,1)];
y = [pt_cp(1,2),pt_cp(1,2),pt_cp(1,2),pt_cp(1,2)];

if pt_cp(1,1)>ax.XLim(1) && pt_cp(1,1)<ax.XLim(2) && pt_cp(1,2)>ax.YLim(1) && pt_cp(1,2)<ax.YLim(2)
    f.Pointer = 'crosshair';
    %Patch
    patch(x,y,'w',...
        'EdgeColor','w',...
        'Tag','Movable_BoxCrop',...
        'FaceAlpha',.1,...
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
    reg = findobj(ax,'Tag','Movable_BoxCrop');
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
hq = findobj(ax,'Tag','Movable_BoxCrop');
set(hq,'Tag','BoxCrop','HitTest','on','ButtonDownFcn',{@click_CropPatchFcn,handles});

set(hObj,'Pointer','arrow');
set(hObj,'WindowButtonMotionFcn','');
set(hObj,'WindowButtonUp','');

set(f,'WindowButtonDownFcn','');
update_imagecrop(handles);

end

function click_CropPatchFcn(hObj,~,handles)

f = handles.VideoFigure;
seltype = get(f,'SelectionType');

if strcmp(seltype,'normal')
    %     handles.MainFigure.Pointer = 'hand';
    %     hObj.Tag = 'Movable_Box';
    %     hObj.UserData.Tag = 'Movable_Trace_Box';
else
    delete(hObj);
    set(f,'WindowButtonDownFcn',{@ax_clickFcn,handles});
end

update_imagecrop(handles);

end

function update_imagecrop(handles)

f = handles.VideoFigure;
t2 = findobj(f,'Tag','Text2');
ax1 = findobj(f,'Tag','AxVideo');
ax2 = findobj(f,'Tag','AxCrop');
im2 = findobj(f,'Tag','ImageCrop');
im1 = findobj(f,'Tag','ImageVideo');
hObj = findobj(f,'Tag','BoxCrop');

if ~isempty(hObj)
    y1 = min(hObj.XData);
    y2 = max(hObj.XData);
    x1 = min(hObj.YData);
    x2 = max(hObj.YData);
else
    y1 = 1;
    y2 = size(im1.CData,2);
    x1 = 1;
    x2 = size(im1.CData,1);
end
% Update image crop
im2.CData = im1.CData(x1:x2,y1:y2);
ax2.YLim = [.5 x2-x1+.5];
ax2.XLim = [.5 y2-y1+.5];


% Update Text2
% s1 = sprintf('Output File: %s','video.mat');
% s2 = sprintf('Time Interval: %s - %s',datestr(datenum(t_interp(1)/(24*3600)),'HH:MM:SS.FFF'),datestr(datenum(t_interp(end)/(24*3600)),'HH:MM:SS.FFF'));
% s3 = sprintf('Total Frames: %d',length(t_interp));
v = f.UserData.v;
t_interp = f.UserData.t_interp;
if ~isempty(hObj)
    esize = ((x2-x1+1)*(y2-y1+1)*length(t_interp))/1e6;
    s7 = sprintf('Expected Size: %.1f / %.1f / %.1f Mb',esize,esize/4,esize/9);
else
    esize = (v.Width*v.Height*length(t_interp)/1e6);
    s7 = sprintf('Expected Size: %.1f / %.1f / %.1f Mb',esize,esize/4,esize/9);
end
t2.String{4}  =s7;

% Storing
f.UserData.x_crop = [x1 x2];
f.UserData.y_crop = [y1 y2];

end

function e1_callback(hObj,~,handles)

f = handles.VideoFigure;
t2 = findobj(f,'Tag','Text2');

temp = datenum(hObj.String);
delay_lfp_video = (temp-floor(temp))*24*3600;
hObj.UserData.delay_lfp_video = delay_lfp_video;
%delay_lfp_video

t_interp = f.UserData.t_interp;
t_corrected = t_interp-delay_lfp_video;
s2 = sprintf('Time Interval: %s - %s',datestr(datenum(t_corrected(1)/(24*3600)),'HH:MM:SS.FFF'),datestr(datenum(t_corrected(end)/(24*3600)),'HH:MM:SS.FFF'));
t2.String{2} = s2;

% Storing 
f.UserData.t_corrected = t_corrected;

end

function cancelButton_callback(~,~,handles)

f = handles.VideoFigure;
v = f.UserData.v;
warning('Video Importation Cancelled [%s].\n',v.Name)
close(f);

end

function okButton_callback(~,~,handles)

f = handles.VideoFigure;
e1 = findobj(f,'Tag','Edit1');
% t1 = findobj(f,'Tag','Text1');
% t2 = findobj(f,'Tag','Text2');
% ax1 = findobj(f,'Tag','AxVideo');
% ax2 = findobj(f,'Tag','AxCrop');
% im2 = findobj(f,'Tag','ImageCrop');
% im1 = findobj(f,'Tag','ImageVideo');
v = f.UserData.v;

% Getting t_interp corrected
delay_lfp_video = e1.UserData.delay_lfp_video;
t_corrected = f.UserData.t_corrected;
t_interp = f.UserData.t_interp;

% Getting indexes
x_crop = f.UserData.x_crop;
y_crop = f.UserData.y_crop;

% Getting Video Quality
video_quality = handles.ButtonGroup.SelectedObject.Tag;
switch video_quality
    case 'High'
        step_quality = 1;
    case 'Medium'
        step_quality = 2;
    case 'Low'
        step_quality = 3;
end

% reading frames
all_frames = [];
% fprintf('Extracting cropped video frames [%s] ...',v.Name);
h = waitbar(0,'Extracting cropped frames: 0.0 % completed [].');
for i = 1:length(t_corrected)
    v.CurrentTime = t_corrected(i);
    try
        % Pulling Video Frame
        vidFrame = readFrame(v);
        if strcmp(v.VideoFormat,'RGB24')
            vidFrame = rgb2gray(vidFrame);
            vidFrame = vidFrame(x_crop(1):step_quality:x_crop(2),y_crop(1):step_quality:y_crop(2));
            all_frames = cat(3,all_frames,vidFrame);
        end
    catch
        % Empty Image Padding
        all_frames = cat(3,all_frames,NaN(size(vidFrame)));
        warning('Missing frame. Time: %.2f. Video Length: %.2f. File [%s]\n',t_corrected(i),v.Duration,F.video);
    end
    waitbar(i/length(t_corrected),h,sprintf('Extracting Video [%s Quality]\n %.1f %% completed [Frame %d/%d].',video_quality,100*i/length(t_corrected),i,length(t_corrected)));
end
close(h);
% fprintf(' done.\n');

% Saving file
output_file = f.UserData.output_file;
fprintf('Saving Cropped video [%s] ...',output_file);
t_video = t_corrected;
t_ref = t_interp;
index_frames = 1:length(t_interp);
save(output_file,'all_frames','index_frames','video_quality','t_ref','t_video','delay_lfp_video','x_crop','y_crop','-v7.3')
fprintf(' done.\n');

% Closing figure
close(f);

end

function cropButton_callback(~,~,handles)

f = handles.VideoFigure;
e1 = findobj(f,'Tag','Edit1');
v = f.UserData.v;

% Getting t_interp corrected
delay_lfp_video = e1.UserData.delay_lfp_video;
t_corrected = f.UserData.t_corrected;
t_interp = f.UserData.t_interp;

% Getting indexes
x_crop = f.UserData.x_crop;
y_crop = f.UserData.y_crop;

% Saving file
output_file = strrep(f.UserData.output_file,'Video.mat','CroppingInfo.mat');
t_video = t_corrected;
t_ref = t_interp;
index_frames = 1:length(t_interp);
save(output_file,'index_frames','t_ref','t_video','delay_lfp_video','x_crop','y_crop','-v7.3');
fprintf('Cropping Information Saved [%s].\n',output_file);

% Closing figure
close(f);

end
