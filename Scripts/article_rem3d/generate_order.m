function [ind_sorted,list_sorted,values_sorted] = generate_order(pattern,ledger_txt)

if nargin < 2
    FileName='Fig3_ALL-GROUPS-B-Mean.txt';
    PathName= '/Users/tonio/Documents/MATLAB/NeuroLab/Figure3';
    ledger_txt =  fullfile(PathName,FileName);
end

if nargin < 1
    pattern = 'Ref-Index-REM';
    % pattern = 'Ref-Index-REM-PHASIC-2';
end

% parsing txt file
[list_group,list_regions,tt_data] = parse_txt(ledger_txt);

% selecting pattern vector
ind_selected = find(strcmp(list_group,pattern)==1);
values = tt_data(:,ind_selected);

[~,ind_sorted] = sort(values,'descend');
list_sorted = list_regions(ind_sorted);
values_sorted = values(ind_sorted);

end

function [list_group,list_regions,tt_data] = parse_txt(ledger_txt)

if nargin ==0
    FileName='Fig3_ALL-GROUPS-B-Mean.txt';
    PathName=pwd;
    ledger_txt =  fullfile(PathName,FileName);
end

% Read file
% all_c1 = [];
% all_c4 = [];
fileID = fopen(ledger_txt);
%header
header = regexp(fgetl(fileID),'\t','split');
list_group = [];
for i=1:length(header)
    temp = strtrim(char(header(i)));
    if i==1 || strcmp(temp,'')
        % Ignore first/empty row
        continue;
    else
        list_group = [list_group ;{temp}];
    end
end

list_regions = [];
tt_data = [];
while ~feof(fileID)
    hline = fgetl(fileID);
    cline = regexp(hline,'\t','split');
    list_regions = [list_regions;strtrim(cline(1))];
    tt_data_line = [];
    for j =1:length(list_group)
        tt_data_line = [tt_data_line,eval(char(cline(j+1)))];
    end
    tt_data = [tt_data ;tt_data_line];
end
fclose(fileID);

end