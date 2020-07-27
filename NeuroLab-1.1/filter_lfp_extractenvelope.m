function success = filter_lfp_extractenvelope(foldername,handles,val)
% Filter LFP channels into bands defined in Gfilt (Preferences.mat)
% Compute and smooth LFP power envelopes
% User can select bands and channels manually
% Selects only main channel (if specified) in batch mode

success = false;
load('Preferences.mat','GFilt');

% if val undefined, set val = 1 (default) user can select which channels to export
if nargin <3
    val = 1;
end

% Loading Configuration
if exist(fullfile(foldername,'Config.mat'),'file')
    data_config = load(fullfile(foldername,'Config.mat'));
else
    errordlg(sprintf('Missing File %s',fullfile(foldername,'Config.mat')));
    return;
end

% Time Reference loading
if exist(fullfile(foldername,'Time_Reference.mat'),'file')
    data_t = load(fullfile(foldername,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
    time_ref = data_t.time_ref;
else
    errordlg(sprintf('Missing File %s',fullfile(foldername,'Time_Reference.mat')));
    return;
end

% Searching LFP channels in Sources_LFP folder
dir_t = dir(fullfile(foldername,'Sources_LFP','LFP_*.mat'));
if isempty(dir_t)
    errordlg(sprintf('No LFP traces_filter found in %s',foldername));
    return;
else

    temp = {dir_t(:).name}';
    if exist(fullfile(foldername,'Nconfig.mat'),'file')
        %sort if lfp configuration is found
        data_lfp = load(fullfile(foldername,'Nconfig.mat'),'channel_type','channel_id');
        channel_id = data_lfp.channel_id(strcmp(data_lfp.channel_type,'LFP'));
        channel_id_diff = strcat(channel_id(1:end-1),'$',channel_id(2:end)); 
        % sorting LFP
        pattern_lfp = strcat('LFP_',[channel_id;channel_id_diff],'.mat');
        ind_1 = [];
        ind_all = zeros(size(temp));
        for i =1:length(pattern_lfp)
            ind_keep = strcmp(temp,pattern_lfp(i));
            ind_all = ind_all+ind_keep;
            ind_1 = [ind_1;find(ind_keep==1)];
        end
        ind_remainder = ~ind_all;
        ind_1=[ind_1;find(ind_remainder==1)];
        
    else
        ind_1 = ones(size(temp));
    end
    channel_list = temp(ind_1);
end

% Initial selection
ind_selected = find(strcmp(channel_list,strcat('LFP_',data_config.File.mainlfp,'.mat'))==1);
if ~isempty(ind_selected)
    ind_selected = ind_selected(1);
else
    ind_selected = 1:length(channel_list);
end
% asks for user input if val == 1
if val == 1
    % user mode
    [ind_lfp,v] = listdlg('Name','LFP Selection','PromptString','Select channels to export',...
        'SelectionMode','multiple','ListString',channel_list,'InitialValue',ind_selected,'ListSize',[300 500]);
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
    channel_list =  channel_list(ind_lfp);
end


% Sorting band info in array and vectors
str_band = {sprintf('Broadband [%.1f - %.1f Hz] (%.3f s)',GFilt.broad_inf,GFilt.broad_sup,GFilt.broad_smooth);...
    sprintf('Delta [%.1f - %.1f Hz] (%.3f s)',GFilt.delta_inf,GFilt.delta_sup,GFilt.delta_smooth);...
    sprintf('Theta [%.1f - %.1f Hz] (%.3f s)',GFilt.theta_inf,GFilt.theta_sup,GFilt.theta_smooth);...
    sprintf('Beta [%.1f - %.1f Hz] (%.3f s)',GFilt.beta_inf,GFilt.beta_sup,GFilt.beta_smooth);...
    sprintf('Gamma Low [%.1f - %.1f Hz] (%.3f s)',GFilt.gammalow_inf,GFilt.gammalow_sup,GFilt.gammalow_smooth);...
    sprintf('Gamma Mid [%.1f - %.1f Hz] (%.3f s)',GFilt.gammamid_inf,GFilt.gammamid_sup,GFilt.gammamid_smooth);...
    sprintf('Gamma Mid Up [%.1f - %.1f Hz] (%.3f s)',GFilt.gammamidup_inf,GFilt.gammamidup_sup,GFilt.gammamidup_smooth);...
    sprintf('Gamma High [%.1f - %.1f Hz] (%.3f s)',GFilt.gammahigh_inf,GFilt.gammahigh_sup,GFilt.gammahigh_smooth);...
    sprintf('Gamma High Up [%.1f - %.1f Hz] (%.3f s)',GFilt.gammahighup_inf,GFilt.gammahighup_sup,GFilt.gammahighup_smooth);...
    sprintf('Ripple [%.1f - %.1f Hz] (%.3f s)',GFilt.ripple_inf,GFilt.ripple_sup,GFilt.ripple_smooth)};
band_list = {'broadband';'delta';'theta';'beta';'gammalow';'gammamid';'gammamidup';'gammahigh';'gammahighup';'ripple'};
fband_inf = [GFilt.broad_inf;GFilt.delta_inf;GFilt.theta_inf;GFilt.beta_inf;GFilt.gammalow_inf;GFilt.gammamid_inf;GFilt.gammamidup_inf;GFilt.gammahigh_inf;GFilt.gammahighup_inf;GFilt.ripple_inf];
fband_sup = [GFilt.broad_sup;GFilt.delta_sup;GFilt.theta_sup;GFilt.beta_sup;GFilt.gammalow_sup;GFilt.gammamid_sup;GFilt.gammamidup_sup;GFilt.gammahigh_sup;GFilt.gammahighup_sup;GFilt.ripple_sup];
tband_smooth = [GFilt.broad_smooth;GFilt.delta_smooth;GFilt.theta_smooth;GFilt.beta_smooth;GFilt.gammalow_smooth;GFilt.gammamid_smooth;GFilt.gammamidup_smooth;GFilt.gammahigh_smooth;GFilt.gammahighup_smooth;GFilt.ripple_smooth];
  

% Initial selection 
%pattern_list = {'Broadband','Delta','Theta','Beta','Gamma Low','Gamma Mid','Gamma High','Ripple'};
pattern_list = {'Theta','Delta'};
ind_selected = find(contains(str_band,pattern_list)==1);
% asks for user input if val == 1
if val == 1
    % user mode
    [ind_band,v] = listdlg('Name','Band Selection','PromptString','Select bands to export',...
        'SelectionMode','multiple','ListString',str_band,'InitialValue',ind_selected','ListSize',[300 500]);
else
    % batch mode
    ind_band = ind_selected;
    v = true;
end
% return if selection empty
if v==0 || isempty(ind_band)
    warning('No band selected .\n');
    return;
else
    band_list =  band_list(ind_band);
    fband_inf =  fband_inf(ind_band);
    fband_sup =  fband_sup(ind_band);
    tband_smooth =  tband_smooth(ind_band);
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
        data  = load(fullfile(foldername,'Sources_LFP',str_channel));
        Y = data.Y;
        X = (data.x_start:data.f:data.x_end)';
        fs = 1/data.f;
        
        % Pass-band filtering
        fprintf('Filtering LFP for %s [%s] [%.1f Hz; %.1f Hz]...',band_name,str_channel,f1,f2);
        [B,A]  = butter(1,[f1 f2]/(fs/2),'bandpass');
        Y_temp = filtfilt(B,A,Y);
        
        % Subsampling filter
        ftemp = 10*f2;
        if ftemp < fs
            X_filt = (X(1):1/ftemp:X(end))';
            Y_filt = interp1(X,Y_temp,X_filt);
        else
            X_filt = X;
            Y_filt = Y_temp;
        end
        
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
        
        % Extract envelope
        % fl = max(round(t_smooth/(X_filt(2)-X_filt(1))),1);
        % [Y_env_up,Y_env_down] = envelope(Y_filt,fl,'analytic');
        fprintf('Smoothing [%.1f s]...',t_smooth);
        f_filt = 1/(X_filt(2)-X_filt(1));
        [Y_env_up,~] = envelope(Y_filt);
        %Gaussian smoothing
        n = max(round(t_smooth*f_filt),1);
        Y_env = conv(Y_env_up,gausswin(n)/n,'same'); 
        fprintf(' done;\n');
        
        % Subsampling envelope
        ftemp = 5/t_smooth;
        if ftemp < f_filt
            X_power = (X_filt(1):1/ftemp:X_filt(end))';
            Y_power = interp1(X_filt,Y_env,X_power);
        else
            X_power = X_filt;
            Y_power = Y_env;
        end
        
        % Saving
        traces_envelope(count).ID = char(temp(2));
        traces_envelope(count).shortname = sprintf('Power-%s',band_name);
        traces_envelope(count).parent = 'Cereplex-Traces';
        traces_envelope(count).fullname = strcat(traces_envelope(count).shortname,'/',traces_envelope(count).ID);
        traces_envelope(count).X = X_power;
        traces_envelope(count).Y = Y_power;
        traces_envelope(count).X_ind = data_t.time_ref.X;
        traces_envelope(count).X_im = data_t.time_ref.Y;
        traces_envelope(count).Y_im = interp1(traces_envelope(count).X,traces_envelope(count).Y,traces_envelope(count).X_im);
        traces_envelope(count).nb_samples = length(Y_power);
        %fprintf('Succesful Importation %s [Parent %s].\n',traces_envelope(i).fullname,traces_envelope(i).parent);     
        
    end
end

% Merging traces
traces = [traces_filter,traces_envelope];

% % Save dans SpikoscopeTraces.mat
% MetaData = [];
% if ~isempty(traces_filter)
%     traces = [traces_filter,traces_envelope];
%     fprintf('Saving Cereplex traces ...\n');
%     save(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Cereplex_Traces.mat'),'traces','MetaData','-v7.3');
%     fprintf('===> Saved at %s.mat\n',fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Cereplex_Traces.mat'));
% end
% success = load_lfptraces(foldername,handles);

% Direct Loading LFP traces
load('Preferences.mat','GDisp','GTraces');
g_colors = get(groot,'DefaultAxesColorOrder');


% Initial selection 
pattern_list = {'Power';'LFP-theta'};
ind_selected = find(contains({traces.fullname}',pattern_list)==1);
% asks for user input if val == 1
if val == 1
    % user mode
    [ind_traces,ok] = listdlg('PromptString','Select Traces','SelectionMode','multiple',...
        'ListString',{traces.fullname}','InitialValue',ind_selected,'ListSize',[400 500]);
else
    % batch mode
    ind_traces = ind_selected;
    ok = true;
end
% return if selection empty
if ~ok || isempty(ind_traces)
    return;
end


% getting lines name
lines = findobj(handles.RightAxes,'Tag','Trace_Cerep');
lines_name = cell(length(lines),1);
for i =1:length(lines)
    lines_name{i} = lines(i).UserData.Name;
end

for i=1:length(ind_traces)
    
    % finding trace name
    t = traces(ind_traces(i)).fullname;
    
    %Adding burst
    Xtemp = traces(ind_traces(i)).X_ind;
    %Xtemp = [reshape(Xtemp,[data_t.length_burst,data_t.n_burst]);NaN(1,data_t.n_burst)];
    Ytemp = traces(ind_traces(i)).Y_im;
    %Ytemp = [reshape(Ytemp,[data_t.length_burst,data_t.n_burst]);NaN(1,data_t.n_burst)];
    
    if sum(strcmp(t,lines_name))>0
        %line already exists overwrite
        ind_overwrite = find(strcmp(t,lines_name)==1);
        lines(ind_overwrite).UserData.X = traces(ind_traces(i)).X;
        lines(ind_overwrite).UserData.Y = traces(ind_traces(i)).Y;
        lines(ind_overwrite).XData = Xtemp;
        lines(ind_overwrite).YData = Ytemp;
        save_name = regexprep(lines(ind_overwrite).UserData.Name,'/|\','_');
        fprintf('Cereplex Trace successfully updated (%s)\n',traces(ind_traces(i)).fullname);
    else
        %line creation
        str = lower(char(traces(ind_traces(i)).fullname));
        if strfind(str,'delta')
            color = g_colors(5,:);
        elseif strfind(str,'theta')
            color = g_colors(7,:);
        elseif strfind(str,'gammalow')
            color = g_colors(1,:);
        elseif strfind(str,'gammamid')
            color = g_colors(2,:);
        elseif strfind(str,'gammahigh')
            color = g_colors(3,:);
        elseif strfind(str,'ripple')
            color = g_colors(4,:);
        else
            color = rand(1,3);
        end
        % Line creation
        hl = line('XData',Xtemp,...
            'YData',Ytemp,...
            'Color',color,...
            'LineWidth',1,...
            'Tag','Trace_Cerep',...
            'Visible','off',...
            'HitTest','off',...
            'Parent', handles.RightAxes);
%         if handles.RightPanelPopup.Value==4
%             set(hl,'Visible','on');
%         end
        str_rpopup = strtrim(handles.RightPanelPopup.String(handles.RightPanelPopup.Value,:));
        if strcmp(str_rpopup,'Trace Dynamics')
            set(hl,'Visible','on');
        end
        
        % Updating UserData
        s.Name = regexprep(t,'_','-');
        s.Selected = 0;
        s.X = traces(ind_traces(i)).X;
        s.Y = traces(ind_traces(i)).Y;
        hl.UserData = s;
        save_name = regexprep(s.Name,'/|\','_');
        fprintf('Cereplex Trace successfully loaded (%s)\n',traces(ind_traces(i)).fullname);        
    end
    % Saving trace
    dir_source = fullfile(foldername,'Sources_LFP');
    if ~exist(dir_source,'dir')
        mkdir(dir_source);
    end
    X = traces(ind_traces(i)).X;
    Y = traces(ind_traces(i)).Y;
    f = X(2)-X(1);
    x_start = X(1);
    x_end = X(end);
    save(fullfile(dir_source,strcat(save_name,'.mat')),'Y','f','x_start','x_end','-v7.3');
    fprintf('Data Saved [%s]\n',fullfile(dir_source,strcat(save_name,'.mat')));
        
end

success = true;

end