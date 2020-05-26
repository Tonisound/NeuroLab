function Bin2MatFus()

% Loading data from binary files
Info=loadEXP([],'no');
[Data,Time]=ExtractContinuousData([],Info,[],0, inf,[],1);
StartTimeStr=datestr(Info.BinFiles(1).TStart,'yyyymmdd');

% Export data in mat format
% Suffixe = 'default';
% Newmatfile=fullfile(Info.FilesDir,[StartTimeStr '_'  Suffixe '.mat']);
% save(Newmatfile,'Data','Time','Info','-v7.3');
% disp('done');

% Getting LFP-Video delay
% LFP-VIDEO Delay (Default: 0)
delay_lfp_video = 0;
if ~isempty(Info.VideosFiles) && ~isempty(Info.BinFiles)
    all_delays = [];
    for i =1:length(Info.VideosFiles.Files)
        all_delays = [all_delays;(Info.VideosFiles.Files(i).TStart-Info.BinFiles.TStart)*24*3600];
    end
    [~,ind_min_delay] = min(abs(all_delays));
    delay_lfp_video = all_delays(ind_min_delay);
else
    ind_min_delay = [];
end

% Getting dir names
global SEED;
if exist(SEED,'dir')
    folder_name = uigetdir(SEED,'Select Destination Folder');
else
    folder_name = uigetdir('Select Destination Folder');
end
temp = regexp(folder_name,filesep,'split');
recording = char(temp(end));
dir_fus = strrep(recording,'_E','_fus');
dir_lfp = strrep(recording,'_E','_lfp');
if ~exist(fullfile(folder_name,dir_lfp),'dir')
    mkdir(fullfile(folder_name,dir_lfp));
end

% Finding trigger channel
ind_ttl = find(contains(lower(Info.ChLabel),'ttl'));
if isempty(ind_ttl)
    warning('No TTL channel found [%s]. Creating default trigger.\n',Info.ExpFileName);  
    ttl_name = 'none';
    ind_ttl = 0;
elseif length(ind_ttl)>1
    warning('Multiple TTL channels found [%s]. Selecting first channel [%d].\n',Info.ExpFileName,ind_ttl(1));
    ind_ttl = ind_ttl(1);
    ttl_name = char(Info.ChLabel(ind_ttl));
else
    fprintf('TTL channel found in [%s]: Channel id: %d, Channel name: %s.\n',Info.ExpFileName,ind_ttl,char(Info.ChLabel(ind_ttl)));
    ttl_name = char(Info.ChLabel(ind_ttl));
end

% Open acq file to get n_frames
dd = dir(fullfile(folder_name,dir_fus,'*.acq'));
if length(dd)>1
    warning('Multiple acq file found [%s]. Taking first.',fullfile(folder_name,dir_fus));
elseif length(dd) == 0
    warning('No acq file found [%s].',fullfile(folder_name,dir_fus));
    return;
end
fprintf('Loading acq file [%s]...',dd(1).name);
data_acq = load(fullfile(folder_name,dir_fus,dd(1).name),'-mat');
fprintf(' done.\n');

%Extract trigger
if ind_ttl ~= 0
    % Trigger Extraction
    f_trig = 1024;
    n_frames = size(data_acq.Acquisition.Data,4);
    Data_ttl = Data(ind_ttl,:);
    reference = sprintf('channel%d-%s[%s]',ind_ttl,ttl_name,Info.ExpFileName);
    [trigger,padding] = extract_trigger_oneiros(Data_ttl,f_trig,n_frames);
    
    if isempty(trigger)
        [trigger,reference,padding] = extract_trigger_nottl(data_acq,f_def);
    end
else
    % Void Extraction
    f_def = 1.0;
    [trigger,reference,padding] = extract_trigger_nottl(data_acq,f_def);
end

% Trigger Offset (Default: 0)
offset = 0;

% Write trigger file
file_txt = fullfile(folder_name,dir_fus,'trigger.txt');
fid_txt = fopen(file_txt,'w');    
fprintf(fid_txt,'%s',sprintf('<REF>\n%s</REF>\n',reference));
fprintf(fid_txt,'%s',sprintf('<PAD>\n%s</PAD>\n',padding));
fprintf(fid_txt,'%s',sprintf('<OFFSET>%.3f</OFFSET>\n',offset));
fprintf(fid_txt,'%s',sprintf('<DELAY>%.3f</DELAY>\n',delay_lfp_video));
fprintf(fid_txt,'%s',sprintf('<TRIG>\n'));
%fprintf(fid_txt,'%s',sprintf('n=%d \n',length(trigger)));
for k = 1:length(trigger)
    fprintf(fid_txt,'%s',sprintf('%.3f\t',trigger(k)));
end
fprintf(fid_txt,'%s',sprintf('</TRIG>'));
fclose(fid_txt);
fprintf('File trigger.txt saved at %s.\n',file_txt);

% Export LFP bands
f_resamp = 1000;
n_channels = Info.NbRecChan;
all_channels = cell(n_channels,1);
Data_sk2=[];
filename = Info.ExpFileName;
% SK2 Conversion
for i=1:n_channels
    channel_id = char(Info.ChLabel(i));
    all_channels(i) = Info.ChLabel(i);
    Y = Data(i,:);
    % resampling
    xq = Time(1):1/f_resamp:Time(end);
    Y_sk2 = interp1(Time,Y,xq);
    Data_sk2=[Data_sk2;(Y_sk2(:))'];
    fprintf('Channel %s extracted [%s].\n',channel_id,filename);
end

% Adding Metadata
Data = Data_sk2;
MetaTags.FileTypeIDMetaData = 'NEURALCD';
MetaTags.SamplingLabel = '1 kS/s          ';
MetaTags.ChannelCount = n_channels;
MetaTags.SamplingFreq = f_resamp;
MetaTags.TimeRes = Info.Fs;
MetaTags.ChannelID = (1:n_channels)';
MetaTags.DateTime = datestr(Info.BinFiles.TStart);
MetaTags.DateTimeRaw = datevec(Info.BinFiles.TStart);
MetaTags.Comment = '';
MetaTags.FileSpec = '';
MetaTags.Timestamp = 0;
MetaTags.DataPoints = size(Data,2);
MetaTags.DataDurationSec = MetaTags.DataPoints/MetaTags.SamplingFreq;
MetaTags.openNSxver = '';
MetaTags.Filename = filename;
MetaTags.FilePath = Info.FilesDir;
MetaTags.FileExt = '.sk2';
MetaTags.DataPointsSec = MetaTags.DataDurationSec;

% Export SK2 file
fprintf('Exporting SK2 file ...');
% save(fullfile(folder_name,dir_lfp,strcat(recording,'.sk2')),'Data','MetaTags','-v7.3');
recording = strrep(Info.BinFiles.FileName,'.bin','.sk2');
save(fullfile(folder_name,dir_lfp,strcat(recording,'.sk2')),'Data','MetaTags','Info','-v7.3');
fprintf(' done.\n');
fprintf('=> [%s].\n',fullfile(folder_name,dir_lfp,strcat(recording,'.sk2')));
%save(strcat(recording,'.sk2'),'Data','MetaTags','-v7.3');

% Copying video to new location
if isfield(Info,'VideosFiles') && ~isempty(Info.VideosFiles)
    
    if length(Info.VideosFiles.Files)==1
        video_file = Info.VideosFiles.Files(1).FileName;
        video_dir = Info.VideosFiles.Files(1).Dir;
    else
        % several video files found
%         temp = regexp(strrep(Info.BinFiles.FileName,'.bin',''),'_','split');
%         pattern = char(temp(end));
%         ind_video = find(contains({Info.VideosFiles.Files(:).FileName}',pattern(1:8))==1);
%         if ~isempty(ind_video)
%             video_file = Info.VideosFiles.Files(ind_video).FileName;
%             video_dir = Info.VideosFiles.Files(ind_video).Dir;
%         else
%             video_file = Info.VideosFiles.Files(1).FileName;
%             video_dir = Info.VideosFiles.Files(1).Dir;
%         end
        if ~isempty(ind_min_delay)
            video_file = Info.VideosFiles.Files(ind_min_delay).FileName;
            video_dir = Info.VideosFiles.Files(ind_min_delay).Dir;
        else
            video_file = Info.VideosFiles.Files(1).FileName;
            video_dir = Info.VideosFiles.Files(1).Dir;
        end        
    end
    
    fprintf('Copying video file ...');
    copyfile(fullfile(video_dir,video_file),fullfile(folder_name,video_file));
    fprintf(' done.\n');
    fprintf('=> [%s].\n',fullfile(folder_name,video_file));
else
    fprintf('No video to export.\n');
end

end

function [trigger,padding] = extract_trigger_oneiros(Data,f_trig,n_frames)

trigger = [];
padding = [];

t = Data(:);
f = figure;
ax = axes('Parent',f);
plot(t,'Parent',ax);
answer = char(inputdlg('Enter threshold value.'));
close(f);
t_thresh = t>eval(answer);
index = find(diff(t_thresh)>0);
trigger_raw = index/f_trig;

% % speciale Essai3
% trigger_raw = [trigger_raw(1:164);trigger_raw(166:167);trigger_raw(176);...
%     trigger_raw(178);trigger_raw(181);trigger_raw(184);trigger_raw(191:202);...
%     trigger_raw(205:1281);trigger_raw(1283:3022);trigger_raw(3024:4328);trigger_raw(4330:end)];

% Trigger correction
cur_trig = trigger_raw(1);
trigger_corrected = cur_trig;
delta = 0.01;
trigger_median = median(diff(trigger_raw));
trig_value_inf = (1-delta)*trigger_median;
trig_value_sup = (1+delta)*trigger_median;
for i=2:length(trigger_raw)
    if (trigger_raw(i)-cur_trig)>trig_value_inf && (trigger_raw(i)-cur_trig)<trig_value_sup
        cur_trig = trigger_raw(i);
        trigger_corrected = [trigger_corrected;cur_trig];
    elseif (trigger_raw(i)-cur_trig)>trig_value_sup
         
%         % checking if there is a trig in [trig+trig_value_inf,trig+trig_value_sup]
%         % code only working for Essai3
%         ind_sign = sign((trigger_raw-(trigger_raw(i)+trig_value_sup)).*(trigger_raw-(trigger_raw(i)+trig_value_inf)));
%         if ~isempty(ind_sign==-1)
%             cur_trig = trigger_raw(i);
%             trigger_corrected = [trigger_corrected;cur_trig];
%         end

        j=i+1;
        flag=0;
        while j<length(trigger_raw) && flag==0
            if (trigger_raw(j)-trigger_raw(i))>trig_value_inf && (trigger_raw(j)-trigger_raw(i))<trig_value_sup
                flag=1;
            else
                j=j+1;
            end
        end
        if flag == 1
            cur_trig = trigger_raw(i);
            trigger_corrected = [trigger_corrected;cur_trig];
        end
    end
end

% removing first trig by hand if necessary
if (trigger_corrected(2)-trigger_corrected(1))<trig_value_inf ...
        || (trigger_corrected(2)-trigger_corrected(1))>trig_value_sup
    trigger_corrected = trigger_corrected(2:end);
end

n_images = n_frames;
% Test if trigger matches n_images
if n_images~= length(trigger_corrected)
    if isempty(trigger_corrected)
        warning('No trig detected. -> Escaping');
        return;
        
    elseif length(trigger_corrected) < n_images
        
        warning('Trigs detected :%d, Doppler size:%d  mismatch [Missing trigs]. -> Adding end trig',length(trigger_corrected),n_images);
        discrepant = n_images-length(trigger_corrected);
        padding = sprintf('missing_%d',abs(discrepant));
        % extend trigger using delta_trig
        delta_trig = trigger_corrected(2)-trigger_corrected(1);
        additional_trigs = (1:discrepant)'*delta_trig;
        trigger = [trigger_corrected; trigger_corrected(end)+additional_trigs];   
        
    elseif length(trigger_corrected) > n_images
        
        warning('Trigs detected :%d, Doppler size:%d  mismatch [Excess trigs]. -> Discarding end trigs',length(trigger_corrected),n_images);
        discrepant = n_images-length(trigger_corrected);
        padding = sprintf('excess_%d',abs(discrepant));
        % keep only first triggers
        trigger = trigger_corrected(end-n_images+1:end);
        %trigger = trigger_corrected(1:n_images);
            
    end
else
    discrepant = 0;
    padding = 'exact';
    trigger = trigger_corrected;
    %time_stamp = time_stamp_raw;
end

end

function [trigger,reference,padding] = extract_trigger_nottl(data_acq,f_def)

reference = sprintf('default_%.1f',f_def);
padding = 'none';
n_frames = size(data_acq.Acquisition.Data,4);

% loading .acq
try
    f_acq = 1/median(diff(data_acq.Acquisition.T));
    % Bug fix if Acquisition.T corrupt
    if f_acq>10 || length(data_acq.Acquisition.T)==1
        f_acq = f_def;
    end
catch
    % if Acquisition.T not found
    f_acq = f_def;
end

trigger = (0:n_frames-1)'/f_acq;

end
