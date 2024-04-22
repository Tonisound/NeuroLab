global DIR_SAVE FILES CUR_FILE CUR_IM IM;

close all;
f = figure('Units','normalized','Position',[0 .25 1 .75]);

ax1 = axes('Parent',f,'Position',[.5 .5 .45 .2]);
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_DVR2.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l1 = line('XData',X,'YData',Y,'Parent',ax1);
ax1.YLim = [-1e-3;1e-3];

ax2 = axes('Parent',f,'Position',[.5 .3 .45 .2],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','Power-beta_DVR2.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l2 = line('XData',X,'YData',Y,'Color','r','LineWidth',2,'Parent',ax2);
ax2.YLim = [5*1e-6 5*1e-5];

ax3 = axes('Parent',f,'Position',[.5 .1 .45 .2],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','Whole-reg.mat'));
X = data.X;
Y = data.Y;
l3 = line('XData',X,'YData',Y,'Color',[.5 .5 .5],'LineWidth',2,'Parent',ax3);
ax3.YLim = [-20;70];

ax0 = axes('Parent',f,'Position',[.5 .75 .45 .1]);
l2b = copyobj(l2,ax0);
l2b.YData = rescale(l2b.YData,0,1);
l3b = copyobj(l3,ax0);
l3b.YData = rescale(l3b.YData,0,1);
ax0.Visible='off';
l_cursor = line('XData',[NaN NaN],'YData',[0 1],'Color','k','LineWidth',3,'Parent',ax0);
% X = data.x_start:data.f:data.x_end;
% Y = data.Y;
% l1 = line('XData',X,'YData',Y,'Parent',ax1);

% Axes Appearance
all_axes= [ax1;ax2;ax3];
all_lines= [l1;l2;l3];
for i=1:length(all_axes)
    ax = all_axes(i);
    ax.Visible='off';
end

ax1.YLabel.String = 'LFP DVR (Contra)';
ax1.YLabel.Visible='on';
ax1.YLabel.FontSize=16;

ax2.YLabel.String = 'Beta Power (Contra)';
ax2.YLabel.Visible='on';
ax2.YLabel.FontSize=16;

ax3.YLabel.String = 'CBV Global';
ax3.YLabel.Visible='on';
ax3.YLabel.FontSize=16;

% Reading PS events
input_file = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','PS-All.csv');
[R,EventHeader,MetaData] = read_csv_events(input_file);

all_tstarts = R(:,1);
all_tends = R(:,2);

for j = 1:size(R,1)
    tstart = all_tstarts(j);
    tend = all_tends(j);
    for i=1:length(all_axes)
        ax = all_axes(i);
        p = patch('XData',[tstart tstart tend tend],'YData',[ax.YLim(1) ax.YLim(2) ax.YLim(2) ax.YLim(1)],'Parent',ax,...
        'FaceColor','r','EdgeColor','none','FaceAlpha',.25);
    end
    % ax0
    p = patch('XData',[tstart tstart tend tend],'YData',[ax0.YLim(1) ax0.YLim(2) ax0.YLim(2) ax0.YLim(1)],'Parent',ax0,...
        'FaceColor','r','EdgeColor','none','FaceAlpha',.25);
end


ax100 = axes('Parent',f,'Position',[.05 .05 .4 .4],'XTickLabel','','YTickLabel','');
im = imagesc(IM(:,:,CUR_IM),'Parent',ax100);
ax100.Title.String = 'Cerebral Blood Volume (%)';
ax100.Visible='off';
ax100.Title.Visible='on';
ax100.Title.FontSize=18;
ax100.DataAspectRatio=[1 1 1];
ax100.Title.FontWeight='normal';

colormap(ax100,'hot');
c = colorbar(ax100,'eastoutside');
c.FontSize=14;
ax100.CLim = [-10 50];

all_frames = myhandles.VideoAxes.UserData.all_frames;
ax101 = axes('Parent',f,'Position',[.05 .5 .4 .4],'XTickLabel','','YTickLabel','');
im2 = imagesc(all_frames(:,:,CUR_IM),'Parent',ax101);
ax101.Title.String = 'Behavior';
ax101.Visible='off';
ax101.Title.Visible='on';
ax101.Title.FontSize=18;
ax101.Title.FontWeight='normal';
ax101.DataAspectRatio=[1 1 1];
colormap(ax101,'gray');


t100 = uicontrol('Units','normalized','Style','text','Parent',f,'Position',[.05 .925 .1 .04],...
    'Fontsize',22,'BackgroundColor','w','FontWeight','bold');
t100.String=myhandles.TimeDisplay.UserData(CUR_IM,:);
colormap(ax100,'hot');

% t101 = uicontrol('Units','normalized','Style','text','Parent',f,'Position',[.4 .925 .1 .04],...
%     'Fontsize',22,'BackgroundColor','k','ForegroundColor','w','String','REM');

im_start = 3292;
im_end = 6494;
temp = datenum(myhandles.TimeDisplay.UserData(im_start,:));
t_start = (temp-floor(temp))*24*3600;
temp = datenum(myhandles.TimeDisplay.UserData(im_end,:));
t_end = (temp-floor(temp))*24*3600;
ax0.XLim = [t_start, t_end];

for i = im_start:im_end
    im.CData = IM(:,:,i);
    im2.CData = all_frames(:,:,i);
    t100.String = myhandles.TimeDisplay.UserData(i,:);
    temp = datenum(myhandles.TimeDisplay.UserData(i,:));
    t_im = (temp-floor(temp))*24*3600;
    l_cursor.XData = [t_im,t_im];
    all_l100=[];
    for j=1:length(all_axes)
        ax = all_axes(j);
        ax.XLim = [t_im-30 t_im+30];
        l100 = line('XData',[t_im t_im],'YData',[ax.YLim(1) ax.YLim(2)],'Parent',ax);
        all_l100=[all_l100;l100];
    end
    
%     if (t_im>=tstart) && (t_im<=tend)
%         t101.Visible='on';
%     else
%         t101.Visible='off';
%     end
%     pause(.1);
    saveas(f,fullfile('MovieSupp-1',sprintf('Image_%04d.jpg',i)));
    drawnow;
    delete(all_l100);
end


