function success = import_intan_files(F,handles,val)

success = false;

global DIR_SAVE;
load('Preferences.mat','GImport','GFilt');
dir_save = fullfile(DIR_SAVE,F.nlab);

% Manual mode val = 1; batch mode val =0
if nargin<3
    val=1;
end

% Loading Time_Reference.mat
if exist(fullfile(dir_save,'Time_Reference.mat'),'file')
    data_t = load(fullfile(dir_save,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
else
    errordlg(sprintf('Missing File %s',fullfile(dir_save,'Time_Reference.mat')));
    return;
end

% Loading Config.mat
if exist(fullfile(dir_save,'Config.mat'),'file')
    data_c = load(fullfile(dir_save,'Config.mat'),'File','UiValues');
else
    errordlg(sprintf('Missing File %s',fullfile(dir_save,'Config.mat')));
    return;
end

% Loading rhd2 file
d_rhd2 = dir(fullfile(F.fullpath,F.dir_lfp,'*.rhd2'));
if length(d_rhd2) == 1
    data_rhd2 = load(fullfile(d_rhd2.folder,d_rhd2.name),'-mat');
    fprintf('File rhd2 loaded at [%s].\n',fullfile(d_rhd2.folder,d_rhd2.name));
elseif isempty(d_rhd2)
    errordlg(sprintf('Missing rhd2 File [%s]',fullfile(F.fullpath,F.dir_lfp)));
    return;
else
    errordlg(sprintf('Multiple rhd2 Files - Abort. [%s]',fullfile(F.fullpath,F.dir_lfp)));
    return;
end
num_channels_amp = data_rhd2.num_channels_amp;
num_channels_aux = data_rhd2.num_channels_aux;
num_channels_adc = data_rhd2.num_channels_adc;
% f_samp = data_rhd2.f_samp;
numChannels = num_channels_amp+num_channels_aux+num_channels_adc;
count=0;


% Browsing dir_lfp
channel_id = cell(numChannels,1);
channel_type = cell(numChannels,1);
channel_list = cell(numChannels,1);
RawData = [];


% Time Data
if isfile(fullfile(F.fullpath,F.dir_lfp,'time.mat'))
    
    fprintf('Loading Time Data [%s]...',F.dir_lfp);
    data_time = load(fullfile(F.fullpath,F.dir_lfp,'time.mat'));
    fprintf(' done.\n');
    
else
    errordlg(sprintf('Missing time.mat [%s]',fullfile(F.fullpath,F.dir_lfp)));
    return;
end

% Amplifier Data
if isfile(fullfile(F.fullpath,F.dir_lfp,'amplifier.mat')) && num_channels_amp>0
    
    fprintf('Loading Amplifier Data [%s]...',F.dir_lfp);
    data_amp = load(fullfile(F.fullpath,F.dir_lfp,'amplifier.mat'));
    fprintf(' done.\n');
    for i = 1:num_channels_amp
        count=count+1;
        native_name = data_amp.InfoRHD(i).native_channel_name;
        port_prefix = data_amp.InfoRHD(i).port_prefix;
        channel_id{count} = strrep(native_name,[port_prefix,'-'],'');
        channel_type{count} = 'LFP';
        channel_list{count} = sprintf('%s/%s',char(channel_type(count)),char(channel_id(count)));      
    end
    RawData = [RawData;data_amp.data];
    
else
    errordlg(sprintf('Missing amplifier.mat [%s]',fullfile(F.fullpath,F.dir_lfp)));
    return;
end

% Auxiliary Data
if isfile(fullfile(F.fullpath,F.dir_lfp,'auxiliary.mat')) && num_channels_aux>0
    
    fprintf('Loading Auxiliary Data [%s]...',F.dir_lfp);
    data_aux = load(fullfile(F.fullpath,F.dir_lfp,'auxiliary.mat'));
    fprintf(' done.\n');
    for i = 1:num_channels_aux
        count=count+1;
        native_name = data_aux.InfoRHD(i).native_channel_name;
        port_prefix = data_aux.InfoRHD(i).port_prefix;
        channel_id{count} = strrep(native_name,[port_prefix,'-'],'');
        channel_type{count} = 'ACC';
        channel_list{count} = sprintf('%s/%s',char(channel_type(count)),char(channel_id(count)));        
    end
    RawData = [RawData;data_aux.data];
    
else
    errordlg(sprintf('Missing auxiliary.mat [%s]',fullfile(F.fullpath,F.dir_lfp)));
    return;
end

% Analogin Data
if isfile(fullfile(F.fullpath,F.dir_lfp,'analogin.mat')) && num_channels_adc>0
    
    fprintf('Loading Analogin Data [%s]...',F.dir_lfp);
    data_adc = load(fullfile(F.fullpath,F.dir_lfp,'analogin.mat'));
    fprintf(' done.\n');
    for i = 1:num_channels_adc
        count=count+1;
        native_name = data_adc.InfoRHD(i).native_channel_name;
        port_prefix = data_adc.InfoRHD(i).port_prefix;
        channel_id{count} = strrep(native_name,[port_prefix,'-'],'');
        channel_type{count} = 'TRIG';
        channel_list{count} = sprintf('%s/%s',char(channel_type(count)),char(channel_id(count)));   
    end
    RawData = [RawData;data_adc.data];
    
else
    errordlg(sprintf('Missing analogin.mat [%s]',fullfile(F.fullpath,F.dir_lfp)));
    return;
end
numSamples = size(RawData,2);


% Looking for NConfig file
if exist(fullfile(DIR_SAVE,F.nlab,'Nconfig.mat'),'file')
    % load from ncf file
    d_ncf = load(fullfile(DIR_SAVE,F.nlab,'Nconfig.mat'),...
        'ind_channel','ind_channel_diff','channel_id','channel_list','channel_type');
    ind_channel = d_ncf.ind_channel;
    ind_channel_diff = d_ncf.ind_channel_diff;
    channel_id = d_ncf.channel_id;
    channel_type = d_ncf.channel_type;
    channel_list = d_ncf.channel_list;
else
    if val==1
        % user mode
        % Prompt user to select files
        [ind_channel,v] = listdlg('Name','Intan Channel Selection','PromptString','Select Intan channels',...
            'SelectionMode','multiple','ListString',channel_list,'InitialValue','','ListSize',[300 500]);
    else
        % batch mode
        % select all channels
        ind_channel = 1:length(channel_list);
        v = 1;  
    end
    
    if isempty(ind_channel)||v==0
        return
    end
    % Save Nconfig.mat
    channel_id = channel_id(ind_channel);
    channel_list = channel_list(ind_channel);
    channel_type = channel_type(ind_channel);
    ind_channel_diff = NaN(size(ind_channel));
    save(fullfile(DIR_SAVE,F.nlab,'Nconfig.mat'),...
        'ind_channel','ind_channel_diff','channel_id','channel_list','channel_type','-v7.3');
    %F.ncf = strcat(F.recording,'.mat');
end

% Loading Data
Data = NaN(length(ind_channel),numSamples);
for i =1:length(ind_channel)
    if isnan(ind_channel_diff(i))
        if isnan(ind_channel(i))
            warning('Invalid index channels importing trace [%s].',char(channel_list(i)));
            Data(i,:) = NaN(1,size(RawData,2));
        else
            Data(i,:) = RawData(ind_channel(i),:);
        end
        
    else
        if isnan(ind_channel(i))
            Data(i,:) = -RawData(ind_channel_diff(i),:);
        else
            Data(i,:) = RawData(ind_channel(i),:)-RawData(ind_channel_diff(i),:);
        end
    end
end

% Data = NaN(length(ind_channel),numSamples);
% for i =1:length(ind_channel)
%     channelName = strcat(char(channel_id(i)),'.mat');
%     data_channel = load(filepath,channelName);
%     Data(i,:) = RawData(ind_channel(i),:);
% end


% Storing data in traces
parent = data_rhd2.parent;
nb_samples = numSamples;
duration = data_time.t(end);
f_samp = data_time.f_samp;
traces = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

for i=1:length(ind_channel)
    traces(i).ID = char(channel_id(i));
    traces(i).shortname = char(channel_type(i));
    traces(i).parent = parent;
    traces(i).fullname = char(channel_list(i));
%     traces(i).X = (0: 1/f_samp : duration-(1/f_samp))';
    traces(i).X = data_time.t;
    traces(i).Y = double(Data(i,:)');
    traces(i).X_ind = data_t.time_ref.X;
    traces(i).X_im = data_t.time_ref.Y;
    traces(i).nb_samples = nb_samples;
    
    % Filtering LFP
    str = lower(traces(i).fullname);
    if contains(str,'temp')
        f1 = GFilt.temp_inf;
        f2 = GFilt.temp_sup;
    elseif contains(str,'acc')
        f1 = GFilt.acc_inf;
        f2 = GFilt.acc_sup;
    elseif contains(str,'gyr')
        f1 = GFilt.gyr_inf;
        f2 = GFilt.gyr_sup;
    elseif contains(str,'emg')
        f1 = GFilt.emg_inf;
        f2 = GFilt.emg_sup;
    else 
        f1 = GFilt.broad_inf;
        f2 = GFilt.broad_sup;
    end
    [B,A]  = butter(1,[f1 f2]/(f_samp/2),'bandpass');
    Y_filt = filtfilt(B,A,traces(i).Y);
    
    % LFP band cut
    if contains(str,'lfp')
        f1 = 49;
        f2 = 51;
        [B,A]  = butter(1,[f1 f2]/(f_samp/2),'stop');
        Y_filt = filtfilt(B,A,traces(i).Y);
    end
    
    traces(i).Y = Y_filt;
    traces(i).Y_im = interp1(traces(i).X,traces(i).Y,traces(i).X_im);
    if contains(str,'lfp')      
        fprintf('Succesful Importation %s [Parent %s] [Bandcut: (%.2f Hz,%.2f Hz)].\n',traces(i).fullname,traces(i).parent,f1,f2);
    else
        fprintf('Succesful Importation %s [Parent %s] [Bandpass: (%.2f Hz,%.2f Hz)].\n',traces(i).fullname,traces(i).parent,f1,f2);
    end
end


% Building traces_diff_lfp
ind_lfp = strcmp(channel_type,'LFP');
traces_lfp = traces(ind_lfp==1);
traces_remainder = traces(ind_lfp==0);
traces_diff_lfp = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

% removing diff channels
ind_keep = ~contains({traces_lfp(:).ID}','$');
channel_id = channel_id(ind_keep);
channel_type = channel_type(ind_keep);
traces_lfp_cleared = traces_lfp(ind_keep);

for i = 1:length(traces_lfp_cleared)-1
    % traces_diff_lfp(i).ID = strcat(char(channel_id(i)),'---',char(channel_id(i+1)));
    
    traces_diff_lfp(i).ID = strcat(char(channel_id(i)),'$',char(channel_id(i+1)));
    traces_diff_lfp(i).shortname = char(channel_type(i));
    traces_diff_lfp(i).parent = parent;
    traces_diff_lfp(i).fullname = sprintf('%s/%s',traces_diff_lfp(i).shortname,traces_diff_lfp(i).ID);
    traces_diff_lfp(i).X = traces_lfp_cleared(i).X;
    traces_diff_lfp(i).Y = traces_lfp_cleared(i).Y-traces_lfp_cleared(i+1).Y;
    traces_diff_lfp(i).X_ind = data_t.time_ref.X;
    traces_diff_lfp(i).X_im = data_t.time_ref.Y;
    traces_diff_lfp(i).Y_im = interp1(traces_diff_lfp(i).X,traces_diff_lfp(i).Y,traces_diff_lfp(i).X_im);
    traces_diff_lfp(i).nb_samples = traces_lfp_cleared(:).nb_samples;
    
end
% Modyfing traces according to GImport.Channel_loading
switch GImport.Channel_loading
    case 'differential'
        traces = [traces_diff_lfp,traces_remainder];
    case 'all'
        traces = [traces_lfp,traces_diff_lfp,traces_remainder];
    otherwise
        traces = [traces_lfp,traces_remainder];   
end


% Direct Loading LFP traces
load('Preferences.mat','GDisp','GTraces');
g_colors = get(groot,'defaultAxesColorOrder');

if val ==1
    [ind_traces,ok] = listdlg('PromptString','Select Traces','SelectionMode','multiple',...
        'ListString',{traces.fullname},'ListSize',[400 500]);
else
    ind_traces = 1:length(traces);
    ok = true;
    
%     % (additional code) importing only mainchannel in batch mode
%     ind_mainchannel = find(strcmp({traces(:).fullname}',strcat('LFP/',data_c.File.mainlfp))==1);
%     ind_traces = ind_mainchannel;
%     ok = true;
    
    if isempty(ind_traces)
        warning('Problem finding main lfp channel [%s].',folder_hd);
        return;
    end
end

if ~ok || isempty(ind_traces)
    return;
end

% getting lines name
lines = findobj(handles.RightAxes,'Tag','Trace_Cerep');
lines_name = cell(length(lines),1);
for i =1:length(lines)
    lines_name{i} = lines(i).UserData.Name;
end

all_X = NaN(length(ind_traces),2);
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
        lines(ind_overwrite).UserData.Y = traces(ind_traces(i)).Y;
        lines(ind_overwrite).XData = Xtemp;
        lines(ind_overwrite).YData = Ytemp;
        fprintf('LFP Trace successfully updated (%s) ',traces(ind_traces(i)).fullname);
        save_name = strrep(t,'/','_');
    else
        %line creation
        str = lower(char(traces(ind_traces(i)).fullname));
        if strfind(str,'lfp')
            color = 'k';
        elseif strfind(str,'emg')
            color = [.5 .5 .5];
        elseif strfind(str,'acc')
            color = 'g';
        elseif strfind(str,'temp')
            color = 'r';
        elseif strfind(str,'gyr')
            color = 'b';
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
        fprintf('LFP Trace successfully loaded (%s) ',traces(ind_traces(i)).fullname);
        save_name = strrep(s.Name,'/','_');
    end
    
    % Save LFP source
    dir_source = fullfile(dir_save,'Sources_LFP');
    if ~exist(dir_source,'dir')
        mkdir(dir_source);
    end
    X = traces(ind_traces(i)).X;
    Y = traces(ind_traces(i)).Y;
    f = X(2)-X(1);
    x_start = X(1);
    x_end = X(end);
    delta = length(Y)-length(x_start:f:x_end);
    if delta>0
        Y=Y(1:end-delta);
    end
    save(fullfile(dir_source,strcat(save_name,'.mat')),'Y','f','x_start','x_end','-v7.3');
    fprintf('- Saved [%s]\n',fullfile(dir_source,strcat(save_name,'.mat')));
    
    all_X(i,:) = [X(1) X(end)];
end

% save TimeTags.mat (whole LFP)
if exist(fullfile(dir_save,'Time_Tags.mat'),'file')
    tt_data = load(fullfile(dir_save,'Time_Tags.mat'));
else
    warning(sprintf('Missing File %s',fullfile(dir_save,'Time_Tags.mat')));
    return;
end

% % Finding Whole-LFP
% Erase previous TimeTags if flag_tag
flag_tag = true;
if flag_tag
    temp = {tt_data.TimeTags(:).Tag}';
    ind_keep = ~contains(temp,"Whole-LFP");
    tt_data.TimeTags_images = tt_data.TimeTags_images(ind_keep,:);
    tt_data.TimeTags_strings = tt_data.TimeTags_strings(ind_keep,:);
    tt_data.TimeTags_cell = [tt_data.TimeTags_cell(1,:);tt_data.TimeTags_cell(find(ind_keep==1)+1,:)];
    tt_data.TimeTags = tt_data.TimeTags(ind_keep);
end

t_start = min(all_X(:,1));
t_end = max(all_X(:,2));
%TimeTags_strings
tts_1 = cellstr(datestr(t_start/(24*3600),'HH:MM:SS.FFF'));
tts_2 = cellstr(datestr((t_end-t_start)/(24*3600),'HH:MM:SS.FFF'));
TimeTags_strings = [tts_1,tts_2];
% TimeTags_images
%data_t = load(fullfile(dir_save,'Time_Reference.mat'),'time_ref');
[~, ind_min_time] = min(abs(data_t.time_ref.Y-t_start));
[~, ind_max_time] = min(abs(data_t.time_ref.Y-t_end));
TimeTags_images = [ind_min_time,ind_max_time];

% TimeTags
TimeTags_seconds = [t_start,t_end];
TimeTags_dur = datestr((TimeTags_seconds(:,2)-TimeTags_seconds(:,1))/(24*3600),'HH:MM:SS.FFF');
TimeTags = struct('Episode',[],'Tag',[],'Onset',[],'Duration',[],'Reference',[]);
TimeTags.Episode = '';
TimeTags.Tag = 'Whole-LFP';
TimeTags.Onset = char(TimeTags_strings(1,1));
TimeTags.Duration =  char(TimeTags_dur(1,:));
TimeTags.Reference = TimeTags.Onset;
TimeTags.Tokens = '';
% TimeTags_cell
TimeTags_cell = {'',TimeTags(1).Tag,TimeTags(1).Onset,TimeTags(1).Duration,TimeTags(1).Reference,''};

% Saving TimeTags.mat
TimeTags_images = [tt_data.TimeTags_images;TimeTags_images];
TimeTags_strings = [tt_data.TimeTags_strings;TimeTags_strings];
TimeTags_cell = [tt_data.TimeTags_cell;TimeTags_cell];
TimeTags = [tt_data.TimeTags;TimeTags];
save(fullfile(dir_save,'Time_Tags.mat'),'TimeTags','TimeTags_cell','TimeTags_strings','TimeTags_images');
fprintf('===> Time Tags updates [%s]\n',fullfile(dir_save,'Time_Tags.mat'));

success = true;

end
