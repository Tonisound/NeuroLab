
% % Pogona
% figure;
% ax11=subplot(611);
% ax22=subplot(612);
% line('YData',Data_all(i,:),'XData',TimeData,'Color','k','Parent',ax11);
% line('YData',NormData,'XData',TimeData,'Color','r','Parent',ax22);
% set(ax11,'XLim',[0 7200]+87,'XTick',[0 1800 3600 5400 7200]+87,'XTickLabel',{'23:51';'00:21';'00:51';'01:21';'01:51'});
% set(ax22,'XLim',[0 7200]+87,'XTick',[0 1800 3600 5400 7200]+87,'XTickLabel',{'23:51';'00:21';'00:51';'01:21';'01:51'});
% patch('XData',3600+[2040 2640 2640 2040],'YData',[ax11.YLim(1) ax11.YLim(1) ax11.YLim(2) ax11.YLim(2)],'Parent',ax11,...
%     'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5);
% 
% ax33=subplot(613);
% ax44=subplot(614);
% line('YData',Data_all(i,:),'XData',TimeData,'Color','k','Parent',ax33);
% line('YData',NormData,'XData',TimeData,'Color','r','Parent',ax44);
% set(ax33,'XLim',3600+[2040 2640],'XTick',3600+(2040:120:2640),'XTickLabel',{'01:24';'01:26';'01:28';'01:30';'01:32';'01:34'});
% set(ax44,'XLim',3600+[2040 2640],'XTick',3600+(2040:120:2640),'XTickLabel',{'01:24';'01:26';'01:28';'01:30';'01:32';'01:34'});
% patch('XData',3600+[2100 2200 2200 2100],'YData',[ax33.YLim(1) ax33.YLim(1) ax33.YLim(2) ax33.YLim(2)],'Parent',ax33,...
%     'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5);
% 
% ax55=subplot(615);
% ax66=subplot(616);
% line('YData',Data_all(i,:),'XData',TimeData,'Color','k','Parent',ax55);
% line('YData',NormData,'XData',TimeData,'Color','r','Parent',ax66);
% set(ax55,'XLim',3600+[2100 2200],'XTick',3600+(2100:20:2200),'XTickLabel',{'01:25';'01:25:20';'01:25:40';'01:26';'01:26:20';'01:26:40'});
% set(ax66,'XLim',3600+[2100 2200],'XTick',3600+(2100:20:2200),'XTickLabel',{'01:25';'01:25:20';'01:25:40';'01:26';'01:26:20';'01:26:40'});


% Mouse
figure;
ax11=subplot(611);
ax22=subplot(612);
line('YData',Data_all(i,:),'XData',TimeData,'Color','k','Parent',ax11);
line('YData',NormData,'XData',TimeData,'Color','r','Parent',ax22);
set(ax11,'XLim',[0 3600]+33.5,'XTick',[0 900 1800 2700 3600]+33.5,'XTickLabel',{'17:00';'17:15';'17:30';'17:45';'18:00'});
set(ax22,'XLim',[0 3600]+33.5,'XTick',[0 900 1800 2700 3600]+33.5,'XTickLabel',{'17:00';'17:15';'17:30';'17:45';'18:00'});
patch('XData',[1500 1800 1800 1500],'YData',[ax11.YLim(1) ax11.YLim(1) ax11.YLim(2) ax11.YLim(2)],'Parent',ax11,...
    'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5);

ax33=subplot(613);
ax44=subplot(614);
line('YData',Data_all(i,:),'XData',TimeData,'Color','k','Parent',ax33);
line('YData',NormData,'XData',TimeData,'Color','r','Parent',ax44);
set(ax33,'XLim',[1500 1800],'XTick',(1500:60:1800),'XTickLabel',{'01:25';'01:26';'01:27';'01:28';'01:29';'01:30'});
set(ax44,'XLim',[1500 1800],'XTick',(1500:60:1800),'XTickLabel',{'01:25';'01:26';'01:27';'01:28';'01:29';'01:30'});
patch('XData',[1655 1705 1705 1655],'YData',[ax33.YLim(1) ax33.YLim(1) ax33.YLim(2) ax33.YLim(2)],'Parent',ax33,...
    'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5);

ax55=subplot(615);
ax66=subplot(616);
line('YData',Data_all(i,:),'XData',TimeData,'Color','k','Parent',ax55);
line('YData',NormData,'XData',TimeData,'Color','r','Parent',ax66);
set(ax55,'XLim',[1655 1705],'XTick',1655:10:1705,'XTickLabel',{'01:27:35';'01:27:45';'01:27:55';'01:28:05';'01:28:15';'01:28:25'});
set(ax66,'XLim',[1655 1705],'XTick',1655:10:1705,'XTickLabel',{'01:27:35';'01:27:45';'01:27:55';'01:28:05';'01:28:15';'01:28:25'});