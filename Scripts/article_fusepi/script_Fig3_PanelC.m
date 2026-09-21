% Panel C - Figure 3 - Guyon et al. 2026
% Ipsilateral vs Contralateral activations

close all;

all_files = {'20241025_K1615_001_E_nlab';...
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


clim1 = -5;
clim2 = 15;
ylim1 = -3;
ylim2 = 15;
t_start_auc = 0;
t_end_auc = 30;
n_trials = 6 ;
all_bdata = [];

for j = 1:length(all_files)
    file_nlab = all_files{j};
    if ~isfolder(fullfile(dir_save,"Ipsi-vs-Contra"))
        mkdir(fullfile(dir_save,"Ipsi-vs-Contra"));
    end

    load(fullfile(seed_stats,file_nlab,'Stim-Test-All_PeriEventSequence'));

    if strcmp(file_nlab,"20241025_K1615_001_E_nlab")
        d_1stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-01sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_2stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-05sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_3stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-10sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        stim_dur = [1,1,1,5,5,5,10,10,10];
    elseif strcmp(file_nlab,"20241028_K1617_001_E_nlab")
        d_1stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-15sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_2stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-05sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_3stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-10sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        stim_dur = [15,15,15,5,5,5,10,10,10];
    elseif strcmp(file_nlab,"20241028_K1619_001_E_nlab")
        d_1stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-10sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_2stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-15sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_3stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-05sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        stim_dur = [10,10,10,15,15,15,5,5,5];
    elseif strcmp(file_nlab,"20241030_K1615_001_E_nlab")
        d_1stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-05sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_2stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-15sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_3stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-10sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        stim_dur = [5,5,5,15,15,15,10,10,10];
    elseif strcmp(file_nlab,"20241031_K1617_001_E_nlab")
        d_1stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-05sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_2stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-15sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_3stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-10sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        stim_dur = [5,5,5,15,15,15,10,10,10];
    elseif strcmp(file_nlab,"20241031_K1619_001_E_nlab")
        d_1stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-10sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_2stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-05sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        d_3stim = load(fullfile(seed_stats,file_nlab,'Stim-Test-15sec_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
        stim_dur = [10,10,10,5,5,5,15,15,15];
    end
    % d_cont = load(fullfile(seed_stats,file_nlab,'Stim-zControl-Laser_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');
    % d_sal = load(fullfile(seed_stats,file_nlab,'Stim-zControl-Saline_PeriEvent_AllEvents_normalized'),'Y2q_evt_normalized');


    n_regions = length(all_labels_regions);
    g_colors = get_colors(n_regions);
    h_colors = get_colors(2);
    ImageSaveFormat = 'pdf';

    % Stim trials
    f1 = figure;
    f1.Name = sprintf('[%s]Ipsi-vs-Contra',file_nlab);
    ax11 = axes('Parent',f1,'Position',[.05 .6 .4 .35]);
    hold(ax11,'on');

    ind_stim_region = find(strcmp(all_labels_regions,'Fiber-Stim-100um')==1);
%     all_stim_trials = [permute(d_1stim.Y2q_evt_normalized(ind_stim_region,:,:),[3 2 1]);...
%         permute(d_2stim.Y2q_evt_normalized(ind_stim_region,:,:),[3 2 1]);...
%         permute(d_3stim.Y2q_evt_normalized(ind_stim_region,:,:),[3 2 1])];
    all_stim_trials = [permute(d_1stim.Y2q_evt_normalized(ind_stim_region,:,:),[3 2 1]);...
        permute(d_2stim.Y2q_evt_normalized(ind_stim_region,:,:),[3 2 1])];
    imagesc('XData',t_bins_fus,'YData',1:n_trials,'CData',all_stim_trials,'Parent',ax11);
    % Stims
    for i = 1:n_trials
        py1_data = [i-1 i i i-1]+.5;
        px1_data = [0 0 stim_dur(i) stim_dur(i)];
        patch('XData',px1_data,'YData',py1_data,'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax11,'FaceAlpha',.5);
    end

    set(ax11,'YTick',1:n_trials,'YTickLabel',stim_dur);
    set(ax11,'XTick',0:10:t_end_auc);
    colorbar(ax11);
    ax11.Title.String = 'Ipsi (All trials)';
    set(ax11,'XLim',[-10 t_end_auc],'YLim',[.5 n_trials+.5]);
    set(ax11,'CLim',[clim1 clim2]);
    ax11.YDir = 'reverse';
    
    % Contra trials
    ax13 = axes('Parent',f1,'Position',[.05 .1 .4 .35]);
    hold(ax13,'on');

    ind_contra_region = find(strcmp(all_labels_regions,'Fiber-Contra-100um')==1);
%     all_contra_trials = [permute(d_1stim.Y2q_evt_normalized(ind_contra_region,:,:),[3 2 1]);...
%         permute(d_2stim.Y2q_evt_normalized(ind_contra_region,:,:),[3 2 1]);...
%         permute(d_3stim.Y2q_evt_normalized(ind_contra_region,:,:),[3 2 1])];
    all_contra_trials = [permute(d_1stim.Y2q_evt_normalized(ind_contra_region,:,:),[3 2 1]);...
        permute(d_2stim.Y2q_evt_normalized(ind_contra_region,:,:),[3 2 1])];
    imagesc('XData',t_bins_fus,'YData',1:n_trials,'CData',all_contra_trials,'Parent',ax13);
    % Stims
    for i = 1:n_trials
        py1_data = [i-1 i i i-1]+.5;
        px1_data = [0 0 stim_dur(i) stim_dur(i)];
        patch('XData',px1_data,'YData',py1_data,'FaceColor',[.5 .5 .5],'EdgeColor','none','Parent',ax13,'FaceAlpha',.5);
    end

    set(ax13,'YTick',1:n_trials,'YTickLabel',stim_dur);
    colorbar(ax13);

    ax13.Title.String = 'Contra (All trials)';
    set(ax13,'XLim',[-10 t_end_auc],'YLim',[.5 n_trials+.5]);
    set(ax13,'XTick',0:10:t_end_auc);
    set(ax13,'CLim',[clim1 clim2]);
    ax13.YDir = 'reverse';

    % Mean
    ax12 = axes('Parent',f1,'Position',[.55 .6 .4 .35]);
    hold(ax12,'on');
    ax12.Title.String = 'Ipsi vs Contra';
    ax12.YLim = [ylim1 ylim2];
    set(ax12,'XLim',[-10 t_end_auc],'YLim',[ylim1 ylim2]);
    set(ax12,'XTick',0:10:t_end_auc,'YTick',0:5:10);
    grid(ax12,'on');

    YData1 = all_stim_trials(1:n_trials,:);
    l1 = line('XData',t_bins_fus,'YData',mean(YData1,1),...
        'Color',g_colors(1,:),'Parent',ax12,'Tag','Fiber-Stim-100um');
    px1_data = [t_bins_fus;flipud(t_bins_fus)];
    py1_data = [mean(YData1,1)+(std(YData1,[],1)/sqrt(n_trials)),fliplr(mean(YData1,1)-(std(YData1,[],1)/sqrt(n_trials)))]';
    patch('XData',px1_data,'YData',py1_data,'FaceColor',g_colors(1,:),'EdgeColor','none','Parent',ax12,'FaceAlpha',.25);

    YData2 = all_contra_trials(1:n_trials,:);
    l2 = line('XData',t_bins_fus,'YData',mean(YData2,1),...
        'Color',g_colors(2,:),'Parent',ax12,'Tag','Fiber-Contra-100um');
    px2_data = [t_bins_fus;flipud(t_bins_fus)];
    py2_data = [mean(YData2,1)+(std(YData2,[],1)/sqrt(n_trials)),fliplr(mean(YData2,1)-(std(YData2,[],1)/sqrt(n_trials)))]';
    patch('XData',px2_data,'YData',py2_data,'FaceColor',g_colors(2,:),'EdgeColor','none','Parent',ax12,'FaceAlpha',.25);

    leg_labels = [{l1.Tag};{l2.Tag}];
    legend([l1,l2],char(leg_labels(1)),char(leg_labels(2)));
 
    
    ax14 = axes('Parent',f1,'Position',[.55 .1 .4 .35]);
    hold(ax14,'on');
    ax14.Title.String = 'Area Under Curve';

    [~,ind_start_auc] = min((t_bins_fus-t_start_auc).^2);
    [~,ind_end_auc] = min((t_bins_fus-t_end_auc).^2);
    bdata = [sum(mean(YData1(:,ind_start_auc:ind_end_auc),1)),sum(mean(YData2(:,ind_start_auc:ind_end_auc),1))];
    %ax14.YLim = [-2 10];
    b = bar(diag(bdata),'stacked','Parent',ax14);
    b(1).FaceColor = g_colors(1,:);
    b(2).FaceColor = g_colors(2,:);
    set(ax14,'XLim',[.5 2.5]);
    set(ax14,'XTick',1:2,'XTickLabel',leg_labels);
    grid(ax14,'on');

    all_bdata = [all_bdata;bdata];

    picname = f1.Name;
    saveas(f1,fullfile(dir_save,"Ipsi-vs-Contra",picname),ImageSaveFormat);
    fprintf('File %s saved at [%s].\n',picname,dir_save);
    %close(f1);

end

f2 = figure;
f2.Name = sprintf('Synthesis-Ipsi-vs-Contra[AUC-%.1f-%.1f]',t_start_auc,t_end_auc);

ax15 = axes('Parent',f2,'Position',[.05 .05 .9 .9]);
hold(ax15,'on');
ax15.Title.String = sprintf('Statistics AUC (N = %d session)',size(all_bdata,1));
bdata = mean(all_bdata,1);
sem_data = std(all_bdata,[],1)/sqrt(size(all_bdata,1));

for i = 1:2
    b = bar(i,bdata(i),'Parent',ax15);
    b.FaceColor = g_colors(i,:);
    errorbar(i,bdata(i),sem_data(i),'Color','k','Parent',ax15);
    % dots
    line('XData',i*ones(size(all_bdata,1),1),'YData',all_bdata(:,i),...
        'LineStyle','none','MarkerFaceColor','k','MarkerSize',10,'Marker','o','Parent',ax15);
end
for j = 1:size(all_bdata,1)
    line('XData',[1 2],'YData',all_bdata(j,:),...
        'LineStyle','-','Marker','none','Parent',ax15);
end

set(ax15,'XLim',[.5 2.5]);
set(ax15,'XTick',1:2,'XTickLabel',leg_labels);

picname = f2.Name;
saveas(f2,fullfile(dir_save,"Ipsi-vs-Contra",picname),ImageSaveFormat);
fprintf('File %s saved at [%s].\n',picname,dir_save);
%close(f2);
