function main_fusephysvid_2nlab()
% Reads a csv file of metadata
% moves Ephys-fUS-Video files to DATA folder
% Parent folder will be the same as the csv filename


% Reading input file
filepath_csv = '/media/hobbes/DataMOBs206/FUS-REPLAY.csv';
[~,basename_csv,~] = fileparts(filepath_csv);
filepath_csv_out = strrep(filepath_csv,'.csv','_out.csv');


% Creating struct S
S = struct('fus',[],'intan',[],'video',[]);
nFiles = 0;

fid = fopen(filepath_csv,'r');
% ignoring header
header = regexp(fgetl(fid),',','split');
while ~feof(fid)
    nFiles = nFiles+1;
    hline = regexp(fgetl(fid),',','split');
    S(nFiles).fus = hline(1);
    S(nFiles).intan = hline(2);
    S(nFiles).video = hline(3);
end
fclose(fid);

% Writing output file
fid2 = fopen(filepath_csv_out,'w');
fwrite(fid2,sprintf('FileName,Importation Start,Importation End,NumTrigs,NumFrames,AnaloginChannels,AmpChannels,AuxChannels\n'));
fclose(fid2);

% Sanity Check for exisiting files and folder
ind_sane = [];
for i = 1:nFiles
    if ~isfile(char(S(i).fus))
        warning('File [%s] does not exist.',char(S(i).fus));
    elseif ~isfolder(char(S(i).intan))
        warning('Folder [%s] does not exist.',char(S(i).intan));
    elseif ~isfolder(char(S(i).video))
        warning('Folder [%s] does not exist.',char(S(i).video));
    else
        ind_sane = [ind_sane;i];
    end
end
fprintf('File Format Check: (%d/%d) files checked. Proceeding.\n',length(ind_sane),nFiles);
S = S(ind_sane);
nFiles = length(S);


% Exporting Data
seed = '/media/hobbes/DataMOBs204/DATA';
parent = basename_csv;
new_path = fullfile(seed,parent);

for i = 1:nFiles
    
    fprintf('================ File (%d/%d): Starting Exportation ================ \n',i,nFiles);
    datestr_start = datestr(now);
    
    % Copy Raw fUS file - Create fus folder
    [base_filepath,fus_name] = create_fus_folder(char(S(i).fus),new_path);
    
    % Copy Intan files - Create lfp folder
    [lfp_name,RHD_S] = create_lfp_folder(char(S(i).intan),base_filepath);
    
    % Generate trigger.txt
    [nTrigs,nFrames] = generate_trigger_txt(char(S(i).fus),base_filepath,lfp_name,fus_name);
    
    % Create ext folder
    ext_name = create_ext_folder(base_filepath);
    
    % Move video file
    %     movefile(char(S(i).fus));
    
    datestr_end = datestr(now);
    num_channels_adc = RHD_S.num_channels_adc;
    num_channels_amp = RHD_S.num_channels_amp;
    num_channels_aux = RHD_S.num_channels_aux;
    
    fid2 = fopen(filepath_csv_out,'a');
    fwrite(fid2,sprintf('%s,%s,%s,%d,%d,%d,%d,%d\n',base_filepath,datestr_start,datestr_end,...
        nTrigs,nFrames,num_channels_adc,num_channels_amp,num_channels_aux));
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
        save(fullfile(lfp_folder,'time.mat'),'t','f_samp','num_samples','-v7.3');
        fprintf('Time Data saved in [%s].\n',fullfile(lfp_folder,'time.mat'));
    end
    
end


% Read analogin.dat
if isfile(fullfile(lfp_folder,'analogin.mat'))
    fprintf('File analogin.mat already exported.\n');
else
    
    if isfield(S,'board_adc_channels')
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
        data_adc = data_adc';
        % Saving analogin data
        InfoRHD = S.board_adc_channels;
        f_samp=f_out;
        data = data_adc;
        save(fullfile(lfp_folder,'analogin.mat'),'data','f_samp','num_channels','num_samples','InfoRHD','-v7.3');
        fprintf('Analogin Data saved in [%s].\n',fullfile(lfp_folder,'analogin.mat'));
    end
    
    % Detecting rising falling edges in analog inputs
    % Detection parameters
    all_thresholds = [6000, 10000, 10000, 10000, 10000, 10000, 10000, 10000];
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


% Read amplifier.dat
if ~isfile(fullfile(lfp_folder,'amplifier.mat'))
    fprintf('File amplifier.mat already exported.\n');
else
    
    if isfield(S,'amplifier_channels')
        
        fprintf('--- Loading amplifier data.\n');
        num_channels = length(S.amplifier_channels); % amplifier channel info from header file
        fileinfo = dir(fullfile(filepath,'amplifier.dat'));
        num_samples = fileinfo.bytes/(num_channels * 2); % int16 = 2 bytes
        % Reading and subsmapling amplifier data
        fid = fopen(fullfile(filepath,'amplifier.dat'), 'r');
        numbersToSkip = subsamp_amp-1;
        bytesToSkip = numbersToSkip * 2; % Multiply by 2 for uint16, which is 2 bytes
        num_samples_sub = ceil(num_samples/subsamp_amp);
        data_amp = NaN(num_samples_sub,num_channels);
        h = waitbar(0,'Please wait');
        for i = 1:num_samples_sub
            data_amp(i,:) = fread(fid, [num_channels, 1], 'int16', bytesToSkip, 'ieee-le');
            prop = i/num_samples_sub;
            waitbar(prop,h,sprintf('Amplifier Data Loaded %.2f %%',100*prop));
        end
        close(h);
        fclose(fid);
        fprintf('%d channels and %d samples found. \n',num_channels,num_samples);
        % convert to microvolts
        data_amp = (data_amp* 0.195);
        % Saving amplifier data
        InfoRHD = S.amplifier_channels;
        f_samp=f_out;
        data = data_amp;
        save(fullfile(lfp_folder,'amplifier.mat'),'data','f_samp','num_channels','num_samples','InfoRHD','-v7.3');
        fprintf('Amplifier Data saved in [%s].\n',fullfile(lfp_folder,'amplifier.mat'));
    end
end


% Read auxiliary.dat
if isfile(fullfile(lfp_folder,'auxiliary.mat'))
    fprintf('File auxiliary.mat already exported.\n');
else
    
    if isfield(S,'aux_input_channels')
        fprintf('--- Loading auxiliary input.\n');
        num_channels = length(S.aux_input_channels); % aux input channel info from header file
        fileinfo = dir(fullfile(filepath,'auxiliary.dat'));
        num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
        fid = fopen(fullfile(filepath,'auxiliary.dat'), 'r');
        
        data_aux = fread(fid, [num_channels, num_samples], 'uint16');
        fclose(fid);
        fprintf('%d auxiliary channels and %d samples found. \n',num_channels,num_samples);
    end
    % convert to volts
    % data_aux = data_aux(:,1:subsamp_aux:end);
    data_aux = data_aux(:,1:subsamp_amp:end);
    data_aux = data_aux * 0.0000374;
    data_aux = data_aux';
    % Saving auxiliary data
    InfoRHD = S.aux_input_channels;
    f_samp=f_out;
    data = data_aux;
    save(fullfile(lfp_folder,'auxiliary.mat'),'data','f_samp','num_channels','num_samples','InfoRHD','-v7.3');
    fprintf('Auxiliary Data saved in [%s].\n',fullfile(lfp_folder,'auxiliary.mat'));
end


% Saving MetaData
if isfile(fullfile(lfp_folder,'info.rhd2'))
    fprintf('File info.rhd2 already exported.\n');
else
    parent = filepath;
    %duration = t(end);
    f_samp = f_out;
    DateExport = datestr(now);
    save(fullfile(lfp_folder,'info.rhd2'),'num_channels_adc','num_channels_amp','num_channels_aux',...
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


function detect_rising_falling_edges(t_raw,y,filepath_csv,thresh,step)

% Padding vectors to extract min-max binned signal
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


function [nTrigs,nFrames] = generate_trigger_txt(filename_fus,base_filepath,lfp_name,fus_name)

filepath_txt = fullfile(base_filepath,fus_name,'trigger.txt');

if isfile(filepath_txt)
    fprintf('File trigger.txt already exported.\n');
else
    
    nFrames = load(filename_fus,'nFrames','-mat');
    nFrames = nFrames.nFrames;
    
    trigger_csv = 'trigger_adc-00.csv';
    if isfile(fullfile(base_filepath,lfp_name,trigger_csv))
        [time_rising,time_falling,~,~] = read_trigger_csv(fullfile(base_filepath,lfp_name,trigger_csv));
    else
        time_rising = [];
        time_falling = [];
    end
    
    % Converting time_rising and time_falling into
    if length(time_rising)>1
        trigger_start = [time_rising(1);time_falling(2:end-1)];
        trigger_end = time_rising(2:end);
        trigger = (trigger_start+trigger_end)/2;
    else
        trigger = (time_rising+time_falling)/2;
    end
    nTrigs = length(trigger);
    
    if nFrames ~= nTrigs
        warning('Found %d trigs (Expected: %d) in [%s] .\n',nTrigs,nFrames,base_filepath);
        %         if (trigger(end)-trigger(1))/(nFrames-1) > 0.495 && (trigger(end)-trigger(1))/(nFrames-1) < 0.505
        %             trigger = rescale((1:nFrames)',trigger(1),trigger(end));
        %         end
    else
        % Write trigger.txt
        reference = fullfile(base_filepath,lfp_name,trigger_csv);
        write_trigger_txt(filepath_txt,trigger,reference);
        
        fprintf('Found %d trigs (Expected: %d).\n',nTrigs,nFrames);
        fprintf('File trigger.txt saved at [%s].\n',filepath_txt);
    end
end

end


function write_trigger_txt(filepath_txt,trigger,reference,padding,offset,delay_lfp_video)

if nargin <4
    padding = 'none';
end
if nargin <5
    offset = 0;
end
if nargin <6
    delay_lfp_video = 0;
end

fid_txt = fopen(filepath_txt,'wt');
fprintf(fid_txt,'%s',sprintf('<REF>%s</REF>\n',reference));
fprintf(fid_txt,'%s',sprintf('<PAD>%s</PAD>\n',padding));
fprintf(fid_txt,'%s',sprintf('<OFFSET>%.3f</OFFSET>\n',offset));
fprintf(fid_txt,'%s',sprintf('<DELAY>%.3f</DELAY>\n',delay_lfp_video));
fprintf(fid_txt,'%s',sprintf('<TRIG>\n'));
%fprintf(fid_txt,'%s',sprintf('n=%d \n',length(trigger)));
for k = 1:length(trigger)
    fprintf(fid_txt,'%s',sprintf('%.3f\n',trigger(k)));
end
fprintf(fid_txt,'%s',sprintf('</TRIG>'));
fclose(fid_txt);
% fprintf('File trigger.txt saved at %s.\n',file_txt);

end


function write_trigger_csv(filepath_csv,time_rising,time_falling,thresh,step)

if nargin <4
    thresh = NaN;
end
if nargin <5
    step = 1;
end

nTrigs = length(time_rising);

fid_csv = fopen(filepath_csv,'w');
fprintf(fid_csv,'%s',sprintf('Threshold=%.2f,BinSize=%.d,NumTrigs=%d\n',thresh,step,nTrigs));
fprintf(fid_csv,'%s',sprintf('Rising(s),Falling(s)\n'));
for k = 1:length(time_rising)
    fprintf(fid_csv,'%s',sprintf('%.3f,%.3f\n',time_rising(k),time_falling(k)));
end
fclose(fid_csv);

end


function [time_rising,time_falling,thresh,step] = read_trigger_csv(filepath_csv)

fid = fopen(filepath_csv,'r');
header = regexp(fgetl(fid),',','split');
thresh = str2double(regexprep(header(1),'Threshold=',''));
step = str2double(regexprep(header(2),'BinSize=',''));
nTrigs = str2double(regexprep(header(3),'NumTrigs=',''));

header2 = regexp(fgetl(fid),',','split');

time_rising = [];
time_falling = [];
while ~feof(fid)
    hline = regexp(fgetl(fid),',','split');
    time_rising = [time_rising;str2double(hline(1))];
    time_falling = [time_falling;str2double(hline(1))];
end
fclose(fid);

if nTrigs~=length(time_rising) || nTrigs~=length(time_falling) || length(time_rising)~=length(time_falling)
    warning('Problem with trig number in [%s].',filepath_csv);
    time_rising = [];
    time_falling = [];
end

end
