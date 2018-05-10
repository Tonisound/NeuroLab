function import_reference_time(dir_spiko,dir_save,handles)

global LAST_IM IM CUR_IM DIR_SAVE FILES CUR_FILE;
load('Preferences.mat','GImport');

%time_ref = struct('name',{},'nb_images',{},'X',{},'Y',{});
dir_time = dir(fullfile(dir_spiko,'FUS_0_fUS_raw_source*_export'));

switch length(dir_time)
    case 0,
        errordlg(sprintf('Missing Reference FUS_0_fUS_raw_source*_export (Dir %s)',dir_spiko));
        return;
    case 1,
        ind_time=1;
    case 2,
        fprintf('Found several files FUS_0_fUS_raw_source*_export.\n Taking: %s.\n',char(dir_time(1).name))
        %ind_time = listdlg('PromptString','Select Reference Time File','SelectionMode','single','ListString',{dir_time.name},'ListSize',[300 500]);
end

text_file = dir(fullfile(dir_spiko,dir_time(ind_time).name,'*.txt'));
filename = fullfile(dir_spiko,dir_time(ind_time).name,text_file(1).name);

% Direct Importation
fileID = fopen(filename,'r');
fgetl(fileID);
hline = fgetl(fileID);
hline = regexp(hline,'(\t+)','split');

% Reading line-by-line Testing for End of file
tline = fgetl(fileID);
T = str2num(tline);
while ischar(tline)
    try
        tline = fgetl(fileID);
        T = [T;str2num(tline)];
    catch
        fprintf('(Warning) Importation stoped at line %d\n (File : %s)',size(T,1)+1,filename);
    end
end
fclose(fileID);

% Importing Time Reference for Middle Trigger
% k=1 : #
% k=2 : Begin(s)
% k=3 : End(s)
% k=4 : Middle(s)
% k=8 : Frame ID_()
% k=9 : Original frame index_()
k=4;
time_ref.name = char(hline(k));
time_ref.X = T(:,1);
time_ref.Y = T(:,k);
time_ref.nb_images = length(T(:,k));

% Finding bursts when time difference between two images > 10s
% Burst detection stored in GImport
ind_newburst = [1;find(diff(time_ref.Y)>GImport.burst_thresh)+1];
n_burst = length(ind_newburst);
size_burst = diff(ind_newburst);
if n_burst==1
    length_burst = time_ref.nb_images;
else
    if sum(diff(size_burst).^2)==0
        % All burst have the same length
        % Assign length_burst
        length_burst = ind_newburst(2)-ind_newburst(1);
    else
        % Not all burst have the same length
        % Assign length_burst to max and pad missing data
        fprintf('(Warning) Inconsitent burst detection %d\n (File : %s) --> Fixing;\n',size(T,1)+1,filename);
        promptMessage = sprintf('Inconsitent burst detection.\nfUSLab will modify Doppler_film.');
        button = questdlg(promptMessage, 'Continue', 'Continue', 'Cancel', 'Continue');
        if strcmpi(button, 'Cancel')
            return;
        end
        
        % Loading Doppler_film
        fprintf('Loading Doppler_film ...\n');
        load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'),'Doppler_film');
        fprintf('Doppler_film loaded : %s\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'));

        m = max(size_burst);
        for i=1:n_burst-1
            l = size_burst(i);
            if l~=m
                % Padding data with last burst image 
                Doppler_film = cat(3,Doppler_film(:,:,1:ind_newburst(i)+l-1),repmat(Doppler_film(:,:,ind_newburst(i)+l-1),[1,1,m-l]),Doppler_film(:,:,ind_newburst(i)+l:end));
                % Padding time_ref with zeros 
                time_ref.Y = [time_ref.Y(1:ind_newburst(i)+l-1);time_ref.Y(ind_newburst(i)+l-1)+(1:m-l)'*(time_ref.Y(2)-time_ref.Y(1));time_ref.Y(ind_newburst(i)+l:end)];
                ind_newburst = [1;find(diff(time_ref.Y)>GImport.burst_thresh)+1];
            end
        end
        IM = Doppler_film;
        LAST_IM = size(IM,3);
        time_ref.nb_images = LAST_IM;
        time_ref.X = (1:LAST_IM)';
        length_burst =m;
        
        % Saving Doppler_film
        save(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'),'Doppler_film');
        fprintf('Doppler_film saved at %s.mat\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'));
    end
end

% Reloading Doppler_film
if ~exist('Doppler_film','var')
    fprintf('Loading Doppler_film ...\n');
    load(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'),'Doppler_film');
    fprintf('Doppler_film loaded : %s\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'));
end
    
% Check fUS
% Removing data points where variance is too high
test = permute(mean(mean(Doppler_film,2,'omitnan'),1,'omitnan'),[3,1,2]);
test = (test-mean(test))/std(test);
ind_remove = find(test.^2>9);

% CHECKPOINT HERE WHEN LOADING
for i=1:length(ind_remove)
    Doppler_film(:,:,ind_remove(i))=Doppler_film(:,:,ind_remove(i)-1);
end

% Doppler Resampling
delta_t = time_ref.Y(2)-time_ref.Y(1);
if n_burst==1
    rate = round(delta_t/GImport.resamp_cont);
else
    rate = round(delta_t/GImport.resamp_burst);
end
if rate>1
    promptMessage = sprintf('fUSLab is about to resample by factor %d,\nThis will modify Doppler_film.\nDo you want to continue ?',rate);
    button = questdlg(promptMessage, 'Continue', 'Continue', 'Cancel', 'Continue');
    if strcmpi(button, 'Cancel')
        return;
    end
    
    % Reshaping Doppler_film
    temp=[];
    Doppler_line = reshape(permute(Doppler_film,[3,1,2]),[size(Doppler_film,3) size(IM,1)*size(Doppler_film,2)]);
    Doppler_dummy = [Doppler_line;Doppler_line(end,:)];
    Doppler_line = resample(Doppler_dummy,rate,1);
    Doppler_line = Doppler_line(1:end-rate,:);
    Doppler_resample = zeros(size(IM,1),size(IM,2),size(Doppler_line,1));
    for k = 1:size(Doppler_line,1)
        Doppler_resample(:,:,k) = reshape(Doppler_line(k,:),[size(IM,1),size(IM,2)]);
        temp=[temp;time_ref.Y(ceil(k/rate))+(delta_t/rate*mod(k-1,rate))];
    end
    % Removing last image
    for i = flip(length_burst*rate*(1:n_burst)')
        Doppler_resample(:,:,i)=[];
        temp(i)=[];
    end
    Doppler_film = Doppler_resample;
    
    % Reshaping time_ref
    time_ref.Y = temp;
    time_ref.X = (1:length(temp))';
    time_ref.nb_images = length(time_ref.Y);
    length_burst = length_burst*rate-1;
        
end

% Updating global variables
IM = Doppler_film;
LAST_IM = size(IM,3);
% Saving Doppler_film
save(fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'),'Doppler_film','-v7.3');
fprintf('Doppler_film saved at %s.mat\n',fullfile(DIR_SAVE,FILES(CUR_FILE).gfus,'Doppler.mat'));

% Save dans ReferenceTime.mat
if  ~isempty(time_ref)
    if time_ref.nb_images~=LAST_IM;
        errordlg(sprintf('Non matching Time Dimensions LAST_IM = %d Ref_Time = %d',LAST_IM,length(T(:,1))));
        return;
    else
        save(fullfile(dir_save,'Time_Reference.mat'),'time_ref','n_burst','length_burst');
        handles.TimeDisplay.UserData = datestr((time_ref.Y)/(24*3600),'HH:MM:SS.FFF');
        handles.TimeDisplay.String = datestr(time_ref.Y(CUR_IM)/(24*3600),'HH:MM:SS.FFF');
        
        fprintf('Succesful Reference Time Importation (File %s /Folder %s).\n', text_file(1).name,dir_time(ind_time).name);
        fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Time_Reference.mat'));
    end
end

end
