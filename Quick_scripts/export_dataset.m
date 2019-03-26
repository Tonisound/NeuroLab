function f = export_dataset(seed_folder,handles)

%global DIR_SAVE FILES CUR_FILE 
global START_IM END_IM IM CUR_IM;


export_folder = fullfile(seed_folder,'Export');
promptMessage = sprintf('fUSLab is about to export processed data to [%s].\nDo you want to continue ?',export_folder);
button = questdlg(promptMessage, 'Continue', 'Continue', 'Cancel', 'Continue');
if strcmpi(button, 'Cancel') || isempty(button)
    return;
end

% Creating directory
fprintf('[Exporting Dataset - File %s]\n',seed_folder);
if ~exist(export_folder,'dir')
    mkdir(export_folder);
end


% Copy Doppler 
fprintf('Copying Doppler.mat ...');
copyfile(fullfile(seed_folder,'Doppler.mat'),fullfile(export_folder,'Doppler.mat'));
fprintf(' done.\n');


% Copy Doppler normalized
fprintf('Copying Doppler_normalized.mat ...');
copyfile(fullfile(seed_folder,'Doppler_normalized.mat'),fullfile(export_folder,'Doppler_normalized.mat'));
fprintf(' done.\n');


% Export Regions
fprintf('Copying Regions ...');
ax = handles.CenterAxes;
patches = findobj(ax,'Tag','Region');
% Creating directory
region_dir = fullfile(export_folder,'Regions');
if exist(region_dir,'dir')
    rmdir(region_dir,'s');
end
mkdir(region_dir);
%¨export
for i = 1:length(patches)
    name = patches(i).UserData.UserData.Name;
    mask = patches(i).UserData.UserData.Mask;
    Xdata = patches(i).XData;
    Ydata = patches(i).YData;
    save(fullfile(region_dir,name),'mask','Xdata','Ydata');
end
fprintf(' done.\n');


% Export Time
fprintf('Copying Time ...');
data_t = load(fullfile(seed_folder,'Time_Reference.mat'),'n_burst','length_burst','time_ref');
t = data_t.time_ref.Y;
save(fullfile(export_folder,'Doppler.mat'),'t','-append');
save(fullfile(export_folder,'Doppler_normalized.mat'),'t','-append');
fprintf(' done.\n');


% Export Time Tags
fprintf('Copying Time Tags ...');
data_r = load(fullfile(seed_folder,'Time_Tags.mat'));
for i = 1:length(data_r.TimeTags)
    TimeTags(i).Tag = data_r.TimeTags(i).Tag;
%     TimeTags(i).start = data_r.TimeTags(i).Onset;
%     TimeTags(i).end = data_r.TimeTags(i).Tag;
%     TimeTags(i).t_start = data_r.TimeTags(i).Tag;
%     TimeTags(i).t_end = data_r.TimeTags(i).Tag;
    
    
    tts1 = char(data_r.TimeTags_strings(i,1));
    t_start = (datenum(tts1)-floor(datenum(tts1)))*24*3600;
    TimeTags(i).t_start = t_start;
    tts2 = char(data_r.TimeTags_strings(i,2));
    t_end = (datenum(tts2)-floor(datenum(tts2)))*24*3600;
    TimeTags(i).t_end = t_end;
end

save(fullfile(export_folder,'TimeTags.mat'),'TimeTags');
fprintf(' done.\n');

end