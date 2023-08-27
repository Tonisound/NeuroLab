function synthesis_Event_Imaging()
% Reorganizes Event-Imaging figures in one folder
% Generates a synthesis video of fUS peri-event activations
% Generates Event Detection synthesis figures


global DIR_SYNT DIR_FIG DIR_STATS;
load('Preferences.mat','GTraces');

event_name = 'RippleEvents';

% Sanity Checks
folder_source_figs = fullfile(DIR_FIG,'Event_Imaging');
if ~isfolder(folder_source_figs)
    errordlg(sprintf('Not a directory [%s]',folder_source_figs));
    return;
end
folder_source_stats = fullfile(DIR_STATS,'Event_Imaging');
if ~isfolder(folder_source_stats)
    errordlg(sprintf('Not a directory [%s]',folder_source_stats));
    return;
end
folder_dest = fullfile(DIR_SYNT,'Event_Imaging',event_name);
if ~isfolder(folder_dest)
    mkdir(folder_dest);
end

% Listing files
d = dir(folder_source_figs);
% Removing hidden files
d = d(arrayfun(@(x) ~strcmp(x.name(1),'.'),d));
all_files = {d(:).name}';

% Listing animals
all_animals = cell(size(all_files));
for i=1:length(all_files)
    temp = regexp(char(all_files(i)),'_','split');
    all_animals(i)=temp(2);
end
unique_animals = unique(all_animals);


% flag_building_struct = false;
flag_moving_figures = false;
flag_synthesis_movie = false;
flag_event_detection = false;
flag_regions_averages = true;


%% Browsing stats - Buidling struct
% if flag_building_struct
S = struct('Y3q_evt_full',[],'name',[],'atlas_name',[],'atlas_coordinate',[],'data_atlas',[]);
% Listing planes
all_planes = cell(size(all_files));
all_coordinates = NaN(size(all_files));
label_Y3q_evt_full = {'Mean';'Median';'Longest';'Fastest';'Largest'};

% list_regions = generate_lists('DisplayObj','groups','DisplayMode','bilateral');
list_regions = {'[SR]AnteriorCortex';'[SR]PosteriorCortex';'[SR]HippocampalFormation';...
    '[SR]Midbrain';'[SR]Thalamus';'[SR]Hypothalamus';'[SR]Amygdala';'[SR]Other'};
R = struct('recording_name',[],'single_events',[],'atlas_coordinate',[],'atlas_name',[],...
    'mean_events',[],'median_events',[],'mean_names',[]);
R(length(list_regions)).recording_name = [];

for i=1:length(all_files)

    % Traces
    dd = dir(fullfile(folder_source_stats,char(all_files(i)),event_name,'*Event-Imaging_Traces.mat'));
    for j=1:length(dd)
        fprintf('Loading file [%s] ...',dd(j).name);
        data_traces = load(fullfile(dd(j).folder,dd(j).name),...
            'Y1_evt_','Yraw_evt_','t_bins_lfp','Cdata_mean','freqdom','Params');
        fprintf(' done.\n');
        S(i).Yraw_evt_ = data_traces.Yraw_evt_;
        S(i).t_bins_lfp = data_traces.t_bins_lfp;
        S(i).Y1_evt_ = data_traces.Y1_evt_;
        S(i).Cdata_mean = data_traces.Cdata_mean;
        S(i).freqdom = data_traces.freqdom;

        t_bins_lfp = data_traces.t_bins_lfp;
    end

    % Sequence
    dd = dir(fullfile(folder_source_stats,char(all_files(i)),event_name,'*Event-Imaging_Sequence.mat'));
    for j=1:length(dd)
        fprintf('Loading file [%s] ...',dd(j).name);
        data_seq = load(fullfile(dd(j).folder,dd(j).name),'Y3q_evt_reshaped','Y3q_evt_median_reshaped',...
            'Y3q_evt_duration_reshaped','Y3q_evt_frequency_reshaped','Y3q_evt_amplitude_reshaped',...
            't_bins_fus','data_atlas','Params');
        fprintf(' done.\n');

        S(i).Y3q_evt_full = cat(4,data_seq.Y3q_evt_reshaped,data_seq.Y3q_evt_median_reshaped,data_seq.Y3q_evt_duration_reshaped,data_seq.Y3q_evt_frequency_reshaped,data_seq.Y3q_evt_amplitude_reshaped);
        S(i).t_bins_fus = data_seq.t_bins_fus;
        S(i).name = strrep(strrep(d(i).name,'_nlab',''),'_','-');
        S(i).animal = char(all_animals(i));
        S(i).atlas_coordinate = data_seq.Params.atlas_coordinate;
        S(i).atlas_name = data_seq.Params.atlas_name;
        S(i).data_atlas = data_seq.data_atlas;
        S(i).plane = strtrim(strrep(strrep(data_seq.data_atlas.AtlasName,'Rat',''),'Paxinos',''));
        S(i).n_events = data_seq.Params.n_events;
        S(i).channel_id = data_seq.Params.channel_id;
        S(i).mean_dur = data_seq.Params.mean_dur;
        S(i).mean_freq = data_seq.Params.mean_freq;
        S(i).mean_p2p = data_seq.Params.mean_p2p;

        t_bins_fus = data_seq.t_bins_fus;
        all_coordinates(i) = data_seq.Params.atlas_coordinate;
        all_planes(i) = {strtrim(strrep(strrep(data_seq.data_atlas.AtlasName,'Rat',''),'Paxinos',''))};

    end

    % Regions
    dd = dir(fullfile(folder_source_stats,char(all_files(i)),event_name,'*Event-Imaging_Regions.mat'));
    for j=1:length(dd)
        fprintf('Loading file [%s] ...',dd(j).name);
        data_regions = load(fullfile(dd(j).folder,dd(j).name),...
            'Y2q_evt_normalized','Y2q_evt_mean','Y2q_evt_median','t_bins_fus','all_labels_2','Params');
        fprintf(' done.\n');
        S(i).Y2q_evt_mean = data_regions.Y2q_evt_mean;
        S(i).Y2q_evt_median = data_regions.Y2q_evt_median;
        S(i).Y2q_evt_normalized = data_regions.Y2q_evt_normalized;
        S(i).t_bins_fus = data_regions.t_bins_fus;
        S(i).all_labels_2 = data_regions.all_labels_2;

        for k=1:length(list_regions)
            cur_region = char(list_regions(k));
            ind_label = find(strcmp(data_regions.all_labels_2,cur_region)==1);
            if ~isempty(ind_label)

                n_events = data_regions.Params.n_events;
                cur_names = repmat({data_regions.Params.recording_name},[n_events,1]);
                atlas_coordinates = repmat(data_regions.Params.atlas_coordinate,[n_events,1]);
                atlas_names = repmat({data_regions.Params.atlas_name},[n_events,1]);
                single_events = squeeze(data_regions.Y2q_evt_normalized(ind_label,:,:))';

                R(k).recording_name = [R(k).recording_name;cur_names];
                R(k).atlas_coordinate = [R(k).atlas_coordinate;atlas_coordinates];
                R(k).atlas_name = [R(k).atlas_name;atlas_names];
                R(k).single_events = [R(k).single_events;single_events];

                R(k).mean_events = [R(k).mean_events;data_regions.Y2q_evt_mean(ind_label,:)];
                R(k).median_events = [R(k).median_events;data_regions.Y2q_evt_median(ind_label,:)];
                R(k).mean_names = [R(k).mean_names;{data_regions.Params.recording_name}];
            end
        end
    end

end
% Sorting S
[~,ind_sorted] = sort(all_coordinates,'descend');
S = S(ind_sorted);

% Create folders
unique_planes = unique(all_planes);
for i=1:length(unique_animals)
    for j=1:length(unique_planes)
        if ~isfolder(fullfile(folder_dest,strcat(char(unique_animals(i)),'-',char(unique_planes(j)))))
            mkdir(fullfile(folder_dest,strcat(char(unique_animals(i)),'-',char(unique_planes(j)))));
        end
    end
end
% end


%% Moving figures
if flag_moving_figures
    all_filetypes = {'Dynamics';'Regions';'Event-Imaging';'Synthesis';'Trials';...
        'Sequence-Mean';'Sequence-Median';'Sequence-Largest';'Sequence-Fastest';'Sequence-Longest'};
    for i=1:length(all_files)
        for j=1:length(all_filetypes)
            filetype = char(all_filetypes(j));
            dd = dir(fullfile(folder_source_figs,char(all_files(i)),event_name,strcat('*',filetype,'*')));
            for j=1:length(dd)
                dd_dest = fullfile(folder_dest,strcat(char(all_animals(i)),'-',char(all_planes(i))),filetype);
                if ~isfolder(dd_dest)
                    mkdir(dd_dest)
                end
                copyfile(fullfile(dd(j).folder,dd(j).name),fullfile(dd_dest,dd(j).name))
                fprintf('File copied [%s] ---> [%s].\n',dd(j).name,dd_dest);
            end
        end
    end
end


%% Displaying synthesis movie
if flag_synthesis_movie
    for j=1:length(unique_animals)
        cur_animal = char(unique_animals(j));
        S_animal = S(strcmp({S(:).animal}',cur_animal)==1);

        for jj=1:length(unique_planes)
            cur_plane = char(unique_planes(jj));
            S_animal_plane = S_animal(strcmp({S_animal(:).plane}',cur_plane)==1);

            % Sanity Check
            if isempty(S_animal_plane)
                continue;
            end

            % n_col = 6;
            n_col = ceil(1.2*sqrt(length(S_animal_plane)));
            n_rows = ceil(length(S_animal_plane)/n_col);
            % eps1=.01;
            % eps2=.01;

            for l=1:length(label_Y3q_evt_full)
                cur_label = char(label_Y3q_evt_full(l));
                f = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Event-Synthesis_',cur_animal,'-',cur_plane,'_',cur_label));
                colormap(f,"parula");
                f_axes = [];
                for i=1:length(S_animal_plane)
                    ax = axes('Parent',f);
                    ax.Position = get_position(n_rows,n_col,i,[.05,.05,.01;.05,.05,.02]);
                    f_axes = [f_axes;ax];
                end
                t = uicontrol(f,'Style','text','BackgroundColor','w','FontSize',16,'FontWeight','bold',...
                    'Units','normalized','Position',[.25 .96 .5 .03],'Parent',f);

                work_dir = fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat('Frames-',cur_animal,'-',cur_plane,'_',cur_label));
                if isfolder(work_dir)
                    rmdir(work_dir,'s');
                end
                mkdir(work_dir);

                for k=1:length(t_bins_fus)
                    for i=1:length(f_axes)
                        ax = f_axes(i);
                        hold(ax,'on');
                        imagesc(S_animal_plane(i).Y3q_evt_full(:,:,k,l),'Parent',ax);
                        ax.Title.String = sprintf('%s [N = %d]',S_animal_plane(i).atlas_name,S_animal_plane(i).n_events);
                        ax.YLabel.String = S_animal_plane(i).name;
                        ax.YLabel.FontSize = 8;
                        t.String = sprintf('[%s] Time from Event Peak = %.1f s',cur_label,t_bins_fus(k));
                        l_ = line('XData',S_animal_plane(i).data_atlas.line_x,'YData',S_animal_plane(i).data_atlas.line_z,'Tag','AtlasMask',...
                            'LineWidth',.5,'Color','r','Parent',ax);
                        l_.Color(4)=.5;
                        % ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                        ax.CLim = [-5,10];
                        ax.XLim = [.5 size(S_animal_plane(i).Y3q_evt_full,2)+.5];
                        ax.YLim = [.5 size(S_animal_plane(i).Y3q_evt_full,1)+.5];
                        set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                        ax.YDir = 'reverse';
                        if i ==length(f_axes)
                            pos = ax.Position;
                            c = colorbar(ax,"eastoutside");
                            c.Position(1) = pos(1)+pos(3)+.01;
                        end
                    end
                    pic_name = sprintf(strcat('Event-Synthesis_%03d.mat'),k);
                    saveas(f,fullfile(work_dir,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
                end

                video_name = strcat('Event-Synthesis_',cur_animal,'-',cur_plane,'_',cur_label);
                save_video(work_dir,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane)),video_name);
                %             rmdir(work_dir,'s');
                close(f);
            end
        end
    end
end


%% Displaying event detection
if flag_event_detection
    for j=1:length(unique_animals)
        cur_animal = char(unique_animals(j));
        S_animal = S(strcmp({S(:).animal}',cur_animal)==1);

        for jj=1:length(unique_planes)
            cur_plane = char(unique_planes(jj));
            S_animal_plane = S_animal(strcmp({S_animal(:).plane}',cur_plane)==1);

            % Sanity Check
            if isempty(S_animal_plane)
                continue;
            end

            n_col = ceil(1.2*sqrt(length(S_animal_plane)));
            n_rows = ceil(length(S_animal_plane)/n_col);

            f = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Event-Detection_',cur_animal,'-',cur_plane));
            colormap(f,'jet');
            f_axes = [];
            for i=1:length(S_animal_plane)
                ax = axes('Parent',f);
                ax.Position = get_position(n_rows,n_col,i,[.05,.05,.01;.05,.05,.02]);
                f_axes = [f_axes;ax];
            end

            % Displaying event detection - Raw Trace
            for i=1:length(f_axes)
                ax = f_axes(i);
                hold(ax,'on');
                for ii=1:S_animal_plane(i).n_events
                    l=line('XData',S_animal_plane(i).t_bins_lfp,'YData',S_animal_plane(i).Yraw_evt_(:,ii),'Color','k','LineWidth',.1,'Parent',ax);
                    l.Color(4)=.5;
                end
                line('XData',S_animal_plane(i).t_bins_lfp,'YData',mean(S_animal_plane(i).Yraw_evt_,2,'omitnan'),'Color','r','LineWidth',2,'Parent',ax);
                ax.Title.String = sprintf('Channel %s [N=%d]',S_animal_plane(i).channel_id,S_animal_plane(i).n_events);
                %             ax.Title.String = sprintf('%s [N = %d]',S_animal_plane(i).atlas_name,S_animal_plane(i).n_events);
                ax.YLabel.String = S_animal_plane(i).name;
                ax.YLabel.FontSize = 8;
                n_iqr = 3;
                Yraw_evt = S_animal_plane(i).Yraw_evt_(:);
                data_iqr = Yraw_evt(~isnan(Yraw_evt));
                ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                ax.XLim = [-.1 .1];
                set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
            end

            pic_name = sprintf(strcat('Event-Detection-Raw','_',cur_animal,'-',cur_plane));
            saveas(f,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);

            % Displaying event detection - Filtered Trace
            for i=1:length(f_axes)
                ax = f_axes(i);
                cla(ax);
                hold(ax,'on');
                for ii=1:S_animal_plane(i).n_events
                    l=line('XData',S_animal_plane(i).t_bins_lfp,'YData',S_animal_plane(i).Y1_evt_(:,ii),'Color',[.5 .5 .5],'LineWidth',.1,'Parent',ax);
                    l.Color(4)=.5;
                end
                line('XData',S_animal_plane(i).t_bins_lfp,'YData',mean(S_animal_plane(i).Y1_evt_,2,'omitnan'),'Color','r','LineWidth',1,'Parent',ax);
                ax.Title.String = sprintf('Channel %s [N=%d]',S_animal_plane(i).channel_id,S_animal_plane(i).n_events);
                %             ax.Title.String = sprintf('%s [N = %d]',S_animal_plane(i).atlas_name,S_animal_plane(i).n_events);
                ax.YLabel.String = S_animal_plane(i).name;
                ax.YLabel.FontSize = 8;
                n_iqr = 15;
                Y1_evt_ = S_animal_plane(i).Y1_evt_(:);
                data_iqr = Y1_evt_(~isnan(Y1_evt_));
                ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                ax.XLim = [-.1 .1];
                set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
            end

            pic_name = sprintf(strcat('Event-Detection-Filtered','_',cur_animal,'-',cur_plane));
            saveas(f,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);

            % Displaying event detection - Spectrogram
            for i=1:length(f_axes)
                ax = f_axes(i);
                cla(ax);
                hold(ax,'on');
                Cdata_mean = S_animal_plane(i).Cdata_mean;
                imagesc('XData',S_animal_plane(i).t_bins_lfp,'YData',S_animal_plane(i).freqdom,'CData',Cdata_mean,...
                    'HitTest','off','Parent',ax);
                ax.Title.String = sprintf('Channel %s [N=%d]',S_animal_plane(i).channel_id,S_animal_plane(i).n_events);
                ax.YLabel.String = S_animal_plane(i).name;
                ax.YLabel.FontSize = 8;
                n_iqr = 2;
                data_iqr = Cdata_mean(~isnan(Cdata_mean));
                ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
                ax.YLim = [S_animal_plane(i).freqdom(1),S_animal_plane(i).freqdom(end)];
                ax.XLim = [-.1 .5];
                set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
                l = line('XData',[0 0],'YData',ax.YLim,'Color','r',...
                    'LineStyle','--','LineWidth',.1,'Parent',ax);
                l.Color(4)=.75;
            end

            pic_name = sprintf(strcat('Event-Detection-Spectrogram','_',cur_animal,'-',cur_plane));
            saveas(f,fullfile(folder_dest,strcat(cur_animal,'-',cur_plane),strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
            close(f);

        end
    end
end

%% Displaying region averages
if flag_regions_averages

    for j=1:length(unique_animals)
        cur_animal = char(unique_animals(j));
    end
    mean_regions = NaN(length(list_regions),length(t_bins_fus));
    median_regions = NaN(length(list_regions),length(t_bins_fus));
    for i=1:length(list_regions)
        mean_regions(i,:) = mean(R(i).single_events,1,'omitnan');
        median_regions(i,:) = median(R(i).single_events,1,'omitnan');
    end
    
%     f = figure('Units','normalized','OuterPosition',[0 0 1 1],'Name',strcat('Region-Average',cur_animal,'-',cur_plane));
    f = figure('Units','normalized','OuterPosition',[0 0 1 1]);
    colormap(f,'jet');

    % fUS
    ax1 = axes('Parent',tab2,'Position',[.2 .05 .3 .9]);
    hold(ax1,'on');
    Y2q_evt_mean = mean(Y2q_evt_normalized,3,'omitnan');
    imagesc('XData',t_bins_fus,'YData',1:length(all_labels_2),'CData',Y2q_evt_mean,'HitTest','off','Parent',ax1);
    n_iqr = 6;
    data_iqr = Y2q_evt_mean(~isnan(Y2q_evt_mean));
    % ax1.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax1.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax1.YLim = [.5 length(all_labels_2)+.5];
    ax1.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax1.YTick = 1:length(all_labels_2);
    ax1.YTickLabel = all_labels_2;
    ax1.Title.String = 'Mean Regions fUS';
    % ax1.FontSize = 8;
    colorbar(ax1,'eastoutside');

    ax2 = axes('Parent',tab2,'Position',[.2 .05 .3 .9]);
    hold(ax2,'on');
    Y2q_evt_median = median(Y2q_evt_normalized,3,'omitnan');
    imagesc('XData',t_bins_fus,'YData',1:length(all_labels_2),'CData',Y2q_evt_median,'HitTest','off','Parent',ax2);
    n_iqr = 6;
    data_iqr = Y2q_evt_median(~isnan(Y2q_evt_median));
    % ax2.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax2.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax2.YLim = [.5 length(all_labels_2)+.5];
    ax2.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax2.YTick = 1:length(all_labels_2);
    ax2.YTickLabel = all_labels_2;
    ax2.Title.String = 'Median Regions fUS';
    % ax2.FontSize = 8;
    colorbar(ax2,'eastoutside');

    f_axes = [ax1;ax2];

%     for i=1:n_channels
%         %     ax = subplot(n_rows,n_col,i,'parent',tab3);
%         ax = axes('Parent',tab3,'Position',get_position(n_rows,n_col,i));
%         hold(ax,'on');
%         YData = squeeze(Y2q_evt_normalized(i,:,:));
%         for j=1:n_events
%             try
%                 l=line('XData',t_bins_fus,'YData',YData(:,j),'Color',g_colors(i,:),'LineWidth',.1,'Parent',ax);
%             catch
%                 l=line('XData',t_bins_fus,'YData',YData(:,j),'Color',g_colors(end,:),'LineWidth',.1,'Parent',ax);
%             end
%             l.Color(4)=.5;
%         end
%         YData_mean = mean(YData,2,'omitnan');
%         l=line('XData',t_bins_fus,'YData',YData_mean,'Color','r','LineWidth',2,'Parent',ax);
%         n_samples = sum(~isnan(YData),2);
%         ebar_data = std(YData,0,2,'omitnan')./sqrt(n_samples);
%         errorbar(t_bins_fus,YData_mean,ebar_data,'Color',[.5 .5 .5],...
%             'linewidth',1,'linestyle','none',...
%             'Parent',ax,'Visible','on','Tag','ErrorBar');
%         uistack(l,'top');
%         ax.XLim = [t_bins_fus(1),t_bins_fus(end)];
% 
%         n_iqr= 2;
%         data_iqr = YData_mean(~isnan(YData_mean));
%         %     ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
%         ax.YLim = [median(data_iqr(:))-5,median(data_iqr(:))+10];
%         ax.Title.String = char(all_labels_2(i));
%         f3_axes=[f3_axes;ax];
%     end
% 
%     for i=1:n_channels
%         %     ax = subplot(n_rows,n_col,i,'parent',tab4);
%         ax = axes('Parent',tab4,'Position',get_position(n_rows,n_col,i));
%         hold(ax,'on');
%         YData = squeeze(Y2q_evt_normalized(i,:,:));
%         imagesc('XData',t_bins_fus,'YData',1:n_events,'CData',YData','Parent',ax)
%         %     imagesc('XData',t_bins_fus,'YData',1:n_events,'CData',YData(:,ind_sorted_duration)','Parent',ax)
% 
%         n_samples = sum(~isnan(YData),2);
%         ax.XLim = [t_bins_fus(1),t_bins_fus(end)];
%         ax.YLim = [.5,n_events+.5];
%         ax.YDir = 'reverse';
%         colorbar(ax,'eastoutside');
% 
%         ax.YTick= 1:10:n_events;
%         ax.YTickLabel= t_events(1:10:end);
%         %     ax.FontSize = 6;
% 
%         n_iqr= 3;
%         data_iqr = YData(~isnan(YData));
%         %     ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
%         ax.CLim = [-10,30];
% 
%         ax.Title.String = char(all_labels_2(i));
%         f4_axes=[f4_axes;ax];
% 
%     end

end

end
