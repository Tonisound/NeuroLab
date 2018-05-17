function success = import_lfptraces(F,handles)

success = false;

global CUR_IM DIR_SAVE;
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
Metadada = data_ns.MetaTags;
channel_list = cell(Metadada.ChannelCount,1);
for i =1:length(channel_list)
    channel_list(i) = {sprintf('Channel %3d',Metadada.ChannelID(i))};
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
traces = struct('shortname',{},'fullname',{},'parent',{},...
    'X',{},'Y','X_ind',{},'X_im',{},'Y_im',{},'nb_samples',{});
for count=1:length(ind_channel)
    i = ind_channel(count);
    traces(count).shortname = char(channel_list(i));
    traces(count).parent = char(dir_traces(ind_traces(i)).name);
    traces(count).fullname = strcat(char(dir_traces(ind_traces(i)).name(1:30)),'/',char(hline_2(k)));
    traces(count).X = T(:,1);
    traces(count).Y = Data(count,:);
    traces(count).X_ind = T(:,1);
    traces(count).X_im = T(:,1);
    traces(count).Y_im = T(:,k);
    traces(count).nb_samples = length(T(:,k));
end
%fprintf('Succesful Importation (File %s /Folder %s).\n',data_ns);

% Save dans SpikoscopeTraces.mat
if ~isempty(traces)
    save(fullfile(dir_save,'LFP_Traces.mat'),'traces','-v7.3');
end
fprintf('===> Saved at %s.mat\n',fullfile(dir_save,'Spikoscope_Traces.mat'));

success = true;
end
