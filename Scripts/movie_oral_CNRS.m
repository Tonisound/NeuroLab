global DIR_SAVE FILES CUR_FILE CUR_IM IM;


f = figure('Units','normalized','Position',[0 .25 1 .75]);

ax1 = axes('Parent',f,'Position',[.05 .8 .45 .1]);
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_006.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l1 = line('XData',X,'YData',Y,'Parent',ax1);

ax2 = axes('Parent',f,'Position',[.05 .7 .45 .1],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_005.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l2 = line('XData',X,'YData',Y,'Parent',ax2);

ax3 = axes('Parent',f,'Position',[.05 .6 .45 .1],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_016.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l3 = line('XData',X,'YData',Y,'Parent',ax3);

ax4 = axes('Parent',f,'Position',[.05 .5 .45 .1],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_015.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l4 = line('XData',X,'YData',Y,'Parent',ax4);

ax5 = axes('Parent',f,'Position',[.05 .4 .45 .1],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_012.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l5 = line('XData',X,'YData',Y,'Parent',ax5);

ax6 = axes('Parent',f,'Position',[.05 .3 .45 .1],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_009.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l6 = line('XData',X,'YData',Y,'Parent',ax6);

ax7 = axes('Parent',f,'Position',[.05 .2 .45 .1],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_019.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l7 = line('XData',X,'YData',Y,'Parent',ax7);

ax8 = axes('Parent',f,'Position',[.05 .1 .45 .1],'XTickLabel','','YTickLabel','');
data = load(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','LFP_025.mat'));
X = data.x_start:data.f:data.x_end;
Y = data.Y;
l8 = line('XData',X,'YData',Y,'Parent',ax8);

all_axes= [ax1;ax2;ax3;ax4;ax5;ax6;ax7;ax8];
all_lines= [l1;l2;l3;l4;l5;l6;l7;l8];
for i=1:length(all_axes)
    ax = all_axes(i);
    ax.Visible='off';
    m = nanmean(all_lines(i).YData);
    ax.YLim = [m-5*1e3 m+5*1e3];
    
    tstart = 728.3;
    tend = 920;
    p = patch('XData',[tstart tstart tend tend],'YData',[ax.YLim(1) ax.YLim(2) ax.YLim(2) ax.YLim(1)],'Parent',ax,...
        'FaceColor','r','EdgeColor','none','FaceAlpha',.5);
end


ax100 = axes('Parent',f,'Position',[.55 .1 .4 .8],'XTickLabel','','YTickLabel','');
im = imagesc(IM(:,:,CUR_IM),'Parent',ax100);
ax100.Title.String = 'Volume Sanguin Cerebral (%)';
ax100.Visible='off';
ax100.Title.Visible='on';
ax100.Title.FontSize=18;
ax100.Title.FontWeight='normal';

colormap(ax100,'hot');
c = colorbar(ax100,'eastoutside');
c.FontSize=14;
ax100.CLim = [-20 100];

t100 = uicontrol('Units','normalized','Style','text','Parent',f,'Position',[.05 .925 .1 .04],...
    'Fontsize',22,'BackgroundColor','w','FontWeight','bold');
t100.String=myhandles.TimeDisplay.UserData(CUR_IM,:);
colormap(ax100,'hot');

t101 = uicontrol('Units','normalized','Style','text','Parent',f,'Position',[.4 .925 .1 .04],...
    'Fontsize',22,'BackgroundColor','k','ForegroundColor','w','String','REM');

for i = 1370:1951
    im.CData = IM(:,:,i);
    t100.String = myhandles.TimeDisplay.UserData(i,:);
    temp = datenum(myhandles.TimeDisplay.UserData(i,:));
    t_im = (temp-floor(temp))*24*3600;
    all_l100=[];
    for j=1:length(all_axes)
        ax = all_axes(j);
        ax.XLim = [t_im-5 t_im+5];
        l100 = line('XData',[t_im t_im],'YData',[ax.YLim(1) ax.YLim(2)],'Parent',ax);
        all_l100=[all_l100;l100];
    end
    
    if (t_im>=tstart) && (t_im<=tend)
        t101.Visible='on';
    else
        t101.Visible='off';
    end
%     pause(.1);
    saveas(f,fullfile('OralCNRS',sprintf('Image_%04d.jpg',i)));
    drawnow;
    delete(all_l100);
end


