function [time_rising,time_falling,thresh,step] = read_trigger_csv(filepath_csv)

time_rising=[];
time_falling=[];
thresh = 'NaN';
step = 1;

fid = fopen(filepath_csv,'r');
header = regexp(fgetl(fid),',','split');
thresh = str2double(regexprep(header(1),'Threshold=',''));
step = str2double(regexprep(header(2),'BinSize=',''));
% nTrigs = str2double(regexprep(header(3),'NumTrigs=',''));

header2 = regexp(fgetl(fid),',','split');

while ~feof(fid)
    hline = regexp(fgetl(fid),',','split');
    time_rising = [time_rising;str2double(hline(1))];
    time_falling = [time_falling;str2double(hline(2))];
end
fclose(fid);

end