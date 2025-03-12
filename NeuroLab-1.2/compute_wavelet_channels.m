function success = compute_wavelet_channels(foldername,handles,val)
% Computes wavelet spectrogram for all LFP channels
% Saves spectrogram in fixed duration files
% Stores files in Nlab folder/Wavelet

success = false;

% if val undefined, set val = 1 (default) user can select channels to compute
if nargin <3
    val = 1;
end

temp = regexp(foldername,filesep,'split');
cur_recording = char(temp(end));

% Parameters
fdom_min = 1;
fdom_max = 250;
fdom_step = 1;
Fb = 2;
Fc = 2;
freqdom = fdom_min:fdom_step:fdom_max;
bout_save_duration = 3600; % seconds
step_save_duration = .01; % seconds
f_save_duration = 1/step_save_duration;
save_ratio = 100;

% Loading Nconfig
channel_mainlfp = '';
if isfile(fullfile(foldername,'Config.mat'))
    d_config = load(fullfile(foldername,'Config.mat'));
    if ~isempty(d_config.File.mainlfp)
        channel_mainlfp = d_config.File.mainlfp;
    end
end

% LFP Channel Loading
d_lfp = dir(fullfile(foldername,'Sources_LFP','LFP_*.mat'));
% renaming LFP channels
all_lfp_channels = {d_lfp(:).name}';
all_lfp_channels = strrep(all_lfp_channels,'LFP_','');
all_lfp_channels = strrep(all_lfp_channels,'.mat','');

% Default Selection
if ~isempty(channel_mainlfp)
    % main channel only
    ind_selected = find(strcmp(all_lfp_channels,'005')==1);
else
    % all channels
    ind_selected = 1:length(all_lfp_channels);
end

% Channel Selection
if val == 1
    % user mode
    [ind_lfp,v] = listdlg('Name','Channel Selection','PromptString','Select channels to export',...
        'SelectionMode','multiple','ListString',all_lfp_channels,'InitialValue',ind_selected,'ListSize',[300 500]);
else
    % batch mode
    ind_lfp = ind_selected;
    v = true;
end
% return if selection empty
if v==0 || isempty(ind_lfp)
    warning('No trace selected .\n');
    return;
else
    all_lfp_channels =  all_lfp_channels(ind_lfp);
end
n_channels = length(all_lfp_channels);


% Loading data
for j=1:n_channels
    cur_channel = char(all_lfp_channels(j));
    d_raw = dir(fullfile(foldername,'Sources_LFP',sprintf('LFP_%s.mat',cur_channel)));
    if isempty(d_raw)
        warning('No channel found [%s]',cur_recording);
        continue;
    else
        data_raw = load(fullfile(d_raw.folder,d_raw.name));
        Xraw = data_raw.x_start:data_raw.f:data_raw.x_end;
        Yraw = data_raw.Y;
        f_samp = 1/data_raw.f;
    end
    
    % Computing Wavelet
    sub_samp = floor(f_samp/(2*fdom_max));          % subsampling frequency factor
    f_sub = f_samp/sub_samp;
    scales = Fc*f_sub./freqdom;
    
    n_samples = round(bout_save_duration*f_samp);
    index_start = 1:n_samples:length(Yraw);
    index_end = [n_samples:n_samples:length(Yraw),length(Yraw)];
    
    % all_Cdata = [];
    
    data_dir = fullfile(foldername,'Wavelet');
    if ~isfolder(data_dir)
        mkdir(data_dir);
    end
    for k=1:length(index_start)
        fprintf('Computing Time-Frequency Spectrogramm [Channel:%s] [Bout:%d/%d] ...',cur_channel,k,length(index_start));
        Y = Yraw(index_start(k):sub_samp:index_end(k));
        coefs_wav   = cmorcwt(Y,scales,Fb,Fc);
        Cdata = log10(abs(coefs_wav)).^2;
        % all_Cdata = [all_Cdata,Cdata];
        fprintf(' done.\n');
        
        x_start = Xraw(index_start(k));
        x_end = Xraw(index_end(k));
        X = Xraw(index_start(k):sub_samp:index_end(k));
        
        % Interpolating Cdata to save (long)
        Xq = x_start:step_save_duration:x_end;
        Cdata_sub_interp = (interp1(X,Cdata',Xq))';
        Cdata_sub = Cdata_sub_interp;
%         % Subsampling Cdata to save (fast)
%         step_sub = max(round(f_sub/f_save_duration),1);
%         Cdata_sub_subsampled = Cdata(:,1:step_sub:end);
%         Cdata_sub = Cdata_sub_subsampled;
        % Saving in int format
        Cdata_sub_int = int16(save_ratio*Cdata_sub);
        
        % Saving
        filename = sprintf('Wav_%s_%03d.mat',cur_channel,k);
        save(fullfile(data_dir,filename),'Fb','Fc','fdom_step','fdom_min','fdom_max','freqdom',...
            'f_sub','f_samp','sub_samp','scales',...
            'cur_recording','cur_channel','bout_save_duration','save_ratio',...
            'Cdata_sub_int','step_save_duration','x_start','x_end','-v7.3');
        fprintf('Data saved at %s.\n',fullfile(data_dir,filename));
    end
    
%     tic;
%     fprintf('Computing Time-Frequency Spectrogramm [%s] ...',cur_channel);
%     coefs_wav   = cmorcwt(Yraw,scales,Fb,Fc);
%     Cdata = log10(abs(coefs_wav)).^2;
%     fprintf(' done.\n');
%     toc;
%     
%     
%     filename = sprintf('[%s][%s]Wavelet_Analysis.mat',cur_recording,cur_channel);
%     save(fullfile(data_dir,filename),'Fb','Fc','fdom_step','fdom_min','fdom_max','freqdom',...
%         'cur_recording','cur_channel','x_start','x_end',...
%         'f_sub','f_samp','sub_samp','scales','all_Cdata','-v7.3');
%     fprintf('Data saved at %s.\n',fullfile(data_dir,filename));
    
end

% fprintf('Wavelet Spectrogram Computed File [%s].\n',cur_recording);
success = true;

end