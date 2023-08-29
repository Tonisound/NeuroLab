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
if exist(fullfile(folder_dest,strcat(event_name,'.mat')),'file')

    fprintf('Loading file [%s] ...',folder_dest,strcat(event_name,'.mat'));
    data_full = load(fullfile(folder_dest,strcat(event_name,'.mat')));
    all_planes = data_full.all_planes;
%     all_coordinates = data_full.all_coordinates;
    list_regions = data_full.list_regions;
    t_bins_fus = data_full.t_bins_fus;
    t_bins_lfp = data_full.t_bins_lfp;
    R = data_full.R;
    Q = data_full.Q;
    S = data_full.S;
    fprintf(' done.\n');

else

    % if flag_building_struct
    S = struct('Y3q_evt_full',[],'name',[],'atlas_name',[],'atlas_coordinate',[],'data_atlas',[]);
    % Listing planes
    all_planes = cell(size(all_files));
    all_coordinates = NaN(size(all_files));
    % label_Y3q_evt_full = {'Mean';'Median';'Longest';'Fastest';'Largest'};

    list_regions = {'OrbitalCortex';'LimbicCortex';'CingulateCortex';'InsularCortex';'MotorCortex';'SomatosensoryCortex';...
        'PiriformCortex';'RetrosplenialCortex';'ParietalCortex';'EntorhinalCortex';'VisualCortex';'AuditoryCortex';'RhinalCortex';...
        'DentateGyrus';'CA1Region';'CA3Region';'ResidualHippocampus';'Subiculum';'Fimbria';...;'CA2Region'
        'Striatum';'BasalForebrain';'SubstantiaNigra';'Septum';...
        'StriaTerminalis';'SuperiorColliculus';'DPAG';'VPAG';...;'InferiorColliculus'
        'DThalamus';'VThalamus';'Habenulla';'ZonaIncerta';'PretectalNuclei';'GeniculateNuclei';'ReticularFormation';...
        'AnteriorAmygdala';'PosteriorAmygdala';...
        'DHypothalamus';'LHypothalamus';'VHypothalamus';'VTegmentalArea';'PreopticArea';'MammillaryNuclei';'OlfactoryNuclei';...
        'BrainStem';'OptChiasm';'Claustrum';'CCallosum';'Ventricles'};...'Cerebellum';'PinealGland'
%     list_regions = {'[SR]AnteriorCortex';'[SR]PosteriorCortex';'[SR]HippocampalFormation';...
%         '[SR]Midbrain';'[SR]Thalamus';'[SR]Hypothalamus';'[SR]Amygdala';'[SR]Other'};
    n_regions = length(list_regions);

    T = struct('recording_name',[],'region',[],'animal',[],'plane',[],...
        'single_events',[],'atlas_coordinate',[],'atlas_name',[]);

    R = struct('recording_name',[],'region',[],'animal',[],'plane',[],...
        'single_events',[],'atlas_coordinate',[],'atlas_name',[]);
    R(n_regions).recording_name = [];

    Q = struct('recording_name',[],'region',[],'animal',[],'plane',[],...
        'mean_events',[],'median_events',[],'atlas_coordinate',[],'atlas_name',[]);
    Q(n_regions).recording_name = [];

    for i=1:length(all_files)

        % Traces
        dd = dir(fullfile(folder_source_stats,char(all_files(i)),event_name,'*Event-Imaging_Traces.mat'));
        for j=1:length(dd)
            fprintf('Loading file [%s] ...',dd(j).name);
            data_traces = load(fullfile(dd(j).folder,dd(j).name),...
                'Y1_evt_','Yraw_evt_','t_bins_lfp','Cdata_mean','freqdom','Params');
            fprintf(' done.\n');

            t_bins_lfp = data_traces.t_bins_lfp;

            S(i).Yraw_evt_ = data_traces.Yraw_evt_;
            S(i).t_bins_lfp = data_traces.t_bins_lfp;
            S(i).Y1_evt_ = data_traces.Y1_evt_;
            S(i).Cdata_mean = data_traces.Cdata_mean;
            S(i).freqdom = data_traces.freqdom;
        end

        % Sequence
        dd = dir(fullfile(folder_source_stats,char(all_files(i)),event_name,'*Event-Imaging_Sequence.mat'));
        for j=1:length(dd)
            fprintf('Loading file [%s] ...',dd(j).name);
            data_seq = load(fullfile(dd(j).folder,dd(j).name),'Y3q_evt_reshaped','Y3q_evt_median_reshaped',...
                'Y3q_evt_duration_reshaped','Y3q_evt_frequency_reshaped','Y3q_evt_amplitude_reshaped',...
                't_bins_fus','data_atlas','Params');
            fprintf(' done.\n');

            t_bins_fus = data_seq.t_bins_fus;
            all_coordinates(i) = data_seq.Params.atlas_coordinate;
            all_planes(i) = {strtrim(strrep(strrep(data_seq.data_atlas.AtlasName,'Rat',''),'Paxinos',''))};

            S(i).Y3q_evt_full = cat(4,data_seq.Y3q_evt_reshaped,data_seq.Y3q_evt_median_reshaped,data_seq.Y3q_evt_duration_reshaped,data_seq.Y3q_evt_frequency_reshaped,data_seq.Y3q_evt_amplitude_reshaped);
            S(i).t_bins_fus = data_seq.t_bins_fus;
            S(i).name = strrep(strrep(d(i).name,'_nlab',''),'_','-');
            S(i).animal = char(all_animals(i));
            S(i).atlas_coordinate = data_seq.Params.atlas_coordinate;
            S(i).atlas_name = data_seq.Params.atlas_name;
            S(i).data_atlas = data_seq.data_atlas;
            S(i).plane = char(all_planes(i));
            S(i).n_events = data_seq.Params.n_events;
            S(i).channel_id = data_seq.Params.channel_id;
            S(i).mean_dur = data_seq.Params.mean_dur;
            S(i).mean_freq = data_seq.Params.mean_freq;
            S(i).mean_p2p = data_seq.Params.mean_p2p;
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

            for k=1:n_regions
                cur_region = char(list_regions(k));
                ind_label = find(strcmp(data_regions.all_labels_2,cur_region)==1);
                if ~isempty(ind_label)

                    n_events = data_regions.Params.n_events;
                    cur_names = repmat({data_regions.Params.recording_name},[n_events,1]);
                    cur_regions = repmat(list_regions(k),[n_events,1]);
                    cur_animals = repmat(all_animals(i),[n_events,1]);
                    cur_planes = repmat(all_planes(i),[n_events,1]);
                    atlas_coordinates = repmat(data_regions.Params.atlas_coordinate,[n_events,1]);
                    atlas_names = repmat({data_regions.Params.atlas_name},[n_events,1]);
                    single_events = squeeze(data_regions.Y2q_evt_normalized(ind_label,:,:))';

%                     T.recording_name = [T.recording_name;cur_names];
%                     T.region = [T.region;cur_regions];
%                     T.animal = [T.animal;cur_animals];
%                     T.plane = [T.plane;cur_planes];
%                     T.atlas_coordinate = [T.atlas_coordinate;atlas_coordinates];
%                     T.atlas_name = [T.atlas_name;atlas_names];
%                     T.single_events = [T.single_events;single_events];

                    R(k).recording_name = [R(k).recording_name;cur_names];
                    R(k).region = [R(k).region;cur_regions];
                    R(k).animal = [R(k).animal;cur_animals];
                    R(k).plane = [R(k).plane;cur_planes];
                    R(k).atlas_coordinate = [R(k).atlas_coordinate;atlas_coordinates];
                    R(k).atlas_name = [R(k).atlas_name;atlas_names];
                    R(k).single_events = [R(k).single_events;single_events];

                    Q(k).recording_name = [Q(k).recording_name;{data_regions.Params.recording_name}];
                    Q(k).region = [Q(k).region;list_regions(k)];
                    Q(k).animal = [Q(k).animal;all_animals(i)];
                    Q(k).plane = [Q(k).plane;all_planes(i)];
                    Q(k).atlas_coordinate = [Q(k).atlas_coordinate;data_regions.Params.atlas_coordinate];
                    Q(k).atlas_name = [Q(k).atlas_name;{data_regions.Params.atlas_name}];
                    Q(k).mean_events = [Q(k).mean_events;data_regions.Y2q_evt_mean(ind_label,:)];
                    Q(k).median_events = [Q(k).median_events;data_regions.Y2q_evt_median(ind_label,:)];
                end
            end
        end
    end
    % Sorting S
    [~,ind_sorted] = sort(all_coordinates,'descend');
    S = S(ind_sorted);

%     % Saving
%     fprintf('Saving file [%s] ...',folder_dest,strcat(event_name,'.mat'));
%     save(fullfile(folder_dest,strcat(event_name,'.mat')),...
%         'all_planes','all_coordinates',...
%         'list_regions','t_bins_fus','t_bins_lfp',...
%         'R','Q','S','-v7.3');
%     fprintf(' done.\n');

end

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

%     for j=1:length(unique_animals)
%         cur_animal = char(unique_animals(j));
%         T_animal = T(strcmp({T(:).animal}',cur_animal)==1);
%         for jj=1:length(unique_planes)
%             cur_plane = char(unique_planes(jj));
%             T_animal_plane = T_animal(strcmp({T_animal(:).plane}',cur_plane)==1);
%         end
%     end

    % All events 
    mean_regions_events = NaN(n_regions,length(t_bins_fus));
    median_regions_events = NaN(n_regions,length(t_bins_fus));
    n_regions_events = NaN(n_regions,1);
    n_regions_recordings = NaN(n_regions,1);
    label_regions = cell(n_regions,1);

    for i=1:n_regions
        if ~isempty(R(i).single_events)
            mean_regions_events(i,:) = mean(R(i).single_events,1,'omitnan');
            median_regions_events(i,:) = median(R(i).single_events,1,'omitnan');
        end        
        n_regions_events(i) = size(R(i).single_events,1);
        n_regions_recordings(i) = size(unique(R(i).recording_name),1);
        label_regions(i) = {sprintf('%s [N=%d-R=%d]',char(strrep(list_regions(i),'_','-')),n_regions_events(i),n_regions_recordings(i))};
    end

    f = figure('Units','normalized','OuterPosition',[0 0 1 1]);
    colormap(f,'jet');

    ax1 = axes('Parent',f,'Position',[.1 .05 .4 .9]);
    hold(ax1,'on');
    imagesc('XData',t_bins_fus,'YData',1:n_regions,'CData',mean_regions_events,'HitTest','off','Parent',ax1);
    n_iqr = 6;
    data_iqr = mean_regions_events(~isnan(mean_regions_events));
    ax1.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax1.YLim = [.5 n_regions+.5];
    ax1.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax1.YTick = 1:n_regions;
    ax1.YTickLabel = label_regions;
    ax1.Title.String = 'Mean Regions All Events';
    ax1.YDir = 'reverse';
    colorbar(ax1,'eastoutside');
    line('XData',[0 0],'YData',ax1.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax1);

    ax2 = axes('Parent',f,'Position',[.6 .05 .4 .9]);
    hold(ax2,'on');
    imagesc('XData',t_bins_fus,'YData',1:n_regions,'CData',median_regions_events,'HitTest','off','Parent',ax2);
    n_iqr = 6;
    data_iqr = median_regions_events(~isnan(mean_regions_events));
    ax2.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax2.YLim = [.5 n_regions+.5];
    ax2.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax2.YTick = 1:n_regions;
    ax2.YTickLabel = label_regions;
    ax2.Title.String = 'Median Regions All Events';
    ax2.YDir = 'reverse';
    colorbar(ax2,'eastoutside');
    line('XData',[0 0],'YData',ax2.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax2);
    f_axes = [ax1;ax2];

    pic_name = 'Regional-Responses_All-Trials-1';
    saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
    %     close(f);

    delete(f_axes);
    %     n_col = 10;
    n_col = ceil(sqrt(n_regions));
    n_rows = ceil(n_regions/n_col);

    f_axes=[];
    for i=1:n_regions
        ax = axes('Parent',f,'Position',get_position(n_rows,n_col,i,[.05 .05 .01;.05 .05 .02]));
        hold(ax,'on');

        YData = R(i).single_events;
        YData_median = median(YData,1,'omitnan');
        YData_mean = mean(YData,1,'omitnan');
        if ~isempty(YData_mean)
            YData_std = std(YData,0,1,'omitnan');
            l1 = line('XData',t_bins_fus,'YData',YData_mean,'Color','r','LineWidth',1,'Parent',ax);
            l2 = line('XData',t_bins_fus,'YData',YData_median,'Color','b','LineWidth',1,'Parent',ax);
            n_samples = sum(~isnan(YData),1);
            ebar_data = YData_std./sqrt(n_samples);
            errorbar(t_bins_fus,YData_mean,ebar_data,'Color','r',...
                'linewidth',1,'linestyle','none',...
                'Parent',ax,'Visible','on','Tag','ErrorBar');
            errorbar(t_bins_fus,YData_median,ebar_data,'Color','b',...
                'linewidth',1,'linestyle','none',...
                'Parent',ax,'Visible','on','Tag','ErrorBar');

            uistack([l1;l2],'top');
            ax.XLim = [t_bins_fus(1),t_bins_fus(end)];

            n_iqr= 2;
            data_iqr = YData_mean(~isnan(YData_mean));
            % ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
            ax.YLim = [median(data_iqr(:))-5,median(data_iqr(:))+10];
        end
        
        line('XData',[0 0],'YData',ax.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax);
        ax.Title.String = char(label_regions(i));
        set(ax,'XTick',[],'XTickLabel',[]);
        f_axes=[f_axes;ax];
        
    end

    pic_name = 'Regional-Responses_All-Trials-2';
    saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
    %     close(f);

    delete(f_axes);
    f_axes=[];
    for i=1:n_regions
        ax = axes('Parent',f,'Position',get_position(n_rows,n_col,i,[.05 .05 .01;.05 .05 .02]));
        hold(ax,'on');
        YData = R(i).single_events;
        if ~isempty(YData)
            imagesc('XData',t_bins_fus,'YData',1:n_regions_events(i),'CData',YData,'Parent',ax);
            line('XData',[0 0],'YData',ax.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax);

            ax.XLim = [t_bins_fus(1),t_bins_fus(end)];
            ax.YLim = [.5,n_regions_events(i)+.5];
            ax.YDir = 'reverse';
            %     colorbar(ax,'eastoutside');
            %     ax.FontSize = 6;

            n_iqr= 3;
            data_iqr = YData(~isnan(YData));
            %     ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
            ax.CLim = [-10,30];
            
        end
        
        ax.Title.String = char(label_regions(i));
        set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);

        f_axes=[f_axes;ax];
    end

    pic_name = 'Regional-Responses_All-Trials-3';
    saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
    close(f);

    % All recordings 
    mean_regions_recordings = NaN(n_regions,length(t_bins_fus));
    median_regions_recordings = NaN(n_regions,length(t_bins_fus));
    n_regions_recordings = NaN(n_regions,1);
    label_regions = cell(n_regions,1);

    for i=1:n_regions
        if ~isempty(Q(i).mean_events)
            mean_regions_recordings(i,:) = mean(Q(i).mean_events,1,'omitnan');
            median_regions_recordings(i,:) = median(Q(i).median_events,1,'omitnan');
        end        
        n_regions_recordings(i) = size(unique(Q(i).recording_name),1);
        label_regions(i) = {sprintf('%s [R=%d]',char(strrep(list_regions(i),'_','-')),n_regions_recordings(i))};
    end

    f = figure('Units','normalized','OuterPosition',[0 0 1 1]);
    colormap(f,'jet');

    ax1 = axes('Parent',f,'Position',[.1 .05 .4 .9]);
    hold(ax1,'on');
    imagesc('XData',t_bins_fus,'YData',1:n_regions,'CData',mean_regions_recordings,'HitTest','off','Parent',ax1);
    n_iqr = 6;
    data_iqr = mean_regions_recordings(~isnan(mean_regions_recordings));
    ax1.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax1.YLim = [.5 n_regions+.5];
    ax1.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax1.YTick = 1:n_regions;
    ax1.YTickLabel = label_regions;
    ax1.Title.String = 'Mean Regions - All Recordings';
    ax1.YDir = 'reverse';
    colorbar(ax1,'eastoutside');
    line('XData',[0 0],'YData',ax1.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax1);

    ax2 = axes('Parent',f,'Position',[.6 .05 .4 .9]);
    hold(ax2,'on');
    imagesc('XData',t_bins_fus,'YData',1:n_regions,'CData',median_regions_recordings,'HitTest','off','Parent',ax2);
    n_iqr = 6;
    data_iqr = median_regions_recordings(~isnan(median_regions_recordings));
    ax2.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax2.YLim = [.5 n_regions+.5];
    ax2.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax2.YTick = 1:n_regions;
    ax2.YTickLabel = label_regions;
    ax2.Title.String = 'Median Regions - All Recordings';
    ax2.YDir = 'reverse';
    colorbar(ax2,'eastoutside');
    line('XData',[0 0],'YData',ax2.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax2);
    f_axes = [ax1;ax2];

    pic_name = 'Regional-Responses_All-Recordings-1';
    saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
    %     close(f);

    delete(f_axes);
    %     n_col = 10;
    n_col = ceil(sqrt(n_regions));
    n_rows = ceil(n_regions/n_col);

    f_axes=[];
    for i=1:n_regions
        ax = axes('Parent',f,'Position',get_position(n_rows,n_col,i,[.05 .05 .01;.05 .05 .02]));
        hold(ax,'on');

        YData1 = Q(i).mean_events;
        YData_mean = mean(YData1,1,'omitnan');
        YData2 = Q(i).median_events;
        YData_median = median(YData2,1,'omitnan');
        if ~isempty(YData_mean)
            YData1_std = std(YData1,0,1,'omitnan');
            YData2_std = std(YData2,0,1,'omitnan');
            l1 = line('XData',t_bins_fus,'YData',YData_mean,'Color','r','LineWidth',1,'Parent',ax);
            l2 = line('XData',t_bins_fus,'YData',YData_median,'Color','b','LineWidth',1,'Parent',ax);
            n_samples_1 = sum(~isnan(YData1),1);
            ebar_data_1 = YData1_std./sqrt(n_samples_1);
            errorbar(t_bins_fus,YData_mean,ebar_data_1,'Color','r',...
                'linewidth',1,'linestyle','none',...
                'Parent',ax,'Visible','on','Tag','ErrorBar');
            n_samples_2 = sum(~isnan(YData2),1);
            ebar_data_2 = YData2_std./sqrt(n_samples_2);
            errorbar(t_bins_fus,YData_median,ebar_data_2,'Color','b',...
                'linewidth',1,'linestyle','none',...
                'Parent',ax,'Visible','on','Tag','ErrorBar');

            uistack([l1;l2],'top');
            ax.XLim = [t_bins_fus(1),t_bins_fus(end)];

            n_iqr= 2;
            data_iqr = YData_mean(~isnan(YData_mean));
            % ax.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
            ax.YLim = [median(data_iqr(:))-5,median(data_iqr(:))+10];
        end
        
        line('XData',[0 0],'YData',ax.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax);
        ax.Title.String = char(label_regions(i));
        set(ax,'XTick',[],'XTickLabel',[]);
        f_axes=[f_axes;ax];
        
    end

    pic_name = 'Regional-Responses_All-Recordings-2';
    saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
    %     close(f);

    delete(f_axes);
    f_axes=[];
    for i=1:n_regions
        ax = axes('Parent',f,'Position',get_position(n_rows,n_col,i,[.05 .05 .01;.05 .05 .02]));
        hold(ax,'on');
        YData = Q(i).mean_events;
        if ~isempty(YData)
            imagesc('XData',t_bins_fus,'YData',1:n_regions_recordings(i),'CData',YData,'Parent',ax);
            line('XData',[0 0],'YData',ax.YLim,'Color','r','LineStyle','--','LineWidth',.5,'Parent',ax);

            ax.XLim = [t_bins_fus(1),t_bins_fus(end)];
            ax.YLim = [.5,n_regions_recordings(i)+.5];
            ax.YDir = 'reverse';
            %     colorbar(ax,'eastoutside');
            %     ax.FontSize = 6;

            n_iqr= 3;
            data_iqr = YData(~isnan(YData));
            %     ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
            ax.CLim = [-5,15];
            
        end
        
        ax.Title.String = char(label_regions(i));
        set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);

        f_axes=[f_axes;ax];
    end

    pic_name = 'Regional-Responses_All-Recordings-3';
    saveas(f,fullfile(folder_dest,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
    close(f);

end

end
