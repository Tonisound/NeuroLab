% Script - Dec 23
% Displays LFP Peri Event associated with ripple events

global FILES CUR_FILE DIR_SAVE DIR_SYNT;

% Parameters
load('Preferences.mat','GTraces');

pattern_csv = {'Ripples-Abs-All.csv'};
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


for i =1:length(FILES)
    
    cur_recording = FILES(i).nlab;
    
    % Select event file
    folder_events = fullfile(DIR_SAVE,cur_recording,'Events');
    d_events = dir(fullfile(folder_events,'*','*.csv'));
    d_events = d_events(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_events));

    % Selecting event files
    if ~isempty(d_events)
        ind_selected_events = [];
        for ii=1:length(pattern_csv)
            ind_keep = find(contains({d_events(:).name}',char(pattern_csv(ii))));
            ind_selected_events = [ind_selected_events;ind_keep];
        end
        d_selected_events = d_events(ind_selected_events);
    else
        d_selected_events = [];
    end
    % Sanity check
    if isempty(d_selected_events)
        warning('Missing Event files [%s][%s].',pattern_csv,folder_events);
        continue;
    end
    all_selected_events = {d_selected_events(:).name}';
    
    % Loading nconfig
    nc_channnels = [];
    if exist(fullfile(DIR_SAVE,cur_recording,'Nconfig.mat'),'file')
        data_nconfig = load(fullfile(DIR_SAVE,cur_recording,'Nconfig.mat'));
        nc_channnels = data_nconfig.channel_id(strcmp(data_nconfig.channel_type,'LFP'));
    else
        warning('Missing Nconfig file [%s].',cur_recording);
        continue;
    end
    
    % LFP Channel Loading
    d_lfp = dir(fullfile(DIR_SAVE,cur_recording,'Sources_LFP','LFP_*.mat'));
    % restricting to LFP channels in Nconfig
    ind_channels = [];
    for ii=1:length(nc_channnels)
        cur_channel = sprintf('LFP_%s.mat',char(nc_channnels(ii)));
        ind_keep = find(strcmp({d_lfp(:).name}',cur_channel));
        ind_channels = [ind_channels;ind_keep];
    end 
    d_lfp = d_lfp(ind_channels);
    % renaming LFP channels
    all_lfp_channels = {d_lfp(:).name}';
    all_lfp_channels = strrep(all_lfp_channels,'LFP_','');
    all_lfp_channels = strrep(all_lfp_channels,'.mat','');
    n_channels = length(all_lfp_channels);    
    
    % Loading data
    S = struct('channel',[],'Yraw',[],'Yfiltered',[],'Yspectro',[]);
    S(n_channels).Yraw = [];
    for j=1:n_channels
        cur_channel = char(all_lfp_channels(j));
        S(j).channel = cur_channel;
        d_raw = dir(fullfile(DIR_SAVE,cur_recording,'Sources_LFP',sprintf('LFP_%s.mat',cur_channel)));
        if isempty(d_raw)
            warning('No channel found [%s]',cur_recording);
            continue
        else
            data_raw = load(fullfile(d_raw.folder,d_raw.name));
            Xraw = data_raw.x_start:data_raw.f:data_raw.x_end;
            S(j).Yraw = data_raw.Y;
            
        end
        d_filtered = dir(fullfile(DIR_SAVE,cur_recording,'Sources_LFP',sprintf('LFP-%s_%s.mat',band_name,cur_channel)));
        if isempty(d_filtered)
            warning('No filtered channel found [%s]',cur_recording);
        else
            data_filtered = load(fullfile(d_filtered.folder,d_filtered.name));
            Xfiltered = data_filtered.x_start:data_filtered.f:data_filtered.x_end;
            S(j).Yfiltered = data_filtered.Y;
        end
        d_spectro = dir(fullfile(DIR_STATS,'Wavelet_Analysis',cur_recording,'*',strcat(cur_recording,'*',cur_channel,'.mat')));
        if isempty(d_spectro)
            warning('No spectrogram found [%s]',cur_recording);
        else
            data_spectro = load(fullfile(d_spectro.folder,d_spectro.name));
            Xspectro = data_spectro.Xdata_sub;
            freqdom = data_spectro.freqdom;
            S(j).Yspectro = data_spectro.Cdata_sub;
        end
        fprintf('Data Loaded [%s][%s].\n',cur_recording,cur_channel);
    end
    
    f1=figure;
    f1.Units='normalized';
    f1.OuterPosition=[0 0 1 1];
    f1.Name = sprintf('[%s]Peri-Event-LFP-raw',cur_recording);
    
    f2=figure;
    f2.Units='normalized';
    f2.OuterPosition=[0 0 1 1];
    f2.Name = sprintf('[%s]Peri-Event-LFP-filtered',cur_recording);
    
    for j=1:n_channels
        cur_channel = char(all_lfp_channels(j));
        
        % Read csv event file
        ind_event = find(contains({d_selected_events(:).name}',sprintf('[%s]',cur_channel))==1);
        if isempty(ind_event)
            warning('No Event file for channel [%s][%s]',cur_channel,cur_recording);
            continue;
        elseif length(ind_event)>1
            warning('Multiple Event file for channel [%s][%s]',cur_channel,cur_recording);
            continue;
        end
        event_file = fullfile(d_selected_events(ind_event).folder,d_selected_events(ind_event).name);
        event_name = strrep(d_selected_events(ind_event).name,'.csv','');
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
        
        counter=j;
        for jj = 1:n_channels
            ax1 = axes('Parent',f1,'Position',get_position(n_channels,n_channels,counter));
            ax2 = axes('Parent',f2,'Position',get_position(n_channels,n_channels,counter));
            counter=counter+n_channels;
            
            Yraw_evt = interp1(Xraw,S(jj).Yraw,Xq_evt_lfp);
            Yfiltered_evt = interp1(Xfiltered,S(jj).Yfiltered,Xq_evt_lfp);
%             Cdata_evt = (interp1(Xspectro,S(jj).Yspectro',Xq_evt_spectro))';
            
%             % Sanity check
%             if isempty(Yraw_evt(~isnan(Yraw_evt)))
%                 warning('No Events to display [%s][%s]',channel_id,cur_channel);
%                 continue;
%             end
            
            % Reshaping LFP
            Yraw_evt_ = reshape(Yraw_evt,[length(t_bins_lfp) n_events]);
            Yfiltered_evt_ = reshape(Yfiltered_evt,[length(t_bins_lfp) n_events]);
%             Cdata_evt_ = reshape(Cdata_evt,[size(Cdata_evt,1) length(t_bins_spectro) n_events]);
            
            % Plotting
            hold(ax1,'on');
            for k=1:n_events
                l=line('XData',t_bins_lfp,'YData',Yraw_evt_(:,k),'Color','k','LineWidth',.1,'Parent',ax1);
                l.Color(4)=.5;
            end
            l = line('XData',t_bins_lfp,'YData',mean(Yraw_evt_,2,'omitnan'),'Color','r','LineWidth',2,'Parent',ax1);

            % Layout
            n_iqr = 3;
            data_iqr = Yraw_evt(~isnan(Yraw_evt));
            if ~isempty(data_iqr)
                ax1.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
            end
            ax1.XLim = [-.1 .1];
            if jj==1
                ax1.Title.String = sprintf('[Rip:%s][N=%d]',channel_id,n_events);
            end
            if j==1
                ax1.YLabel.String = S(jj).channel;
            end
            if strcmp(S(jj).channel,channel_id)
                l.Color = 'b';
            end
            if jj==n_channels
                set(ax1,'YTick',[],'YTickLabel',[]);
            else
                set(ax1,'XTick',[],'XtickLabel',[],'YTick',[],'YTickLabel',[]);
            end
            
            % Filtered
            hold(ax2,'on');
            for k=1:n_events
                l=line('XData',t_bins_lfp,'YData',Yfiltered_evt_(:,k),'Color',[.5 .5 .5],'LineWidth',.1,'Parent',ax2);
                l.Color(4)=.5;
            end
            l=line('XData',t_bins_lfp,'YData',mean(Yfiltered_evt_,2,'omitnan'),'Color','r','Parent',ax2);
            
            % Layout
            n_iqr = 6;
            data_iqr = Yfiltered_evt_(~isnan(Yfiltered_evt_));
            if ~isempty(data_iqr)
                ax2.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
            end
            ax2.XLim = [-.1 .1];
            if jj==1
                ax2.Title.String = sprintf('[Rip:%s][N=%d]',channel_id,n_events);
            end
            if j==1
                ax2.YLabel.String = S(jj).channel;
            end
            if strcmp(S(jj).channel,channel_id)
                l.Color = 'b';
            end
            if jj==n_channels
                set(ax2,'YTick',[],'YTickLabel',[]);
            else
                set(ax2,'XTick',[],'XtickLabel',[],'YTick',[],'YTickLabel',[]);
            end
            
%             % Spectrogram
%             hold(ax3,'on');
%             Cdata_mean = mean(Cdata_evt_,3,'omitnan');
%             imagesc('XData',t_bins_lfp,'YData',data_spectro.freqdom,'CData',Cdata_mean,'HitTest','off','Parent',ax3);
%             
%             n_iqr= 2;
%             data_iqr = Cdata_mean(~isnan(Cdata_mean));
%             ax3.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
%             ax3.YLim = [data_spectro.freqdom(1),data_spectro.freqdom(end)];
%             % ax3.XLim = [t_bins_lfp(1),t_bins_lfp(end)];
%             ax3.XLim = ax1.XLim;
%             %         ax3.Title.String = 'Mean Spectrogram';
%             if j==1
%                 ax3.Title.String = 'Mean Spectrogram';
%             end
%             if j~=n_channels
%                 set(ax3,'XTick',[],'XtickLabel',[],'YTick',[],'YTickLabel',[]);
%             end
        end
    end
    
    % Saving figure
    if flag_save_figure
        save_dir = fullfile(DIR_SYNT,'Peri-Event-LFP-raw');
        if ~isfolder(save_dir)
            mkdir(save_dir);
        end
        pic_name = sprintf(f1.Name,GTraces.ImageSaveExtension);
        saveas(f1,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
        
        save_dir = fullfile(DIR_SYNT,'Peri-Event-LFP-filtered');
        if ~isfolder(save_dir)
            mkdir(save_dir);
        end
        pic_name = sprintf(f1.Name,GTraces.ImageSaveExtension);
        saveas(f2,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
    end
    close(f1);
    close(f2);
end