function generate_movie_fusephysvideo(recording_name,t_start,t_end)

% Script fus-ephys-video
% Article Guyon et al 2026

% path to NLab_DATA folder
seed_recording = '/Users/tonio/Documents/Antoine-fUSDataset/NEUROLAB/NLab_DATA';

if nargin < 1
    % Default recording_name
    recording_name = '20240820_K1656_001_E_nlab';
end

path_to_recording = fullfile(seed_recording,recording_name);
% Loading Time Reference
data_tr = load(fullfile(path_to_recording,'Time_Reference.mat'));

if nargin < 2
    % Default t_start
    %     t_start = data_tr.time_ref.Y(1);
    t_start = 34*60+15;
end
if nargin < 3
    % Default t_end
    %     t_end = data_tr.time_ref.Y(end);
    t_end = 38*60+15;
end
[~,im_start] = min((data_tr.time_ref.Y-t_start).^2);
[~,im_end] = min((data_tr.time_ref.Y-t_end).^2);


% Loading Time Groups
if exist(fullfile(path_to_recording,'Time_Groups.mat'),'file')
    tg_data = load(fullfile(path_to_recording,'Time_Groups.mat'),...
        'TimeGroups_name','TimeGroups_frames','TimeGroups_duration','TimeGroups_S');
    flag_group = 1;
    tg_cell = tg_data.TimeGroups_name;

    % Excluding unwanted Time Groups
    ind_keep_tg = ~contains(tg_cell,["BASELINE","TEST","REM-SHORT","REM-LONG"]);
    tg_cell = tg_cell(ind_keep_tg==1);
    TimeGroups_S = tg_data.TimeGroups_S(ind_keep_tg==1,:);
else
    flag_group = 0;
    tg_cell = [];
    TimeGroups_S = [];
    tg_data.TimeGroups_name = [];
    tg_data.TimeGroups_frames = [];
    tg_data.TimeGroups_duration = [];
    tg_data.TimeGroups_S = [];
end

% Loading Sleep Scoring
if exist(fullfile(path_to_recording,'Sleep_Scoring.mat'),'file')
    ss_data = load(fullfile(path_to_recording,'Sleep_Scoring.mat'),...
        'channel_lfp','channel_acc','channel_emg');
else
    ss_data = [];
end
% f.UserData.ss_data = ss_data;


% Loading Atlas
if exist(fullfile(path_to_recording,'Atlas.mat'),'file')
    atlas_data = load(fullfile(path_to_recording,'Atlas.mat'));
    if ~isempty(atlas_data.AP_mm)
        atlas_name = sprintf('Coronal-AP%.2fmm',atlas_data.AP_mm);
    elseif ~isempty(atlas_data.ML_mm)
        atlas_name = sprintf('Sagittal-ML%.2fmm',atlas_data.ML_mm);
    else
        atlas_name = 'Unregistered';
    end
else
    atlas_data = [];
    atlas_name = 'Unregistered';
end


% Collecting spike data
file_spike_mat = 'amplifier.spikes.cellinfo.mat';
data_spike = load(fullfile(path_to_recording,file_spike_mat));
fprintf('Spike Data loaded [%s].\n',fullfile(path_to_recording,file_spike_mat));
nb_units = length(data_spike.spikes.ids);
t_spikes = data_spike.spikes.times;


% Collecting NConfig
if isfile(fullfile(path_to_recording,'Nconfig.mat'))
    d_ncf = load(fullfile(path_to_recording,'Nconfig.mat'));
    ind_channel = d_ncf.ind_channel(:);
    ind_channel_diff = d_ncf.ind_channel_diff(:);
    temp = [];
    for k =1:length(ind_channel)
        temp = [temp;{sprintf('%d-%d',ind_channel(k),ind_channel_diff(k))}];
    end
    temp = strrep(temp,'-NaN','');
    temp = strrep(temp,'NaN','');
    channel_id = d_ncf.channel_id(:);
    channel_type = d_ncf.channel_type(:);
    channel_list = d_ncf.channel_list(:);
    D = [temp,channel_id,channel_type,channel_list];
else
    % default NConfig
    d_ncf = [];
    D=cell(39,4);
    for j=1:32
        D(j,:)={sprintf('%d',j),sprintf('%d',j),'LFP',sprintf('LFP-%03d',j)};
    end
    for j=33:35
        D(j,:)={sprintf('%d',j),sprintf('%d',j),'ACC',sprintf('ACC-%03d',j)};
    end
    D(36,:)={sprintf('%d',j),sprintf('%d',36),'TEMP',sprintf('TEMP-%03d',36)};
    for j=37:39
        D(j,:)={sprintf('%d',j),sprintf('%d',j),'GYR',sprintf('GYR-%03d',j)};
    end
end
D_lfp = D(strcmp(D(:,3),'LFP'),:);
D_acc = D(strcmp(D(:,3),'ACC'),:);


% Collecting LFP data
nb_channels = size(D_lfp,1);
file_lfp = sprintf('LFP_%s.mat',char(D_lfp(1,2)));
data_lfp = load(fullfile(path_to_recording,'Sources_LFP',file_lfp),'x_start','f','x_end');
X = data_lfp.x_start:data_lfp.f:data_lfp.x_end;
Ydata = NaN(nb_channels,length(X));

for i = 1:length(D_lfp)
    file_lfp = sprintf('LFP_%s.mat',char(D_lfp(i,2)));
    if isfile(fullfile(path_to_recording,'Sources_LFP',file_lfp))
        data_lfp = load(fullfile(path_to_recording,'Sources_LFP',file_lfp),'Y');
        Ydata(i,:) = data_lfp.Y;
        fprintf('LFP Data loaded [%s].\n',file_lfp);
    end
end


% Collecting video data
file_video = 'Video.mat';
data_video = load(fullfile(path_to_recording,file_video));
fprintf('Video Data loaded [%s].\n',fullfile(path_to_recording,file_video));


% Collecting Doppler data
file_doppler = 'Doppler.mat';
data_doppler = load(fullfile(path_to_recording,file_doppler));
data_doppler.Doppler_smoothed = NaN(size(data_doppler.Doppler_film,1),size(data_doppler.Doppler_film,2),size(data_doppler.Doppler_film,3));
fprintf('Doppler Data loaded [%s].\n',fullfile(path_to_recording,file_doppler));

% Smooting Movie
t_gauss = 3; % seconds
delta =  data_tr.time_ref.Y(2)-data_tr.time_ref.Y(1);
w = gausswin(round(2*t_gauss/delta));
w = w/sum(w);
% Smoothing Doopler
for i=1:size(data_doppler.Doppler_film,1)
    for j=1:size(data_doppler.Doppler_film,2)
        y_smooth =  squeeze(data_doppler.Doppler_film(i,j,:));
        y_conv = nanconv(y_smooth,w,'same');
        data_doppler.Doppler_smoothed(i,j,:) = permute(y_conv',[3,2,1]);
    end
    fprintf('Smoothing Doppler [%.1f s] - %d/%d\n',t_gauss,i,size(data_doppler.Doppler_film,1));
end
% Overwrite
data_doppler.Doppler_film = data_doppler.Doppler_smoothed;


% Building figure
f = figure('Name',sprintf('fUS-EEG-Video[%s]',recording_name),...
    'Units','normalized','MenuBar','none','Toolbar','none');
colormap(f,'parula');
bigfontsize = 18;
smallfontsize = 12;


% fUSi Axis
ax0 = axes('Parent',f,'TickLength',[0 0],'FontSize',bigfontsize);
% ax0.XLim = [t_start t_end];
ax0.XLim = [data_tr.time_ref.Y(1) data_tr.time_ref.Y(end)];
set(ax0,'XTick',[],'XTickLabel',[]);
set(ax0,'YTick',[],'YTickLabel',[]);
ax0.XLabel.String = [];

Ymean = squeeze(nanmean(nanmean(data_doppler.Doppler_film)));
nb_frames = length(Ymean);
c1 = min(Ymean,[],'omitnan');
c2 = max(Ymean,[],'omitnan');

% Time Patches
load('Preferences.mat','GColors','GTraces');
for i =1:length(tg_data.TimeGroups_name)
    name = tg_data.TimeGroups_name(i);
    ind_color = find(strcmp({GColors.TimeGroups(:).Name}',name)==1);
    patch_color = GColors.TimeGroups(ind_color).Color;
    patch_alpha = GColors.TimeGroups(ind_color).Transparency;
%     frames = tg_data.TimeGroups_frames(i);
%     dur = tg_data.TimeGroups_duration(i);
    n_patches = length(tg_data.TimeGroups_S(i).Name);
    tts = tg_data.TimeGroups_S(i).TimeTags_strings;
    for j = 1:n_patches
        a = datenum(tts(j,1));
        b = datenum(tts(j,2));
        px_data = [a-floor(a),b-floor(b),b-floor(b),a-floor(a)]*24*3600;
        patch('XData',px_data,'YData',[c1 c1 c2 c2],'Parent',ax0,...
            'EdgeColor','none','FaceColor',patch_color,'FaceAlpha',patch_alpha);
    end
end

% Mean Line with cursor
line('XData',data_tr.time_ref.Y,'YData',Ymean,'Parent',ax0);
ax0.YLim = [c1 c2];
ax0.Title.String = 'CBV Whole-brain (1 hour)';
ax0.Title.FontSize = bigfontsize;
ax0.YLabel.String = 'CBV Change (%)';
ax0_cursor = line('XData',[NaN NaN],'YData',[c1 c2],'Parent',ax0,'Color','r','LineWidth',2);



% fUSi Frame
ax1 = axes('Parent',f,...
    'CLimMode','manual',...
    'TickLength',[0 0],...
    'FontSize',bigfontsize);
fus_frame = imagesc(NaN(size(data_doppler.Doppler_film,1),size(data_doppler.Doppler_film,2)),'Parent',ax1,'Tag','fUSFrame');
ax1.CLim = [-20;80];
ax1.Title.String = 'Doppler film';
ax1.Title.FontSize = bigfontsize;

set(ax1,'XTickLabel','','XTick','','YTick','','YTickLabel','');
colormap(ax1,'hot');
% Colorbar
cbar = colorbar(ax1,'Parent',f);
cbar.FontSize = smallfontsize;
cbar.Position = [.03 .425 .015 .425];

% Atlas
l=line('XData',atlas_data.line_x,'YData',atlas_data.line_z,'Tag','AtlasMask','Parent',ax1,...
    'Color','w','LineWidth',.5);
l.Color(4)=.5;


% Video
ax2 = axes('Parent',f,...
    'CLimMode','manual',...
    'TickLength',[0 0],'FontSize',bigfontsize);
bw_frame = imagesc(NaN(size(data_video.all_frames,1),size(data_video.all_frames,2)),'Parent',ax2,'Tag','VideoFrame');
ax2.Title.String = 'Video';
ax2.Title.FontSize = bigfontsize;
set(ax2,'XTickLabel','','XTick','','YTick','','YTickLabel','');
ax2.DataAspectRatio = [1 1 1];
colormap(ax2,'gray');

% Ephys
ax3 = axes('Parent',f,'FontSize',bigfontsize);
set(ax3,'YTick','','YTickLabel','');

% Spikes
ax4 = axes('Parent',f,'FontSize',bigfontsize);
set(ax4,'YTick','','YTickLabel','');

% Firing Rate
ax5 = axes('Parent',f,'FontSize',bigfontsize);
set(ax5,'YTick','','YTickLabel','');


% Position
margin = .001;
f.OuterPosition =[0 0 1 1];
ax1.Position = [.05 .425 .3 .425];
ax2.Position = [.05 .025 .3 .375];
ax0.Position = [.05 .875 .3 .075];
ax3.Position = [.38 .3+margin .5 .65-2*margin];
ax4.Position = [.38 .05+margin .5 .2-2*margin];
ax5.Position = [.9 .05+margin .05 .2-2*margin];

t1 = uicontrol(f,'Units','normalized','Style','text','BackgroundColor','w',...
    'String','','FontSize',bigfontsize,'FontWeight','bold','TooltipString','Time');
t2 = uicontrol(f,'Units','normalized','Style','text',...
    'String','','FontSize',bigfontsize,'TooltipString','# Frame','BackgroundColor','w');
t1.Position = [.91 .9 .08 .05];
t2.Position = [.91 .85 .08 .05];


% Time Groups
ttg = gobjects(8,1);
ttg(1) = uicontrol(f,'Units','normalized','Style','text',...
    'String',GColors.TimeGroups(1).Name,'BackgroundColor',GColors.TimeGroups(1).Color);
ttg(2) = uicontrol(f,'Units','normalized','Style','text',...
    'String',GColors.TimeGroups(2).Name,'BackgroundColor',GColors.TimeGroups(2).Color);
ttg(3) = uicontrol(f,'Units','normalized','Style','text',...
    'String',GColors.TimeGroups(3).Name,'BackgroundColor',GColors.TimeGroups(3).Color);
ttg(4) = uicontrol(f,'Units','normalized','Style','text',...
    'String',GColors.TimeGroups(4).Name,'BackgroundColor',GColors.TimeGroups(4).Color);
ttg(1).Position = [.91 .45 .08 .04];
ttg(2).Position = [.91 .4 .08 .04];
ttg(3).Position = [.91 .35 .08 .04];
ttg(4).Position = [.91 .3 .08 .04];

% % Scale
% t_factor = 1;
% t100 = uicontrol(f,'Units','normalized','Style','text',...
%     'TooltipString','Scale','String','','BackgroundColor','k');
% t101 = uicontrol(f,'Units','normalized','Style','text',...
%     'String',sprintf('%d s',t_factor),'FontSize',8);
% t100.Position = [.91 .1 .08 .04];
% t101.Position = [.91 .05 .08 .04];


% First Doppler frame
cur_im = im_start;


% % Color tag patches
% default_color = [.5 .5 .5];
% default_face_alpha = 0;
% alpha_value = 0.25;
% patch_colors = repmat(default_color,[size(TimeTags_seconds,1),1]);
% face_alpha = default_face_alpha*ones(size(TimeTags_seconds,1),1);
% edge_color = 'none';
% y_inf = 1e6;

while cur_im <= im_end

    t_cur = data_tr.time_ref.Y(cur_im);

    % Doppler frame
    ax0_cursor.XData = [t_cur t_cur];
%     fus_frame = imagesc(data_doppler.Doppler_film(:,:,cur_im),'Parent',ax1,'Tag','fUSFrame');
    fus_frame.CData = data_doppler.Doppler_film(:,:,cur_im);

    % Movie frame
    bw_frame.CData = data_video.all_frames(:,:,cur_im);

    % Setting time
    t1.String = char(data_tr.time_str(cur_im));
    t2.String = sprintf('%d/%d',cur_im,nb_frames);

    
    % Plotting Channels
    % 1D Interpolation
    cla(ax3);
    t_win = 5;         % seconds
    freq_win = 0.01;    % Hz
    g_colors = get_colors(nb_channels,'parula');
    color1 = g_colors(1,:);
    color2 = g_colors(20,:);
    g_colors = interp1([1,nb_channels],[color1;color2],1:nb_channels);

    Xq = t_cur-t_win:freq_win:t_cur+t_win;
    Yq = interp1(X,Ydata',Xq)';
    for i=1:nb_channels
%         line('XData',X,'YData',nb_channels-i+1+Ydata(i,:)/1000,'Color',g_colors(i,:),'Parent',ax3);
        line('XData',Xq,'YData',nb_channels-i+1+Yq(i,:)/300,'Color',g_colors(i,:),'Parent',ax3);
    end
    ax3.XLim = [Xq(1)  Xq(end)];
    ax3.YLim = [-2+.5 nb_channels+.5+2];
%     set(ax3,'YTick',1:nb_channels,'YTickLabel',D_lfp(:,4));
    set(ax3,'YTick',1:10:nb_channels,'YTickLabel',1:10:nb_channels);
    set(ax3,'XTick',Xq(1):2:Xq(end),'XTickLabel',Xq(1):2:Xq(end));
    ax3.YLabel.String = 'Channel Nr';
    line('XData',[t_cur t_cur],'YData',[ax3.YLim(1) ax3.YLim(2)],'Parent',ax3,'Color','r','LineWidth',1);


    % Plotting Spikes
    cla(ax4);
    g_colors = get_colors(nb_units,'parula');
    spikecount = zeros(nb_units,1);
    for i=1:nb_units
        this_spikes = t_spikes{i};
%         for j=1:10:length(this_spikes)
%             line('XData',[this_spikes(j) this_spikes(j)],'YData',[nb_units-i+1 nb_units-i],'Color',g_colors(i,:),'Parent',ax4);
%         end
        ind_very_spikes = (this_spikes>Xq(1)).*(this_spikes<Xq(end));
        this_very_spikes = this_spikes(ind_very_spikes==1);
        for j=1:length(this_very_spikes)
            line('XData',[this_very_spikes(j) this_very_spikes(j)],'YData',[nb_units-i+1 nb_units-i],'Color',g_colors(i,:),'Parent',ax4);
        end
        spikecount(i)=length(this_very_spikes);
    end
    ax4.XLim = [Xq(1)  Xq(end)];
    ax4.YLim = [.5 nb_units+.5];
    set(ax4,'YTick',1:10:nb_units,'YTickLabel',1:10:nb_units);
    ax4.YLabel.String = 'Unit Nr';
    ax4.XLabel.String = 'Time (seconds)';
    line('XData',[t_cur t_cur],'YData',[ax4.YLim(1) ax4.YLim(2)],'Parent',ax4,'Color','r','LineWidth',1);


    % Plotting Firing Rats
    spikecount_relative = spikecount./(data_spike.spikes.total');
    spikecount_normalized = ((X(end)-X(1))/(2*t_win))*spikecount_relative;

    b = barh(diag(spikecount_normalized),'stacked','Parent',ax5);
    for i =1:length(b)
        b(i).FaceColor = g_colors(length(b)-i+1,:);
        b(i).EdgeColor = 'none';
    end
    ax5.YLim = [.5 nb_units+.5];
    ax5.XLim = [0 5];
    line('XData',[1 1],'YData',[ax5.YLim(1) ax5.YLim(2)],'Parent',ax5,'Color','r','LineWidth',1);
    set(ax5,'YTick',1:10:nb_units,'YTickLabel',1:10:nb_units);
    set(ax5,'XTick',0:5,'YTickLabel',0:5);
    ax5.Title.String = 'Firing Rate';
    
        
    % Time Patches
    for i =1:length(tg_data.TimeGroups_name)
        name = tg_data.TimeGroups_name(i);
        ind_color = find(strcmp({GColors.TimeGroups(:).Name}',name)==1);
        patch_color = GColors.TimeGroups(ind_color).Color;
        patch_alpha = GColors.TimeGroups(ind_color).Transparency;
        n_patches = length(tg_data.TimeGroups_S(i).Name);
        tts = tg_data.TimeGroups_S(i).TimeTags_strings;
        for j = 1:n_patches
            a = datenum(tts(j,1));
            b = datenum(tts(j,2));
            px_data = [a-floor(a),b-floor(b),b-floor(b),a-floor(a)]*24*3600;
            if (px_data(1)-Xq(1))*(px_data(2)-Xq(1))<=0 || (px_data(1)-Xq(end))*(px_data(2)-Xq(end))<=0
                p1 = patch('XData',px_data,'YData',[ax3.YLim(1) ax3.YLim(1) ax3.YLim(2) ax3.YLim(2)],'Parent',ax3,...
                    'EdgeColor','none','FaceColor',patch_color,'FaceAlpha',patch_alpha/2);
                p2 = patch('XData',px_data,'YData',[.5 .5 nb_channels+.5 nb_channels+.5],'Parent',ax4,...
                    'EdgeColor','none','FaceColor',patch_color,'FaceAlpha',patch_alpha/2);
                uistack(p1,'bottom');
                uistack(p2,'bottom');
            end
        end
    end

%     % Displaying Time Groups
%     for j = 1:min(length(ttg),length(tg_cell))
%         if ttg(j).UserData.index_timegroup(i)>0
%             ttg(j).BackgroundColor = 'k';
%             ttg(j).ForegroundColor = 'w';
%         else
%             ttg(j).BackgroundColor = 'w';
%             ttg(j).ForegroundColor = 'k';
%         end
%     end

    % Saving
    seed_save = '/Users/tonio/Desktop';
    work_dir = fullfile(seed_save,f.Name,'Frames');
    if cur_im==im_start
        if isfolder(work_dir)
            rmdir(work_dir,'s');
        end
        mkdir(work_dir);
    end
    pic_name = strcat(sprintf('%s_Frame%05d',f.Name,cur_im),GTraces.ImageSaveExtension);
    saveas(f,fullfile(work_dir,pic_name),GTraces.ImageSaveFormat);
    fprintf('Frame Saved [%s].\n',pic_name);
                    
    cur_im = cur_im +1;

end

% Saving Video
save_dir = fullfile(seed_save,f.Name);
save_video(work_dir,save_dir,sprintf('%s[%.2f-%.2f]',f.Name,t_start,t_end),25);

end