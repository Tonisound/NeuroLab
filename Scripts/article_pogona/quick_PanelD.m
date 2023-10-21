function f=quick_PanelD(rec_name)

folder = '/Users/tonio/Documents/Antoine-fUSDataset/NEUROLAB/NLab_Statistics/Auto-Correlation';
rec_name = '20190930_P3-020_E_nlab';
filename = strcat(rec_name,'_Auto-Correlation-Dynamics.mat');
data_ac=load(fullfile(folder,rec_name,filename));

f=[];
i=[find(strcmp(data_ac.label_regions,'Whole-reg')==1);find(strcmp(data_ac.label_regions,'Whole_reg')==1)];
if isempty(data_ac) || isempty(i)
    errordlg(sprintf('Error loading data [%s]',filename));
    return;
end


im_mid=(data_ac.Params.im_start+data_ac.Params.im_end)/2;
lags=data_ac.Params.lags;
label_regions=data_ac.label_regions;
all_r_dynamic=squeeze(data_ac.IM_all_r_dynamic(i,:,:));
all_pks_dynamic_1=squeeze(data_ac.IM_all_pks_dynamic(i,:,1));
all_pks_dynamic_2=squeeze(data_ac.IM_all_pks_dynamic(i,:,2));
all_pks_dynamic_3=squeeze(data_ac.IM_all_pks_dynamic(i,:,3));
all_pks_dynamic_4=squeeze(data_ac.IM_all_pks_dynamic(i,:,4));

all_locs_dynamic_1=squeeze(data_ac.IM_all_locs_dynamic(i,:,1));
all_locs_dynamic_2=squeeze(data_ac.IM_all_locs_dynamic(i,:,2));
all_locs_dynamic_3=squeeze(data_ac.IM_all_locs_dynamic(i,:,3));
all_locs_dynamic_4=squeeze(data_ac.IM_all_locs_dynamic(i,:,4));


f=figure;
f.Name = strcat(rec_name,' - Panel D');
colormap(f,'jet');
color1 = 'r';
color2 = [.5 .5 .5];
color3 = [.5 .5 .5];
color4 = [.5 .5 .5];
marker1 = "^";
marker2 = "v";
marker3 = 'none';
marker4 = 'none';

ax1a = subplot(1,2,1);
imagesc('XData',lags,'YData',im_mid,'CData',all_r_dynamic,'Parent',ax1a);
hold(ax1a,'on');
line('XData',all_locs_dynamic_1,'YData',im_mid,'Parent',ax1a,'Tag','MaxPeak',...
    'LineStyle','none','Color','k','Linewidth',1,...
    'MarkerSize',3,'Marker',marker1,'MarkerFaceColor',color1,'MarkerEdgeColor',color1);
line('XData',all_locs_dynamic_3,'YData',im_mid,'Parent',ax1a,'Tag','MinPeak',...
    'LineStyle','none','Color','k','Linewidth',1,...
    'MarkerSize',3,'Marker',marker2,'MarkerFaceColor','none','MarkerEdgeColor',color2);
line('XData',all_locs_dynamic_2,'YData',im_mid,'Parent',ax1a,'Tag','MaxPeak',...
    'LineStyle','none','Color',color2,'Linewidth',1,...
    'MarkerSize',3,'Marker',marker3,'MarkerFaceColor',color3,'MarkerEdgeColor',color3);
line('XData',all_locs_dynamic_4,'YData',im_mid,'Parent',ax1a,'Tag','MinPeak',...
    'LineStyle','none','Color',color2,'Linewidth',1,...
    'MarkerSize',3,'Marker',marker4,'MarkerFaceColor','none','MarkerEdgeColor',color3);
ax1a.XLim =[lags(1) lags(end)];
ax1a.YDir ='reverse';
ax1a.YLim =[im_mid(1) im_mid(end)];
ax1a.YTick = im_mid(1:10:end);
ax1a.Title.String = label_regions(i);
ax1a.CLim = [-.5 1];

ax3a = subplot(1,8,5);
hold(ax3a,'on');
line('XData',all_locs_dynamic_1-all_locs_dynamic_3,'YData',im_mid,'Parent',ax3a,'Tag','DiffFirstTime',...
    'LineStyle','-','Color',color1,'Linewidth',1,...
    'MarkerSize',3,'Marker','none','MarkerFaceColor',color1,'MarkerEdgeColor',color1);
% line('XData',all_locs_dynamic_1,'YData',im_mid,'Parent',ax3a,'Tag','DiffFirstTime',...
%     'LineStyle','-','Color',color1,'Linewidth',1,...
%     'MarkerSize',3,'Marker','none','MarkerFaceColor',color1,'MarkerEdgeColor',color1);
% line('XData',all_locs_dynamic_3,'YData',im_mid,'Parent',ax3a,'Tag','DiffFirstTime',...
%     'LineStyle','-','Color',color2,'Linewidth',1,...
%     'MarkerSize',3,'Marker','none','MarkerFaceColor',color1,'MarkerEdgeColor',color1);
ax3a.YDir ='reverse';
ax3a.YLim =[im_mid(1) im_mid(end)];
ax3a.YTick = im_mid(1:10:end);
ax3a.Title.String = 'DiffFirstTime';

ax4a = subplot(1,8,6);
line('XData',all_pks_dynamic_1-all_pks_dynamic_3,'YData',im_mid,'Parent',ax4a,'Tag','MaxPeak',...
    'LineStyle','-','Color',color2,'Linewidth',1,...
    'MarkerSize',3,'Marker','none','MarkerFaceColor',color2,'MarkerEdgeColor',color2);
ax4a.YDir ='reverse';
ax4a.YLim =[im_mid(1) im_mid(end)];
ax4a.YTick = im_mid(1:10:end);
ax4a.Title.String = 'DiffFirstPeak';

ax5a = subplot(1,8,7);
hold(ax5a,'on');
line('XData',all_locs_dynamic_2-all_locs_dynamic_4,'YData',im_mid,'Parent',ax5a,'Tag','DiffFirstTime',...
    'LineStyle','-','Color',color3,'Linewidth',1,...
    'MarkerSize',3,'Marker','none','MarkerFaceColor',color3,'MarkerEdgeColor',color3);
ax5a.YDir ='reverse';
ax5a.YLim =[im_mid(1) im_mid(end)];
ax5a.YTick = im_mid(1:10:end);
ax5a.Title.String = 'DiffMaxTime';

ax6a = subplot(1,8,8);
line('XData',all_pks_dynamic_2-all_pks_dynamic_4,'YData',im_mid,'Parent',ax6a,'Tag','MaxPeak',...
    'LineStyle','-','Color',color4,'Linewidth',1,...
    'MarkerSize',3,'Marker','none','MarkerFaceColor',color4,'MarkerEdgeColor',color4);
ax6a.YDir ='reverse';
ax6a.YLim =[im_mid(1) im_mid(end)];
ax6a.YTick = im_mid(1:10:end);
ax6a.Title.String = 'DiffMaxPeak';

all_axes = findobj(f,'Type','Axes');
linkaxes(all_axes,'y');


% Saving
f.Units='normalized';
f.OuterPosition=[0 0 1 1];
load('Preferences.mat','GTraces');
save_dir = '/Users/tonio/Documents/Antoine-fUSDataset/NEUROLAB/NLab_Statistics/Auto-Correlation/PanelD';
% Creating Save Directory
if ~isdir(save_dir)
    mkdir(save_dir);
end
saveas(f,fullfile(save_dir,rec_name),GTraces.ImageSaveFormat);
fprintf('Image saved at %s.\n',fullfile(save_dir,rec_name));

end