function import_reference_time(dir_save,handles)

global LAST_IM IM CUR_IM DIR_SAVE FILES CUR_FILE;
load('Preferences.mat','GImport');

% Trigger Importation
if exist(fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).nev), 'file')
    fprintf('Importing Neural-Event data.\n');
    data_nev = openNEV(fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).nev));
else
    errrordlg('Missing NEV file.\n');
end

% Asks User to pick trigger chanel if two or more channels detected
trig_list  = unique(data_nev.Data.Spikes.Electrode);
switch length(trig_list) 
    case 0
        errordlg('No trigger channel found');
        return
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

% Test if trigger matches IM size
if size(IM,3)~= length(trigger)
    warning('Trigger (%d) and IM size (%d) do not match.\n',length(trigger),size(IM,3));
    if length(trigger)+1 == size(IM,3)
        trigger = [trigger; trigger(end)+trigger(2)-trigger(1)];
        time_stamp = [time_stamp; time_stamp(end)+time_stamp(2)-time_stamp(1)];
    else
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

% % Reloading Doppler_film
% if ~exist('Doppler_film','var')
%     fprintf('Loading Doppler_film ...\n');
%     load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'),'Doppler_film');
%     fprintf('Doppler_film loaded : %s\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'));
% end
%     
% % Check fUS
% % Removing data points where variance is too high
% test = permute(mean(mean(Doppler_film,2,'omitnan'),1,'omitnan'),[3,1,2]);
% test = (test-mean(test))/std(test);
% ind_remove = find(test.^2>9);
% 
% % CHECKPOINT HERE WHEN LOADING
% for i=1:length(ind_remove)
%     Doppler_film(:,:,ind_remove(i)) = Doppler_film(:,:,ind_remove(i)-1);
% end
% 
% % Doppler Resampling
% delta_t = time_ref.Y(2)-time_ref.Y(1);
% if n_burst==1
%     rate = round(delta_t/GImport.resamp_cont);
% else
%     rate = round(delta_t/GImport.resamp_burst);
% end
% if rate>1
%     promptMessage = sprintf('fUSLab is about to resample by factor %d,\nThis will modify Doppler_film.\nDo you want to continue ?',rate);
%     button = questdlg(promptMessage, 'Continue', 'Continue', 'Cancel', 'Continue');
%     if strcmpi(button, 'Cancel')
%         return;
%     end
%     
%     % Reshaping Doppler_film
%     temp=[];
%     Doppler_line = reshape(permute(Doppler_film,[3,1,2]),[size(Doppler_film,3) size(IM,1)*size(Doppler_film,2)]);
%     Doppler_dummy = [Doppler_line;Doppler_line(end,:)];
%     Doppler_line = resample(Doppler_dummy,rate,1);
%     Doppler_line = Doppler_line(1:end-rate,:);
%     Doppler_resample = zeros(size(IM,1),size(IM,2),size(Doppler_line,1));
%     for k = 1:size(Doppler_line,1)
%         Doppler_resample(:,:,k) = reshape(Doppler_line(k,:),[size(IM,1),size(IM,2)]);
%         temp=[temp;time_ref.Y(ceil(k/rate))+(delta_t/rate*mod(k-1,rate))];
%     end
%     % Removing last image
%     for i = flip(length_burst*rate*(1:n_burst)')
%         Doppler_resample(:,:,i)=[];
%         temp(i)=[];
%     end
%     Doppler_film = Doppler_resample;
%     
%     % Reshaping time_ref
%     time_ref.Y = temp;
%     time_ref.X = (1:length(temp))';
%     time_ref.nb_images = length(time_ref.Y);
%     length_burst = length_burst*rate-1;
%         
% end
% 
% % Updating global variables
% IM = Doppler_film;
% LAST_IM = size(IM,3);
% % Saving Doppler_film
% save(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'),'Doppler_film','-v7.3');
% fprintf('Doppler_film saved at %s.mat\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'));

% Save dans ReferenceTime.mat
if  ~isempty(time_ref)
    
    save(fullfile(dir_save,'Time_Reference.mat'),'time_ref','n_burst','length_burst','reference','-v7.3');
    handles.TimeDisplay.UserData = datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF');
    handles.TimeDisplay.String = datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF');
    fprintf('Succesful Reference Time Importation\n===> Saved at %s.mat\n',fullfile(dir_save,'Time_Reference.mat'));
    
end

end
