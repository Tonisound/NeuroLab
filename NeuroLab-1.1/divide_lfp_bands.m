function success = divide_lfp_bands(foldername,handles,val)
% Searches for LFP power envelopes and computes ratio
% User can select bands and channels manually
% Selects only main channel (if specified) in batch mode

success = false;
load('Preferences.mat','GFilt');

% val = 0: batch mode
% val = 1: user can select which channels to export
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
d_lfp = dir(fullfile(foldername,'Sources_LFP','LFP_*.mat'));
if isempty(d_lfp)
    errordlg(sprintf('No LFP traces_filter found in %s',foldername));
    return;
else

    temp = {d_lfp(:).name}';
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
    [ind_lfp,v] = listdlg('Name','LFP Selection','PromptString','Select channels to divide',...
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
% str_band = {sprintf('Broadband [%.1f-%.1fHz]',GFilt.broad_inf,GFilt.broad_sup);...
%     sprintf('Delta [%.1f-%.1fHz]',GFilt.delta_inf,GFilt.delta_sup);...
%     sprintf('Theta [%.1f-%.1fHz]',GFilt.theta_inf,GFilt.theta_sup);...
%     sprintf('Gamma [%.1f-%.1fHz]',GFilt.gammalow_inf,GFilt.gammalow_sup);...
%     sprintf('Gamma Mid [%.1f-%.1fHz]',GFilt.gammamid_inf,GFilt.gammamid_sup);...
%     sprintf('Gamma Mid Up [%.1f-%.1fHz]',GFilt.gammamidup_inf,GFilt.gammamidup_sup);...
%     sprintf('Gamma High [%.1f-%.1fHz]',GFilt.gammahigh_inf,GFilt.gammahigh_sup);...
%     sprintf('Gamma High Up [%.1f-%.1fHz]',GFilt.gammahighup_inf,GFilt.gammahighup_sup);...
%     sprintf('Ripple [%.1f-%.1fHz]',GFilt.ripple_inf,GFilt.ripple_sup,GFilt.ripple_smooth)};
str_band = {'Broadband';'Delta';'Theta';'Gamma Low';'Gamma Mid';'Gamma Mid Up';'Gamma High';'Gamma High Up';'Ripple'};
band_list = {'broadband';'delta';'theta';'gammalow';'gammamid';'gammamidup';'gammahigh';'gammahighup';'ripple'};

str_ratio = [];
band_ratio = [];
for i =1:length(str_band)
    for j=1:length(str_band)
        if i==j
            continue;
        else
            str_ratio = [str_ratio;{sprintf('%s/%s',char(str_band(i)),char(str_band(j)))}];
            band_ratio = [band_ratio;{sprintf('%s/%s',char(band_list(i)),char(band_list(j)))}];
        end
    end
end


% Initial selection 
pattern_list = {'Theta/'};
ind_selected = find(contains(str_ratio,pattern_list)==1);
% asks for user input if val == 1
if val == 1
    % user mode
    [ind_ratio,v] = listdlg('Name','Band Selection','PromptString','Select band ratios to import',...
        'SelectionMode','multiple','ListString',str_ratio,'InitialValue',ind_selected','ListSize',[300 500]);
else
    % batch mode
    ind_ratio = ind_selected;
    v = true;
end
% return if selection empty
if v==0 || isempty(ind_ratio)
    warning('No band selected .\n');
    return;
else
    band_ratio =  band_ratio(ind_ratio);
    str_ratio = str_ratio(ind_ratio);
end


% Saving struct
count = 0;
d_envelope = dir(fullfile(foldername,'Sources_LFP','Power-*.mat'));
traces_ratio = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

% Extracting bands for each channel
for j = 1:length(channel_list)
    % loading
    str_channel = char(channel_list(j));
    channel = strrep(str_channel,'LFP_','');
    channel = strrep(channel,'.mat','');
    
    for i = 1:length(band_ratio)
        %getting band params
        temp = regexp(char(band_ratio(i)),'/','split');
        band_den = strcat(char(temp(2)),'_');
        band_num = strcat(char(temp(1)),'_');
    
        index_channel = contains({d_envelope(:).name}',channel);
        index_num = find((index_channel.*contains({d_envelope(:).name}',band_num))==1);
        index_den = find((index_channel.*contains({d_envelope(:).name}',band_den))==1);
        
        if isempty(index_num)
            warning('Missing Power Envelope (%s) for channel (%s). Proceeding.',char(str_ratio(i)),str_channel);
            continue;
        elseif isempty(index_den)
            warning('Missing Power Envelope (%s) for channel (%s). Proceeding.',char(str_ratio(i)),str_channel);
            continue;
        else
            data_num = load(fullfile(d_envelope(index_num).folder,d_envelope(index_num).name));
            data_den = load(fullfile(d_envelope(index_den).folder,d_envelope(index_den).name));
        end
            
        Y_num = data_num.Y;
        X_num = (data_num.x_start:data_num.f:data_num.x_end)';
        Y_den = data_den.Y;
        X_den = (data_den.x_start:data_den.f:data_den.x_end)';
        
        if data_num.f == data_den.f
            X = X_num;
            Y = Y_num./Y_den;
        elseif data_num.f > data_den.f
            X = X_den;
            Y = interp1(X_num,Y_num,X)./Y_den;
        else
            X = X_num;
            Y = Y_num./interp1(X_den,Y_den,X);
        end
        
        % Saving
        count = count+1;
        % temp = regexp(strrep(str_channel,'.mat',''),'_','split');
        % traces_ratio(count).ID = char(temp(2));
        traces_ratio(count).ID = channel;
        traces_ratio(count).shortname = sprintf('Power-%s',strrep(char(band_ratio(i)),'/','|'));
        traces_ratio(count).parent = 'Cereplex-Traces';
        traces_ratio(count).fullname = strcat(traces_ratio(count).shortname,'/',traces_ratio(count).ID);
        traces_ratio(count).X = X;
        traces_ratio(count).Y = Y;
        traces_ratio(count).X_ind = data_t.time_ref.X;
        traces_ratio(count).X_im = data_t.time_ref.Y;
        traces_ratio(count).Y_im = interp1(traces_ratio(count).X,traces_ratio(count).Y,traces_ratio(count).X_im);
        traces_ratio(count).nb_samples = length(Y);
        %fprintf('Succesful Importation %s [Parent %s].\n',traces_ratio(i).fullname,traces_ratio(i).parent);   
        
    end
end

% Merging traces
traces = traces_ratio;
ind_traces = 1:length(traces_ratio);

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


% % Initial selection 
% pattern_list = {'Power';'LFP-theta'};
% ind_selected = find(contains({traces.fullname}',pattern_list)==1);
% % asks for user input if val == 1
% if val == 1
%     % user mode
%     [ind_traces,ok] = listdlg('PromptString','Select Traces','SelectionMode','multiple',...
%         'ListString',{traces.fullname}','InitialValue',ind_selected,'ListSize',[400 500]);
% else
%     % batch mode
%     ind_traces = ind_selected;
%     ok = true;
% end
% % return if selection empty
% if ~ok || isempty(ind_traces)
%     return;
% end


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