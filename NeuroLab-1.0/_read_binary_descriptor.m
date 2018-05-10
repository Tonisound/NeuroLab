function S = read_binary_descriptor(filename)

% Importation from header file
fileID = fopen(filename,'r');
raw_list = fread(fileID,'*char')';
rawlist = regexp(raw_list,'(==CHANNEL==|==EPISODE==|==FILENAME==|==OFFSET_AND_PACKET_SIZE==|==#SAMPLE==|==CONTAINER==)','split');

%Channel
channel = regexp(char(rawlist(:,2)),'\r+','split');
channel = channel(~cellfun('isempty',channel));
CHANNEL = regexp(char(channel(1)),'\t+','split');
CHANNEL = regexprep(CHANNEL,'\W','');
for k=2:length(channel)
    CHANNEL = [CHANNEL;regexp(char(channel(k)),'\t','split')];
end
S = cell2struct(CHANNEL(2:end,:),CHANNEL(1,:),2);

%Filename
fname = regexp(char(rawlist(:,4)),'\r+','split');
fname = fname(~cellfun('isempty',fname));
FNAME = [];
for k=1:length(fname)
    FNAME = [FNAME;regexp(char(fname(k)),'\t+','split')];
end
for j=2:size(FNAME,2)
    ind = find(ismember(CHANNEL(:,1),char(FNAME(1,j))));
    S(ind-1).filename = char(FNAME(2,j));
end

% Offset
offset = regexp(char(rawlist(:,5)),'\r+','split');
offset = offset(~cellfun('isempty',offset));
OFFSET = [];
for k=1:length(offset)
    OFFSET = [OFFSET;regexp(char(offset(k)),'\t+','split')];
end
for j=2:size(OFFSET,2)
    ind = find(ismember(CHANNEL(:,1),char(OFFSET(1,j))));
    S(ind-1).packetsize = char(OFFSET(2,j));
    S(ind-1).offset = char(OFFSET(3,j));
end

% Sample
sample = regexp(char(rawlist(:,6)),'\r+','split');
sample = sample(~cellfun('isempty',sample));
SAMPLE = [];
for k=1:length(sample)
    SAMPLE = [SAMPLE;regexp(char(sample(k)),'\t+','split')];
end
for j=2:size(SAMPLE,2)
    ind = find(ismember(CHANNEL(:,1),char(SAMPLE(1,j))));
    S(ind-1).nb_samples = char(SAMPLE(2,j));
end

% Header
header = regexp(char(rawlist(:,1)),'\r+','split');
header = header(~cellfun('isempty',header));
HEADER = [];
for k=1:length(header)
    HEADER = [HEADER;regexp(char(header(k)),'\=+','split')];
end
for j=1:length(S)
    S(j).packet_duration = str2num(char(HEADER(1,2)));
end

% Container
container = regexp(char(rawlist(:,7)),'(\=|\r+)','split');
container = container(~cellfun('isempty',container));
for j=1:length(S)
    S(j).container = char(container(end));
end

end