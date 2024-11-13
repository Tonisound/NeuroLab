function [t,Y] = fiber_csv_ext(filepath_csv)

fid = fopen(filepath_csv,'r');
header = regexp(fgetl(fid),',','split');
% thresh = str2double(regexprep(header(1),'Threshold=',''));
% step = str2double(regexprep(header(2),'BinSize=',''));
% nTrigs = str2double(regexprep(header(3),'NumTrigs=',''));

t = [];
Y = [];
    
while ~feof(fid)
    hline = regexp(fgetl(fid),',','split');
    t = [t;str2double(hline(1))];
    Y = [Y;str2double(hline(2))];
end
fclose(fid);

write_ext_file(t2,Y,'fiber-test.ext','Nico','ACh','Grab-ACh-DG-R');

end