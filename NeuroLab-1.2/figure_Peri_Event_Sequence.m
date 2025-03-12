function f1 = figure_Peri_Event_Sequence(handles,val,str_regions,str_traces)
% (Figure) Displays fUS imaging sequence associated with events

load('Preferences.mat','GTraces');
global FILES CUR_FILE DIR_SAVE DIR_FIG DIR_STATS IM;


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


f1 = [];
recording_name = FILES(CUR_FILE).nlab;


% % Loading time reference
% data_tr = load(fullfile(DIR_SAVE,recording_name,'Time_Reference.mat'));

% Loading atlas
if exist(fullfile(DIR_SAVE,recording_name,'Atlas.mat'),'file')
    data_atlas = load(fullfile(DIR_SAVE,recording_name,'Atlas.mat'));
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

% Processed File Selection
pe_dir = fullfile(DIR_STATS,'PeriEvent_Sequence',recording_name);
d_pe = dir(fullfile(pe_dir,'*.mat'));
% Removing hidden files
d_pe = d_pe(arrayfun(@(x) ~strcmp(x.name(1),'.'),d_pe));

if isempty(d_pe)
    errordlg('No Peri-Event file computed [%s].',pe_dir);
    return;
elseif length(d_pe)==1
    ind_pe = 1;
else
    if val == 1
        % user mode
        [ind_pe,v] = listdlg('Name','Sequence Selection','PromptString','Select Sequence to display',...
            'SelectionMode','multiple','ListString',{d_pe(:).name}','InitialValue',1,'ListSize',[300 500]);
        if v==0 || isempty(ind_pe)
            return;
        end

    else
        % batch mode
        % ind_pe = 1:length(d_pe);
        batch_csv_timegroup = {'[NREM]'};
        ind_keep1 = zeros(length(d_pe),1);
        for i=1:length(batch_csv_timegroup)
            this_timegroup = char(batch_csv_timegroup(i));
            ind_keep1 = ind_keep1+contains({d_pe(:).name}',this_timegroup);
        end
        ind_keep1 = ind_keep1>0;
        
        batch_csv_eventname = {'[Ripples-Abs-All]';'[Ripples-Sqrt-All]'};
%         batch_csv_eventname = {'[Ripples-Abs-All]'};
%         batch_csv_eventname = {'[[Pyr]Ripples-Abs-Fast]';'[[Pyr]Ripples-Abs-Long]';'[[Pyr]Ripples-Abs-Strong]';...
%             '[[Gyr]Ripples-Abs-Fast]';'[[Gyr]Ripples-Abs-Long]';'[[Gyr]Ripples-Abs-Strong]'};  
        ind_keep2 = zeros(length(d_pe),1);
        for i=1:length(batch_csv_eventname)
            this_event = char(batch_csv_eventname(i));
            ind_keep2 = ind_keep2+contains({d_pe(:).name}',this_event);
        end
        ind_keep2 = ind_keep2>0;

        ind_pe = find((ind_keep1.*ind_keep2)==1);
    end
end

all_pe_names = {d_pe(ind_pe).name}';
for kk = 1:length(all_pe_names)

    % Processed File Loading
    pe_filename = d_pe(ind_pe(kk)).name;
    fprintf('Loading Data [%s] ...',pe_filename);
    data_pe = load(fullfile(pe_dir,pe_filename),'Params',...
        'all_labels_channels','freqdom','t_bins_lfp',...
        'Xq_evt_lfp_','Y0q_evt_','Y1q_evt_','Cdata_evt_int',...
        'all_labels_regions','t_bins_fus',...
        'Xq_evt_fus_','Y2q_evt_normalized',...
        'Y3q_evt_normalized','Y3q_evt_mean_reshaped','Y3q_evt_median_reshaped');
    fprintf(' done.\n');


    % Params
    recording_name = data_pe.Params.recording_name;
    timegroup = data_pe.Params.timegroup;
    event_name = data_pe.Params.event_name;
    band_name = data_pe.Params.band_name;
    timegroup_duration = data_pe.Params.timegroup_duration;
    EventHeader = data_pe.Params.EventHeader;
    MetaData = data_pe.Params.MetaData;
    events = data_pe.Params.events;
    t_events = data_pe.Params.t_events;
    n_events = data_pe.Params.n_events;
    density_events = data_pe.Params.density_events;
    channel_id = data_pe.Params.channel_id;
    t_baseline_start = data_pe.Params.t_baseline_start;
    t_baseline_end = data_pe.Params.t_baseline_end;
    t_before = data_pe.Params.t_before;
    t_after = data_pe.Params.t_after;
    sampling_fus = data_pe.Params.sampling_fus;
    sampling_lfp = data_pe.Params.sampling_lfp;
    size_im = data_pe.Params.size_im;
    save_ratio_spectro = data_pe.Params.save_ratio_spectro;

    all_labels_channels = data_pe.all_labels_channels;
    freqdom = data_pe.freqdom;
    t_bins_lfp = data_pe.t_bins_lfp;
    % Xq_evt_lfp_ = data_pe.Xq_evt_lfp_;
    Y0q_evt_ = data_pe.Y0q_evt_;
    Y1q_evt_ = data_pe.Y1q_evt_;
    Cdata_evt_ = double(data_pe.Cdata_evt_int/save_ratio_spectro);

    all_labels_regions = data_pe.all_labels_regions;
    t_bins_fus = data_pe.t_bins_fus;
    % Xq_evt_fus_ = data_pe.Xq_evt_fus_;
    Y2q_evt_normalized = data_pe.Y2q_evt_normalized;
    Y2q_evt_normalized = data_pe.Y2q_evt_normalized;
    Y3q_evt_normalized = data_pe.Y3q_evt_normalized;


    % Computing mean-median sequences
    Y3q_evt_mean = mean(Y3q_evt_normalized,3,'omitnan');
    Y3q_evt_mean_reshaped = reshape(Y3q_evt_mean,[size(IM,1) size(IM,2) length(t_bins_fus)]);
    Y3q_evt_median = median(Y3q_evt_normalized,3,'omitnan');
    Y3q_evt_median_reshaped = reshape(Y3q_evt_median,[size(IM,1) size(IM,2) length(t_bins_fus)]);
    Cdata_mean = mean(Cdata_evt_,3,'omitnan');


    % markersize = 3;
    % face_color = [0.9300    0.6900    0.1900];
    % face_alpha = .5 ;
    % g_colors = get_colors(n_channels+1,'jet');
    % Flag save
    flag_save_figure = 1; % all panels
    flag_save_movie = 1; % movie


    % Building Figure and Plotting
    f1 = figure;
    f1.UserData.success = false;

    % f1.Name = sprintf(strcat('[%s]%s'),atlas_fullname,strrep(recording_name,'_nlab',''));
    f1.Name = sprintf(strcat('[%s][%s]%s'),event_name,timegroup,strrep(recording_name,'_nlab',''));
    set(f1,'Units','normalized','OuterPosition',[0 0 1 1]);
    colormap(f1,'jet');
    bg_color='w';

    mP = uipanel('Units','normalized',...
        'Position',[0 0 1 1],...
        'bordertype','etchedin',...
        'Tag','MainPanel',...
        'Parent',f1);
    tabgp = uitabgroup('Units','normalized',...
        'Position',[0 0 1 1],...
        'Parent',mP,...
        'Tag','TabGroup');
    tab2 = uitab('Parent',tabgp,...
        'Units','normalized',...
        'Title','Synthesis',...
        'BackgroundColor',bg_color,...
        'Tag','SecondTab');
    tab3 = uitab('Parent',tabgp,...
        'Units','normalized',...
        'Title','Sequence-Mean',...
        'BackgroundColor',bg_color,...
        'Tag','ThirdTab');
    tab4 = uitab('Parent',tabgp,...
        'Units','normalized',...
        'Title','Sequence-Median',...
        'BackgroundColor',bg_color,...
        'Tag','FourthTab');


    % SecondTab
    channel_main_raw = strcat('LFP-',channel_id);
    % channel_main_filt = sprintf('LFP-%s_%s',band_name,channel_id);
    ind_main_raw = strcmp(all_labels_channels,channel_main_raw);
    Yraw_evt_ = squeeze(Y0q_evt_(ind_main_raw,:,:));
    Yraw_evt = Yraw_evt_(:);

    ax1 = axes('Parent',tab2,'Position',[.05 .7 .25 .25]);
    hold(ax1,'on');
    for i=1:n_events
        l=line('XData',t_bins_lfp,'YData',Yraw_evt_(:,i),'Color','k','LineWidth',.1,'Parent',ax1);
        l.Color(4)=.5;
    end
    line('XData',t_bins_lfp,'YData',mean(Yraw_evt_,2,'omitnan'),'Color','r','LineWidth',2,'Parent',ax1);
    ax1.Title.String = sprintf('Raw LFP [N=%d][%.2fHz]',n_events,density_events);
    n_iqr = 4;
    data_iqr = Yraw_evt(~isnan(Yraw_evt));
    if isempty(data_iqr)
        return;
    end
    ax1.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax1.XLim = [-.1 .1];

    % ax2 = subplot(323,'parent',tab2);
    ax2 = axes('Parent',tab2,'Position',[.05 .4 .25 .25]);
    hold(ax2,'on');
    for i=1:n_events
        l=line('XData',t_bins_lfp,'YData',Y1q_evt_(:,i),'Color',[.5 .5 .5],'LineWidth',.1,'Parent',ax2);
        l.Color(4)=.5;
    end
    line('XData',t_bins_lfp,'YData',mean(Y1q_evt_,2,'omitnan'),'Color','r','Parent',ax2);
    ax2.Title.String = 'Filtered trace LFP';
    n_iqr= 20;
    data_iqr = Y1q_evt_(~isnan(Y1q_evt_));
    ax2.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax2.XLim = ax1.XLim;

    % Spectrogram
    % ax3 = subplot(325,'parent',tab2);
    ax3 = axes('Parent',tab2,'Position',[.05 .05 .25 .3]);
    hold(ax3,'on');
    imagesc('XData',t_bins_lfp,'YData',freqdom,'CData',Cdata_mean,'HitTest','off','Parent',ax3);

    n_iqr= 2;
    data_iqr = Cdata_mean(~isnan(Cdata_mean));
    ax3.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax3.YLim = [freqdom(1),freqdom(end)];
    % ax3.XLim = [t_bins_lfp(1),t_bins_lfp(end)];
    ax3.XLim = ax1.XLim;
    ax3.Title.String = 'Mean Spectrogram';

    % fUS
    % ax4 = subplot(122,'parent',tab2);
    ax4 = axes('Parent',tab2,'Position',[.375 .05 .25 .9]);
    hold(ax4,'on');
    Y2q_evt_mean = mean(Y2q_evt_normalized,3,'omitnan');
    imagesc('XData',t_bins_fus,'YData',1:length(all_labels_regions),'CData',Y2q_evt_mean,'HitTest','off','Parent',ax4);
    n_iqr = 6;
    data_iqr = Y2q_evt_mean(~isnan(Y2q_evt_mean));
    % ax4.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax4.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax4.YLim = [.5 length(all_labels_regions)+.5];
    ax4.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax4.YTick = 1:length(all_labels_regions);
    ax4.YTickLabel = all_labels_regions;
    ax4.Title.String = 'Mean Regions fUS';
    % ax4.FontSize = 8;
    colorbar(ax4,'eastoutside');

    ax5 = axes('Parent',tab2,'Position',[.7 .05 .25 .9]);
    hold(ax5,'on');
    Y2q_evt_median = median(Y2q_evt_normalized,3,'omitnan');
    imagesc('XData',t_bins_fus,'YData',1:length(all_labels_regions),'CData',Y2q_evt_median,'HitTest','off','Parent',ax5);
    n_iqr = 6;
    data_iqr = Y2q_evt_median(~isnan(Y2q_evt_median));
    % ax5.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax5.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax5.YLim = [.5 length(all_labels_regions)+.5];
    ax5.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax5.YTick = 1:length(all_labels_regions);
    ax5.YTickLabel = all_labels_regions;
    ax5.Title.String = 'Median Regions fUS';
    % ax5.FontSize = 8;
    colorbar(ax5,'eastoutside');


    f2_axes=[ax1;ax2;ax3;ax4];
    fprintf('>> Process 2/6 done [%s].\n',tab2.Title);


    % ThirdTab
    f3_axes=[];
    n_iqr= 3;
    data_iqr = Y3q_evt_mean_reshaped(~isnan(Y3q_evt_mean_reshaped));
    temp = 1:length(t_bins_fus);
    index_t_bins_fus = temp(1:end-1);%(1:2:end-1);

    for i=index_t_bins_fus

        n=ceil(sqrt(length(index_t_bins_fus)));
        ax = subplot(n,n,i,'parent',tab3);
        hold(ax,'on');
        imagesc(Y3q_evt_mean_reshaped(:,:,i),'Parent',ax);

        %     ax.Title.String = sprintf('t= %.1f s',t_bins_fus(i));
        %     ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
        ax.CLim = [-5,10];
        ax.XLim = [.5 size_im(2)+.5];
        ax.YLim = [.5 size_im(1)+.5];

        set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
        ax.YDir = 'reverse';
        if i == index_t_bins_fus(end)
            cbar = colorbar(ax,'eastoutside');
            cbar.Position = [.94 .01 .01 .15];
        end
        f3_axes=[f3_axes;ax];
    end

    n_col = 10 ;
    %     % comment when done
    %     n_col = 5 ;
    n_rows = ceil(length(f3_axes)/n_col);
    eps1=.01;
    eps2=.01;
    for i=1:length(f3_axes)
        f3_axes(i).Position = get_position(n_rows,n_col,i,[.01,.07,.01;.01,.01,.02]);
    end
    fprintf('>> Process 5/6 done [%s].\n',tab3.Title);


    % FourthTab
    f4_axes = [];
    n_iqr = 3;
    data_iqr = Y3q_evt_median_reshaped(~isnan(Y3q_evt_median_reshaped));
    temp=1:length(t_bins_fus);
    index_t_bins_fus = temp(1:end-1);
    for i=index_t_bins_fus
        n=ceil(sqrt(length(index_t_bins_fus)));
        ax = subplot(n,n,i,'parent',tab4);
        hold(ax,'on');
        imagesc(Y3q_evt_median_reshaped(:,:,i),'Parent',ax);
        %         ax.Title.String = sprintf('t= %.1f s',t_bins_fus(i));
        %     ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
        ax.CLim = [-5,10];
        ax.XLim = [.5 size_im(2)+.5];
        ax.YLim = [.5 size_im(1)+.5];
        set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
        ax.YDir = 'reverse';
        if i == index_t_bins_fus(end)
            cbar = colorbar(ax,'eastoutside');
            cbar.Position = [.94 .01 .01 .15];
        end
        f4_axes=[f4_axes;ax];
    end
    n_col = 10 ;
    n_rows = ceil(length(f4_axes)/n_col);
    eps1=.01;
    eps2=.01;
    for i=1:length(f4_axes)
        f4_axes(i).Position = get_position(n_rows,n_col,i,[.01,.07,.01;.01,.01,.02]);
    end
    fprintf('>> Process 6/6 done [%s].\n',tab4.Title);


    % Saving Tabs
    if flag_save_figure
        save_dir = fullfile(DIR_FIG,'PeriEvent_Sequence',recording_name);
        if ~isfolder(save_dir)
            mkdir(save_dir);
        end

        tabgp.SelectedTab = tab2;
        saveas(f1,fullfile(save_dir,strcat(f1.Name,'_',tab2.Title,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('Tab %s saved in [%s].\n',tab2.Title,save_dir);

        tabgp.SelectedTab = tab3;
        saveas(f1,fullfile(save_dir,strcat(f1.Name,'_',tab3.Title,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('Tab %s saved in [%s].\n',tab3.Title,save_dir);

        tabgp.SelectedTab = tab4;
        saveas(f1,fullfile(save_dir,strcat(f1.Name,'_',tab4.Title,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        fprintf('Tab %s saved in [%s].\n',tab4.Title,save_dir);

    end


    % Saving Movie
    if flag_save_movie

        save_dir = fullfile(DIR_FIG,'PeriEvent_Sequence',recording_name);
        if ~isfolder(save_dir)
            mkdir(save_dir);
        end
        work_dir = fullfile(save_dir,'Frames');
        if isfolder(work_dir)
            rmdir(work_dir,'s');
        end
        mkdir(work_dir);

        f2 = figure('Units','normalized');
        f2.Position=[0.1    0.4    0.4    0.25];
        t = uicontrol(f2,'Style','text','BackgroundColor','w','FontSize',16,'FontWeight','bold','Units','normalized','Position',[.25 .9 .5 .1],'Parent',f2);

        for i = index_t_bins_fus
            t.String = sprintf('Time from Event Peak = %.1f s',t_bins_fus(i));

            ax2 = copyobj(f3_axes(i),f2);
            ax2.Title.String = 'Mean';
            ax2.Position = [.005 .05 .49 .8];
            colorbar(ax2,'eastoutside');
            if ~isempty(data_atlas)
                l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
                    'LineWidth',1,'Color','r','Parent',ax2);
                l.Color(4) = .25;
            end
            ax2 = copyobj(f4_axes(i),f2);
            ax2.Title.String = 'Median';
            ax2.Position = [.505 .05 .49 .8];
            colorbar(ax2,'eastoutside');
            if ~isempty(data_atlas)
                l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
                    'LineWidth',1,'Color','r','Parent',ax2);
                l.Color(4) = .25;
            end

            pic_name = sprintf(strcat('%s_Event-Imaging_%03d'),recording_name,i);
            saveas(f2,fullfile(work_dir,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
            delete(findobj(f2,'Type','Axes'));

        end

        close(f2);
        video_name = sprintf(strcat('%s_Event-Imaging'),f1.Name);
        save_video(work_dir,save_dir,video_name);
        % Removing frame directory
        rmdir(work_dir,'s');

    end
end

f1.UserData.success = true;

end
