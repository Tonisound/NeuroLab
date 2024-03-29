% Script - Dec 23
% Displays LFP Peri Event associated with ripple events

close all;
global FILES DIR_SAVE DIR_SYNT;

% Parameters
load('Preferences.mat','GTraces');

all_csv_patterns = {'-000]Ripples-Abs-All';'-999]Ripples-Abs-All'};
% all_csv_patterns = {'Ripples-Sqrt-All'};

timegroup = 'NREM';
band_name = 'ripple';
pattern_evt = 'Peak(s)';

t_before = -1;          % time window before (seconds)
t_after = 5;            % time window after (seconds)
sampling_lfp = 500;    % Hz
sampling_spectro = 500;    % Hz
flag_save_figure = 1;

% markersize = 3;
% face_color = [0.9300    0.6900    0.1900];
% face_alpha = .5 ;
% g_colors = get_colors(n_channels+1,'jet');

for h = 1:length(all_csv_patterns)
    
    cur_csv_pattern = all_csv_patterns{h};
    
    for i = 1:length(FILES)
        
        cur_recording = FILES(i).nlab;
        % Listing all event files
        folder_events = fullfile(DIR_SAVE,cur_recording,'Events');
        d_events = dir(fullfile(folder_events,'*','*.csv'));
        d_events = d_events(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_events));
        % Selecting event files
        if ~isempty(d_events)
            ind_selected_events = contains({d_events(:).name}',strcat(cur_csv_pattern,'.csv'));
            d_selected_events = d_events(ind_selected_events);
        else
            d_selected_events = [];
        end
        % Sanity check
        if isempty(d_selected_events)
            warning('Missing Event files [%s][%s].',cur_csv_pattern,folder_events);
            continue;
        end
        all_selected_events = {d_selected_events(:).name}';
        
        % Loading Nconfig
        nc_channnels = [];
        if exist(fullfile(DIR_SAVE,cur_recording,'Nconfig.mat'),'file')
            data_nconfig = load(fullfile(DIR_SAVE,cur_recording,'Nconfig.mat'));
            nc_channnels = data_nconfig.channel_id(strcmp(data_nconfig.channel_type,'LFP'));
        else
            warning('Missing Nconfig file [%s].',cur_recording);
            continue;
        end
        
        % Loading time groups
        if exist(fullfile(DIR_SAVE,cur_recording,'Time_Groups.mat'),'file')
            data_tg = load(fullfile(DIR_SAVE,cur_recording,'Time_Groups.mat'));
            fprintf('Time Groups loaded [%s].\n',fullfile(DIR_SAVE,cur_recording,'Time_Groups.mat'));
        else
            warning('Time Groups not found [%s]',cur_recording);
        end
        % Finding timegroup
        ind_tg = find(strcmp(data_tg.TimeGroups_name,timegroup)==1);
        % Computing timegroup duration
        if isempty(ind_tg)
            warning('Time Group not found [%s-%s]',timegroup,cur_recording);
            timegroup_duration = NaN;
        else
            temp = datenum(data_tg.TimeGroups_duration);
            all_tg_dur = 24*3600*(temp-floor(temp));
            timegroup_duration = all_tg_dur(ind_tg);
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
            [Cdata_sub,Xspectro,freqdom] = load_wavelet(cur_recording,cur_channel);
            if isempty(Cdata_sub)
                warning('No spectrogram found [%s]',cur_recording);
            else
                S(j).Yspectro = Cdata_sub;
            end
            fprintf('Data Loaded [%s][%s].\n',cur_recording,cur_channel);
        end
        
        % Building timegroup index
        if isempty(ind_tg)
            y_tg = [];
        else
            tts1 = data_tg.TimeGroups_S(ind_tg).TimeTags_strings(:,1);
            temp1 = datenum(tts1);
            t1 = 24*3600*(temp1-floor(temp1));
            tts2 = data_tg.TimeGroups_S(ind_tg).TimeTags_strings(:,2);
            temp2 = datenum(tts2);
            t2 = 24*3600*(temp2-floor(temp2));
            y_tg = NaN(size(Xraw));
            for k=1:length(t1)
                [~,ind_1] = min(abs(Xraw-t1(k)));
                [~,ind_2] = min(abs(Xraw-t2(k)));
                y_tg(ind_1:ind_2)=0;
            end
        end
        
        f1=figure;
        f1.Units='normalized';
        f1.OuterPosition=[0 0 1 1];
        f1.Name = sprintf('[%s][%s]Peri-Event-LFP-raw',cur_recording,cur_csv_pattern);
        
        f2=figure;
        f2.Units='normalized';
        f2.OuterPosition=[0 0 1 1];
        f2.Name = sprintf('[%s][%s]Peri-Event-LFP-zscored',cur_recording,cur_csv_pattern);
        
        f3=figure;
        f3.Units='normalized';
        f3.OuterPosition=[0 0 1 1];
        f3.Name = sprintf('[%s][%s]Peri-Event-LFP-filtered',cur_recording,cur_csv_pattern);
        
        f4=figure;
        f4.Units='normalized';
        f4.OuterPosition=[0 0 1 1];
        f4.Name = sprintf('[%s][%s]Peri-Event-LFP-spectro',cur_recording,cur_csv_pattern);
        colormap(f4,'jet');
        
        f5=figure;
        f5.Units='normalized';
        f5.OuterPosition=[0 0 1 1];
        f5.Name = sprintf('[%s][%s]Peri-Event-LFP-crosscorr',cur_recording,cur_csv_pattern);
        colormap(f5,'jet');
        
        all_y_tg = [];
        all_ax1 = gobjects(n_channels,n_channels);
        all_ax2 = gobjects(n_channels,n_channels);
        all_ax3 = gobjects(n_channels,n_channels);
        all_ax4 = gobjects(n_channels,n_channels);
        all_ax5 = gobjects(n_channels,n_channels);
        
        for j=1:n_channels
            cur_channel = char(all_lfp_channels(j));
            
            % Read csv event file
            ind_event = find(contains({d_selected_events(:).name}',sprintf('[%s',cur_channel))==1);
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
            %         % Getting channel_id if MetaData contains timegroup
            %         mline = char(MetaData(contains(MetaData,'timegroup')));
            %         if ~isempty(mline)
            %             textsep = ',';
            %             temp = regexp(mline,textsep,'split');
            %             % Removing blanks
            %             while isempty(char(temp(end)))
            %                 temp=temp(1:end-1);
            %             end
            %             timegroup = char(temp(end));
            %         end
            
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
            density_events = n_events/timegroup_duration;
            % Sanity Check
            if isempty(t_events) || n_events == 0
                warning('Error loading Events [File: %s]',event_file);
                continue;
            end
            
            % Building timegroup index
            cur_y_tg = y_tg;
            for k=1:n_events
                [~,ind_1] = min(abs(Xraw-(t_events(k)-.05)));
                [~,ind_2] = min(abs(Xraw-(t_events(k)+.05)));
                cur_y_tg(ind_1:ind_2)=1;
            end
            all_y_tg = [all_y_tg;cur_y_tg];
            
            % Computing event averages and fUS averages
            t_bins_lfp  = (t_before:1/sampling_lfp:t_after)';
            t_bins_spectro  = (t_before:1/sampling_spectro:t_after)';
            % Interpolate LFP
            Xq_evt_lfp = [];
            for k =1:n_events
                Xq_evt_lfp = [Xq_evt_lfp;t_events(k)+t_bins_lfp];
            end
            % Interpolate spectro
            Xq_evt_spectro = [];
            for k =1:n_events
                Xq_evt_spectro = [Xq_evt_spectro;t_events(k)+t_bins_spectro];
            end
            
            counter=j;
            for jj = 1:n_channels
                ax1 = axes('Parent',f1,'Position',get_position(n_channels,n_channels,counter));
                ax2 = axes('Parent',f2,'Position',get_position(n_channels,n_channels,counter));
                ax3 = axes('Parent',f3,'Position',get_position(n_channels,n_channels,counter));
                ax4 = axes('Parent',f4,'Position',get_position(n_channels,n_channels,counter));
                ax5 = axes('Parent',f5,'Position',get_position(n_channels,n_channels,counter));
                counter=counter+n_channels;
                
                Yraw_evt = interp1(Xraw,S(jj).Yraw,Xq_evt_lfp);
                Yfiltered_evt = interp1(Xfiltered,S(jj).Yfiltered,Xq_evt_lfp);
                Cdata_evt = (interp1(Xspectro,S(jj).Yspectro',Xq_evt_spectro))';
                
                % Reshaping LFP
                Yraw_evt_ = reshape(Yraw_evt,[length(t_bins_lfp) n_events]);
                Yfiltered_evt_ = reshape(Yfiltered_evt,[length(t_bins_lfp) n_events]);
                Cdata_evt_ = reshape(Cdata_evt,[size(Cdata_evt,1) length(t_bins_spectro) n_events]);
                
                % time-window based zscoring
                t1 = -.1;
                t2 = .1;
                [~,ind_z1] = min((t_bins_lfp-t1).^2);
                [~,ind_z2] = min((t_bins_lfp-t2).^2);
                m_z=mean(Yraw_evt_(ind_z1:ind_z2,:));
                m_z_mat = repmat(m_z,[length(t_bins_lfp) 1]);
                std_z=std(Yraw_evt_(ind_z1:ind_z2,:));
                std_z_mat = repmat(std_z,[length(t_bins_lfp) 1]);
                Yraw_evt_zscored = (Yraw_evt_-m_z_mat)./std_z_mat;
                
                % Plotting Raw
                hold(ax1,'on');
                % for k=1:n_events
                %     l=line('XData',t_bins_lfp,'YData',Yraw_evt_(:,k),'Color','k','LineWidth',.1,'Parent',ax1);
                %     l.Color(4)=.5;
                % end
                y_mean = mean(Yraw_evt_,2,'omitnan');
                y_std = std(Yraw_evt_,[],2,'omitnan');
                l = line('XData',t_bins_lfp,'YData',y_mean,'Color','k','LineWidth',2,'Parent',ax1);
                % line('XData',t_bins_lfp,'YData',y_mean+y_std,'Color',[.5 .5 .5],'LineWidth',1,'Parent',ax1);
                % line('XData',t_bins_lfp,'YData',y_mean-y_std,'Color',[.5 .5 .5],'LineWidth',1,'Parent',ax1);
                xdata = [t_bins_lfp(:);flip(t_bins_lfp(:))];
                ydata = [y_mean(:)-y_std(:);flip(y_mean(:)+y_std(:))];
                patch('XData',xdata,'YData',ydata,'Parent',ax1,...
                    'Tag','PatchEpisode','FaceColor',[.5 .5 .5],'FaceAlpha',.5,'EdgeColor','none');                
                % Layout
                n_iqr = 1.5;
                data_iqr = Yraw_evt(~isnan(Yraw_evt));
                if ~isempty(data_iqr)
                    ax1.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                end
                ax1.XLim = [-.1 .1];
                if jj==1
                    ax1.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',channel_id,n_events,density_events);
                end
                if j==1
                    ax1.YLabel.String = S(jj).channel;
                end
                if strcmp(S(jj).channel,channel_id)
                    l.Color = 'r';
                end
                if jj==n_channels
                    set(ax1,'YTick',[],'YTickLabel',[]);
                else
                    set(ax1,'XTick',[],'XtickLabel',[]);
                    set(ax1,'YTick',[],'YTickLabel',[]);
                end
                
                % Plotting Zscored
                hold(ax2,'on');
                % for k=1:n_events
                %     l=line('XData',t_bins_lfp,'YData',Yraw_evt_zscored(:,k),'Color','k','LineWidth',.1,'Parent',ax2);
                %     l.Color(4)=.5;
                % end
                y_mean = mean(Yraw_evt_zscored,2,'omitnan');
                y_std = std(Yraw_evt_zscored,[],2,'omitnan');
                l = line('XData',t_bins_lfp,'YData',y_mean,'Color','k','LineWidth',2,'Parent',ax2);
                % line('XData',t_bins_lfp,'YData',y_mean+y_std,'Color',[.5 .5 .5],'LineWidth',1,'Parent',ax2);
                % line('XData',t_bins_lfp,'YData',y_mean-y_std,'Color',[.5 .5 .5],'LineWidth',1,'Parent',ax2);
                xdata = [t_bins_lfp(:);flip(t_bins_lfp(:))];
                ydata = [y_mean(:)-y_std(:);flip(y_mean(:)+y_std(:))];
                patch('XData',xdata,'YData',ydata,'Parent',ax2,...
                    'Tag','PatchEpisode','FaceColor',[.5 .5 .5],'FaceAlpha',.5,'EdgeColor','none');                
                % Layout
                n_iqr = 1.5;
                data_iqr = Yraw_evt_zscored(~isnan(Yraw_evt_zscored));
                data_iqr=data_iqr(:);
                if ~isempty(data_iqr)
                    ax2.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                end
                ax2.XLim = [-.1 .1];
                if jj==1
                    ax2.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',channel_id,n_events,density_events);
                end
                if j==1
                    ax2.YLabel.String = S(jj).channel;
                end
                if strcmp(S(jj).channel,channel_id)
                    l.Color = 'r';
                end
                if jj==n_channels
                    set(ax2,'YTick',[],'YTickLabel',[]);
                else
                    set(ax2,'XTick',[],'XtickLabel',[]);
                    set(ax2,'YTick',[],'YTickLabel',[]);
                end
                
                % Filtered
                hold(ax3,'on');
                % for k=1:n_events
                %      l=line('XData',t_bins_lfp,'YData',Yfiltered_evt_(:,k),'Color',[.5 .5 .5],'LineWidth',.1,'Parent',ax3);
                %      l.Color(4)=.5;
                % end
                y_mean = mean(Yfiltered_evt_,2,'omitnan');
                y_std = std(Yfiltered_evt_,[],2,'omitnan');
                l=line('XData',t_bins_lfp,'YData',y_mean,'Color','k','LineWidth',2,'Parent',ax3);
                % line('XData',t_bins_lfp,'YData',y_mean+y_std,'Color',[.5 .5 .5],'LineWidth',1,'Parent',ax3);
                % line('XData',t_bins_lfp,'YData',y_mean-y_std,'Color',[.5 .5 .5],'LineWidth',1,'Parent',ax3);
                xdata = [t_bins_lfp(:);flip(t_bins_lfp(:))];
                ydata = [y_mean(:)-y_std(:);flip(y_mean(:)+y_std(:))];
                patch('XData',xdata,'YData',ydata,'Parent',ax3,...
                    'Tag','PatchEpisode','FaceColor',[.5 .5 .5],'FaceAlpha',.5,'EdgeColor','none');               
                % Layout
                n_iqr = 6;
                data_iqr = Yfiltered_evt_(~isnan(Yfiltered_evt_));
                if ~isempty(data_iqr)
                    ax3.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                end
                ax3.XLim = [-.1 .1];
                if jj==1
                    ax3.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',channel_id,n_events,density_events);
                end
                if j==1
                    ax3.YLabel.String = S(jj).channel;
                end
                if strcmp(S(jj).channel,channel_id)
                    l.Color = 'r';
                end
                if jj==n_channels
                    set(ax3,'YTick',[],'YTickLabel',[]);
                else
                    set(ax3,'XTick',[],'XtickLabel',[],'YTick',[],'YTickLabel',[]);
                end
                
                % Spectrogram
                hold(ax4,'on');
                Cdata_mean = mean(Cdata_evt_,3,'omitnan');
                imagesc('XData',t_bins_lfp,'YData',freqdom,'CData',Cdata_mean,'HitTest','off','Parent',ax4);
                n_iqr= 1.5;
                data_iqr = Cdata_mean(~isnan(Cdata_mean));
                if ~isempty(data_iqr)
                    ax4.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                end
                ax4.YLim = [freqdom(1),freqdom(end)];
                ax4.XLim = [-.1 .1];               
                if jj==1
                    ax4.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',channel_id,n_events,density_events);
                end
                if j==1
                    ax4.YLabel.String = S(jj).channel;
                end
                if j==jj
                    set(ax4,'YTick',[50 100 150 200]);
                else
                    set(ax4,'YTick',[],'YTickLabel',[]);
                end
                if jj~=n_channels
                    set(ax4,'XTick',[],'XtickLabel',[]);
                end
                
                % cross-corr
                if jj==1
                    ax5.Title.String = sprintf('[Rip:%s][N=%d][%.2fHz]',channel_id,n_events,density_events);
                end
                if j==1
                    ax5.YLabel.String = S(jj).channel;
                end
%                 if j==jj
%                     set(ax5,'YTick',[-.1 0 .1 .2 .3 .4 .5]);
%                 else
%                     set(ax5,'YTick',[],'YTickLabel',[]);
%                 end
%                 if jj~=n_channels
%                     set(ax5,'XTick',[],'XtickLabel',[]);
%                 end
                
                all_ax1(jj,j) = ax1;
                all_ax2(jj,j) = ax2;
                all_ax3(jj,j) = ax3;
                all_ax4(jj,j) = ax4;
                all_ax5(jj,j) = ax5;
            end
        end
        
        % Evnt Correlation Matrix
        tic;
        tmax = 2;
        tstep = .1;
        max_step = max(round(tmax/median(diff(Xraw))),1);
        step_size = max(round(tstep/median(diff(Xraw))),1);
        C = corr(all_y_tg','rows','complete');
        for j=1:n_channels
            for jj=1:n_channels
                ax=all_ax5(jj,j);
                X = all_y_tg(j,:);
                Y = all_y_tg(jj,:);
                [r,lags] = cross_corr(X,Y,max_step,step_size);
                t_lags = median(diff(Xraw))*lags;
                l=line('XData',t_lags,'YData',r,'Parent',ax);
                ax.XLim = [t_lags(1) t_lags(end)];
                if j==jj
                    ax.YLim = [-.1 1];
                    l.Color='r';
                elseif ~isnan(C(jj,j))
                    ax.YLim = [-.1 C(jj,j)+.1];
                end
                grid(ax,'on');
                % zero-lag
                x = ax.XLim(1)+.75*(ax.XLim(2)-ax.XLim(1));
                y = ax.YLim(1)+.85*(ax.YLim(2)-ax.YLim(1));
                str = sprintf('C=%.2f',C(jj,j));
                t1 = text(x,y,str,'Parent',ax);
                t1.FontSize=8;
                t1.BackgroundColor='w';
            end
        end
        toc;
        
%         for j=1:n_channels
%             for jj=1:n_channels
%                 if j~=jj
%                     ax=all_ax1(jj,j);
%                     x = ax.XLim(1)+.8*(ax.XLim(2)-ax.XLim(1));
%                     y = ax.YLim(1)+.9*(ax.YLim(2)-ax.YLim(1));
%                     str = sprintf('C=%.2f',C(jj,j));
%                     t1 = text(x,y,str,'Parent',ax);
%                     t1.FontSize=8;
%                     t1.BackgroundColor='w';
%                     ax=all_ax2(jj,j);
%                     x = ax.XLim(1)+.8*(ax.XLim(2)-ax.XLim(1));
%                     y = ax.YLim(1)+.9*(ax.YLim(2)-ax.YLim(1));
%                     str = sprintf('C=%.2f',C(jj,j));
%                     t1 = text(x,y,str,'Parent',ax);
%                     t1.FontSize=8;
%                     t1.BackgroundColor='w';
%                     ax=all_ax3(jj,j);
%                     x = ax.XLim(1)+.8*(ax.XLim(2)-ax.XLim(1));
%                     y = ax.YLim(1)+.9*(ax.YLim(2)-ax.YLim(1));
%                     str = sprintf('C=%.2f',C(jj,j));
%                     t1 = text(x,y,str,'Parent',ax);
%                     t1.FontSize=8;
%                     t1.BackgroundColor='w';
%                     ax=all_ax4(jj,j);
%                     x = ax.XLim(1)+.8*(ax.XLim(2)-ax.XLim(1));
%                     y = ax.YLim(1)+.9*(ax.YLim(2)-ax.YLim(1));
%                     str = sprintf('C=%.2f',C(jj,j));
%                     t1 = text(x,y,str,'Parent',ax);
%                     t1.FontSize=8;
%                     t1.BackgroundColor='w';
%                 end
%             end
%         end
        
        % Saving figure
        if flag_save_figure
            save_dir = fullfile(DIR_SYNT,'Peri-Event-LFP',cur_csv_pattern,'raw');
            if ~isfolder(save_dir)
                mkdir(save_dir);
            end
            pic_name = sprintf(f1.Name,GTraces.ImageSaveExtension);
            saveas(f1,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
            fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
            
            save_dir = fullfile(DIR_SYNT,'Peri-Event-LFP',cur_csv_pattern,'zscored');
            if ~isfolder(save_dir)
                mkdir(save_dir);
            end
            pic_name = sprintf(f2.Name,GTraces.ImageSaveExtension);
            saveas(f2,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
            fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
            
            save_dir = fullfile(DIR_SYNT,'Peri-Event-LFP',cur_csv_pattern,'filtered');
            if ~isfolder(save_dir)
                mkdir(save_dir);
            end
            pic_name = sprintf(f1.Name,GTraces.ImageSaveExtension);
            saveas(f3,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
            fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
            
            save_dir = fullfile(DIR_SYNT,'Peri-Event-LFP',cur_csv_pattern,'spectro');
            if ~isfolder(save_dir)
                mkdir(save_dir);
            end
            pic_name = sprintf(f4.Name,GTraces.ImageSaveExtension);
            saveas(f4,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
            fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
            
            save_dir = fullfile(DIR_SYNT,'Peri-Event-LFP',cur_csv_pattern,'cross-corr');
            if ~isfolder(save_dir)
                mkdir(save_dir);
            end
            pic_name = sprintf(f5.Name,GTraces.ImageSaveExtension);
            saveas(f5,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
            fprintf('Image saved at %s.\n',fullfile(save_dir,pic_name));
        end
        close(f1);
        close(f2);
        close(f3);
        close(f4);
        close(f5);
    end
end