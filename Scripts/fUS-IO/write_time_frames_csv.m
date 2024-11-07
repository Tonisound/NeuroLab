function write_time_frames_csv(filepath_csv,t_tracking,t_apparent,video_name,numVidFrames,numGotFrames,numTrackedFrames)

if nargin <3
    video_name = '';
end
if nargin <4
    numVidFrames = NaN;
end

fid_csv = fopen(filepath_csv,'w');
fprintf(fid_csv,'%s',sprintf('VideoName=%s,NumVidFrames=%d,NumGotFrames=%d,NumTrackedFrames=%d\n',...
    video_name,numVidFrames,numGotFrames,numTrackedFrames));
fprintf(fid_csv,'%s',sprintf('FrameNumber,Real Time (s),Apparent Time (s)\n'));
for k = 1:length(t_tracking)
    fprintf(fid_csv,'%s',sprintf('%d,%.3f,%.3f\n',k,t_tracking(k),t_apparent(k)));
end
fclose(fid_csv);

end