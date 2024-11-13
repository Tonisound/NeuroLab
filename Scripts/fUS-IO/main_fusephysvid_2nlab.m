function main_fusephysvid_2nlab(filepath_csv,seed)
% Reads a csv file of metadata
% Moves Ephys-fUS-Video files to seed/DATA/Parent folder
% Parent will be the same as the csv filename


if nargin<1
    % Reading input file
    filepath_csv = '/media/hobbes/DataMOBs206/FUS-REPLAY.csv';
end
if nargin<2
    % Destination folder
    seed = '/media/hobbes/DataMOBs204/DATA';
end


% Creating struct S
S = struct('fus',[],'intan',[],'video',[],'fipho',[]);
nFiles = 0;

fid = fopen(filepath_csv,'r');
% reading header
header = regexp(fgetl(fid),',','split');
if length(header)==3 && contains(header(1),'fUS') && contains(header(2),'Intan') && contains(header(3),'Tracking')
    rec_type = 'Ephys-fUS-Vid';
elseif length(header)==4 && contains(header(1),'fUS') && contains(header(2),'Intan') && contains(header(3),'Tracking') contains(header(4),'Fiber')
    rec_type = 'Fiber-fUS-Vid';
else
    errordlg(sprintf('Incompatible CSV header. Impossible to find recording type.\n File [%s]',filepath_csv));
    return;
end

while ~feof(fid)
    nFiles = nFiles+1;
    hline = regexp(fgetl(fid),',','split');
    S(nFiles).fus = hline(1);
    S(nFiles).intan = hline(2);
    S(nFiles).video = hline(3);
    if strcmp(rec_type,'Fiber-fUS-Vid')
        S(nFiles).fipho = hline(4);
    end
end
fclose(fid);

% Sanity Check for exisiting files and folder
ind_sane = [];
for i = 1:nFiles
    if ~isfile(char(S(i).fus))
        warning('File [%s] does not exist.',char(S(i).fus));
    elseif ~isfolder(char(S(i).intan))
        warning('Folder [%s] does not exist.',char(S(i).intan));
    elseif ~isfolder(char(S(i).video))
        warning('Folder [%s] does not exist.',char(S(i).video));
    elseif strcmp(rec_type,'Fiber-fUS-Vid') && ~isfile(char(S(i).fipho))
        warning('File [%s] does not exist.',char(S(i).fipho));
    else
        ind_sane = [ind_sane;i];
    end
end
fprintf('File Format Check: (%d/%d) files checked. Proceeding.\n',length(ind_sane),nFiles);
S = S(ind_sane);
nFiles = length(S);


% Exporting Data
[~,basename_csv,~] = fileparts(filepath_csv);
parent = basename_csv;
new_path = fullfile(seed,parent);

% Writing output file
filepath_fipho_out = strcat(new_path,'-','FiPho_timing.csv');
fid1 = fopen(filepath_fipho_out,'w');
fwrite(fid1,sprintf('FileName,FirstRising,FirstFalling,LastRising,LastFalling\n'));
fclose(fid1);
% Writing output file
filepath_csv_out = strcat(new_path,'_out.csv');
fid2 = fopen(filepath_csv_out,'w');
fwrite(fid2,sprintf('FileName,TriggerFile,Importation Start,Importation End,fUSTrigs,fUSFrames,FirstTrig,LastTrig,Analogin,Amp,Aux,VidFrames,GotFrames,TrackedFrames\n'));
fclose(fid2);

for i = 1:nFiles
    
    fprintf('================ File (%d/%d): Starting Exportation ================ \n',i,nFiles);
    datestr_start = datestr(now);
    
    % Copy Raw fUS file - Create fus folder
    [base_filepath,fus_name] = create_fus_folder(char(S(i).fus),new_path);
    
    % Copy Intan files - Create lfp folder
    [lfp_name,RHD_S] = create_lfp_folder(char(S(i).intan),base_filepath);
    
    % Generate trigger.txt
    [nTrigs,nFrames,first_trig,last_trig,filepath_txt] = generate_trigger_txt(char(S(i).fus),base_filepath,lfp_name,fus_name);
    
    % Create ext folder
    ext_name = create_ext_folder(base_filepath);
    
    % Move video file
    [numVidFrames,numGotFrames,numTrackedFrames,~] = move_video_file(char(S(i).video),base_filepath,ext_name);
    
    % Fiber trigs
    filepath_csv_fipho = fullfile(base_filepath,lfp_name,'trigger_adc-01.csv');
    if ~isempty(S(i).fipho) && isfile(filepath_csv_fipho)
        [time_rising,time_falling,~,~] = read_trigger_csv(filepath_csv_fipho);
        if ~isempty(time_rising) && ~isempty(time_falling)
            fid1 = fopen(filepath_fipho_out,'a');
            fwrite(fid1,sprintf('%s,%.3f,%.3f,%.3f,%.3f\n',char(S(i).fipho),time_rising(1),time_falling(1),time_rising(end),time_falling(end)));
            fclose(fid1);
        else
            fid1 = fopen(filepath_fipho_out,'a');
            fwrite(fid1,sprintf('%s,%.3f,%.3f,%.3f,%.3f\n',char(S(i).fipho),NaN,NaN,NaN,NaN));
            fclose(fid1);
        end
    end
    
    % Log file
    datestr_end = datestr(now);
    num_channels_adc = RHD_S.num_channels_adc;
    num_channels_amp = RHD_S.num_channels_amp;
    num_channels_aux = RHD_S.num_channels_aux;
    
    fid2 = fopen(filepath_csv_out,'a');
    fwrite(fid2,sprintf('%s,%s,%s,%s,%d,%d,%.3f,%.3f,%d,%d,%d,%d,%d,%d\n',base_filepath,filepath_txt,datestr_start,datestr_end,...
        nTrigs,nFrames,first_trig,last_trig,num_channels_adc,num_channels_amp,num_channels_aux,...
        numVidFrames,numGotFrames,numTrackedFrames));
    fclose(fid2);
    
    fprintf('================ File (%d/%d): Exportation Done ================ \n',i,nFiles);
end

end


function [base_filepath,fus_name] = create_fus_folder(filename,new_path)

[cur_folder,cur_file,ext] = fileparts(filename);
basename = strrep(cur_file,'_fus2D.source','_E');

%session_name = strrep(basename,'_E','_MySession');
temp = regexp(cur_folder,filesep,'split');
session_name = strcat(char(temp(end)),'_',char(temp(end-1)),'_MySession');
session_name = strrep(session_name,'ses-Session_','');

base_filepath = fullfile(new_path,session_name,basename);
fus_name = strrep(basename,'_E','_fus');

new_folder = fullfile(base_filepath,fus_name);
new_file = strcat(strrep(cur_file,'.source',''),ext);

if ~isfolder(new_folder)
    mkdir(new_folder);
end

filename_out = fullfile(new_folder,new_file);
if ~isfile(filename_out)
    copyfile(filename,filename_out);
    fprintf('File [%s] moved to [%s].\n',cur_file,new_folder);
else
    fprintf('File [%s] already exported.\n',cur_file);
end

end


function [lfp_name,S] = create_lfp_folder(filepath,base_filepath)

% Checking if rhd file is present
if ~isfile(fullfile(filepath,'info.rhd'))
    fprintf('Missing RHD file [%s]. Skipping LFP folder creation.\n',filepath);
    lfp_name = [];
    return;
end

% Creating LFP folder
[base_folder,basename,~] = fileparts(base_filepath);
lfp_name = strrep(basename,'_E','_lfp');
lfp_folder = fullfile(base_folder,basename,lfp_name);
if ~isfolder(lfp_folder)
    mkdir(lfp_folder);
end

% Read rhd file
S = read_Intan_RHD2000_file_AB(filepath);
f_amp = S.frequency_parameters.amplifier_sample_rate;
f_aux = S.frequency_parameters.aux_input_sample_rate;
f_adc = S.frequency_parameters.board_adc_sample_rate;
f_dig = S.frequency_parameters.board_dig_in_sample_rate;

f_out = 1000;
subsamp_amp = ceil(f_amp/f_out);
subsamp_aux = ceil(f_aux/f_out);
subsamp_adc = ceil(f_adc/f_out);
subsamp_dig = ceil(f_dig/f_out);
if isfield(S,'board_adc_channels')
    num_channels_adc = length(S.board_adc_channels);
else
    num_channels_adc = 0 ;
end
if isfield(S,'amplifier_channels')
    num_channels_amp = length(S.amplifier_channels);
else
    num_channels_amp = 0;
end
if isfield(S,'aux_input_channels')
    num_channels_aux = length(S.aux_input_channels);
else
    num_channels_aux = 0 ;
end


% Read time.dat
if isfile(fullfile(lfp_folder,'time.mat'))
    fprintf('File time.mat already exported.\n');
else
    
    if isfile(fullfile(filepath,'time.dat'))
        fprintf('--- Loading time data.\n');
        fileinfo = dir(fullfile(filepath,'time.dat'));
        num_samples = fileinfo.bytes/4; % int32 = 4 bytes
        fid = fopen(fullfile(filepath,'time.dat'), 'r');
        t_raw = fread(fid, num_samples, 'int32');
        t_raw = t_raw / f_amp; % sample rate from header file
        fclose(fid);
        fprintf('File duration: %.2f seconds sampled at %.f Hz. \n',t_raw(end),f_amp);
        % Zero-ing time data
        t_raw = t_raw-t_raw(1);
        t = t_raw(1:subsamp_amp:end);
        % Saving time data
        f_samp=f_out;
        num_samples=length(t);
        save(fullfile(lfp_folder,'time.mat'),'t','f_samp','num_samples','-v7.3');
        fprintf('Time Data saved in [%s].\n',fullfile(lfp_folder,'time.mat'));
    end
end


% Read analogin.dat
if isfile(fullfile(lfp_folder,'analogin.mat'))
    fprintf('File analogin.mat already exported.\n');
else
    
    if num_channels_adc > 0
        fprintf('--- Loading analog input ---\n');
        num_channels = length(S.board_adc_channels); % ADC input info from header file
        fileinfo = dir(fullfile(filepath,'analogin.dat'));
        num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
        fid = fopen(fullfile(filepath,'analogin.dat'), 'r');
        data_adc_raw = fread(fid, [num_channels, num_samples], 'uint16');
        fclose(fid);
        fprintf('%d analog channels and %d samples found. \n',num_channels,num_samples);
        % convert to volts
        data_adc = data_adc_raw(:,1:subsamp_adc:end);
        data_adc = (data_adc - 32768) * 0.0003125;
        % Saving analogin data
        InfoRHD = S.board_adc_channels;
        f_samp=f_out;
        data = data_adc;
        save(fullfile(lfp_folder,'analogin.mat'),'data','f_samp','num_channels','num_samples','InfoRHD','-v7.3');
        fprintf('Analogin Data saved in [%s].\n',fullfile(lfp_folder,'analogin.mat'));
    end
    
    % Detecting rising falling edges in analog inputs
    % Detection parameters
    all_thresholds = [6000, 10000, Inf, Inf, Inf, Inf, Inf, Inf];
    all_steps = [20, 1, 1, 1, 1, 1, 1, 1];
    % Selecting unprocessed channels
    for i=1:num_channels_adc
        channel_adc = S.board_adc_channels(i).native_channel_name;
        filepath_csv = fullfile(lfp_folder,['trigger','_',lower(channel_adc),'.csv']);
        if ~isfile(filepath_csv)
            thresh = all_thresholds(i);
            step = all_steps(i);
            y = data_adc_raw(i,:)';
            detect_rising_falling_edges(t_raw,y,filepath_csv,thresh,step);
        end
    end
end


% Reading and subsmapling amplifier data by bouts
if isfile(fullfile(lfp_folder,'amplifier.mat'))
    fprintf('File amplifier.mat already exported.\n');
else
    bout_dur = 60; % bout duration
    
    if num_channels_amp > 0
        fprintf('--- Loading amplifier data by bouts .\n');
        num_channels = length(S.amplifier_channels); % amplifier channel info from header file
        fileinfo = dir(fullfile(filepath,'amplifier.dat'));
        num_samples = fileinfo.bytes/(num_channels * 2); % int16 = 2 bytes
        fprintf('%d channels and %d samples found. \n',num_channels,num_samples);
        
        % Reading and subsmapling amplifier data
        %     numbersToSkip = subsamp_amp-1;
        %     bytesToSkip = numbersToSkip * 2; % Multiply by 2 for uint16, which is 2 bytes
        %     num_samples_sub = ceil(num_samples/subsamp_amp);
        %     data_amp = NaN(num_samples_sub,num_channels);
        data_amp=[];
        nBouts = ceil(num_samples/(f_amp*bout_dur));
        h = waitbar(0,'Please wait');
        fid = fopen(fullfile(filepath,'amplifier.dat'), 'r');
        for i=1:nBouts
            
            data_bout = fread(fid, [num_channels, f_amp*bout_dur], 'int16', 0, 'ieee-le');
            data_amp = [data_amp,data_bout(:,1:subsamp_amp:end)];
            prop = i/nBouts;
            waitbar(prop,h,sprintf('Amplifier Data Bout Loaded %.2f %%',100*prop));
            
        end
        fclose(fid);
        close(h);
        % convert to microvolts
        data_amp = (data_amp* 0.195);
        % Saving amplifier data
        InfoRHD = S.amplifier_channels;
        f_samp=f_out;
        data = data_amp;
        num_channels = size(data,1);
        num_samples = size(data,2);
        save(fullfile(lfp_folder,'amplifier.mat'),'data','f_samp','num_channels','num_samples','InfoRHD','-v7.3');
        fprintf('Amplifier Data saved in [%s].\n',fullfile(lfp_folder,'amplifier.mat'));
    end
end


% Read auxiliary.dat
if isfile(fullfile(lfp_folder,'auxiliary.mat'))
    fprintf('File auxiliary.mat already exported.\n');
else
    
    if num_channels_aux > 0
        fprintf('--- Loading auxiliary input.\n');
        num_channels = length(S.aux_input_channels); % aux input channel info from header file
        fileinfo = dir(fullfile(filepath,'auxiliary.dat'));
        num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
        fid = fopen(fullfile(filepath,'auxiliary.dat'), 'r');
        
        data_aux = fread(fid, [num_channels, num_samples], 'uint16');
        fclose(fid);
        fprintf('%d auxiliary channels and %d samples found. \n',num_channels,num_samples);
        
        % convert to volts
        % data_aux = data_aux(:,1:subsamp_aux:end);
        data_aux = data_aux(:,1:subsamp_amp:end);
        data_aux = data_aux * 0.0000374;
        % Saving auxiliary data
        InfoRHD = S.aux_input_channels;
        f_samp=f_out;
        data = data_aux;
        save(fullfile(lfp_folder,'auxiliary.mat'),'data','f_samp','num_channels','num_samples','InfoRHD','-v7.3');
        fprintf('Auxiliary Data saved in [%s].\n',fullfile(lfp_folder,'auxiliary.mat'));
    end
end


% Saving MetaData
temp = regexp(filepath,filesep,'split');
filename_rhd2 = [char(temp(end)),'.rhd2'];
if isfile(fullfile(lfp_folder,filename_rhd2))
    fprintf('File info.rhd2 already exported.\n');
else
    %duration = t(end);
    parent = filepath;
    f_samp = f_out;
    DateExport = datestr(now);
    save(fullfile(lfp_folder,filename_rhd2),'num_channels_adc','num_channels_amp','num_channels_aux',...
        'parent','f_samp','DateExport','-v7.3');
    fprintf('Intan Data saved at [%s].\n',fullfile(lfp_folder,'info.rhd2'));
end

S.num_channels_adc = num_channels_adc;
S.num_channels_amp = num_channels_amp;
S.num_channels_aux = num_channels_aux;

end


function ext_name = create_ext_folder(base_filepath)

% [cur_folder,cur_file,~] = fileparts(filepath);

[base_folder,basename,~] = fileparts(base_filepath);
ext_name = strrep(basename,'_E','_ext');
ext_folder = fullfile(base_folder,basename,ext_name);
% Creating ext folder
if ~isfolder(ext_folder)
    mkdir(ext_folder);
end

end


function [numVidFrames,numGotFrames,numTrackedFrames,video_name] = move_video_file(filepath,base_filepath,ext_name)

% Checking if video file is present
d_vid = dir(fullfile(filepath,'*.avi'));
if isempty(d_vid)
    warning('Missing video file in [%s].',filepath);
elseif length(d_vid) > 1
    warning('Multiple video files in [%s]. Taking first: [%s].',filepath,d_vid(1).name);
    d_vid = d_vid(1);
end

video_name = d_vid.name;
filepath_csv = fullfile(base_filepath,[video_name,'_sync.csv']);

% Checking if video file is present - Copying video
if  isfile(filepath_csv)
    fprintf('Video file already exported.\n');
    [~,~,video_name,numVidFrames,numGotFrames,numTrackedFrames] = read_time_frames_csv(filepath_csv);
    
else
    % Loading behavResources.mat
    if isfile(fullfile(filepath,'behavResources.mat'))
        
        data_br = load(fullfile(filepath,'behavResources.mat'));
        % Tracked Frames
        numTrackedFrames = length(data_br.PosMat(:,1));
        t_gotframe = data_br.PosMat(data_br.GotFrame==1,1);
        numGotFrames = length(t_gotframe);
        
        % Vid Frames
        try
            v = VideoReader(fullfile(d_vid.folder,video_name));
            t_apparent = (0:1/v.FrameRate:v.Duration-1/v.FrameRate)';
            numVidFrames = v.Duration*v.FrameRate;
        catch
            numVidFrames = 0;
            t_apparent = NaN(size(t_gotframe));
        end
        
        % Sanity Check
        if numVidFrames~=numGotFrames
            errordlg(sprintf('Mismatch between numGotFrames and numVideoFrames [%s].',fullfile(base_filepath,d_vid.name)));
        end
        
        % Writing sync file
        write_time_frames_csv(filepath_csv,t_gotframe,t_apparent,video_name,numVidFrames,numGotFrames,numTrackedFrames)
        fprintf('Sync File exported [%s].\n',filepath_csv);
        % Copying video file
        copyfile(fullfile(d_vid.folder,d_vid.name),fullfile(base_filepath,video_name));
        fprintf('Video File exported [%s].\n',fullfile(base_filepath,video_name));
        
        % Body temperature
        parent = fullfile(filepath,'behavResources.mat');
        shortname = 'Temp';
        fullname = 'MouseTemp';
        file_ext = fullfile(base_filepath,ext_name,[fullname,'.ext']);
        if ~isfile(file_ext)
            t_temp = data_br.MouseTemp(:,1);
            Y_temp = data_br.MouseTemp(:,2);
            write_ext_file(t_temp,Y_temp,file_ext,parent,shortname,fullname);
            fprintf('Body Temperature exported [%s].\n',file_ext);
        end
        
        % Body position
        parent = fullfile(filepath,'behavResources.mat');
        shortname = 'Xpos';
        fullname = 'Xposition';
        file_ext = fullfile(base_filepath,ext_name,[fullname,'.ext']);
        if ~isfile(file_ext)
            t_pos = data_br.PosMat(:,1);
            X_pos = data_br.PosMat(:,2);
            write_ext_file(t_pos,X_pos,file_ext,parent,shortname,fullname);
            fprintf('X Body Position exported [%s].\n',file_ext);
        end
        shortname = 'Ypos';
        fullname = 'Yposition';
        file_ext = fullfile(base_filepath,ext_name,[fullname,'.ext']);
        if ~isfile(file_ext)
            t_pos = data_br.PosMat(:,1);
            Y_pos = data_br.PosMat(:,3);
            write_ext_file(t_pos,Y_pos,file_ext,parent,shortname,fullname);
            fprintf('Y Body Position exported [%s].\n',file_ext);
        end
    end
    
end

end


function detect_rising_falling_edges(t_raw,y,filepath_csv,thresh,step)

% Padding vectors to extract min-max binned signal
if step>1
    r=mod(length(t_raw),step);
    if r~=0
        t_padded = [t_raw;zeros(step-r,1)];
        y_padded = [y;zeros(step-r,1)];
    else
        t_padded = t_raw;
        y_padded = y;
    end
    
    % Reshaping Data
    t_reshaped = reshape(t_padded,[step,(length(t_padded)/step)]);
    y_reshaped = reshape(y_padded,[step,(length(y_padded)/step)]);
    y_min = min(y_reshaped);
    y_max = max(y_reshaped);
    v = (y_min+y_max)/2;
    t = t_reshaped(1,:);
else
    t=t_raw;
    v=y;
end
% Detect rising and falling edges
time_rising = t(diff(v>thresh)>0);
time_falling = t(diff(v>thresh)<0);
% Sanity check
if length(time_rising) == length(time_falling)+1
    time_rising = time_rising(1:end-1);
end

% Saving Trigger as csv file
write_trigger_csv(filepath_csv,time_rising,time_falling,thresh,step);

end


function [nTrigs,nFrames,first_trig,last_trig,filepath_txt] = generate_trigger_txt(filename_fus,base_filepath,lfp_name,fus_name)

filepath_txt = fullfile(base_filepath,fus_name,'trigger.txt');

nFrames = load(filename_fus,'nFrames','-mat');
nFrames = nFrames.nFrames;

if isfile(filepath_txt)
    
    fprintf('File trigger.txt already exported.\n');
    trigger = read_trigger_txt(filepath_txt);
    nTrigs = length(trigger);
    first_trig = trigger(1);
    last_trig = trigger(end);
    
else
    
    trigger_csv = 'trigger_adc-00.csv';
    if isfile(fullfile(base_filepath,lfp_name,trigger_csv))
        [time_rising,time_falling,~,~] = read_trigger_csv(fullfile(base_filepath,lfp_name,trigger_csv));
    else
        %     time_rising = [];
        %     time_falling = [];
        %     trigger = [];
        first_trig = [];
        last_trig = [];
        nTrigs = 0;
        filepath_txt = [];
        return
    end
    
    % Converting time_rising and time_falling into trigger
    if length(time_rising)>1
        trigger_start = [time_rising(1);time_falling(2:end-1)];
        trigger_end = time_rising(2:end);
        trigger = (trigger_start+trigger_end)/2;
    elseif length(time_rising)==1
        trigger = (time_rising+time_falling)/2;
    end
    nTrigs = length(trigger);
    first_trig = trigger(1);
    last_trig = trigger(end);
    
    % Trigger Correction
    if nFrames ~= nTrigs && nTrigs>0
        
        f_fus=0.5; %Hertz
        warning('Found %d trigs (Expected: %d) in [%s] .\n',nTrigs,nFrames,base_filepath);
        if mean(diff(diff(time_rising))) < 1e-3 && (nTrigs == nFrames+1)
            
            % Regular timing  with one single additional trigout
            trigger = trigger(1:end-1);
            nTrigs = length(trigger);
            first_trig = trigger(1);
            last_trig = trigger(end);
            
        elseif time_falling(end)-time_rising(1) > 0.9999*(nFrames*f_fus) && time_falling(end)-time_rising(1) < 1.0001*(nFrames*f_fus)
            
            % First rising and last falling within right range
            trigger = rescale((1:nFrames)',(time_rising(1)+time_falling(1))/2,(time_rising(end)+time_falling(end))/2);
            nTrigs = length(trigger);
            first_trig = trigger(1);
            last_trig = trigger(end);
            
        else
            
            % Skip trigger saving
            fprintf('File trigger.txt not saved.\n');
            filepath_txt = [];
            return;
        end
   
    end
    
    % Write trigger.txt
    reference = fullfile(base_filepath,lfp_name,trigger_csv);
    write_trigger_txt(filepath_txt,trigger,reference);
    fprintf('Found %d trigs (Expected: %d).\n',nTrigs,nFrames);
    fprintf('File trigger.txt saved at [%s].\n',filepath_txt);
    
end

end

