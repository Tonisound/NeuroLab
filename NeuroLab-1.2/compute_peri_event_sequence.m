function success = compute_peri_event_sequence(savedir,val,str_regions,str_traces)
% (Figure) Computes Peri-Event Traces

global DIR_STATS IM;

success = false;

% If nargin > 2 batch processing
% val indicates callback provenance (0 : batch mode - 1 : user mode)
if nargin<2
    val=1;
end
if nargin<3
    str_regions = [];
end
if nargin<4
    str_traces = [];
end
%     str_group = [];
%     str_tag = [];


% Parameters
flag_save_large = false;            % Saving all events
band_name = 'ripple';               % Filtered band for main channel
sampling_fus = 5;                   % fUS interpolation frequency (Hz)
sampling_lfp = 1000;                % LFP interpolation frequency (Hz)
sampling_spectro = 200;             % Spectrogram interpolation frequency (Hz)
t_before = -1;                      % time window start (seconds)
t_after = 5;                        % time window end (seconds) 
t_baseline_start = -1;              % time start baseline (seconds) 
t_baseline_end = 0;                 % time end baseline (seconds) 
save_ratio_spectro = 100;           % ratio for spectrogram compression
save_ratio_fus = 1000;               % ratio for fus compression 


% Getting recording name
temp = regexp(savedir,filesep,'split');
recording_name = char(temp(end));

% Loading time reference
data_tr = load(fullfile(savedir,'Time_Reference.mat'));

% Loading atlas
if exist(fullfile(savedir,'Atlas.mat'),'file')
    data_atlas = load(fullfile(savedir,'Atlas.mat'));
    atlas_name = data_atlas.AtlasName;
    switch atlas_name
        case 'Rat Coronal Paxinos'
            atlas_fullname = sprintf('AP=%.2fmm',data_atlas.AP_mm);
            atlas_coordinate = data_atlas.AP_mm;

        case 'Rat Sagittal Paxinos'
            atlas_fullname = sprintf('ML=%.2fmm',data_atlas.ML_mm);
            atlas_coordinate = data_atlas.ML_mm;

        case 'Mouse Coronal Paxinos'
            atlas_fullname = sprintf('AP=%.2fmm',data_atlas.AP_mm);
            atlas_coordinate = data_atlas.AP_mm;

        case 'Mouse Sagittal Paxinos'
            atlas_fullname = sprintf('ML=%.2fmm',data_atlas.ML_mm);
            atlas_coordinate = data_atlas.ML_mm;
    end
else
    data_atlas = [];
    atlas_name = [];
    atlas_fullname = 'Unregistered';
    atlas_coordinate = 0;
end


% Event File Selection
folder_events = fullfile(savedir,'Events');
d_events = dir(fullfile(folder_events,'*.csv'));
% Removing hidden files
d_events = d_events(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_events));
if isempty(d_events)
    errordlg('Absent or empty Event folder [%s].',folder_events);
    return;
% elseif length(d_events)==1
%     all_event_names = char(d_events.name);
else
    if val == 1
        % user mode
        [ind_events,v] = listdlg('Name','Event Selection','PromptString','Select Events to display',...
            'SelectionMode','multiple','ListString',{d_events(:).name}','InitialValue',1,'ListSize',[300 500]);
        if v==0 || isempty(ind_events)
            return;
        end
        
    else
        % batch mode
        % ind_events = 1:length(d_events);
%         batch_csv_events = {'Ripples-Merged-All.csv';'Ripples-Merged-Fast.csv';'Ripples-Merged-Long.csv';'Ripples-Merged-Strong.csv'};
        batch_csv_events = {'[AW]Ripples-Merged-All.csv';'[QW]Ripples-Merged-All.csv';'[NREM]Ripples-Merged-All.csv'};
        ind_events = [];
        for i=1:length(batch_csv_events)
            ind_keep = find(strcmp({d_events(:).name}',char(batch_csv_events(i))));
            ind_events = [ind_events;ind_keep];
        end
    end
    all_event_names = {d_events(ind_events).name}';
end


% Selecting and loading LFP channels
d_lfp = dir(fullfile(savedir,'Sources_LFP','LFP_*.mat'));
d_lfp = d_lfp(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_lfp));
% % Manual Selection
% [ind_lfp,v] = listdlg('Name','Channel Selection','PromptString','Select LFP channels to display',...
%     'SelectionMode','multiple','ListString',{d_lfp(:).name}','InitialValue',1,'ListSize',[300 500]);
% if v==0
%     return;
% end
ind_lfp = 1:length(d_lfp);
all_channels = strrep({d_lfp(ind_lfp).name}','.mat','');
n_channels = length(all_channels);
all_labels_channels = strrep(all_channels,'_','-');

fprintf('Loading %d LFP Channels [%s] ...',n_channels,recording_name);
d0 = [];
for i = 1:n_channels
    d0 = [d0;dir(fullfile(savedir,'*',strcat(char(all_channels(i,:)),'.mat')))];
end
if isempty(d0)
    warning('No LFP channels found [%s]',recording_name);
    return;
else
    Y0 = [];
    for i = 1:n_channels
        data_0 = load(fullfile(d0(i).folder,d0(i).name));
        X0 = (data_0.x_start:data_0.f:data_0.x_end)';
        Y0 = [Y0,data_0.Y];
    end
end
fprintf(' done.\n');


% Selecting and loading fUS regions
d_regions = dir(fullfile(savedir,'Sources_fUS','*.mat'));
d_regions = d_regions(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_regions));
% % Restricting to bilateral regions
% ind_leftright = contains({d_regions(:).name}','-L.mat')+contains({d_regions(:).name}','-R.mat');
% if ~isempty(d_regions(ind_leftright==0))
%     d_regions = d_regions(ind_leftright==0);
% end
% % Manual Selection
% [ind_regions,v] = listdlg('Name','Region Selection','PromptString','Select Regions to display',...
%     'SelectionMode','multiple','ListString',{d_regions(:).name}','InitialValue',1,'ListSize',[300 500]);
% if v==0
%     return;
% end
ind_regions = 1:length(d_regions);
all_regions = strrep({d_regions(ind_regions).name}','.mat','');
n_regions = length(all_regions);
all_labels_regions = strrep(all_regions,'_','-');
% all_labels_regions = strrep(all_labels_regions,'[SR]','');
% all_labels_regions = strcat('[fUS]',all_labels_regions);

fprintf('Loading %d fUS Regions [%s] ...',n_regions,recording_name);
d2 = [];
for i = 1:n_regions
    d2 = [d2;dir(fullfile(savedir,'*',strcat(char(all_regions(i,:)),'.mat')))];
end
if isempty(d2)
    warning('No fUS regions found [%s]',recording_name);
    return;
else
    Y2 = [];
    for i = 1:n_regions
        data_2 = load(fullfile(d2(i).folder,d2(i).name));
        X2 = data_tr.time_ref.Y;
        Y2 = [Y2,data_2.Y];
    end
end
fprintf(' done.\n');

% Getting all voxels activity
Y3 = reshape(IM,[size(IM,1)*size(IM,2) size(IM,3)])';


% Computing Peri-Event Traces
% Looping on all events
for kk=1:length(all_event_names)
    
    % Read csv event file
    event_name_csv = char(all_event_names(kk));
    event_name = strrep(event_name_csv,'.csv','');
    event_file = fullfile(savedir,'Events',event_name_csv);
    [events,EventHeader,MetaData] = read_csv_events(event_file);
    
    % Getting channel_ripple identifier
    mline = char(MetaData(contains(MetaData,'channel_ripple')));
    textsep = ',';
    temp = regexp(mline,textsep,'split');
    % Removing blanks
    while isempty(char(temp(end)))
        temp=temp(1:end-1);
    end
    channel_id = char(temp(end));
    ind_channel_id = find(strcmp(all_labels_channels,sprintf('LFP-%s',channel_id))==1);
    % channel_main_raw = strcat('LFP_',channel_id);
    channel_main_filt = sprintf('LFP-%s_%s',band_name,channel_id);
    
    % Getting timegroup_name
    mline = char(MetaData(contains(MetaData,'timegroup_name')));
    textsep = ',';
    temp = regexp(mline,textsep,'split');
    % Removing blanks
    while isempty(char(temp(end)))
        temp=temp(1:end-1);
    end
    timegroup_name = char(temp(end));
    
    % Getting timegroup_duration
    mline = char(MetaData(contains(MetaData,'timegroup_duration(s)')));
    textsep = ',';
    temp = regexp(mline,textsep,'split');
    % Removing blanks
    while isempty(char(temp(end)))
        temp=temp(1:end-1);
    end
    timegroup_duration = str2double(char(temp(end)));
    
    % Getting density_events
    mline = char(MetaData(contains(MetaData,'density_events(Hz)')));
    textsep = ',';
    temp = regexp(mline,textsep,'split');
    % Removing blanks
    while isempty(char(temp(end)))
        temp=temp(1:end-1);
    end
    density_events = str2double(char(temp(end)));
    
    % Getting t_events
    ref_event = 'Peak(s)';
    if sum(strcmp(EventHeader,ref_event))>0
        % Selecting reference event
        t_events = events(:,strcmp(EventHeader,ref_event)==1);
    else
        % Taking first column as default
        t_events = events(:,1);
    end

    % Sanity Check (if number of events is zero)
    if isempty(t_events)
        errordlg(sprintf('Unable to load events [File: %s]',event_file));
        continue;
    end

    % Keeping events restricted to time_group
    index_keep = zeros(length(t_events),1);
    for i=1:length(t_events)
        if t_events(i)>data_tr.time_ref.Y(1) && t_events(i)<data_tr.time_ref.Y(end)
            index_keep(i)=1;
        end
    end
    events = events(index_keep==1,:);
    t_events = t_events(index_keep==1);
    n_events = size(events,1);
    
    if n_events == 0
        warning('No events left within fUS bounds [%s]. Proceeding.',event_name);
        continue;
    else
        fprintf('Number of events within fUS bounds : %d/%d events [%s].\n',n_events,length(index_keep),event_name);
    end

    
    % Loading main channel filtered
    d1 = dir(fullfile(savedir,'*',strcat(channel_main_filt,'.mat')));
    if isempty(d1)
        warning('Channel not found [%s-%s]',recording_name,channel_main_filt);
        return;
    else
        data_1 = load(fullfile(d1.folder,d1.name));
        X1 = (data_1.x_start:data_1.f:data_1.x_end)';
        Y1 = data_1.Y;
    end

    % Loading main channel Wavelet
    [Cdata_sub,Xdata_sub,freqdom] = load_wavelet(recording_name,channel_id);
    % Load random spectrogram
    if isempty(Cdata_sub)
        Xdata_sub = X1;
        freqdom = 1:1:250;
        Cdata_sub = rand(length(freqdom),length(Xdata_sub));
        % return;
    end

    % Correction
    exp_cor = .25;
    correction = repmat((freqdom(:).^exp_cor),1,size(Cdata_sub,2));
    correction = correction/correction(end,1);
    Cdata_corr = Cdata_sub.*correction;
    % %Gaussian smoothing
    % t_gauss = .1;
    % step = t_gauss*round(1/median(diff(Xdata_sub)));
    % Cdata_smooth = imgaussfilt(Cdata_corr,[1 step]);
    % Cdata = Cdata_smooth;
    Cdata = Cdata_corr;
    

    % Computing event averages and fUS averages
    t_bins_fus  = (t_before:1/sampling_fus:t_after)';
    t_bins_lfp  = (t_before:1/sampling_lfp:t_after)';
    t_bins_spectro  = (t_before:1/sampling_spectro:t_after)';
    
    
    % Interpolate LFP
    fprintf('Interpolating %d LFP channels [%s] ...',n_channels,recording_name);
    Xq_evt_lfp = [];
    Xq_evt_spectro = [];
    for i =1:n_events
        Xq_evt_lfp = [Xq_evt_lfp;t_events(i)+t_bins_lfp];
        Xq_evt_spectro = [Xq_evt_spectro;t_events(i)+t_bins_spectro];
    end
    Y0q_evt = (interp1(X0,Y0,Xq_evt_lfp))';
    Y1q_evt = interp1(X1,Y1,Xq_evt_lfp);
    Cdata_evt = (interp1(Xdata_sub,Cdata',Xq_evt_spectro))';
    fprintf(' done.\n');

    % Interpolate fUS
    fprintf('Interpolating %d fUS regions [%s] ...',n_regions,recording_name);
    Xq_evt_fus = [];
    for i =1:n_events
        Xq_evt_fus = [Xq_evt_fus;t_events(i)+t_bins_fus];
    end
    Y2q_evt = (interp1(X2,Y2,Xq_evt_fus))';
    Y3q_evt = (interp1(X2,Y3,Xq_evt_fus))';
    fprintf(' done.\n');


    % Reshaping fUS
    % Xq_evt_fus_ = reshape(Xq_evt_fus,[length(t_bins_fus) n_events]);
    Y2q_evt_ = reshape(Y2q_evt,[size(Y2q_evt,1) length(t_bins_fus) n_events]);
    Y3q_evt_ = reshape(Y3q_evt,[size(Y3q_evt,1) length(t_bins_fus) n_events]);  
    
    % Reshaping LFP
    Xq_evt_lfp_ = reshape(Xq_evt_lfp,[length(t_bins_lfp) n_events]);
    Xq_evt_spectro_ = reshape(Xq_evt_spectro,[length(t_bins_spectro) n_events]);
    Y0q_evt_ = reshape(Y0q_evt,[size(Y0q_evt,1) length(t_bins_lfp) n_events]);
    Y0q_evt_mean = mean(Y0q_evt_,3,'omitnan');
    Y0q_evt_median = median(Y0q_evt_,3,'omitnan');
    Y0q_evt_std = std(Y0q_evt_,[],3,'omitnan');
    n_true_events = sum(~isnan(Y0q_evt_),3);
    Y0q_evt_sem = Y0q_evt_std./sqrt(n_true_events);

    % time-window based zscoring
    Z0q_evt_ = squeeze(Y0q_evt_(ind_channel_id,:,:));
    t1_zscore = -.1;
    t2_zscore = .1;
    [~,ind_z1] = min((t_bins_lfp-t1_zscore).^2);
    [~,ind_z2] = min((t_bins_lfp-t2_zscore).^2);
    m_z = mean(Z0q_evt_(ind_z1:ind_z2,:),1,'omitnan');
    m_z_mat = repmat(m_z,[length(t_bins_lfp) 1]);
    std_z = std(Z0q_evt_(ind_z1:ind_z2,:),[],1,'omitnan');
    std_z_mat = repmat(std_z,[length(t_bins_lfp) 1]);
    Z0q_evt_zscored = (Z0q_evt_- m_z_mat)./std_z_mat;
    Z0q_evt_mean = mean(Z0q_evt_zscored,2,'omitnan');
    Z0q_evt_median = median(Z0q_evt_zscored,2,'omitnan');
    Z0q_evt_std = std(Z0q_evt_zscored,[],2,'omitnan');
    n_true_events = sum(~isnan(Z0q_evt_),2);
    Z0q_evt_sem = Z0q_evt_std./sqrt(n_true_events);    
    
    Y1q_evt_ = reshape(Y1q_evt,[length(t_bins_lfp) n_events]);
    Y1q_evt_mean = mean(Y1q_evt_,2,'omitnan');
    Y1q_evt_median = median(Y1q_evt_,2,'omitnan');
    Y1q_evt_std = std(Y1q_evt_,[],2,'omitnan');
    n_true_events = sum(~isnan(Y1q_evt_),2);
    Y1q_evt_sem = Y1q_evt_std./sqrt(n_true_events);
    
    Cdata_evt_ = reshape(Cdata_evt,[size(Cdata_evt,1) length(t_bins_spectro) n_events]);
    Cdata_mean = mean(Cdata_evt_,3,'omitnan');
    % Saving in int format
    Cdata_evt_int = int16(save_ratio_spectro*Cdata_evt_);     
    
    % Baseline extraction and normalization
    Xq_evt_fus_ = reshape(Xq_evt_fus,[length(t_bins_fus) n_events]);
    ind_baseline  = find((t_bins_fus-t_baseline_start).*(t_bins_fus-t_baseline_end)<=0);
    Y2q_evt_baseline = mean(Y2q_evt_(:,ind_baseline,:),2,'omitnan');
    Y2q_evt_normalized = Y2q_evt_-repmat(Y2q_evt_baseline,[1 size(Y2q_evt_,2) 1]);
    Y2q_evt_mean = mean(Y2q_evt_normalized,3,'omitnan');
    Y2q_evt_median = median(Y2q_evt_normalized,3,'omitnan');
    Y2q_evt_std = std(Y2q_evt_,[],3,'omitnan');
    n_true_events = sum(~isnan(Y2q_evt_),3);
    Y2q_evt_sem = Y2q_evt_std./sqrt(n_true_events);

    Y3q_evt_baseline = mean(Y3q_evt_(:,ind_baseline,:),2,'omitnan');
    Y3q_evt_normalized = Y3q_evt_ - repmat(Y3q_evt_baseline,[1 size(Y3q_evt_,2) 1]);
%     % Saving in int format
%     Y3q_evt_normalized_int = int16(save_ratio_fus*Y3q_evt_normalized); 
    
    % Computing mean-median sequences
    Y3q_evt_mean = mean(Y3q_evt_normalized,3,'omitnan');
    Y3q_evt_mean_reshaped = reshape(Y3q_evt_mean,[size(IM,1) size(IM,2) length(t_bins_fus)]);
    Y3q_evt_median = median(Y3q_evt_normalized,3,'omitnan');
    Y3q_evt_median_reshaped = reshape(Y3q_evt_median,[size(IM,1) size(IM,2) length(t_bins_fus)]);
    
    
    % Saving Data
    save_dir = fullfile(DIR_STATS,'PeriEvent_Sequence',recording_name);
    if ~isfolder(save_dir)
        mkdir(save_dir);
    end
    
    Params.recording_name = recording_name;
    Params.timegroup = timegroup_name;
    Params.timegroup_duration = timegroup_duration;
    Params.event_name = event_name;
    Params.band_name = band_name;
    Params.EventHeader = EventHeader;
    Params.MetaData = MetaData;
    Params.events = events;
    Params.t_events = t_events;
    Params.n_events = n_events;
    Params.density_events = density_events;
    Params.channel_id = channel_id;
    Params.ind_channel_id = ind_channel_id;
    Params.t_baseline_start = t_baseline_start;
    Params.t_baseline_end = t_baseline_end;
    Params.t_before = t_before;
    Params.t_after = t_after;
    Params.sampling_fus = sampling_fus;
    Params.sampling_lfp = sampling_lfp;
    Params.sampling_spectro = sampling_spectro;
    Params.size_im = [size(IM,1),size(IM,2),size(IM,3)];
    Params.save_ratio_spectro = save_ratio_spectro;
    Params.save_ratio_fus = save_ratio_fus;
%     Params.t_bins_fus = t_bins_fus;
%     Params.t_bins_lfp = t_bins_lfp;
%     Params.all_labels_regions = all_labels_regions;
%     Params.all_labels_channels = all_labels_channels;

    filename_save_1 = sprintf(strcat('%s_PeriEventSequence.mat'),event_name);
    save(fullfile(save_dir,filename_save_1),'Params',...
        'data_atlas','atlas_name','atlas_fullname','atlas_coordinate',...
        'all_labels_channels','t_bins_lfp',...
        'Y0q_evt_mean','Y0q_evt_median','Y0q_evt_std','Y0q_evt_sem',...
        'Z0q_evt_mean','Z0q_evt_median','Z0q_evt_std','Z0q_evt_sem',...
        'Y1q_evt_mean','Y1q_evt_median','Y1q_evt_std','Y1q_evt_sem',...
        'freqdom','Cdata_mean',...
        'all_labels_regions','t_bins_fus',...
        'Y2q_evt_mean','Y2q_evt_median','Y2q_evt_std','Y2q_evt_sem',...
        'Y3q_evt_mean_reshaped','Y3q_evt_median_reshaped','-v7.3');
    fprintf('Data saved [%s].\n',fullfile(save_dir,filename_save_1));

    if flag_save_large
        filename_save_2 = sprintf(strcat('%s_PeriEvent_AllEvents.mat'),event_name);
        save(fullfile(save_dir,filename_save_2),'Params',...
            'all_labels_channels','t_bins_lfp',...
            'Xq_evt_lfp_','Y0q_evt_','Y1q_evt_',...
            'freqdom','Xq_evt_spectro_','Cdata_evt_int',...
            'all_labels_regions','t_bins_fus',...
            'Xq_evt_fus_','Y2q_evt_normalized',...
            'Y3q_evt_normalized','-v7.3'); % ,'Y3q_evt_normalized_int'
        fprintf('Data saved [%s].\n',fullfile(save_dir,filename_save_2));
    end
    
end

success = true;

end
