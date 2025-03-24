function f1 = figure_PeriEventSequence(handles,val,str_regions,str_traces)
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

% Loading nconfig
nc_channnels = [];
if isfile(fullfile(DIR_SAVE,recording_name,'Nconfig.mat'))
    data_nconfig = load(fullfile(DIR_SAVE,recording_name,'Nconfig.mat'));
    nc_channnels = data_nconfig.channel_id(strcmp(data_nconfig.channel_type,'LFP'));
end

% Processed File Selection
pe_dir = fullfile(DIR_STATS,'PeriEvent_Sequence',recording_name);
d_pe = dir(fullfile(pe_dir,'*Sequence.mat'));
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

        % batch_csv_eventname = {'[Ripples-Abs-All]'};
        batch_csv_eventname = {'[Ripples-Abs-All]';'[Ripples-Sqrt-All]';'[Ripples-Sqrt-Fast]';'[Ripples-Sqrt-Long]';'[Ripples-Sqrt-Strong]'};
        % batch_csv_eventname = {'[[Pyr]Ripples-Abs-Fast]';'[[Pyr]Ripples-Abs-Long]';'[[Pyr]Ripples-Abs-Strong]';...
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


% Display Parameters
% markersize = 3;
% face_color = [0.9300    0.6900    0.1900];
% face_alpha = .5 ;
% g_colors = get_colors(n_channels+1,'jet');
offset_stepping = 250;                 % offset between channels (uV)
flag_load_large = false;                    % Loading all events
sequence_display_reg = 'median';            % Displaying region sequence
sequence_display_vox = 'median';            % Displaying voxel sequence
% Flag save
flag_save_figure = 0;           % Save Figure
flag_save_movie = 1;            % Save Movie



% Building Figure and Plotting
f1 = figure;
f1.UserData.success = false;

f1.Name = sprintf(strcat('[%s]%s-PeriEventSequence'),atlas_fullname,strrep(recording_name,'_nlab',''));
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

all_pe_names = {d_pe(ind_pe).name}';
all_tabs = gobjects(length(all_pe_names),1);

for kk = 1:length(all_pe_names)

    % Processed File Loading
    pe_filename = d_pe(ind_pe(kk)).name;
    pe_filename_large = strrep(pe_filename,'Sequence','AllEvents');

    fprintf('Loading Data [%s] ...',pe_filename);
    data_pe_small = load(fullfile(pe_dir,pe_filename),'Params',...
        'all_labels_channels','t_bins_lfp',...
        'Y0q_evt_mean','Y0q_evt_median','Y0q_evt_std',...
        'Y1q_evt_mean','Y1q_evt_median','Y1q_evt_std',...
        'freqdom','Cdata_mean',...
        'all_labels_regions','t_bins_fus',...
        'Y2q_evt_mean','Y2q_evt_median',...
        'Y3q_evt_mean_reshaped','Y3q_evt_median_reshaped');
    fprintf(' done.\n');


    if flag_load_large
        fprintf('Loading Data [%s] ...',pe_filename_large);
        data_pe_large = load(fullfile(pe_dir,pe_filename_large),'Params',...
            'all_labels_channels','t_bins_lfp',...
            'Xq_evt_lfp_','Y0q_evt_','Y1q_evt_',...
            'freqdom','Xq_evt_spectro_','Cdata_evt_int',...
            'all_labels_regions','t_bins_fus',...
            'Xq_evt_fus_','Y2q_evt_normalized',...
            'Y3q_evt_normalized');
        fprintf(' done.\n');

        % Re-building from large file
        Xq_evt_lfp_ = data_pe_large.Xq_evt_lfp_;
        Xq_evt_fus_ = data_pe_large.Xq_evt_fus_;
        Xq_evt_spectro_ = data_pe_large.Xq_evt_spectro_;
        Cdata_evt_ = double(data_pe_large.Cdata_evt_int/data_pe_large.Params.save_ratio_spectro);
        Y2q_evt_normalized = data_pe_large.Y2q_evt_normalized;
        Y3q_evt_normalized = data_pe_large.Y3q_evt_normalized;
        %         Y3q_evt_normalized = double(data_pe_large.Y3q_evt_normalized_int/data_pe_large.Params.save_ratio_fus);
        %         Y2q_evt_mean = mean(Y2q_evt_normalized,3,'omitnan');
        %         Y2q_evt_median = median(Y2q_evt_normalized,3,'omitnan');
        %         Y3q_evt_mean = mean(Y3q_evt_normalized,3,'omitnan');
        %         Y3q_evt_mean_reshaped = reshape(Y3q_evt_mean,[data_pe_large.Params.size_im(1) data_pe_large.Params.size_im(2) length(data_pe_large.t_bins_fus)]);
        %         Y3q_evt_median = median(Y3q_evt_normalized,3,'omitnan');
        %         Y3q_evt_median_reshaped = reshape(Y3q_evt_median,[data_pe_large.Params.size_im(1) data_pe_large.Params.size_im(2) length(data_pe_large.t_bins_fus)]);
        %         Cdata_mean = mean(Cdata_evt_,3,'omitnan');
    end


    % Params
    recording_name = data_pe_small.Params.recording_name;
    timegroup = data_pe_small.Params.timegroup;
    event_name = data_pe_small.Params.event_name;
    band_name = data_pe_small.Params.band_name;
    timegroup_duration = data_pe_small.Params.timegroup_duration;
    EventHeader = data_pe_small.Params.EventHeader;
    MetaData = data_pe_small.Params.MetaData;
    events = data_pe_small.Params.events;
    t_events = data_pe_small.Params.t_events;
    n_events = data_pe_small.Params.n_events;
    density_events = data_pe_small.Params.density_events;
    channel_id = data_pe_small.Params.channel_id;
    t_baseline_start = data_pe_small.Params.t_baseline_start;
    t_baseline_end = data_pe_small.Params.t_baseline_end;
    t_before = data_pe_small.Params.t_before;
    t_after = data_pe_small.Params.t_after;
    sampling_fus = data_pe_small.Params.sampling_fus;
    sampling_lfp = data_pe_small.Params.sampling_lfp;
    size_im = data_pe_small.Params.size_im;
    save_ratio_spectro = data_pe_small.Params.save_ratio_spectro;
    save_ratio_fus = data_pe_small.Params.save_ratio_fus;


    all_labels_channels = data_pe_small.all_labels_channels;
    n_channels = length(all_labels_channels);
    freqdom = data_pe_small.freqdom;
    t_bins_lfp = data_pe_small.t_bins_lfp;
    all_labels_regions = data_pe_small.all_labels_regions;
    t_bins_fus = data_pe_small.t_bins_fus;


    % Direct Loading from light file
    Y0q_evt_mean = data_pe_small.Y0q_evt_mean;
    %     Y0q_evt_median = data_pe_small.Y0q_evt_median;
    Y0q_evt_std = data_pe_small.Y0q_evt_std;
    Y1q_evt_mean = data_pe_small.Y1q_evt_mean;
    %     Y1q_evt_median = data_pe_small.Y1q_evt_median;
    Y1q_evt_std = data_pe_small.Y1q_evt_std;
    Cdata_mean = data_pe_small.Cdata_mean;
    Y2q_evt_mean = data_pe_small.Y2q_evt_mean;
    Y2q_evt_median = data_pe_small.Y2q_evt_median;
    Y3q_evt_mean_reshaped = data_pe_small.Y3q_evt_mean_reshaped;
    Y3q_evt_median_reshaped = data_pe_small.Y3q_evt_median_reshaped;

    % Main Tab and Panels
    tab = uitab('Parent',tabgp,...
        'Units','normalized',...
        'BackgroundColor',bg_color,...
        'Tag','MainTab');
    all_tabs(kk) = tab;
    tab.Title = sprintf(strcat('[%s][%s]'),event_name,timegroup);
    panel1 = uipanel('Units','normalized',...
        'Position',[0 0 .33 1],...
        'bordertype','etchedin',...
        'Tag','Panel1',...
        'Parent',tab);
    panel2 = uipanel('Units','normalized',...
        'Position',[.33 .75 .67 .25],...
        'bordertype','etchedin',...
        'Tag','Panel2',...
        'Parent',tab);
    panel3 = uipanel('Units','normalized',...
        'Position',[.33 0 .67 .75],...
        'bordertype','etchedin',...
        'Tag','Panel3',...
        'Parent',tab);

    % channel_main_raw = strcat('LFP-',channel_id);
    % channel_main_filt = sprintf('LFP-%s_%s',band_name,channel_id);
    % ind_main_raw = strcmp(all_labels_channels,channel_main_raw);

    % Panel 1
    ax1 = axes('Parent',panel1,'Position',[.075 .05 .9 .9]);
    hold(ax1,'on');
    yTickLabel = cell(n_channels,1);

    for j=1:n_channels

        this_channel_name = strrep(char(all_labels_channels(j)),'LFP-','');
        channel_position = find(strcmp(nc_channnels,this_channel_name)==1);
        if ~isempty(channel_position)
            y_offset = offset_stepping*(n_channels+1-channel_position);
            yTickLabel(n_channels+1-channel_position) = {this_channel_name};
        else
            y_offset = n_channels;
        end
        %         for i=1:n_events
        %             l=line('XData',t_bins_lfp,'YData',this_Yraw_evt_(:,i)+y_offset,'Color','k','LineWidth',.1,'Parent',ax1);
        %             l.Color(4)=.5;
        %         end
        y_data = (Y0q_evt_mean(j,:)+y_offset)';
        y_std = Y0q_evt_std(j,:)';
        % y_sem = (Y0q_evt_std(j,:))'/sqrt(n_events);

        % Error Patch
        % px_data = [t_bins_lfp;flipud(t_bins_lfp)];
        % py_data = [y_data+y_std;flipud(y_data-y_std)];
        % py_data = [y_data+y_sem;flipud(y_data-y_sem)];
        % patch('XData',px_data,'YData',py_data,'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax1,'FaceAlpha',.5);
        % Error Line
        line('XData',t_bins_lfp,'YData',y_data+y_std,'Color',[.5 .5 .5],'LineStyle',':','LineWidth',1,'Parent',ax1);
        line('XData',t_bins_lfp,'YData',y_data-y_std,'Color',[.5 .5 .5],'LineStyle',':','LineWidth',1,'Parent',ax1);
        % Main Line
        l = line('XData',t_bins_lfp,'YData',y_data,'Color','k','LineWidth',1,'Parent',ax1);
        if strcmp(this_channel_name,channel_id)
            l.Color = 'r';
        end
    end
    ax1.Title.String = sprintf('All LFP channels [N=%d][%.2f events/s]',n_events,density_events);
    ax1.YLim = offset_stepping*[-1;length(nc_channnels)+1];
    ax1.XLim = [-.1 .1];
    ax1.XLabel.String = 'time(sec)';
    ax1.YTickLabel = yTickLabel;
    ax1.YTick = offset_stepping*(1:n_channels);
    % ax1.YDir = 'reverse';
    ax1.TickLength(2) = 0;
    % ax1.YTickLabelRotation = 90;
    ax1.Title.FontSize = 14;


    % Panel 2
    ax2 = axes('Parent',panel2,'Position',[.05 .1 .275 .85]);
    %     hold(ax2,'on');
    %     for i=1:n_events
    %         l=line('XData',t_bins_lfp,'YData',Y1q_evt_(:,i),'Color',[.5 .5 .5],'LineWidth',.1,'Parent',ax2);
    %         l.Color(4)=.5;
    %     end

    % Error Patch
    px_data = [t_bins_lfp;flipud(t_bins_lfp)];
    py_data = [Y1q_evt_mean+Y1q_evt_std;flipud(Y1q_evt_mean-Y1q_evt_std)];
    patch('XData',px_data,'YData',py_data,'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax2,'FaceAlpha',.5);
    % % Error Line
    % line('XData',t_bins_lfp,'YData',Y1q_evt_mean+Y1q_evt_std,'Color',[.5 .5 .5],'LineStyle','-','Parent',ax2);
    % line('XData',t_bins_lfp,'YData',Y1q_evt_mean-Y1q_evt_std,'Color',[.5 .5 .5],'LineStyle','-','Parent',ax2);
    % Main Line
    line('XData',t_bins_lfp,'YData',Y1q_evt_mean,'Color','r','Parent',ax2);
    ax2.Title.String = 'Filtered trace LFP';
    n_iqr = 200;
    data_iqr = Y1q_evt_mean(~isnan(Y1q_evt_mean));
    ax2.YLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax2.XLim = ax1.XLim;

    % Spectrogram
    ax3 = axes('Parent',panel2,'Position',[.35 .1 .275 .85]);
    %     hold(ax3,'on');
    imagesc('XData',t_bins_lfp,'YData',freqdom,'CData',Cdata_mean,'HitTest','off','Parent',ax3);
    n_iqr= 2;
    data_iqr = Cdata_mean(~isnan(Cdata_mean));
    ax3.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    ax3.YLim = [freqdom(1),freqdom(end)];
    % ax3.XLim = [t_bins_lfp(1),t_bins_lfp(end)];
    ax3.XLim = ax1.XLim;
    ax3.Title.String = 'Mean Spectrogram';

    % fUS
    ax4 = axes('Parent',panel2,'Position',[.7 .1 .275 .85]);
    hold(ax4,'on');
    switch sequence_display_reg
        case 'mean'
            cdata = Y2q_evt_mean;
        case 'median'
            cdata = Y2q_evt_median;
    end
    imagesc('XData',t_bins_fus,'YData',1:length(all_labels_regions),'CData',cdata,'HitTest','off','Parent',ax4);
    % data_iqr = cdata(~isnan(cdata));
    % n_iqr = 4;
    % ax4.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    % ax4.CLim = [median(data_iqr(:))-2,median(data_iqr(:))+5];
    ax4.YLim = [.5 length(all_labels_regions)+.5];
    ax4.XLim = [t_bins_fus(1),t_bins_fus(end)];
    ax4.YTick = 1:length(all_labels_regions);
    ax4.YTickLabel = all_labels_regions;
    ax4.Title.String = 'Regions fUS';
    % ax4.FontSize = 8;
    colorbar(ax4,'eastoutside');


    % Panel 3
    temp = 1:length(t_bins_fus);
    index_t_bins_fus = temp(1:end-1); %(1:2:end-1);

    n_col = 5 ;
    n_rows = ceil(length(index_t_bins_fus)/n_col);
    w_margin_1 = .02; % left margin
    w_margin_2 = .02; % right margin
    w_eps = .01;      % horizontal spacing
    h_margin_1 = .02; % bottom margin
    h_margin_2 = .02; % top margin
    h_eps = .01;      % vertical spacing
    margins = [w_margin_1,w_margin_2,w_eps;h_margin_1,h_margin_2,h_eps];

    switch sequence_display_vox
        case 'mean'
            cdata2 = Y3q_evt_mean_reshaped;
        case 'median'
            cdata2 = Y3q_evt_median_reshaped;
    end
    n_iqr = 3;
    data_iqr = cdata2(~isnan(cdata2));

    all_axes = gobjects(length(index_t_bins_fus),1);
    for i = index_t_bins_fus
        ax = axes('Parent',panel3);
        ax.Position = get_position(n_rows,n_col,i,margins);
        hold(ax,'on');
        imagesc('CData',cdata2(:,:,i),'Parent',ax);
        t = text(0,5,sprintf('t=%0.1fs',t_bins_fus(i)),'Parent',ax);
        t.FontSize = 16;
        % t.FontWeight = 'bold';
        t.BackgroundColor = 'w';

        % ax.Title.String = sprintf('t= %.1f s',t_bins_fus(i));
        ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
        % ax.CLim = [-5,10];
        ax.XLim = [.5 size_im(2)+.5];
        ax.YLim = [.5 size_im(1)+.5];
        set(ax,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
        ax.YDir = 'reverse';
        if i == index_t_bins_fus(end)
            cbar = colorbar(ax,'eastoutside');
            %             cbar.Position = [.94 .01 .01 .15];
        end
        all_axes(i) = ax;
    end
    panel3.UserData.all_axes = all_axes;
end

% Saving Tabs
if flag_save_figure
    save_dir = fullfile(DIR_FIG,'PeriEvent_Sequence',recording_name);
    if ~isfolder(save_dir)
        mkdir(save_dir);
    end

    for i = 1: length(all_tabs)
        tab = all_tabs(i);
        tabgp.SelectedTab = tab;
        pic_name = strcat(tab.Title,recording_name,'_PeriEventSequence',GTraces.ImageSaveExtension);
        saveas(f1,fullfile(save_dir,pic_name),GTraces.ImageSaveFormat);
        fprintf('Tab %s saved in [%s].\n',tab.Title,save_dir);
    end

end

% Saving Movie
n_col = 5 ;
n_rows = ceil(length(all_tabs)/n_col);
w_margin_1 = .02; % left margin
w_margin_2 = .02; % right margin
w_eps = .01;      % horizontal spacing
h_margin_1 = .02; % bottom margin
h_margin_2 = .15; % top margin
h_eps = .01;      % vertical spacing
margins = [w_margin_1,w_margin_2,w_eps;h_margin_1,h_margin_2,h_eps];


% Save Movie
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
    f2.OuterPosition = [0    0.4    1    0.4];

    for i = index_t_bins_fus
        delete(f2.Children);

        t = uicontrol(f2,'Style','text','BackgroundColor','w','FontSize',16,'FontWeight','bold',...
            'Units','normalized','Position',[.25 .9 .5 .1],'Parent',f2);
        t.String = sprintf('Time from Event Peak = %.1f s',t_bins_fus(i));

        for j = 1:length(all_tabs)
            tab = all_tabs(j);
            panel3 = findobj(tab,'Tag','Panel3');
            ax = copyobj(panel3.UserData.all_axes(i),f2);
            ax.Position = get_position(n_rows,n_col,j,margins);
            ax.Title.String = tab.Title;
            colormap(ax,"jet");
            ax.CLim = [-2.5,5];
            % ax.CLim = [-5,10];

            colorbar(ax,'eastoutside');
            if ~isempty(data_atlas)
                l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
                    'LineWidth',1,'Color','r','Parent',ax);
                l.Color(4) = .25;
            end
        end

        pic_name = sprintf(strcat('%s_%03d'),recording_name,i);
        saveas(f2,fullfile(work_dir,strcat(pic_name,GTraces.ImageSaveExtension)),GTraces.ImageSaveFormat);
        delete(findobj(f2,'Type','Axes'));

    end

    close(f2);
    video_name = sprintf(strcat('%s-2'),f1.Name);
    save_video(work_dir,save_dir,video_name);
    % Removing frame directory
    rmdir(work_dir,'s');

end

f1.UserData.success = true;

end
