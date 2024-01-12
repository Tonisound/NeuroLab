global DIR_STATS DIR_SAVE;

d_mat = dir(fullfile(DIR_STATS,'Event_Imaging','*','*','*.mat'));

for i =1:length(d_mat)
    data_mat = load(fullfile(d_mat(i).folder,d_mat(i).name));
    recording_name = data_mat.Params.recording_name;
    timegroup='NREM';
    % Loading time groups
    data_tg = load(fullfile(DIR_SAVE,recording_name,'Time_Groups.mat'));
    ind_group = strcmp(data_tg.TimeGroups_name,timegroup);
    if isempty(ind_group)
        warning('Time Group not found [%s-%s]',recording_name,timegroup);
        timegroup_duration = 0;
        density_events = 0;
    else
        temp = datenum(data_tg.TimeGroups_duration);
        all_tg_dur = 24*3600*(temp-floor(temp));
        timegroup_duration = all_tg_dur(ind_group);
        density_events = data_mat.Params.n_events/timegroup_duration;   
    end
    Params=data_mat.Params;
    Params.timegroup = timegroup;
    Params.timegroup_duration = timegroup_duration;
    Params.density_events = density_events;
    
    save(fullfile(d_mat(i).folder,d_mat(i).name),'Params','-append');
    fprintf('[%d/%d].\n',i,length(d_mat));
end