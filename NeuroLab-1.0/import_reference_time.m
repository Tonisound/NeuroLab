function import_reference_time(F,Doppler_film,handles)
% Import reference time - Detects NEV channel and extracts trigger from it
% Adds one trigger if discrepancy between fus data and trigger number

%global LAST_IM IM CUR_IM  FILES CUR_FILE;
global CUR_IM DIR_SAVE;
load('Preferences.mat','GImport');
dir_save = fullfile(DIR_SAVE,F.nlab);

% Trigger Importation
if exist(fullfile(F.fullpath,F.nev), 'file')
    fprintf('Importing Neural-Event data.\n');
    data_nev = openNEV(fullfile(F.fullpath,F.nev),'nosave','nomat');
else
    % Missing NEV : template trigger
    warning('Missing NEV file.\n');
    templatetrigg_save(Doppler_film, dir_save,handles);
    return;
end

% Asks User to pick trigger chanel if two or more channels detected
trig_list  = unique(data_nev.Data.Spikes.Electrode);
switch length(trig_list) 
    case 0
        % Missing NEV : template trigger
        warning('No trigger channel found: using template trigger.\n');
        templatetrigg_save(Doppler_film, dir_save,handles);
        return;
        
    case 1
        fprintf('Trigger channel detected : %d.\n',trig_list(1));
        ind_trig = 1;
        
    otherwise
        [ind_trig,v] = listdlg('Name','Tag Selection','PromptString','Select Triger',...
            'SelectionMode','single','ListString',trig_list,...
            'InitialValue',1,'ListSize',[300 500]);
        if v==0
            return;
        elseif isempty(ind_tag)
            return;
        else
            %trigger = trig_list(ind_trig);
            fprintf('Trigger channel detected : %d.\n',trig_list(ind_trig))
        end
end

% Extracting_timing
f_trig = 30000;
time_stamp_raw = data_nev.Data.Spikes.TimeStamp(data_nev.Data.Spikes.Electrode==trig_list(ind_trig))';
trigger_raw = double(time_stamp_raw)/f_trig;
n_images = size(Doppler_film,3);

% Test if trigger matches Doppler_film size
if n_images~= length(trigger_raw)
    if length(trigger_raw) < n_images
        
        warning('Trigger (%d) and IM size (%d) do not match [Missing end trig]. -> Adding end trig',length(trigger_raw),n_images);
        discrepant = n_images-length(trigger_raw);
        padding = 'missing';
        % extend trigger using delta_trig
        delta_trig = trigger_raw(2)-trigger_raw(1);
        additional_trigs = (1:discrepant)'*delta_trig;
        trigger = [trigger_raw; trigger_raw(end)+additional_trigs];
        time_stamp = [time_stamp_raw; time_stamp_raw(end)+time_stamp_raw(2)-time_stamp_raw(1)];
        
    elseif length(trigger_raw) > n_images
        
        warning('Trigger (%d) and IM size (%d) do not match [Excess trigs]. -> Discarding end trigs',length(trigger_raw),n_images);
        discrepant = n_images-length(trigger_raw);
        padding = 'excess'; 
        % keep only first triggers
        trigger = trigger_raw(end-n_images+1:end);
        %trigger = trigger_raw(1:n_images);
        time_stamp = time_stamp_raw(1:n_images);
            
    end
else
    discrepant = 0;
    padding = 'exact';
    trigger = trigger_raw;
    time_stamp = time_stamp_raw;
end

time_ref.name = sprintf('Channel %d',trig_list(ind_trig));
time_ref.X = (1:length(trigger))';
time_ref.Y = trigger;
time_ref.time_stamp = time_stamp;
time_ref.nb_images = length(trigger);
n_burst = 1;
length_burst = length(trigger);
reference = time_ref.name;

% Save dans ReferenceTime.mat
if  ~isempty(time_ref)
    time_str = cellstr(datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF'));
    handles.TimeDisplay.UserData = char(time_str);
    handles.TimeDisplay.String = char(time_str(CUR_IM));
    %datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF');
    save(fullfile(dir_save,'Time_Reference.mat'),'time_str','time_ref','n_burst','length_burst','n_images',...
        'reference','padding','discrepant','trigger','trigger_raw','time_stamp','time_stamp_raw','-v7.3');
    fprintf('Succesful Reference Time Importation\n===> Saved at %s.mat\n',fullfile(dir_save,'Time_Reference.mat'));
end

end

function templatetrigg_save(Doppler_film,dir_save,handles)

global CUR_IM;

n_images = size(Doppler_film,3);
n_burst = 1;
length_burst = n_images;
reference = 'default';
padding = 'none';
discrepant = 0;
trigger_raw = (0:length_burst-1)'/2.5;
trigger = trigger_raw;
time_stamp_raw = single(30000*trigger_raw);
time_stamp = time_stamp_raw;

time_ref.X=(1:length_burst)';
time_ref.Y=trigger;
time_ref.nb_images= n_images;
time_ref.name = reference;
time_ref.time_stamp = [];
time_str = cellstr(datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF'));
handles.TimeDisplay.UserData = char(time_str);
handles.TimeDisplay.String = char(time_str(CUR_IM));
%datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF');

save(fullfile(dir_save,'Time_Reference.mat'),'time_str','time_ref','n_burst','length_burst','n_images',...
    'reference','padding','discrepant','trigger','trigger_raw','time_stamp','time_stamp_raw','-v7.3');
fprintf('Time_Reference.mat saved at %s.\n',fullfile(dir_save,'Time_Reference.mat'));

end
