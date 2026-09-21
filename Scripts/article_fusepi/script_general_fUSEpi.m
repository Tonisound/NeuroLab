close all;

all_files = {'20241028_K1616_001_E_nlab';...
    '20241028_K1617_001_E_nlab';...
    '20241028_K1619_001_E_nlab';...
    '20241030_K1615_001_E_nlab';...
    '20241031_K1617_001_E_nlab';...
    '20241031_K1619_001_E_nlab'};

seed_stats = '/Users/tonio/Documents/Antoine-fUSDataset/NEUROLAB/NLab_Statistics/PeriEvent_Sequence';
dir_save = '/Users/tonio/Desktop/fUS-Epi';
if ~isfolder(dir_save)
    mkdir(dir_save);
end

ipsi_vs_contra(all_files,seed_stats,dir_save);
stim_vs_lightcontrol(all_files,seed_stats,dir_save);

function f1 = ipsi_vs_contra(all_files,seed_stats,dir_save)

for j = 1:length(all_files)
    file_nlab = all_files{j};
    if ~isfolder(fullfile(dir_save,"Ipsi-vs-Contra"))
        mkdir(fullfile(dir_save,"Ipsi-vs-Contra"));
    end

    load(fullfile(seed_stats,file_nlab,'Stim-Test-All_PeriEventSequence'));
    d_05 = load(fullfile(seed_stats,file_nlab,'Stim-Test-05sec_PeriEventSequence'));
    d_10 = load(fullfile(seed_stats,file_nlab,'Stim-Test-10sec_PeriEventSequence'));
    d_15 = load(fullfile(seed_stats,file_nlab,'Stim-Test-15sec_PeriEventSequence'));
    d_all = load(fullfile(seed_stats,file_nlab,'Stim-Test-All_PeriEventSequence'));
    d_cont = load(fullfile(seed_stats,file_nlab,'Stim-zControl-Laser_PeriEventSequence'));
    d_sal = load(fullfile(seed_stats,file_nlab,'Stim-zControl-Saline_PeriEventSequence'));


    n_regions = length(all_labels_regions);
    g_colors = get_colors(n_regions);
    h_colors = get_colors(2);
    ImageSaveFormat = 'pdf';


    % Contra vs Ipsi
    f1 = figure;
    f1.Name = sprintf('[%s]Ipsi-vs-Contra',file_nlab);
    ax11 = axes('Parent',f1,'Position',[.05 .6 .4 .35]);
    hold(ax11,'on');
    patch('XData',[0 5 5 0],'YData',[-2 -2 10 10],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax11,'FaceAlpha',.25);
    patch('XData',[0 10 10 0],'YData',[-2 -2 10 10],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax11,'FaceAlpha',.25);
    patch('XData',[0 15 15 0],'YData',[-2 -2 10 10],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax11,'FaceAlpha',.25);
    ax11.Title.String = 'Ipsi vs Contra (All trials)';
    set(ax11,'XLim',[-10 60],'YLim',[-2 10]);
    set(ax11,'XTick',0:20:60,'YTick',0:5:10);
    grid(ax11,'on');


    ax12 = axes('Parent',f1,'Position',[.55 .6 .4 .35]);
    hold(ax12,'on');
    patch('XData',[0 5 5 0],'YData',[-2 -2 10 10],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax12,'FaceAlpha',.25);
    ax12.Title.String = 'Ipsi vs Contra (Stim 05 sec)';
    ax12.YLim = [-2 10];
    set(ax12,'XLim',[-10 60],'YLim',[-2 10]);
    set(ax12,'XTick',0:20:60,'YTick',0:5:10);
    grid(ax12,'on');

    ax13 = axes('Parent',f1,'Position',[.05 .1 .4 .35]);
    hold(ax13,'on');
    patch('XData',[0 10 10 0],'YData',[-2 -2 10 10],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax13,'FaceAlpha',.25);
    ax13.Title.String = 'Ipsi vs Contra (Stim 10 sec)';
    ax13.YLim = [-2 10];
    set(ax13,'XLim',[-10 60],'YLim',[-2 10]);
    set(ax13,'XTick',0:20:60,'YTick',0:5:10);
    grid(ax13,'on');


    ax14 = axes('Parent',f1,'Position',[.55 .1 .4 .35]);
    hold(ax14,'on');
    patch('XData',[0 15 15 0],'YData',[-4 -4 20 20],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax14,'FaceAlpha',.25);
    ax14.Title.String = 'Ipsi vs Contra (Stim 15 sec)';
    ax14.YLim = [-2 10];
    set(ax14,'XLim',[-10 60],'YLim',[-4 20]);
    set(ax14,'XTick',0:20:60,'YTick',0:5:10);
    grid(ax14,'on');

    all_l1 = [];
    leg_labels = {};
    
    for i = 1:n_regions

        % px_data = [t_bins_fus;flipud(t_bins_fus)];
        % py_data = [d_all.Y2q_evt_mean(i,:)+d_all.Y2q_evt_sem(i,:),flipud(d_all.Y2q_evt_mean(i,:)-d_all.Y2q_evt_sem(i,:))]';
        % patch('XData',px_data,'YData',py_data,'FaceColor',g_colors(i,:),'EdgeColor','none','Parent',ax11,'FaceAlpha',.25);
        if strcmp(all_labels_regions(i),'Fiber-Stim-100um') || strcmp(all_labels_regions(i),'Fiber-Contra-100um')
            l1 = line('XData',t_bins_fus,'YData',d_all.Y2q_evt_mean(i,:),...
                'Color',g_colors(i,:),'Parent',ax11,'Tag',char(all_labels_regions(i)));
            all_l1 = [all_l1 ;l1];
            leg_labels = [leg_labels;{l1.Tag}];
            l2 = line('XData',t_bins_fus,'YData',d_05.Y2q_evt_mean(i,:),...
                'Color',g_colors(i,:),'Parent',ax12,'Tag',char(all_labels_regions(i)));
            l3 = line('XData',t_bins_fus,'YData',d_10.Y2q_evt_mean(i,:),...
                'Color',g_colors(i,:),'Parent',ax13,'Tag',char(all_labels_regions(i)));
            l4 = line('XData',t_bins_fus,'YData',d_15.Y2q_evt_mean(i,:),...
                'Color',g_colors(i,:),'Parent',ax14,'Tag',char(all_labels_regions(i)));
        end
    end
    leg = legend(all_l1,char(leg_labels(1)),char(leg_labels(2)));

    picname = f1.Name;
    saveas(f1,fullfile(dir_save,"Ipsi-vs-Contra",picname),ImageSaveFormat);
    fprintf('File %s saved at [%s].\n',picname,dir_save);
    close(f1);
end

end


function f2 = stim_vs_lightcontrol(all_files,seed_stats,dir_save)

for j = 1:length(all_files)
    file_nlab = all_files{j};
    if ~isfolder(fullfile(dir_save,"Stim-vs-LightControl"))
        mkdir(fullfile(dir_save,"Stim-vs-LightControl"));
    end

    load(fullfile(seed_stats,file_nlab,'Stim-Test-All_PeriEventSequence'));
    d_05 = load(fullfile(seed_stats,file_nlab,'Stim-Test-05sec_PeriEventSequence'));
    d_10 = load(fullfile(seed_stats,file_nlab,'Stim-Test-10sec_PeriEventSequence'));
    d_15 = load(fullfile(seed_stats,file_nlab,'Stim-Test-15sec_PeriEventSequence'));
    d_all = load(fullfile(seed_stats,file_nlab,'Stim-Test-All_PeriEventSequence'));
    d_cont = load(fullfile(seed_stats,file_nlab,'Stim-zControl-Laser_PeriEventSequence'));
    d_sal = load(fullfile(seed_stats,file_nlab,'Stim-zControl-Saline_PeriEventSequence'));

    if strcmp(file_nlab,'20241028_K1617_001_E_nlab') || strcmp(file_nlab,'20241031_K1617_001_E_nlab')
        d_first = d_15;
    elseif strcmp(file_nlab,'20241028_K1619_001_E_nlab') || strcmp(file_nlab,'20241031_K1619_001_E_nlab')
        d_first = d_10;
    elseif strcmp(file_nlab,'20241030_K1615_001_E_nlab') 
        d_first = d_05;
    else
        d_first = d_15;
    end


    n_regions = length(all_labels_regions);
    g_colors = get_colors(n_regions);
    h_colors = get_colors(2);
    ImageSaveFormat = 'pdf';

    % Stim vs Control
    f2 = figure;
    f2.Name = sprintf('[%s]Stim-vs-LightControl',file_nlab);

    ylim1 = -4;
    ylim2 = 20;

    ax21 = axes('Parent',f2,'Position',[.05 .6 .4 .35]);
    hold(ax21,'on');
    patch('XData',[0 15 15 0],'YData',[ylim1 ylim1 ylim2 ylim2],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax21,'FaceAlpha',.25);
    ax21.Title.String = 'Stim vs Control (Fiber-Stim-100um)';
    set(ax21,'XLim',[-10 60],'YLim',[ylim1 ylim2]);
    set(ax21,'XTick',0:20:60,'YTick',0:5:10);
    grid(ax21,'on');

    ax22 = axes('Parent',f2,'Position',[.55 .6 .4 .35]);
    hold(ax22,'on');
    patch('XData',[0 15 15 0],'YData',[ylim1 ylim1 ylim2 ylim2],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax22,'FaceAlpha',.25);
    ax22.Title.String = 'Stim vs Control (Fiber-Contra-100um)';
    set(ax22,'XLim',[-10 60],'YLim',[ylim1 ylim2]);
    set(ax22,'XTick',0:20:60,'YTick',0:5:10);
    grid(ax22,'on');

    ax23 = axes('Parent',f2,'Position',[.05 .1 .4 .35]);
    hold(ax23,'on');
    patch('XData',[0 15 15 0],'YData',[ylim1 ylim1 ylim2 ylim2],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax23,'FaceAlpha',.25);
    ax23.Title.String = 'Stim vs Control (Fiber-Stim-200um)';
    set(ax23,'XLim',[-10 60],'YLim',[ylim1 ylim2]);
    set(ax23,'XTick',0:20:60,'YTick',0:5:10);
    grid(ax23,'on');


    ax24 = axes('Parent',f2,'Position',[.55 .1 .4 .35]);
    hold(ax24,'on');
    patch('XData',[0 15 15 0],'YData',[ylim1 ylim1 ylim2 ylim2],'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax24,'FaceAlpha',.25);
    ax24.Title.String = 'Stim vs Control (Fiber-Stim-500um)';
    set(ax24,'XLim',[-10 60],'YLim',[ylim1 ylim2]);
    set(ax24,'XTick',0:20:60,'YTick',0:5:10);
    grid(ax24,'on');

    for i = 1:n_regions

        % px_data = [t_bins_fus;flipud(t_bins_fus)];
        % py_data = [d_all.Y2q_evt_mean(i,:)+d_all.Y2q_evt_sem(i,:),flipud(d_all.Y2q_evt_mean(i,:)-d_all.Y2q_evt_sem(i,:))]';
        % patch('XData',px_data,'YData',py_data,'FaceColor',g_colors(i,:),'EdgeColor','none','Parent',ax11,'FaceAlpha',.25);
        if strcmp(all_labels_regions(i),'Fiber-Stim-100um') %%|| strcmp(all_labels_regions(i),'Fiber-Contra-100um')
            l1 = line('XData',t_bins_fus,'YData',d_first.Y2q_evt_mean(i,:),...
                'Color',h_colors(1,:),'Tag','Fiber-Stim-100um','Parent',ax21);
            l2 = line('XData',t_bins_fus,'YData',d_cont.Y2q_evt_mean(i,:),...
                'Color',h_colors(2,:),'Tag','Light-Control','Parent',ax21);
            legend([l1,l2],char(l1.Tag),char(l2.Tag));
        end

        if strcmp(all_labels_regions(i),'Fiber-Contra-100um')
            l1 = line('XData',t_bins_fus,'YData',d_first.Y2q_evt_mean(i,:),...
                'Color',h_colors(1,:),'Tag','Fiber-Contra-100um','Parent',ax22);
            l2 = line('XData',t_bins_fus,'YData',d_cont.Y2q_evt_mean(i,:),...
                'Color',h_colors(2,:),'Tag','Light-Control','Parent',ax22);
            legend([l1,l2],char(l1.Tag),char(l2.Tag));
        end

        if strcmp(all_labels_regions(i),'Fiber-Stim-200um')
            l1 = line('XData',t_bins_fus,'YData',d_first.Y2q_evt_mean(i,:),...
                'Color',h_colors(1,:),'Tag','Fiber-Stim-200um','Parent',ax23);
            l2 = line('XData',t_bins_fus,'YData',d_cont.Y2q_evt_mean(i,:),...
                'Color',h_colors(2,:),'Tag','Light-Control','Parent',ax23);
            legend([l1,l2],char(l1.Tag),char(l2.Tag));
        end

        if strcmp(all_labels_regions(i),'Fiber-Stim-500um')
            l1 = line('XData',t_bins_fus,'YData',d_first.Y2q_evt_mean(i,:),...
                'Color',h_colors(1,:),'Tag','Fiber-Stim-500um','Parent',ax24);
            l2 = line('XData',t_bins_fus,'YData',d_cont.Y2q_evt_mean(i,:),...
                'Color',h_colors(2,:),'Tag','Light-Control','Parent',ax24);
            legend([l1,l2],char(l1.Tag),char(l2.Tag));
        end
    end

    picname = f2.Name;
    saveas(f2,fullfile(dir_save,"Stim-vs-LightControl",picname),ImageSaveFormat);
    fprintf('File %s saved at [%s].\n',picname,dir_save);
    close(f2);

end

end

% f3 = figure;
% f3.Name = 'Peak-Response';
% colormap(f3,'jet');
%
% clim1 = 0;
% clim2 = 20;
% xlim1 = 12;  %16;
% xlim2 = 38; %32;
% ylim1 = 40;  %40;
% ylim2 = 60; %60;
%
% ax31 = axes('Parent',f3,'Position',[.05 .6 .4 .35]);
% Cdata = max(d_05.Y3q_evt_mean_reshaped,[],3);
% im = imagesc(Cdata,'Parent',ax31);
% im.AlphaData = im.CData>=10;
% l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
%     'LineWidth',1,'Color','r','Parent',ax31);
% l.Color(4) = .25;
% set(ax31,'XLim',[xlim1 xlim2],'YLim',[ylim1 ylim2],'CLim',[clim1 clim2]);
% ax31.Title.String = 'Stim 05 sec';
% colorbar;
%
% ax32 = axes('Parent',f3,'Position',[.55 .6 .4 .35]);
% Cdata = max(d_10.Y3q_evt_mean_reshaped,[],3);
% im = imagesc(Cdata,'Parent',ax32);
% im.AlphaData = im.CData>=10;
% l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
%     'LineWidth',1,'Color','r','Parent',ax32);
% l.Color(4) = .25;
% set(ax32,'XLim',[xlim1 xlim2],'YLim',[ylim1 ylim2],'CLim',[clim1 clim2]);
% ax32.Title.String = 'Stim 10 sec';
% colorbar;
%
% ax33 = axes('Parent',f3,'Position',[.05 .1 .4 .35]);
% Cdata = max(d_15.Y3q_evt_mean_reshaped,[],3);
% im = imagesc(Cdata,'Parent',ax33);
% im.AlphaData = im.CData>=10;
% l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
%     'LineWidth',1,'Color','r','Parent',ax33);
% l.Color(4) = .25;
% set(ax33,'XLim',[xlim1 xlim2],'YLim',[ylim1 ylim2],'CLim',[clim1 clim2]);
% ax33.Title.String = 'Stim 15 sec';
% colorbar;
%
% ax34 = axes('Parent',f3,'Position',[.55 .1 .4 .35]);
% Cdata = max(d_cont.Y3q_evt_mean_reshaped,[],3);
% im = imagesc(Cdata,'Parent',ax34);
% im.AlphaData = im.CData>=10;
% l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
%     'LineWidth',1,'Color','r','Parent',ax34);
% l.Color(4) = .25;
% set(ax34,'XLim',[xlim1 xlim2],'YLim',[ylim1 ylim2],'CLim',[clim1 clim2]);
% ax34.Title.String = 'Stim Control';
% colorbar;
%
% picname = sprintf('[%s]%s',file_nlab,f3.Name);
% saveas(f3,fullfile(seed_stats,file_nlab,picname),ImageSaveFormat);
% fprintf('File %s saved at [%s].\n',picname,seed_stats);
%
%
% f4 = figure;
% f4.Name = 'Area-Under-Curve';
% colormap(f4,'jet');
%
% clim1 = 0;
% clim2 = 500;
% thresh = 200;
% % xlim1 = 0;  %16;
% % xlim2 = 64; %32;
% % ylim1 = 0;  %40;
% % ylim2 = 72; %60;
% tmin = 0;
% tmax = 40;
% index_keep = (t_bins_fus>tmin).*(t_bins_fus<tmax);
%
% ax41 = axes('Parent',f4,'Position',[.05 .6 .4 .35]);
%
% Cdata = d_05.Y3q_evt_mean_reshaped(:,:,index_keep==1);
% Cdata(Cdata<0)=0;
% Cdata = sum(Cdata,3);
% im = imagesc(Cdata,'Parent',ax41);
% im.AlphaData = im.CData>=100;
% l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
%     'LineWidth',1,'Color','r','Parent',ax41);
% l.Color(4) = .25;
% set(ax41,'XLim',[xlim1 xlim2],'YLim',[ylim1 ylim2],'CLim',[clim1 clim2]);
% ax41.Title.String = 'Stim 05 sec';
% colorbar;
%
% ax42 = axes('Parent',f4,'Position',[.55 .6 .4 .35]);
%
% Cdata = d_10.Y3q_evt_mean_reshaped(:,:,index_keep==1);
% Cdata(Cdata<0)=0;
% Cdata = sum(Cdata,3);
%
% im = imagesc(Cdata,'Parent',ax42);
% im.AlphaData = im.CData>=thresh;
% l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
%     'LineWidth',1,'Color','r','Parent',ax42);
% l.Color(4) = .25;
% set(ax42,'XLim',[xlim1 xlim2],'YLim',[ylim1 ylim2],'CLim',[clim1 clim2]);
% ax42.Title.String = 'Stim 10 sec';
% colorbar;
%
% ax43 = axes('Parent',f4,'Position',[.05 .1 .4 .35]);
%
% Cdata = d_15.Y3q_evt_mean_reshaped(:,:,index_keep==1);
% Cdata(Cdata<0)=0;
% Cdata = sum(Cdata,3);
%
% im = imagesc(Cdata,'Parent',ax43);
% im.AlphaData = im.CData>=thresh;
% l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
%     'LineWidth',1,'Color','r','Parent',ax43);
% l.Color(4) = .25;
% set(ax43,'XLim',[xlim1 xlim2],'YLim',[ylim1 ylim2],'CLim',[clim1 clim2]);
% ax43.Title.String = 'Stim 15 sec';
% colorbar;
%
% ax44 = axes('Parent',f4,'Position',[.55 .1 .4 .35]);
%
% Cdata = d_all.Y3q_evt_mean_reshaped(:,:,index_keep==1);
% Cdata(Cdata<0)=0;
% Cdata = sum(Cdata,3);
%
% im = imagesc(Cdata,'Parent',ax44);
% im.AlphaData = im.CData>=thresh;
% l = line('XData',data_atlas.line_x,'YData',data_atlas.line_z,'Tag','AtlasMask',...
%     'LineWidth',1,'Color','r','Parent',ax44);
% l.Color(4) = .25;
% set(ax44,'XLim',[xlim1 xlim2],'YLim',[ylim1 ylim2],'CLim',[clim1 clim2]);
% ax44.Title.String = 'Stim Control';
% colorbar;
%
% picname = sprintf('[%s]%s',file_nlab,f4.Name);
% saveas(f4,fullfile(seed_stats,file_nlab,picname),ImageSaveFormat);
% fprintf('File %s saved at [%s].\n',picname,seed_stats);