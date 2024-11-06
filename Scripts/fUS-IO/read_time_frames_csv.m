function [t_tracking,t_apparent,video_name,numVidFrames] = read_time_frames_csv(filepath_csv)

t_tracking=[];
t_apparent=[];
video_name = '';
numVidFrames = NaN;

fid = fopen(filepath_csv,'r');
header = regexp(fgetl(fid),',','split');
video_name = str2double(regexprep(header(1),'VideoName=',''));
numVidFrames = str2double(regexprep(header(2),'NumVidFrames=',''));

header2 = regexp(fgetl(fid),',','split');

frameId = [];
t_tracking = [];
while ~feof(fid)
    hline = regexp(fgetl(fid),',','split');
    frameId = [frameId;str2double(hline(1))];
    t_tracking = [t_tracking;str2double(hline(2))];
    t_apparent = [t_apparent;str2double(hline(3))];
end
fclose(fid);

end