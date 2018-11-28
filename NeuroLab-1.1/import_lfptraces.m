function success = import_lfptraces(F,handles)

success = false;

global DIR_SAVE DIR_CONFIG;
load('Preferences.mat','GImport');
dir_save = fullfile(DIR_SAVE,F.nlab);

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
    traces(i).Y_im = interp1(traces(i).X,traces(i).Y,traces(i).X_im);
    traces(i).nb_samples = nb_samples;
    fprintf('Succesful Importation %s [Parent %s].\n',traces(i).fullname,traces(i).parent);
end


% Save dans SpikoscopeTraces.mat
if ~isempty(traces)
    save(fullfile(dir_save,'Cereplex_Traces.mat'),'traces','MetaData','-v7.3');
end
fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Cereplex_Traces.mat'));

success = true;

end
