function [R,EventHeader,MetaData] = read_csv_events(input_file,textsep)
% Read csv file and generates arrays
% Text separator = ',';

if nargin < 2
    textsep = ',';
end

% Sanity Check
if ~isfile(input_file)
    R = [];
    EventHeader = [];
    MetaData = [];
    warning('File not found [%s].',input_file);
    return;
end

fid = fopen(input_file,'r');
hline = fgetl(fid);
temp = regexp(hline,textsep,'split')';
mlines = str2double(strrep(char(temp(contains(temp,'MetadataLines'))),'MetadataLines=',''));
flag_header = str2double(strrep(char(temp(contains(temp,'EventHeader'))),'EventHeader=',''));
elines = str2double(strrep(char(temp(contains(temp,'EventLines'))),'EventLines=',''));

% Metadata
MetaData = [];
for k=1:mlines
    MetaData = [MetaData;{fgetl(fid)}];
end
% Event Header
EventHeader = [];
if flag_header
    hline = fgetl(fid);
    temp = regexp(hline,textsep,'split')';
    EventHeader = [];
    for i = 1:length(temp)
        EventHeader = [EventHeader;temp(i)];
    end
end
% Events
R = [];
for k=1:elines
    hline = fgetl(fid);
    temp = regexp(hline,textsep,'split')';
    cur_event = [];
    for i = 1:length(temp)
        cur_event = [cur_event,str2double(temp(i))];
    end
    R = [R;cur_event];
end

fclose(fid);
fprintf('Event File Loaded [%s].\n',input_file);

end