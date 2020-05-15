function success = load_video(folder_name,handles)
% Load Video if file_video exists

video_file = fullfile(folder_name,'Video.mat');

load('Preferences.mat','GImport');
if strcmp(GImport.Video_loading,'skip')
    fprintf('Loading Video skipped [%s].\n',video_file);
    if ~isempty(handles.VideoAxes.UserData)
        delete(handles.VideoAxes.UserData.Image);
        delete(handles.VideoAxes.UserData.Text);
        handles.VideoAxes.UserData = [];
    end
    return;
end

% Loading Video Frames
if exist(video_file,'file')
    fprintf('Loading Video file ...\n');
    data_video = load(video_file);
    fprintf('Video file loaded %s.\n',video_file);
    
    % Plotting Current Frame
    im = imagesc(data_video.all_frames(:,:,1),'Parent',handles.VideoAxes);
    handles.VideoAxes.XTick = [];
    handles.VideoAxes.YTick = [];
    handles.VideoAxes.XTickLabel = [];
    handles.VideoAxes.YTickLabel = [];
    
    % Show timing
    t = text(.05*handles.VideoAxes.XLim(2),.95*handles.VideoAxes.YLim(2),cellstr([{''};{''}]),...
        'Tag','TimingBox','BackgroundColor','none',...
        'Color','w','LineWidth',2,...
        'Parent',handles.VideoAxes);
    t_str1 = datestr(data_video.t_ref(1)/(24*3600),'HH:MM:SS.FFF');
    t_str2 = datestr(data_video.t_video(1)/(24*3600),'HH:MM:SS.FFF');
    t.String(1) = {sprintf('Absolute Time: %s',t_str1)};
    t.String(2) = {sprintf('Relative Time: %s',t_str2)};
    
    %Postion
    %         f=handles.VideoAxes.Parent;
    %         f.Position(4) = f.Position(3)*v.Height/v.Width;
    
    % Storing
    %handles.VideoAxes.UserData.all_frames = data_video.all_frames;
    handles.VideoAxes.UserData = data_video;
    handles.VideoAxes.UserData.VideoFile = video_file;
    handles.VideoAxes.UserData.Image = im;
    handles.VideoAxes.UserData.Text = t;
    handles.VideoAxes.Visible = 'off';
    handles.DisplayMenu_Video.Enable = 'on';
    
else
    if ~isempty(handles.VideoAxes.UserData)
        if ~isempty(handles.VideoAxes.UserData)
            delete(handles.VideoAxes.UserData.Image);
            delete(handles.VideoAxes.UserData.Text);
            handles.VideoAxes.UserData = [];
        end
    end
    % fprintf('Video file not found [%s].\n',video_file);
    warning('Video file not found [%s].',video_file);
    handles.DisplayMenu_Video.Enable = 'off';
end

success = true;

end