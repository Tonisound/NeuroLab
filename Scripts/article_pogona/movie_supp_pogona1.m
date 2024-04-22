global DIR_SAVE FILES CUR_FILE CUR_IM IM;


f = figure('Units','normalized','Position',[0 .25 1 .75]);


ax100 = axes('Parent',f,'Position',[.05 .05 .9 .85],'XTickLabel','','YTickLabel','');
im = imagesc(IM(:,:,CUR_IM),'Parent',ax100);
ax100.XLim=[40 120];
ax100.Title.String = 'Cerebral Blood Volume (%)';
ax100.Visible='off';
ax100.Title.Visible='on';
ax100.Title.FontSize=18;
ax100.Title.FontWeight='normal';
ax100.DataAspectRatio=[1 1 1];

colormap(ax100,'hot');
c = colorbar(ax100,'eastoutside');
c.FontSize=14;
ax100.CLim = [-10 50];

t100 = uicontrol('Units','normalized','Style','text','Parent',f,'Position',[.05 .925 .1 .04],...
    'Fontsize',22,'BackgroundColor','w','FontWeight','bold');
t100.String=myhandles.TimeDisplay.UserData(CUR_IM,:);
colormap(ax100,'hot');

t101 = uicontrol('Units','normalized','Style','text','Parent',f,'Position',[.85 .925 .1 .04],...
    'Fontsize',22,'BackgroundColor','k','ForegroundColor','w','String','Sleep');

im_start = 2270;
temp = datenum(myhandles.TimeDisplay.UserData(im_start,:));
tstart = (temp-floor(temp))*24*3600;

im_end = 14400;
temp = datenum(myhandles.TimeDisplay.UserData(im_end,:));
tend = (temp-floor(temp))*24*3600;

folder_save = 'Movie-Supp-Pogona-1';
if isfolder(folder_save)
    rmdir(folder_save,'s');
end
mkdir(folder_save);

for i = 1:10:14400
    im.CData = IM(:,:,i);
    t100.String = myhandles.TimeDisplay.UserData(i,:);
    temp = datenum(myhandles.TimeDisplay.UserData(i,:));
    t_im = (temp-floor(temp))*24*3600;
    
    if (t_im>=tstart) ...&& (t_im<=tend)
        t101.Visible='on';
    else
        t101.Visible='off';
    end
%     pause(.1);
    saveas(f,fullfile(folder_save,sprintf('Image_%05d.jpg',i)));
    drawnow;
    delete(all_l100);
end

workingDir = folder_save;
video_name = 'SuppMovie-Pogo-1-30s';
video_quality = 100;
save_video(workingDir,workingDir,video_name,video_quality)
