function script_polar_plot(n_bins,step_interp)

global DIR_SAVE FILES CUR_FILE;
close all;

if nargin<1
    n_bins = 72;
end
if nargin<2
    step_interp = .5;
end

d_fus = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','*.mat'));
d_lfp = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','*.mat'));
d_ext = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_ext','*.mat'));
d = [d_fus;d_lfp;d_ext];


% Loading Reference events and Building Time frame
input_file = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','PS-All.csv');
% input_file = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','Infraslow.csv');
% d_csv = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','*.csv'));
% str_csv = strrep({d_csv(:).name}','.mat','');
% [ind_csv,v] = listdlg('Name','Event Selection','PromptString','Select Reference Events',...
%     'SelectionMode','single','ListString',str_csv,'ListSize',[300 500]);
% if v==0 || isempty(ind_csv)
%     return;
% else
%     input_file = fullfile(d_csv(ind_csv).folder,d_csv(ind_csv).name);
% end
[R,EventHeader,MetaData] = read_csv_events(input_file);


% Loading traces
str_traces = strrep({d(:).name}','.mat','');
[ind_traces,v] = listdlg('Name','Trace Selection','PromptString','Select traces to display',...
    'SelectionMode','multiple','ListString',str_traces,'ListSize',[300 500]);
if v==0 || isempty(ind_traces)
    return;
else
    d_selected = d(ind_traces);
end


% counter = 0; % S2 between 0 and 180 degrees
counter = .5; % S1 between 0 and 180 degrees
n_events = size(R,1);
X_events = [];
Y_events = [];
window_peth = -60:1:60;
Xq_peth_start = [];
Xq_peth_end = [];

for i=1:n_events
    X_events = [X_events;R(i,1)];
    Y_events = [Y_events;counter];
    X_events = [X_events;R(i,2)];
    Y_events = [Y_events;counter+.5];
    Xq_peth_start = [Xq_peth_start;R(i,1)+window_peth'];
    Xq_peth_end = [Xq_peth_end;R(i,2)+window_peth'];
    counter=counter+1;
end

Xq = X_events(1):step_interp:X_events(end);
Yq = interp1(X_events,Y_events,Xq);
% Yphase = rescale(mod(Yq,1),-pi,pi);
Yphase = rescale(mod(Yq,1),0,2*pi);

all_labels = [];
all_Y = [];
all_Y_peth_start = NaN(n_events,length(window_peth),length(d_selected));
all_Y_peth_end = NaN(n_events,length(window_peth),length(d_selected));

for j=1:length(d_selected)
    cur_d = d_selected(j);
    cur_label = strrep(cur_d.name,'.mat','');
    cur_label = strrep(cur_label,'_','-');
    data = load(fullfile(cur_d.folder,cur_d.name));
    if contains(cur_d.folder,'Sources_LFP')
        data.X = data.x_start:data.f:data.x_end;
    end
    Y = interp1(data.X,data.Y,Xq);
    Y = Y(:);
    all_labels = [all_labels;{cur_label}];
    all_Y = [all_Y,Y];
    Y_peth_start = interp1(data.X,data.Y,Xq_peth_start);
    all_Y_peth_start(:,:,j)=reshape(Y_peth_start,[length(window_peth),n_events])';
    Y_peth_end = interp1(data.X,data.Y,Xq_peth_end);
    all_Y_peth_end(:,:,j)=reshape(Y_peth_end,[length(window_peth),n_events])';
end

% % Rescaling all_Y_peth_start and all_Y_peth_end
% ind_keep = find((window_peth>=-1).*(window_peth<=1));
% for k=1:length(d_selected)
%     for i=1:size(all_Y_peth_start,1)
%         m1 = nanmean(all_Y_peth_start(i,ind_keep,k));
%         all_Y_peth_start(i,:,k) = all_Y_peth_start(i,:,k)/m1;
%         m2 = nanmean(all_Y_peth_end(i,ind_keep,k));
%         all_Y_peth_end(i,:,k) = all_Y_peth_end(i,:,k)/m2;
%     end
% end

n_traces = length(d_selected);
g_colors = get_colors(n_traces,'parula');
n_columns = 6;
n_rows = ceil(n_traces/n_columns);


% Normalizing data
for i =1:size(all_Y,2)
    all_Y(:,i) = rescale(all_Y(:,i),0,1);
end


% bin_edges = -pi:(2*pi)/n_bins:pi;
bin_edges = 0:(2*pi)/n_bins:(2*pi);
bin_counts = zeros(length(bin_edges)-1,n_traces);
n_counts = zeros(length(bin_edges)-1,n_traces);
bin_counts_std = zeros(length(bin_edges)-1,n_traces);
bin_counts_sem = zeros(length(bin_edges)-1,n_traces);

for i = 1:size(bin_counts,1)
    index_keep = (Yphase>=bin_edges(i)).*(Yphase<bin_edges(i+1));
    bin_counts(i,:) = mean(all_Y(index_keep==1,:),'omitnan');
    n_counts(i,:) = sum(~isnan(all_Y(index_keep==1,:)));
    bin_counts_std(i,:) = std(all_Y(index_keep==1,:),[],'omitnan');
end
% bin_counts(isnan(bin_counts))=0;
bin_counts_sem = bin_counts_std./sqrt(n_counts);

bin_centers = bin_edges(1:end-1)+.5*(bin_edges(2)-bin_edges(1));
%     mvl_x=sum(repmat(cos(bin_centers)',[1 n_traces]).*bin_counts);
%     mvl_y=sum(repmat(sin(bin_centers)',[1 n_traces]).*bin_counts);
%     mvl = sqrt(mvl_x.^2+mvl_y.^2);
all_mvl = [];
all_mvl_lp = [];
all_mvl_fa = [];
all_pd = [];
all_pd_lp = [];
all_pd_fa = [];

YPhase=bin_centers;
YData=bin_counts;
YData_std=bin_counts_std;
YData_sem=bin_counts_sem;
save('MyPolarPlot_data','YPhase','YData','YData_std','YData_sem','-v7.3')

f1_1 = figure('Units','normalized','Name','Raw tuning curves');
for counter = 1:n_traces
    pos = get_position(n_rows,n_columns,counter);
    pax = polaraxes('Parent',f1_1,'Position',pos);

    hold(pax,'on');
    polarplot(Yphase,all_Y(:,counter),'Parent',pax,...
        'LineStyle','none','Marker','.','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    %     set(pax,'RTick',[],'RTickLabel',[],'ThetaTick',[],'ThetaTickLabel',[]);
    %     set(pax,'RTickLabel',[],'ThetaTickLabel',[]);
    %     pax.Title.String = strcat(char(all_labels(counter)));
    pax.ThetaZeroLocation='right';

    this_bin_counts = bin_counts(:,counter);
    pimp_factor = 1/max(this_bin_counts);
    polarhistogram('BinEdges',bin_edges,'BinCounts',this_bin_counts,'Parent',pax,...
        'FaceAlpha',.75,'FaceColor',[.5 .5 .5],'EdgeColor','k');

    % Generating pvalue
    [pvalue,pdf,this_mvl2] = PAC_stats(Yphase,all_Y(:,counter)); 
%     [MeanRho,MeanAmp,pvalue] = MyPolarPlot(hax,Yphase,0,all_Y(:,counter),'r');

    mvl_x = mean(cos(bin_centers)'.*this_bin_counts);
    mvl_y = mean(sin(bin_centers)'.*this_bin_counts);
    this_mvl = sqrt(mvl_x.^2+mvl_y.^2);
    %     [~,ind_pd] = max(this_bin_counts);
    %     this_pd = bin_centers(ind_pd);
    if mvl_x>0
        this_pd = atan(mvl_y/mvl_x);
    else
        this_pd = atan(mvl_y/mvl_x)+pi;
    end
    
    polarplot([this_pd this_pd],[0 pimp_factor*this_mvl],'Parent',pax,'LineStyle','-','Color','r','LineWidth',2);
    pax.Title.String = strcat(char(all_labels(counter)),sprintf('[MVL=%.2f][MVL=%.2f][P=%.4f]',this_mvl*pimp_factor,this_mvl2*pimp_factor,pvalue));

    all_mvl = [all_mvl;this_mvl];
    all_pd = [all_pd;this_pd];
end
f1_1.OuterPosition = [0 .5 1 .5];



f1_2 = figure('Units','normalized','Name','Peri-Event Time Histogram (Start)');

f1_2bis = figure('Units','normalized','Name','Peri-Event Time Histogram (Start) Bis');
ax_bis = axes('Parent',f1_2bis);

for counter = 1:n_traces
    pos = get_position(n_rows,n_columns,counter,[.05,.05,.01;.05,.05,.05]);
    ax = axes('Parent',f1_2,'Position',pos);

    hold(ax,'on');
    im = imagesc('YData',1:n_events,'XData',window_peth,'CData',all_Y_peth_start(:,:,counter),'Parent',ax);

    ax.YLim = [.5 n_events+.5];
    ax.YDir = 'reverse';
    ax.XLim = [window_peth(1) window_peth(end)];

    %     grid(ax,'on');
    %     ax.XTickLabel = {'0';'90';'180';'270';'360'};
    ax.Title.String = strcat(char(all_labels(counter)));
    line('XData',[0 0],'YData',ax.YLim,'Parent',ax,'Color','w');

    n_iqr = 2;
    data_iqr = im.CData(~isnan(im.CData));
    ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    colorbar(ax,'southoutside');
    colormap(ax,'jet');
%     ax.CLim = [-10 40];

    % Mean line
    n_samples = sum(~isnan(im.CData),1);
    if strcmp(char(all_labels(counter)),'Power-beta-DVR2')
        mdata = 1e6*nanmean(im.CData,1);
        std_data = 1e6*std(im.CData,1,'omitnan');
    else
        mdata = nanmean(im.CData,1);
        std_data = std(im.CData,1,'omitnan');
    end
    
    sem_data = std_data./sqrt(n_samples);

    mline_data = rescale(mdata,.5,n_events-.5);
    line('XData',window_peth,'YData',n_events-mline_data,'Parent',ax,'Color','r','Linewidth',2);
    
    patch_xdata = [window_peth,fliplr(window_peth)];
    line('XData',window_peth,'YData',mdata,'Parent',ax_bis,'Color','r','Linewidth',1);
%     patch_ydata = [mdata-std_data,fliplr(mdata+std_data)];
    patch_ydata = [mdata-sem_data,fliplr(mdata+sem_data)];
    patch('XData',patch_xdata,'YData',patch_ydata,'EdgeColor','none','Parent',ax_bis,'FaceColor','r','FaceAlpha',.25);

end
f1_2.OuterPosition = [0 0 1 .5];

f1_2b = figure('Units','normalized','Name','Peri-Event Time Histogram (End)');
for counter = 1:n_traces
    pos = get_position(n_rows,n_columns,counter,[.05,.05,.01;.05,.05,.05]);
    ax = axes('Parent',f1_2b,'Position',pos);

    hold(ax,'on');
    im = imagesc('YData',1:n_events,'XData',window_peth,'CData',all_Y_peth_end(:,:,counter),'Parent',ax);

    ax.YLim = [.5 n_events+.5];
    ax.YDir = 'reverse';
    ax.XLim = [window_peth(1) window_peth(end)];
    ax.Title.String = strcat(char(all_labels(counter)));
    line('XData',[0 0],'YData',ax.YLim,'Parent',ax,'Color','w');

    n_iqr = 2;
    data_iqr = im.CData(~isnan(im.CData));
    ax.CLim = [median(data_iqr(:))-n_iqr*iqr(data_iqr(:)),median(data_iqr(:))+n_iqr*iqr(data_iqr(:))];
    colorbar(ax,'southoutside');

    % Mean line
    mline_data = rescale(nanmean(im.CData,1),.5,n_events-.5);
    line('XData',window_peth,'YData',n_events-mline_data,'Parent',ax,'Color','r','Linewidth',2);
end
f1_2b.OuterPosition = [0 0 1 .5];

f1_3 = figure('Units','normalized','Name','Mean curves Polar');
for counter = 1:n_traces
    pos = get_position(n_rows,n_columns,counter);
    pax = polaraxes('Parent',f1_3,'Position',pos);

    hold(pax,'on');
    this_bin_counts = bin_counts(:,counter);
    this_bin_counts_plus_sem = bin_counts(:,counter)+bin_counts_sem(:,counter);
    this_bin_counts_plus_std = bin_counts(:,counter)+bin_counts_std(:,counter);
    this_bin_counts_minus_sem = bin_counts(:,counter)-bin_counts_sem(:,counter);
    this_bin_counts_minus_std = bin_counts(:,counter)-bin_counts_std(:,counter);

    %     this_bin_counts_plot = rescale([this_bin_counts(:);this_bin_counts(1)],0,1);
    this_bin_counts_plot = [this_bin_counts(:);this_bin_counts(1)];
    this_bin_counts_plot_plus_sem = [this_bin_counts_plus_sem(:);this_bin_counts_plus_sem(1)];
    this_bin_counts_plot_plus_std = [this_bin_counts_plus_std(:);this_bin_counts_plus_std(1)];
    this_bin_counts_plot_minus_sem = [this_bin_counts_minus_sem(:);this_bin_counts_minus_sem(1)];
    this_bin_counts_plot_minus_std = [this_bin_counts_minus_std(:);this_bin_counts_minus_std(1)];
    bin_centers_plot = [bin_centers(:);bin_centers(1)];
    

    polarplot(bin_centers_plot,this_bin_counts_plot,'Parent',pax,...
        'LineStyle','-','LineWidth',1,'Color',g_colors(counter,:),...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    polarplot(bin_centers_plot,this_bin_counts_plot_plus_sem,'Parent',pax,...
        'LineStyle','-','LineWidth',.5,'Color',[.5 .5 .5],...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    polarplot(bin_centers_plot,this_bin_counts_plot_minus_sem,'Parent',pax,...
        'LineStyle','-','LineWidth',.5,'Color',[.5 .5 .5],...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    %     if mod(counter,n_columns)~=1
    %         set(pax,'RTick',[],'RTickLabel',[],'ThetaTick',[],'ThetaTickLabel',[]);
    %         set(pax,'RTickLabel',[],'ThetaTickLabel',[]);
    %     end

    this_pd = all_pd(counter);
    this_pd_rad = mod(this_pd*180,360);
    polarplot([this_pd this_pd],[min(this_bin_counts_plot_minus_sem) mean(this_bin_counts_plot)],'Parent',pax,...
        'LineStyle','-','Color','r','LineWidth',2);
    pax.ThetaZeroLocation='right';
    pax.ThetaDir='counterclockwise';
    pax.Title.String = strcat(char(all_labels(counter)),sprintf(' [PD=%.2f]',this_pd_rad));
%     pax.Title.String = strcat(char(all_labels(counter)));
    pax.RLim = [min(this_bin_counts_plot_minus_sem) max(this_bin_counts_plot_plus_sem)];
end
f1_3.OuterPosition = [0 .5 1 .5];

f1_4 = figure('Units','normalized','Name','Mean curves Cartesian');
for counter = 1:n_traces
    pos = get_position(n_rows,n_columns,counter,[.05,.05,.01;.05,.05,.05]);
    ax = axes('Parent',f1_4,'Position',pos);

    hold(ax,'on');
    this_bin_counts = bin_counts(:,counter);
    this_bin_counts_plus_sem = bin_counts(:,counter)+bin_counts_sem(:,counter);
    this_bin_counts_plus_std = bin_counts(:,counter)+bin_counts_std(:,counter);
    this_bin_counts_minus_sem = bin_counts(:,counter)-bin_counts_sem(:,counter);
    this_bin_counts_minus_std = bin_counts(:,counter)-bin_counts_std(:,counter);


    plot(bin_centers,this_bin_counts,'Parent',ax,...
        'LineStyle','-','LineWidth',1,'Color',g_colors(counter,:),...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    plot(bin_centers,this_bin_counts_plus_sem,'Parent',ax,...
        'LineStyle','-','LineWidth',1,'Color',[.5 .5 .5],...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    plot(bin_centers,this_bin_counts_minus_sem,'Parent',ax,...
        'LineStyle','-','LineWidth',1,'Color',[.5 .5 .5],...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    %     % Patch
    %     patch('XData',[bin_centers_plot;(bin_centers_plot)],...
    %         'YData',[this_bin_counts_plus_sem;(this_bin_counts_minus_sem)],'Parent',ax,...
    %         'FaceAlpha',.5,'EdgeColor',g_colors(counter,:),'FaceColor',g_colors(counter,:));

    ax.XLim=[bin_centers(1) bin_centers(end)];
    ax.XTick = 0:pi/2:2*pi;
    grid(ax,'on');
    ax.XTickLabel = {'0';'90';'180';'270';'360'};
    ax.Title.String = strcat(char(all_labels(counter)));
    %     if counter>6
    %         ax.YLim = [min(this_bin_counts_minus_sem) max(this_bin_counts_plus_sem)];
    %     else
    %         ax.YLim = [0 .5];
    %     end
    ax.YLim = [min(this_bin_counts_minus_sem) max(this_bin_counts_plus_sem)];
    line('XData',[pi pi],'YData',ax.YLim,'Parent',ax,'Color','r');
end
f1_4.OuterPosition = [0 0 1 .5];

end