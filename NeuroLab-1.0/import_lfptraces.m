function success = import_lfptraces(F,handles)

success = false;

global DIR_SAVE;
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
        data_ns = openNSx('read',fullfile(F.fullpath,F.ns1));
        %parent = F.ns1;
    case 'ns2'
        data_ns = openNSx('read',fullfile(F.fullpath,F.ns2));
    case 'ns3'
        data_ns = openNSx('read',fullfile(F.fullpath,F.ns3));
    case 'ns4'
        data_ns = openNSx('read',fullfile(F.fullpath,F.ns4));
    case 'ns5'
        data_ns = openNSx('read',fullfile(F.fullpath,F.ns5));
    case 'ns6'
        data_ns = openNSx('read',fullfile(F.fullpath,F.ns6));
    otherwise
        data_ns = openNSx('read');
end
fprintf(' done.\n');

%Storing MetaData
MetaData = data_ns.MetaTags;
channel_list = cell(MetaData.ChannelCount,1);
for i =1:length(channel_list)
    channel_list(i) = {sprintf('LFP/%03d',MetaData.ChannelID(i))};
end

% Prompt user to select files 
[ind_channel,v] = listdlg('Name','LFP Channel Selection','PromptString','Select LFP channels',...
    'SelectionMode','multiple','ListString',channel_list,'InitialValue','','ListSize',[300 500]);
if isempty(ind_channel)||v==0
    return
% else
%     Data = data_ns.Data(ind_channels,:);
%     channel_list = channel_list(ind_channel);
end


% Storing data in traces
parent = strcat(MetaData.Filename,MetaData.FileExt);
nb_samples = MetaData.DataPoints;
duration = MetaData.DataDurationSec;
f_samp = MetaData.SamplingFreq;
traces = struct('shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y',{},'X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});

for count=1:length(ind_channel)
    i = ind_channel(count);
    traces(count).shortname = char(channel_list(i));
    traces(count).parent = parent;
    traces(count).fullname = fullfile(parent,char(channel_list(i)));
    traces(count).X = (0: 1/f_samp : duration-(1/f_samp))';
    traces(count).Y = double(data_ns.Data(count,:)');
    traces(count).X_ind = data_t.time_ref.X;
    traces(count).X_im = data_t.time_ref.Y;
    traces(count).Y_im = interp1(traces(count).X,traces(count).Y,traces(count).X_im);
    traces(count).nb_samples = nb_samples;
    fprintf('Succesful Importation %s [Parent %s].\n',traces(count).shortname,traces(count).parent);
end


% Save dans SpikoscopeTraces.mat
if ~isempty(traces)
    save(fullfile(dir_save,'Cereplex_Traces.mat'),'traces','MetaData','-v7.3');
end
fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Cereplex_Traces.mat'));

success = true;
end
