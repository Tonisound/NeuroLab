function success = detect_animal_position(F,handles,val)
% Animal Detection in Video File

global DIR_SAVE;
folder_name = fullfile(DIR_SAVE,F.nlab);
success = false;

% If nargin > 2 batch processing
% val indicates callback origin
% (0 : batch mode - 1 : user mode)
if nargin == 2
    val = 1;
end

% Loading Time Reference
if ~exist(fullfile(folder_name,'Time_Reference.mat'),'file')
    errordlg(sprintf('Missing File Time_Reference.mat [%s].',folder_name));
    return;
else
    data_tr = load(fullfile(folder_name,'Time_Reference.mat'));
end

% Loading Video File
if ~exist(fullfile(folder_name,'Video.mat'),'file')
    errordlg(sprintf('Missing Video File [%s].',folder_name));
    return;
else
    data_video = load(fullfile(folder_name,'Video.mat'));
end

% Extractin selected_frames
n_frames = 10;
index_frames = rescale(1:n_frames,1,length(size(data_video.all_frames,3)));
selected_frames = data_video.all_frames(:,:,index_frames);

f = figure('Name',sprintf('Animal Position Detection [%s]',F.nlab),...
    'NumberTitle','off',...
    'Units','normalized',...
    'Tag','DetectionFigure',...
    'Position',[.1 .1 .4 .4]);
% f.UserData.v = v;
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