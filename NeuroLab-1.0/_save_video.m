function save_video(workingDir,savedir,video_name)

load('Preferences.mat','GTraces');
switch GTraces.CompressionFormat
    case 'MPEG-4'
        %MPEG-4 file with H.264 encoding (systems with Windows 7 or later, or Mac OS X 10.7 and later)
        extension = '.mp4';
    case {'Motion JPEG AVI','Uncompressed AVI','Indexed AVI','Grayscale AVI'}
        %AVI file using Motion JPEG encoding
        %Uncompressed AVI file with RGB24 video
        %Uncompressed AVI file with indexed video
        %Uncompressed AVI file with grayscale video
        extension = '.avi';
    case {'Motion JPEG 2000','Archival'}
        %Motion JPEG 2000 file
        %Motion JPEG 2000 file with lossless compression
        extension = '.mj2';
    otherwise
        errordlg('Unrecognized Video Encoding Format');
        return;
end

yourfolder= dir(fullfile(workingDir,strcat('*',GTraces.ImageSaveExtension))); 
xlsfiles = {yourfolder.name}; 
[~,idx] = sort(xlsfiles);
new_folder = yourfolder(idx);
imageNames = {new_folder.name}';

outputVideo = VideoWriter(fullfile(savedir,strcat(video_name,extension)),GTraces.CompressionFormat);
outputVideo.FrameRate = GTraces.FrameRate;
open(outputVideo);

for ii = 1:length(imageNames)
   img = imread(fullfile(workingDir,imageNames{ii}));
   writeVideo(outputVideo,img)
end

fprintf('Video Saved at %s\n',fullfile(savedir,strcat(video_name,extension)));
fprintf('[Working Directory: %s]\n',workingDir);
close(outputVideo);

end