function success = import_lfptraces(F,handles,val)

success = false;

global DIR_SAVE DIR_CONFIG;
load('Preferences.mat','GImport','GFilt');
dir_save = fullfile(DIR_SAVE,F.nlab);

% Manual mode val = 1; batch mode val =0
if nargin<3
    val=1;
end

if exist(fullfile(dir_save,'Time_Reference.mat'),'file')
    data_t = load(fullfile(dir_save,'Time_Reference.mat'),'time_ref','length_burst','n_burst');
else
    errordlg(sprintf('Missing File %s',fullfile(dir_save,'Time_Reference.mat')));
    return;
end

fprintf('Loading LFP data (%s)...',GImport.LFP_loading);
switch GImport.LFP_loading
    case 'ns1'
        if contains(F.ns1,'ns1')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns1));
        elseif contains(F.ns1,'sk1')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns1),'-mat');
        else
            errordlg('No file with NS1 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
    case 'ns2'
        if contains(F.ns2,'ns2')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns2));
        elseif contains(F.ns2,'sk2')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns2),'-mat');
        else
            errordlg('No file with NS2 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
    case 'ns3'
        if contains(F.ns3,'ns3')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns3));
        elseif contains(F.ns3,'sk3')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns3),'-mat');
        else
            errordlg('No file with NS3 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
    case 'ns4'
        if contains(F.ns4,'ns4')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns4));
        elseif contains(F.ns4,'sk4')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns4),'-mat');
        else
            errordlg('No file with NS4 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
    case 'ns5'
        if contains(F.ns5,'ns5')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns5));
        elseif contains(F.ns5,'sk5')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns5),'-mat');
        else
            errordlg('No file with NS5 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
    case 'ns6'
        if contains(F.ns6,'ns6')
            data_ns = openNSx('read',fullfile(F.fullpath,F.dir_lfp,F.ns6));
        elseif contains(F.ns6,'sk6')
            data_ns = load(fullfile(F.fullpath,F.dir_lfp,F.ns6),'-mat');
        else
            errordlg('No file with NS6 format in %s',fullfile(F.fullpath,F.dir_lfp));
            return;
        end
    otherwise
        data_ns = openNSx('read');
end
fprintf(' done.\n');

%Storing MetaData
MetaData = data_ns.MetaTags;
channel_id = cell(MetaData.ChannelCount,1);
channel_type = cell(MetaData.ChannelCount,1);
channel_list = cell(MetaData.ChannelCount,1);
for i =1:length(channel_list)
    channel_id(i) = {sprintf('%03d',MetaData.ChannelID(i))};
    %channel_id(i) = {MetaData.ChannelID(i,:)};
    %channel_type(i) = {'LFP-raw'};
    channel_type(i) = {'LFP'};
    channel_list(i) = {sprintf('%s/%s',char(channel_type(i)),char(channel_id(i)))};
end

% Looking for NConfig file
if exist(fullfile(DIR_SAVE,F.nlab,'Nconfig.mat'),'file')
    % load from ncf file
    d_ncf = load(fullfile(DIR_SAVE,F.nlab,'Nconfig.mat'),...
        'ind_channel','channel_id','channel_list','channel_type');
    ind_channel = d_ncf.ind_channel;
    channel_id = d_ncf.channel_id;
    channel_type = d_ncf.channel_type;
    channel_list = d_ncf.channel_list;
else
    % Prompt user to select files
    [ind_channel,v] = listdlg('Name','LFP Channel Selection','PromptString','Select LFP channels',...
        'SelectionMode','multiple','ListString',channel_list,'InitialValue','','ListSize',[300 500]);
    if isempty(ind_channel)||v==0
        return
    end
    % Save ind_channel
    channel_id = channel_id(ind_channel);
    channel_list = channel_list(ind_channel);
    channel_type = channel_type(ind_channel);
    save(fullfile(DIR_SAVE,F.nlab,'Nconfig.mat'),...
        'ind_channel','channel_id','channel_list','channel_type','-v7.3');
    %F.ncf = strcat(F.recording,'.mat');
end
Data = data_ns.Data(ind_channel,:);

% Storing data in traces
parent = strcat(MetaData.Filename,MetaData.FileExt);
nb_samples = MetaData.DataPoints;
duration = MetaData.DataDurationSec;
f_samp = MetaData.SamplingFreq;
traces = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

for i=1:length(ind_channel)
    traces(i).ID = char(channel_id(i));
    traces(i).shortname = char(channel_type(i));
    traces(i).parent = parent;
    traces(i).fullname = char(channel_list(i));
    traces(i).X = (0: 1/f_samp : duration-(1/f_samp))';
    traces(i).Y = double(Data(i,:)');
    traces(i).X_ind = data_t.time_ref.X;
    traces(i).X_im = data_t.time_ref.Y;
    traces(i).nb_samples = nb_samples;
    
    % Filtering LFP
    str = lower(traces(i).fullname);
    if contains(str,'temp')
        f1 = GFilt.temp_inf;
        f2 = GFilt.temp_sup;
    elseif contains(str,{'acc';'gyr'})
        f1 = GFilt.acc_inf;
        f2 = GFilt.acc_sup;
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
    fprintf('Succesful Importation %s [Parent %s] [Bandpass: (%.2f Hz,%.2f Hz)].\n',traces(i).fullname,traces(i).parent,f1,f2);
end


% Building traces_diff_lfp
ind_lfp = strcmp(channel_type,'LFP');
traces_lfp = traces(ind_lfp==1);
traces_remainder = traces(ind_lfp==0);
traces_diff_lfp = struct('ID',{},'shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});
for i = 1:length(traces_lfp)-1
    % traces_diff_lfp(i).ID = strcat(char(channel_id(i)),'---',char(channel_id(i+1)));
    traces_diff_lfp(i).ID = strcat(char(channel_id(i)),'$',char(channel_id(i+1)));
    traces_diff_lfp(i).shortname = char(channel_type(i));
    traces_diff_lfp(i).parent = parent;
    traces_diff_lfp(i).fullname = sprintf('%s/%s',traces_diff_lfp(i).shortname,traces_diff_lfp(i).ID);
    traces_diff_lfp(i).X = traces_lfp(i).X;
    traces_diff_lfp(i).Y = traces_lfp(i).Y-traces_lfp(i+1).Y;
    traces_diff_lfp(i).X_ind = data_t.time_ref.X;
    traces_diff_lfp(i).X_im = data_t.time_ref.Y;
    traces_diff_lfp(i).Y_im = interp1(traces_diff_lfp(i).X,traces_diff_lfp(i).Y,traces_diff_lfp(i).X_im);
    traces_diff_lfp(i).nb_samples = traces_lfp(:).nb_samples;
    
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

for i=1:length(ind_traces)
     
    % finding trace name
    t = traces(ind_traces(i)).fullname;
    
    if sum(strcmp(t,lines_name))>0
        %line already exists overwrite
        ind_overwrite = find(strcmp(t,lines_name)==1);
        lines(ind_overwrite).UserData.Y = traces(ind_traces(i)).Y;
        lines(ind_overwrite).YData = traces(ind_traces(i)).Y_im;
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
        hl = line('XData',traces(ind_traces(i)).X_ind,...
            'YData',traces(ind_traces(i)).Y_im,...
            'Color',color,...
            'Tag','Trace_Cerep',...
            'Visible','off',...
            'HitTest','off',...
            'Parent', handles.RightAxes);
        if handles.RightPanelPopup.Value==4
            set(hl,'Visible','on');
        end
        % Updating UserData
        s.Name = regexprep(t,'_','-');
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
    save(fullfile(dir_source,strcat(save_name,'.mat')),'Y','f','x_start','x_end','-v7.3');
    fprintf('- Saved [%s]\n',fullfile(dir_source,strcat(save_name,'.mat')));
end

success = true;

end
