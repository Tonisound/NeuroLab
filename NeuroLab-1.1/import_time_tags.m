 function success = import_time_tags(dir_tags,dir_save)

success = false;
dir_time = dir(fullfile(dir_tags,'*tags.txt'));
% Removing hidden files
dir_time = dir_time(arrayfun(@(x) ~strcmp(x.name(1),'.'),dir_time));

switch length(dir_time)
    case 0
        errordlg(sprintf('Missing Time Tags File *tags.txt (Dir %s)',dir_tags));
        return;
    case 1
        ind_time = 1;
    otherwise
        [ind_time,ok] = listdlg('PromptString','Select Time tags to import',...
            'SelectionMode','multiple','ListString',{dir_time.name},'ListSize',[300 500]);
        if isempty(ind_time) || ~ok
            return;
        end
end

tag = [];
t_start = [];
t_end = [];
for i=1:length(ind_time)
    filename = fullfile(dir_tags,dir_time(ind_time(i)).name);
    
    % Direct Importation
    fileID = fopen(filename,'r');
    hline = fgetl(fileID);
    hline = regexp(hline,'(\t+)','split');
    
    % Reading line-by-line Testing for End of file
    while ~feof(fileID)
        tline = fgetl(fileID);
        if ~isempty(tline)
            temp = regexp(tline,'(\t+)','split');
            tag = [tag;strtrim(temp(1))];
%             t_start = [t_start;eval(char(temp(2)))];
%             t_end = [t_end;eval(char(temp(3)))];
            t_start = [t_start;str2double(char(temp(2)))];
            t_end = [t_end;str2double(char(temp(3)))];
        end
    end
    fclose(fileID); 
end

%TimeTags_strings
tts_1 = cellstr(datestr(t_start/(24*3600),'HH:MM:SS.FFF'));
tts_2 = cellstr(datestr((t_end-t_start)/(24*3600),'HH:MM:SS.FFF'));
TimeTags_strings = [tts_1,tts_2];
TimeTags_seconds = [t_start,t_end];
TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');

% TimeTags_cell & TimeTags
n = length(tag);
TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
TimeTags_cell = cell(n+1,6);
TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'};

for k=1:n
    TimeTags_cell(k+1,:) = {'',char(tag(k)),char(TimeTags_strings(k,1)),char(TimeTags_dur(k,:)),char(TimeTags_strings(k,1)),''};
    TimeTags(k,1).Episode = '';
    TimeTags(k,1).Tag = char(tag(k));
    TimeTags(k,1).Onset = char(TimeTags_strings(k,1));
    TimeTags(k,1).Duration = char(TimeTags_dur(k,:));
    TimeTags(k,1).Reference = char(TimeTags_strings(k,1));
    TimeTags(k,1).Tokens = '';
end

% TimeTags_images
data_t = load(fullfile(dir_save,'Time_Reference.mat'),'time_ref');
% temp = datenum(handles.TimeDisplay.UserData);
% tts = (temp-abs(temp))*24*3600;
tts = data_t.time_ref.Y;
TimeTags_images = zeros(n,2);
for k=1:size(TimeTags_strings,1)
    min_time = t_start(k);
    max_time = t_end(k);
    [~, ind_min_time] = min(abs(tts-datenum(min_time)));
    [~, ind_max_time] = min(abs(tts-datenum(max_time)));
    %TimeTags_strings(k,:) = {min_time,max_time};
    TimeTags_images(k,:) = [ind_min_time,ind_max_time];
end


% Loading Time Tags
if exist(fullfile(dir_save,'Time_Tags.mat'),'file')
    tdata = load(fullfile(dir_save,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
    TimeTags_images = [tdata.TimeTags_images;TimeTags_images];
    TimeTags_strings = [tdata.TimeTags_strings;TimeTags_strings];
    TimeTags_cell = [tdata.TimeTags_cell;TimeTags_cell(2:end,:)];
    TimeTags = [tdata.TimeTags;TimeTags];
end

% Saving
save(fullfile(dir_save,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
for i=1:length(ind_time)
fprintf('Time Tags importation successful [%s].\n',fullfile(dir_tags,dir_time(ind_time(i)).name));
end

end
