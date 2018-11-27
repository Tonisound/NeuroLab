function success = import_video(video_file,handles)
% Load Video if file_video exists

load('Preferences.mat','GImport');
if strcmp(GImport.Video_loading,'skip')
    fprintf('Loading Video skipped : %s\n',video_file);
    if ~isempty(handles.VideoAxes.UserData)
        delete(handles.VideoAxes.UserData.Image);
        delete(handles.VideoAxes.UserData.VideoReader);
        handles.VideoAxes.UserData = [];
    end
    return;
end


%global CUR_IM;

load('Preferences.mat','GTraces');
%load_fmt = GTraces.GraphicLoadFormat;
%success = false;

% Load Video File as Video Reader
if exist(video_file,'file')
    if contains(video_file,'.mpg')
        tic
        fprintf('Loading Video file ...\n');
        v = VideoReader(video_file);
        fprintf('Video file loaded %s.\n',video_file);
        
        % Reading Current Frame
        temp = datenum(handles.TimeDisplay.UserData(1,:));
        v.CurrentTime = (temp-floor(temp))*24*3600;
        vidFrame = readFrame(v);
        
        % Plotting Current Frame
        %im = image(zeros(v.Width,v.Height,3),'Parent',handles.VideoAxes);
        im = image(vidFrame,'Parent',handles.VideoAxes);
        handles.VideoAxes.XTick = [];
        handles.VideoAxes.YTick = [];
        handles.VideoAxes.XTickLabel = [];
        handles.VideoAxes.YTickLabel = [];
        
        % Storing
        handles.VideoAxes.UserData.VideoFile = video_file;
        handles.VideoAxes.UserData.VideoReader = v;
        handles.VideoAxes.UserData.Image = im;
        handles.VideoAxes.UserData.rgb_video = [];
        handles.VideoAxes.UserData.start_im = 0;
        handles.VideoAxes.UserData.end_im = 0;
        handles.VideoAxes.Visible = 'off';
        handles.DisplayMenu_Video.Enable = 'on';
        toc
        
    elseif contains(video_file,'.avi')
        % canceling importation to prevent bug
        warning('Video file format causing Matlab shutdown. Skipping. [%s]',video_file);
        if ~isempty(handles.VideoAxes.UserData)
            delete(handles.VideoAxes.UserData.Image);
            delete(handles.VideoAxes.UserData.VideoReader);
            handles.VideoAxes.UserData = [];
        end
        handles.DisplayMenu_Video.Enable = 'off';
    end
else
    if ~isempty(handles.VideoAxes.UserData)
        if ~isempty(handles.VideoAxes.UserData)
            delete(handles.VideoAxes.UserData.Image);
            delete(handles.VideoAxes.UserData.VideoReader);
            handles.VideoAxes.UserData = [];
        end
        handles.DisplayMenu_Video.Enable = 'off';
    end
    fprintf('Video file not found.\n');
end

success = true;

end