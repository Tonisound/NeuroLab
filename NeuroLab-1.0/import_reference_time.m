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
time_stamp = data_nev.Data.Spikes.TimeStamp(data_nev.Data.Spikes.Electrode==trig_list(ind_trig))';
trigger = double(time_stamp)/f_trig;

% Test if trigger matches Doppler_film size
if size(Doppler_film,3)~= length(trigger)
    if length(trigger)+1 == size(Doppler_film,3)
        warning('Trigger (%d) and IM size (%d) do not match. -> Adding end trig',length(trigger),size(Doppler_film,3));
        % extend one trigger
        trigger = [trigger; trigger(end)+trigger(2)-trigger(1)];
        time_stamp = [time_stamp; time_stamp(end)+time_stamp(2)-time_stamp(1)];
    elseif length(trigger) > size(Doppler_film,3)
        warning('Trigger (%d) and IM size (%d) do not match. -> Discarding end trigs',length(trigger),size(Doppler_film,3));
        % keep only first triggers
        trigger = trigger(end-size(Doppler_film,3)+1:end);
        %trigger = trigger(1:size(Doppler_film,3));
        time_stamp = time_stamp(1:size(Doppler_film,3));
    else
        errordlg('Trigger (%d) and IM size (%d) do not match.\n',length(trigger),size(Doppler_film,3));
        return;
    end
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
    save(fullfile(dir_save,'Time_Reference.mat'),'time_ref','n_burst','length_burst','reference','-v7.3');
    handles.TimeDisplay.UserData = datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF');
    handles.TimeDisplay.String = datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF');
    fprintf('Succesful Reference Time Importation\n===> Saved at %s.mat\n',fullfile(dir_save,'Time_Reference.mat'));
end

end

function templatetrigg_save(Doppler_film,dir_save,handles)

global CUR_IM;

n_burst = 1;
length_burst = size(Doppler_film,3);
reference = 'default';
time_ref.X=(1:length_burst)';
time_ref.Y=(0:length_burst-1)'/2.5;
time_ref.nb_images= size(Doppler_film,3);
time_ref.name = reference;
time_ref.time_stamp = [];
save(fullfile(dir_save,'Time_Reference.mat'),'time_ref','n_burst','length_burst','reference','-v7.3');
handles.TimeDisplay.UserData = datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF');
handles.TimeDisplay.String = datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF');
fprintf('Time_Reference.mat saved at %s.\n',fullfile(dir_save,'Time_Reference.mat'));

end
