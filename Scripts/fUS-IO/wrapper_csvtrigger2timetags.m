global FILES DIR_SAVE;

for i = 1:length(FILES)

folder_name = fullfile(DIR_SAVE,FILES(i).nlab);
    
filepath_tt = fullfile(folder_name,'Time_Tags.mat');
if ~isfile(filepath_tt)
    warning('File Time_Tags.mat not found [%s].',folder_name);
    continue;
end
tt_data = load(filepath_tt);

% % Keeping only first time tag
% % Uncomment if needed
% tt_data.TimeTags = tt_data.TimeTags(1);
% tt_data.TimeTags_cell = tt_data.TimeTags_cell(1:2,:);
% tt_data.TimeTags_images = tt_data.TimeTags_images(1,:);
% tt_data.TimeTags_strings = tt_data.TimeTags_strings(1,:);

filepath_tr = fullfile(folder_name,'Time_Reference.mat');
if ~isfile(filepath_tr)
    warning('File Time_Reference.mat not found [%s].',folder_name);
    continue;
end
tr_data = load(filepath_tr);

filepath_csv = fullfile(FILES(i).fullpath,FILES(i).dir_lfp,'trigger_adc-01.csv');
if ~isfile(filepath_csv)
    warning('CSV Trigger file not found [%s].',fullfile(FILES(i).fullpath,FILES(i).dir_lfp));
    continue;
end
[time_rising,time_falling,thresh,step] = read_trigger_csv(filepath_csv);

% Building all_times and all_tags
all_times = [330,390;570,630];
all_tags = [{'Injection-Saline'};{'Injection-Drug'}];
for i =1:size(time_rising,1)
    all_times = [all_times;time_rising(i) time_falling(i)];
    if i>=1 && i<=3
        all_tags = [all_tags;{'Stim-Control'}];
    elseif i>=4 && i<=12
        all_tags = [all_tags;{'Stim-Test'}];
    end
end

TimeTags_strings = [];
TimeTags_images = [];
TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
% TimeTags_cell = cell(n_ep+1,6);
% TimeTags_cell(1,:) = {'Episode','Tag','Onset','Duration','Reference','Tokens'};

for i = 1:length(all_tags)
    TimeTags_strings = [{datestr(all_times(i,1)/(24*3600),'HH:MM:SS.FFF')},{datestr(all_times(i,2)/(24*3600),'HH:MM:SS.FFF')}];
    TimeTags_seconds = all_times(i,:);
    TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
    [~, ind_min_time] = min(abs(tr_data.time_ref.Y-all_times(i,1)));
    [~, ind_max_time] = min(abs(tr_data.time_ref.Y-all_times(i,2)));
    TimeTags_images = [ind_min_time,ind_max_time];
    temp_cell = {'',char(all_tags(i)),char(TimeTags_strings(1)),char(TimeTags_dur),char(TimeTags_strings(1)),''};
    TimeTags.Episode = '';
    TimeTags.Tag = char(all_tags(i));
    TimeTags.Onset = char(TimeTags_strings(1));
    TimeTags.Duration = char(TimeTags_dur);
    TimeTags.Reference = char(TimeTags_strings(1));
    TimeTags.Tokens = '';
    
    % Adding
    tt_data.TimeTags_strings = [tt_data.TimeTags_strings;TimeTags_strings];
    tt_data.TimeTags_images = [tt_data.TimeTags_images;TimeTags_images];
    tt_data.TimeTags_cell = [tt_data.TimeTags_cell;temp_cell];
    tt_data.TimeTags = [tt_data.TimeTags;TimeTags];
    
end

% Save
TimeTags_images = tt_data.TimeTags_images;
TimeTags_strings = tt_data.TimeTags_strings;
TimeTags_cell = tt_data.TimeTags_cell;
TimeTags = tt_data.TimeTags;TimeTags;
save(filepath_tt,'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
fprintf('===> Time Tags overwritten [%s].\n',filepath_tt);

end