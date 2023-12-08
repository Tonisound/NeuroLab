function f1 = figure_PeriEventLFP(handles,val,str_traces)
% (Figure) Displays fUS imaging sequence associated with events

if nargin < 3
    str_traces = [];
end

global FILES CUR_FILE DIR_SAVE DIR_FIG DIR_STATS;
recording_name = FILES(CUR_FILE).nlab;

% Parameters
load('Preferences.mat','GTraces');
band_name = 'ripple';
pattern_evt = 'Peak(s)';
t_before = -1;          % time window before (seconds)
t_after = 5;            % time window after (seconds)
sampling_lfp = 1000;    % Hz
sampling_spectro = 100;    % Hz
flag_save_figure = 1;
    

% markersize = 3;
% face_color = [0.9300    0.6900    0.1900];
% face_alpha = .5 ;
% g_colors = get_colors(n_channels+1,'jet');


% Select event file
folder_events = fullfile(DIR_SAVE,recording_name,'Events');
d_events = dir(fullfile(folder_events,'*.csv'));
d_events = d_events(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_events));
d_sub_events = dir(fullfile(folder_events,'*','*.csv'));
d_sub_events = d_sub_events(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_sub_events));
d_events = [d_events;d_sub_events];
if isempty(d_events)
    errordlg('Absent or empty Event folder [%s].',folder_events);
    return;
elseif length(d_events)==1
    ind_selected_events = 1;
else
    if val == 1
        % user mode
        str_events=[];
        for i =1:length(d_events)
            str_events = [str_events;{strrep(fullfile(d_events(i).folder,d_events(i).name),strcat(folder_events,filesep),'')}];
        end
        [ind_selected_events,v] = listdlg('Name','Event Selection','PromptString','Select Events to display',...
            'SelectionMode','multiple','ListString',str_events,'InitialValue',1,'ListSize',[300 500]);
        if v==0 || isempty(ind_selected_events)
            return;
        end
        
    else
        % batch mode
%         ind_events = 1:length(d_events);
        batch_csv_events = {'Ripples-Abs-All.csv'};
        ind_selected_events = [];
        for i=1:length(batch_csv_events)
            ind_keep = find(contains({d_events(:).name}',char(batch_csv_events(i))));
            ind_selected_events = [ind_selected_events;ind_keep];
        end
    end
end
d_selected_events = d_events(ind_selected_events);

% Loading time reference
data_tr = load(fullfile(DIR_SAVE,recording_name,'Time_Reference.mat'));

% Loading nconfig
nc_channnels = [];
if exist(fullfile(DIR_SAVE,recording_name,'Nconfig.mat'),'file')
    data_nconfig = load(fullfile(DIR_SAVE,recording_name,'Nconfig.mat'));
    nc_channnels = data_nconfig.channel_id(strcmp(data_nconfig.channel_type,'LFP'));
end

% LFP Channel Selection
d_lfp = dir(fullfile(DIR_SAVE,recording_name,'Sources_LFP','LFP_*.mat'));
if isempty(nc_channnels)
    if val == 1 
        % user mode
        [ind_channels,v] = listdlg('Name','Channel Selection','PromptString','Select channels to display',...
            'SelectionMode','multiple','ListString',{d_lfp(:).name}','InitialValue',1,'ListSize',[300 500]);
        if v==0 || isempty(ind_channels)
            return;
        end
    else
        ind_channels = 1:length(d_lfp);
    end
else
    % all LFP channels in Nconfig
    ind_channels = [];
    for i=1:length(nc_channnels)
        cur_channel = sprintf('LFP_%s.mat',char(nc_channnels(i)));
        ind_keep = find(strcmp({d_lfp(:).name}',cur_channel));
        ind_channels = [ind_channels;ind_keep];
    end
end
d_lfp = d_lfp(ind_channels);
all_lfp_channels = {d_lfp(:).name}';
all_lfp_channels = strrep(all_lfp_channels,'LFP_','');
all_lfp_channels = strrep(all_lfp_channels,'.mat','');
n_channels = length(all_lfp_channels);


% Loading data
S = struct('Yraw',[],'Yfiltered',[],'Yspectro',[]);
S(n_channels).Yraw = [];
for jj=1:n_channels
    cur_channel = char(all_lfp_channels(jj));
    d_raw = dir(fullfile(DIR_SAVE,recording_name,'Sources_LFP',sprintf('LFP_%s.mat',cur_channel)));
    if isempty(d_raw)
        warning('No channel found [%s]',recording_name);
        continue
    else
        data_raw = load(fullfile(d_raw.folder,d_raw.name));
        Xraw = data_raw.x_start:data_raw.f:data_raw.x_end;
        S(jj).Yraw = data_raw.Y;
        
    end
    d_filtered = dir(fullfile(DIR_SAVE,recording_name,'Sources_LFP',sprintf('LFP-%s_%s.mat',band_name,cur_channel)));
    if isempty(d_filtered)
        warning('No filtered channel found [%s]',recording_name);
    else
        data_filtered = load(fullfile(d_filtered.folder,d_filtered.name));
        Xfiltered = data_filtered.x_start:data_filtered.f:data_filtered.x_end;
        S(jj).Yfiltered = data_filtered.Y;
    end
    d_spectro = dir(fullfile(DIR_STATS,'Wavelet_Analysis',recording_name,'*',strcat(recording_name,'*',cur_channel,'.mat')));
    if isempty(d_spectro)
        warning('No spectrogram found [%s]',recording_name);
    else
        data_spectro = load(fullfile(d_spectro.folder,d_spectro.name));
        Xspectro = data_spectro.Xdata_sub;
        freqdom = data_spectro.freqdom;
        S(jj).Yspectro = data_spectro.Cdata_sub;
    end
    fprintf('Data Loaded [%s][%s].\n',recording_name,cur_channel);
end

f1=figure;
f1.UserData.success = false;

for kk=1:length(d_selected_events)
    
    % Building Figure
    counter = 1;
    clf(f1);
    
    % Read csv event file
    event_file = fullfile(d_selected_events(kk).folder,d_selected_events(kk).name);
    event_name_csv = strrep(event_file,strcat(folder_events,filesep),'');
    event_name = strrep(event_name_csv,'.csv','');
    [events,EventHeader,MetaData] = read_csv_events(event_file);
    
    % Getting channel_id if MetaData contains channel_ripple
    mline = char(MetaData(contains(MetaData,'channel_ripple')));
    if ~isempty(mline)
        textsep = ',';
        temp = regexp(mline,textsep,'split');
        % Removing blanks
        while isempty(char(temp(end)))
            temp=temp(1:end-1);
        end
        channel_id = char(temp(end));
    end
    
    % Getting t_events
    ind_events = find(strcmp(EventHeader,pattern_evt)==1);
    if isempty(ind_events)
        % Taking first column as default
        t_events = events(:,1);
    else
       % Taking column containing pattern_evt
       t_events = events(:,ind_events);
    end
    n_events = size(events,1);
    
    % Sanity Check
    if isempty(t_events) || n_events == 0
        warning('Error loading Events [File: %s]',event_file);
        continue;
    end
    f1.Name = sprintf('[%s]Peri-Event-LFP[%s][N=%d]',recording_name,strrep(event_name,filesep,'|'),n_events);
    

    % Computing event averages and fUS averages
    t_bins_lfp  = (t_before:1/sampling_lfp:t_after)';
    t_bins_spectro  = (t_before:1/sampling_spectro:t_after)';

    % Interpolate LFP
    Xq_evt_lfp = [];
    for i =1:n_events
        Xq_evt_lfp = [Xq_evt_lfp;t_events(i)+t_bins_lfp];
    end
    % Interpolate spectro
    Xq_evt_spectro = [];
    for i =1:n_events
        Xq_evt_spectro = [Xq_evt_spectro;t_events(i)+t_bins_spectro];
    end

    for jj=1:n_channels

        cur_channel = char(all_lfp_channels(jj));
        ax1 = axes('Parent',f1,'Position',get_position(n_channels,3,counter));
        ax2 = axes('Parent',f1,'Position',get_position(n_channels,3,counter+1));
        ax3 = axes('Parent',f1,'Position',get_position(n_channels,3,counter+2));

        Yraw_evt = interp1(Xraw,S(jj).Yraw,Xq_evt_lfp);
        Yfiltered_evt = interp1(Xfiltered,S(jj).Yfiltered,Xq_evt_lfp);
        Cdata_evt = (interp1(Xspectro,S(jj).Yspectro',Xq_evt_spectro))';

        % Reshaping LFP
        % Xq_evt_lfp_ = reshape(Xq_evt_lfp,[length(t_bins_lfp) n_events]);
        Yraw_evt_ = reshape(Yraw_evt,[length(t_bins_lfp) n_events]);
        Yfiltered_evt_ = reshape(Yfiltered_evt,[length(t_bins_lfp) n_events]);
        Cdata_evt_ = reshape(Cdata_evt,[size(Cdata_evt,1) length(t_bins_spectro) n_events]);

        % Plotting
        hold(ax1,'on');
        for i=1:n_events
            l=line('XData',t_bins_lfp,'YData',Yraw_evt_(:,i),'Color','k','LineWidth',.1,'Parent',ax1);
            l.Color(4)=.5;
        end
        line('XData',t_bins_lfp,'YData',mean(Yraw_evt_,2,'omitnan'),'Color','r','LineWidth',2,'Parent',ax1);
        if jj==1
            ax1.Title.String = 'Raw';
        end
        ax1.YLabel.String = cur_channel;
        n_iqr = 4;
        data_iqr = Yraw_evt(~isnan(Yraw_evt));
        ax1.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
        ax1.XLim = [-.1 .1];
        if jj==n_channels
            set(ax1,'YTick',[],'YTickLabel',[]);
        else
            set(ax1,'XTick',[],'XtickLabel',[],'YTick',[],'YTickLabel',[]);
        end

        hold(ax2,'on');
        for i=1:n_events
            l=line('XData',t_bins_lfp,'YData',Yfiltered_evt_(:,i),'Color',[.5 .5 .5],'LineWidth',.1,'Parent',ax2);
            l.Color(4)=.5;
        end
        line('XData',t_bins_lfp,'YData',mean(Yfiltered_evt_,2,'omitnan'),'Color','r','Parent',ax2);
        if jj==1
            ax2.Title.String = strcat('Filtered-',band_name);
        end
        n_iqr= 10;
        data_iqr = Yfiltered_evt_(~isnan(Yfiltered_evt_));
        ax2.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
        ax2.XLim = ax1.XLim;
        if jj==n_channels
            set(ax2,'YTick',[],'YTickLabel',[]);
        else
            set(ax2,'XTick',[],'XtickLabel',[],'YTick',[],'YTickLabel',[]);
        end

        % Spectrogram
        hold(ax3,'on');
        Cdata_mean = mean(Cdata_evt_,3,'omitnan');
        imagesc('XData',t_bins_lfp,'YData',data_spectro.freqdom,'CData',Cdata_mean,'HitTest','off','Parent',ax3);

        n_iqr= 2;
        data_iqr = Cdata_mean(~isnan(Cdata_mean));
        ax3.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
        ax3.YLim = [data_spectro.freqdom(1),data_spectro.freqdom(end)];
        % ax3.XLim = [t_bins_lfp(1),t_bins_lfp(end)];
        ax3.XLim = ax1.XLim;
%         ax3.Title.String = 'Mean Spectrogram';
        if jj==1
            ax3.Title.String = 'Mean Spectrogram';
        end
        if jj~=n_channels
            set(ax3,'XTick',[],'XtickLabel',[],'YTick',[],'YTickLabel',[]);
        end
        counter = counter+3;
    end

    if flag_save_figure
        save_dir = fullfile(DIR_FIG,'Peri-Event-LFP',recording_name);
        if ~isfolder(save_dir)
            mkdir(save_dir);
        end
        pic_name = sprintf(f1.Name,GTraces.ImageSaveExtension);
        saveas(f1,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
    end
end

f1.UserData.success = true;

end