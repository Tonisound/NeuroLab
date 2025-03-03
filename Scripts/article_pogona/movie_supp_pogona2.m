
global DIR_SAVE FILES CUR_FILE CUR_IM IM LAST_IM;

close all;
f = figure('Units','normalized','Position',[0 .25 1 .75],'Color','w');

% Getting first and last times
temp = datenum(myhandles.TimeDisplay.UserData(1,:));
t_first = (temp-floor(temp))*24*3600;
temp = datenum(myhandles.TimeDisplay.UserData(LAST_IM,:));
t_last = (temp-floor(temp))*24*3600;

% Displaying global CBV
ax1 = axes('Parent',f,'Position',[.1 .3 .8 .2],'FontSize',16);
% data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','Whole-reg.mat'));
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','Whole_reg.mat'));
X = data.X;
Y = data.Y;
l1 = line('XData',X,'YData',Y,'Parent',ax1,'LineWidth',2);
% ax1.YLim = [0;150];
ax1.YLim = [-20;30];


% Getting regions
all_regions = {'Neocortex-L';'Neocortex-R';'DVR-L';'DVR-R';'Dienecephalon';...
    'Mesencephalon-L';'Mesencephalon-R';'DorsalBrainstem';'VentralBrainstem'};...
all_regions = {'CTX-L';'CTX-R';'dHPC-L';'dHPC-R';'THAL-L';'THAL-R';'vHPC-L';'vHPC-R'};
all_Y = [];
for i =1:length(all_regions)
    cur_region = char(all_regions(i));
    data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS',sprintf('%s.mat',cur_region)));
    X = data.X;
    all_Y = [all_Y,data.Y];
end
% Displaying local CBV
ax2 = axes('Parent',f,'Position',[.1 .05 .8 .2],'YTick',[],'YTickLabel',[],'FontSize',16);
imagesc('XData',X,'YData',1:length(all_regions),'CData',all_Y','Parent',ax2);
% ax2.CLim = [0;150];
ax2.CLim = [-20;30];
ax2.YLim = [.5;length(all_regions)+.5];
colormap(ax2,'hot');
ax2.YDir = 'reverse';
cbar2 = colorbar(ax2,'eastoutside');
cbar2.Position = [.91 .05 .01 .2];
cbar2.Label.String = '(% Change)';

% linkaxes([ax1,ax2],'x');


% Immobile Axis
% ax0 = axes('Parent',f,'Position',[.5 .75 .45 .1]);
% l2b = copyobj(l2,ax0);
% l2b.YData = rescale(l2b.YData,0,1);
% l3b = copyobj(l3,ax0);
% l3b.YData = rescale(l3b.YData,0,1);
% ax0.Visible='off';
% l_cursor = line('XData',[NaN NaN],'YData',[0 1],'Color','k','LineWidth',3,'Parent',ax0);
% X = data.x_start:data.f:data.x_end;
% Y = data.Y;
% l1 = line('XData',X,'YData',Y,'Parent',ax1);

% Axes Appearance
all_axes= [ax1;ax2];
for i=1:length(all_axes)
    ax = all_axes(i);
%     ax.Visible='off';
end

ax1.YLabel.String = 'Global CBV';
ax1.YLabel.Visible='off';
ax1.YLabel.FontSize=16;

ax2.YLabel.String = 'Local CBV';
ax2.YLabel.Visible='off';
ax2.YLabel.FontSize=16;

% Dummy axes
ax11 = axes('Parent',f,'Position',ax1.Position);
ax11.YLabel.String = {'Global'};
ax11.Visible = 'off';
ax11.YLabel.Visible = 'on';
ax11.YLabel.FontSize = 16;

ax22 = axes('Parent',f,'Position',ax2.Position);
ax22.YLabel.String = {'Regional'};
ax22.Visible = 'off';
ax22.YLabel.Visible = 'on';
ax22.YLabel.FontSize = 16;

ax33 = axes('Parent',f,'Position',[.075 .0751 .8 .4]);
ax33.YLabel.String = {'Cerebral Blood Volume'};
ax33.Visible = 'off';
ax33.YLabel.Visible = 'on';
ax33.YLabel.FontSize = 20;

ax44 = axes('Parent',f,'Position',[.09 .05 .01 .2]);
ax44.XLim = [0 1];
ax44.YLim = [0 length(all_regions)];
ax44.Visible='off';
ax44.YDir = 'reverse';

% Axes Time Label
% time_step = 240;
time_step = 60;
time_ticks = 0:time_step:60*ceil(t_last/60);
time_label = datestr((time_ticks)/(24*3600),'HH:MM:SS');
set(ax1,'XTick',time_ticks,'XTickLabel',time_label);
set(ax2,'XTick',[],'XTickLabel',[]);

% Ticks
ax1.TickLength=[.0075 .05];
ax2.TickLength=[0 0];
for i=1:length(time_ticks)
    l=line('XData',[time_ticks(i) time_ticks(i)],'YData',[-1e3 1e3],'Parent',ax1,'Color',[.5 .5 .5],'Parent',ax1);
    l.Color(4)=.5;
end
ax1.YAxisLocation = 'right';
ax1.YLabel.String = '(% change)';
ax1.YLabel.Visible = 'on';

% Reading PS events
input_file = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','Infraslow.csv');
[R,EventHeader,MetaData] = read_csv_events(input_file);

all_tstarts = R(:,1);
all_tends = R(:,2);

for j = 1:size(R,1)
    tstart = all_tstarts(j);
    tend = all_tends(j);
%     for i=1:length(all_axes)
%         ax = all_axes(i);
%         p = patch('XData',[tstart tstart tend tend],'YData',[ax.YLim(1) ax.YLim(2) ax.YLim(2) ax.YLim(1)],'Parent',ax,...
%         'FaceColor','r','EdgeColor','none','FaceAlpha',.25);
%     end
    % ax0
    p = patch('XData',[tstart tstart tend tend],'YData',[ax1.YLim(1) ax1.YLim(2) ax1.YLim(2) ax1.YLim(1)],'Parent',ax1,...
        'FaceColor','r','EdgeColor','none','FaceAlpha',.25);
end

tic;
file_db = fullfile(FILES(CUR_FILE).fullpath,FILES(CUR_FILE).dir_fus,FILES(CUR_FILE).acq);
data_db = load(file_db,'-mat');
db_im = 3000;
Doppler_film = permute(data_db.Acquisition.Data,[3,1,4,2]);
Doppler_dB = 20*log10(abs(Doppler_film)/max(max(abs(Doppler_film(:,:,db_im)))));
dB_frame = Doppler_dB(:,:,db_im);
toc;


%data_db = load('Doppler_DB_Frame.mat');
%dB_frame = data_db.dB_IM;

% ax99 = axes('Parent',f,'Position',[.1 .55 .2 .4],'XTickLabel','','YTickLabel','');
ax99 = axes('Parent',f,'Position',[.05 .55 .3 .4],'XTickLabel','','YTickLabel','');
imagesc(dB_frame,'Parent',ax99);
colormap(ax99,'gray');
ax99.CLim = [-38 0];
% ax99.XLim = [40 120];
ax99.Visible='off';
ax99.Title.String = 'Region segmentation';
ax99.Title.Visible='on';
ax99.Title.FontSize=18;
ax99.DataAspectRatio=[1 1 1];
ax99.Title.FontWeight='normal';

% Copying patches
raw_patches = findobj(myhandles.CenterAxes,'Type','Patch');
raw_names = cell(length(raw_patches),1);
for i =1:length(raw_patches)
    raw_names{i} = raw_patches(i).UserData.UserData.Name;
end

all_patches = gobjects(length(all_regions),1);
for i =1:length(all_regions)
    cur_region = all_regions(i);
    ind_raw = find(strcmp(raw_names,cur_region)==1);
    all_patches(i) = raw_patches(ind_raw);
end

for i =1:length(all_patches)
    p = copyobj(all_patches(i),ax99);
    p.EdgeColor = 'none';
    p.FaceAlpha = .35;
    
    p2 = copyobj(all_patches(i),ax44);
    p2.EdgeColor = 'none';
    p2.XData = [0 0 1 1];
    p2.YData = [i-1 i i i-1];
end


% ax100 = axes('Parent',f,'Position',[.3 .55 .2 .4],'XTickLabel','','YTickLabel','');
ax100 = axes('Parent',f,'Position',[.325 .55 .3 .4],'XTickLabel','','YTickLabel','');
im = imagesc(IM(:,:,CUR_IM),'Parent',ax100);
ax100.Title.String = 'fUS Imaging';
ax100.Visible='off';
ax100.Title.Visible='on';
ax100.Title.FontSize=18;
ax100.DataAspectRatio=[1 1 1];
ax100.Title.FontWeight='normal';
%ax100.XLim = [40 120];

colormap(ax100,'hot');
c = colorbar(ax100,'eastoutside');
c.FontSize=14;
% ax100.CLim = [0;150];
ax100.CLim = [-20;30];
c.Label.String = '(% Change)';

all_frames = myhandles.VideoAxes.UserData.all_frames;
% ax101 = axes('Parent',f,'Position',[.5 .55 .3 .4],'XTickLabel','','YTickLabel','');
ax101 = axes('Parent',f,'Position',[.65 .55 .3 .4],'XTickLabel','','YTickLabel','');
im2 = imagesc(all_frames(:,:,CUR_IM),'Parent',ax101);
ax101.Title.String = 'Infrared Video';
ax101.Visible='off';
ax101.Title.Visible='on';
ax101.Title.FontSize=18;
ax101.Title.FontWeight='normal';
ax101.DataAspectRatio=[1 1 1];
colormap(ax101,'gray');


t100 = uicontrol('Units','normalized','Style','text','Parent',f,'Position',[.45 .5 .1 .04],...
    'Fontsize',20,'BackgroundColor','w','FontWeight','bold');
t100.String=myhandles.TimeDisplay.UserData(CUR_IM,:);
colormap(ax100,'hot');

% t101 = uicontrol('Units','normalized','Style','text','Parent',f,'Position',[.4 .925 .1 .04],...
%     'Fontsize',22,'BackgroundColor','k','ForegroundColor','w','String','REM');

im_start = 2836;
im_end = 3763;
temp = datenum(myhandles.TimeDisplay.UserData(im_start,:));
t_start = (temp-floor(temp))*24*3600;
temp = datenum(myhandles.TimeDisplay.UserData(im_end,:));
t_end = (temp-floor(temp))*24*3600;
ax0.XLim = [t_start, t_end];


% % Moving axes
% for i = im_start:im_end
%     im.CData = IM(:,:,i);
%     
%     temp2 = all_frames(:,:,i);
%     temp2 = nansum(temp2(:));
%     if temp2~=0
%         im2.CData = all_frames(:,:,i);
%     end
%     t100.String = myhandles.TimeDisplay.UserData(i,:);
%     temp = datenum(myhandles.TimeDisplay.UserData(i,:));
%     t_im = (temp-floor(temp))*24*3600;
%     all_l100=[];
%     for j=1:length(all_axes)
%         ax = all_axes(j);
%         ax.XLim = [t_im-600 t_im+600];
%         l100 = line('XData',[t_im t_im],'YData',[ax.YLim(1) ax.YLim(2)],'LineWidth',3,'Parent',ax);
%         all_l100=[all_l100;l100];
%     end
%     
%     saveas(f,fullfile('MovieSupp','Dynamic',sprintf('Image_%06d.jpg',i)));
%     drawnow;
%     delete(all_l100);
% end
% save_video('MovieSupp/Dynamic','MovieSupp/Dynamic','SM-v2-dynamic-20',100);

% Fixed axes
l_cursor = line('XData',[NaN NaN],'YData',ax1.YLim,'Color','r','LineWidth',3,'Parent',ax1);
l_cursor2 = line('XData',[NaN NaN],'YData',ax2.YLim,'Color',[.5 .5 .5],'LineWidth',2,'Parent',ax2);
ax1.XLim = [t_start t_end];
ax2.XLim = [t_start t_end];

dir_video = fullfile('MovieSupp');
for i = im_start:im_end
    im.CData = IM(:,:,i);
    
    temp2 = all_frames(:,:,i);
    temp2 = nansum(temp2(:));
    if temp2~=0
        im2.CData = all_frames(:,:,i);
    end
    t100.String = myhandles.TimeDisplay.UserData(i,:);
    temp = datenum(myhandles.TimeDisplay.UserData(i,:));
    t_im = (temp-floor(temp))*24*3600;
    
    l_cursor.XData = [t_im,t_im];
    l_cursor2.XData = [t_im,t_im];
    
    if ~isfolder(dir_video)
        mkdir(dir_video);
    end
    saveas(f,fullfile(dir_video,sprintf('Image_%06d.jpg',i)));
    drawnow;
    %delete(all_l100);
end
save_video(dir_video,dir_video,'SM-v2-static-20',100);
