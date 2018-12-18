function export_lfp_bands(foldername,handles,val)
% Export bands in Cereplex_Traces.mat
% bands frequencies and smoothing defined in the Preferences.mat
% user can select bands and channels manually

global DIR_SAVE FILES CUR_FILE;
load('Preferences.mat','GFilt');

% if val == 1 (default) user can select which channels to export
if nargin <4
    val = 1;
end

% Time Reference loading
if exist(fullfile(foldername,'Time_Reference.mat'),'file')
    data_t = load(fullfile(foldername,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
    time_ref = data_t.time_ref;
else
    errordlg(sprintf('Missing File %s',fullfile(foldername,'Time_Reference.mat')));
    return;
end

% Searching LFP channels in Traces_Cerep folder
dir_t = dir(fullfile(foldername,'Traces_Cerep','LFP_*.mat'));
if isempty(dir_t)
    errordlg(sprintf('No LFP traces_filter found in %s',foldername));
    return;
else
    
    channel_list = {dir_t(:).name}';
    %Sorting LFP channels according to configuration
    if exist(fullfile(foldername,'Nconfig.mat'),'file')
        %sort if lfp configuration is found
        data_lfp = load(fullfile(foldername,'Nconfig.mat'),'channel_type','ind_channel','channel_id');
        pattern_channels = data_lfp.channel_id(strcmp(data_lfp.channel_type,'LFP'));
        ind_1 = [];
        for i =1:length(pattern_channels)
            pattern = char(pattern_channels(i));
            ind_1 = [ind_1;find(~(cellfun('isempty',strfind(channel_list,pattern)))==1)];
        end
        ind_1 = flipud(ind_1);
        channel_list = {dir_t(ind_1).name}';
    end
end

% asks for user input if val == 1
if val == 1
    [ind_lfp,v] = listdlg('Name','LFP Selection','PromptString','Select channels to export',...
        'SelectionMode','multiple','ListString',channel_list,'InitialValue',[],'ListSize',[300 500]);
    if v==0 || isempty(ind_lfp)
        warning('No trace selected .\n');
        return;
    else
        channel_list =  channel_list(ind_lfp);
    end
end

% Sorting band info in array and vectors
str_band = {sprintf('Delta [%.1f - %.1f Hz] (%.3f s)',GFilt.delta_inf,GFilt.delta_sup,GFilt.delta_smooth);...
    sprintf('Theta [%.1f - %.1f Hz] (%.3f s)',GFilt.theta_inf,GFilt.theta_sup,GFilt.theta_smooth);...
    sprintf('Gamma Low [%.1f - %.1f Hz] (%.3f s)',GFilt.gammalow_inf,GFilt.gammalow_sup,GFilt.gammalow_smooth);...
    sprintf('Gamma Mid [%.1f - %.1f Hz] (%.3f s)',GFilt.gammamid_inf,GFilt.gammamid_sup,GFilt.gammamid_smooth);...
    sprintf('Gamma High [%.1f - %.1f Hz] (%.3f s)',GFilt.gammahigh_inf,GFilt.gammahigh_sup,GFilt.gammahigh_smooth);...
    sprintf('Ripple [%.1f - %.1f Hz] (%.3f s)',GFilt.ripple_inf,GFilt.ripple_sup,GFilt.ripple_smooth)};
band_list = {'delta';'theta';'gammalow';'gammamid';'gammahigh';'ripple'};
fband_inf = [GFilt.delta_inf;GFilt.theta_inf;GFilt.gammalow_inf;GFilt.gammamid_inf;GFilt.gammahigh_inf;GFilt.ripple_inf];
fband_sup = [GFilt.delta_sup;GFilt.theta_sup;GFilt.gammalow_sup;GFilt.gammamid_sup;GFilt.gammahigh_sup;GFilt.ripple_sup];
tband_smooth = [GFilt.delta_smooth;GFilt.theta_smooth;GFilt.gammalow_smooth;GFilt.gammamid_smooth;GFilt.gammahigh_smooth;GFilt.ripple_smooth];
        
if val == 1
    [ind_band,v] = listdlg('Name','Band Selection','PromptString','Select bands to export',...
        'SelectionMode','multiple','ListString',str_band,'InitialValue',[],'ListSize',[300 500]);
    if v==0 || isempty(ind_band)
        warning('No band selected .\n');
        return;
    else 
        band_list =  band_list(ind_band);
        fband_inf =  fband_inf(ind_band);
        fband_sup =  fband_sup(ind_band);
        tband_smooth =  tband_smooth(ind_band);
    end
end

% Saving struct
count = 0;
traces_filter = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});
traces_envelope = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

% Extracting bands for each channel
for i =1:length(band_list)
    %getting band params
    band_name = char(band_list(i));
    f1 = fband_inf(i);
    f2 = fband_sup(i);
    t_smooth  = tband_smooth(i);
    
    for j =1:length(channel_list)
        % loading
        str_channel = char(channel_list(j));
        data  = load(fullfile(foldername,'Traces_Cerep',str_channel));
        Y = data.Y;
        X = (data.x_start:data.f:data.x_end)';
        fs = 1/data.f;
        
        % Pass-band filtering
        fprintf('Filtering LFP for %s [%s]...',band_name,str_channel);
        [B,A]  = butter(1,[f1 f2]/(fs/2),'bandpass');
        Y_temp = filtfilt(B,A,Y);
        
        % Subsampling
        ftemp = 10*f2;
        if ftemp < fs
            X_filt = (X(1):1/ftemp:X(end))';
            Y_filt = interp1(X,Y_temp,X_filt);
        else
            X_filt = X;
            Y_filt = Y_temp;
        end
        fprintf(' done;\n');
        
        % Extract envelope
        % fl = max(round(t_smooth/(X_filt(2)-X_filt(1))),1);
        % [Y_env_up,Y_env_down] = envelope(Y_filt,fl,'analytic');        
        f_filt = 1/(X_filt(2)-X_filt(1));
        [Y_env_up,~] = envelope(Y_filt);
        %Gaussian smoothing
        n = max(round(t_smooth*f_filt),1);
        Y_power = conv(Y_env_up,gausswin(n)/n,'same');

        % Saving
        count = count+1;
        temp = regexp(strrep(str_channel,'.mat',''),'_','split');
        traces_filter(count).ID = char(temp(2));
        traces_filter(count).shortname = sprintf('LFP-%s',band_name);
        traces_filter(count).parent = 'Cereplex-Traces';
        traces_filter(count).fullname = strcat(traces_filter(count).shortname,'/',traces_filter(count).ID);
        traces_filter(count).X = X_filt;
        traces_filter(count).Y = Y_filt;
        traces_filter(count).X_ind = data_t.time_ref.X;
        traces_filter(count).X_im = data_t.time_ref.Y;
        traces_filter(count).Y_im = interp1(traces_filter(count).X,traces_filter(count).Y,traces_filter(count).X_im);
        traces_filter(count).nb_samples = length(Y_filt);
        %fprintf('Succesful Importation %s [Parent %s].\n',traces_filter(i).fullname,traces_filter(i).parent);
        
        % Saving
        traces_envelope(count).ID = char(temp(2));
        traces_envelope(count).shortname = sprintf('Power-%s',band_name);
        traces_envelope(count).parent = 'Cereplex-Traces';
        traces_envelope(count).fullname = strcat(traces_envelope(count).shortname,'/',traces_envelope(count).ID);
        traces_envelope(count).X = X_filt;
        traces_envelope(count).Y = Y_power;
        traces_envelope(count).X_ind = data_t.time_ref.X;
        traces_envelope(count).X_im = data_t.time_ref.Y;
        traces_envelope(count).Y_im = interp1(traces_envelope(count).X,traces_envelope(count).Y,traces_envelope(count).X_im);
        traces_envelope(count).nb_samples = length(Y_power);
        %fprintf('Succesful Importation %s [Parent %s].\n',traces_envelope(i).fullname,traces_envelope(i).parent);     
        
    end
end

% Save dans SpikoscopeTraces.mat
MetaData = [];
if ~isempty(traces_filter)
    traces = [traces_filter,traces_envelope];
    fprintf('Saving Cereplex traces ...\n');
    save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Cereplex_Traces.mat'),'traces','MetaData','-v7.3');
    fprintf('===> Saved at %s.mat\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Cereplex_Traces.mat'));
end


end