function quick_polarplot(n_bins,step_interp)

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

str_traces = strrep({d(:).name}','.mat','');
[ind_traces,v] = listdlg('Name','Trace Selection','PromptString','Select traces to display',...
    'SelectionMode','multiple','ListString',str_traces,'ListSize',[300 500]);
if v==0 || isempty(ind_traces)
    return;
else
    d_selected = d(ind_traces);
end

% Loading Events and Building Time frame
input_file = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','PS-All.csv');
[R,EventHeader,MetaData] = read_csv_events(input_file);

% counter = 0; % S2 between 0 and 180 degrees
counter = .5; % S1 between 0 and 180 degrees
X_events = [];
Y_events = [];
for i=1:size(R,1)
    X_events = [X_events;R(i,1)];
    Y_events = [Y_events;counter];
    X_events = [X_events;R(i,2)];
    Y_events = [Y_events;counter+.5];
    counter=counter+1;
end

Xq = X_events(1):step_interp:X_events(end);
Yq = interp1(X_events,Y_events,Xq);
% Yphase = rescale(mod(Yq,1),-pi,pi);
Yphase = rescale(mod(Yq,1),0,2*pi);

all_labels = [];
all_Y = [];
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
end

n_traces = length(d_selected);
g_colors = get_colors(n_traces,'parula');
n_columns = 6;
n_rows = ceil(n_traces/n_columns);

hd_miniscope = Yphase;
data_miniscope_cells = all_Y;
% Normalizing miniscope data
for i =1:size(data_miniscope_cells,2)
    data_miniscope_cells(:,i) = rescale(data_miniscope_cells(:,i),0,1);
end
labels_miniscope_cells = all_labels;


% bin_edges = -pi:(2*pi)/n_bins:pi;
bin_edges = 0:(2*pi)/n_bins:(2*pi);
bin_counts = zeros(length(bin_edges)-1,n_traces);
n_counts = zeros(length(bin_edges)-1,n_traces);
bin_counts_std = zeros(length(bin_edges)-1,n_traces);
bin_counts_sem = zeros(length(bin_edges)-1,n_traces);

for i = 1:size(bin_counts,1)
    index_keep = (hd_miniscope>=bin_edges(i)).*(hd_miniscope<bin_edges(i+1));
    bin_counts(i,:) = mean(data_miniscope_cells(index_keep==1,:),'omitnan');
    n_counts(i,:) = sum(~isnan(data_miniscope_cells(index_keep==1,:)));
    bin_counts_std(i,:) = std(data_miniscope_cells(index_keep==1,:),[],'omitnan');
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
pimp_factor = 2;

% f1_1 = figure('Name','Raw tuning curves');
% for counter = 1:n_traces
%     pos = get_position(n_rows,n_columns,counter);
%     pax = polaraxes('Parent',f1_1,'Position',pos);
%
%     hold(pax,'on');
%     polarplot(hd_miniscope,data_miniscope_cells(:,counter),'Parent',pax,...
%         'LineStyle','none','Marker','.','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
% %     set(pax,'RTick',[],'RTickLabel',[],'ThetaTick',[],'ThetaTickLabel',[]);
% %     set(pax,'RTickLabel',[],'ThetaTickLabel',[]);
% %     pax.Title.String = strcat(char(labels_miniscope_cells(counter)));
%     pax.ThetaZeroLocation='top';
%
%     this_bin_counts = bin_counts(:,counter);
%     polarhistogram('BinEdges',bin_edges,'BinCounts',pimp_factor*this_bin_counts,'Parent',pax,...
%         'FaceAlpha',.75,'FaceColor',[.5 .5 .5],'EdgeColor','k');
%
%     this_mvl = sqrt((sum(cos(bin_centers)'.*this_bin_counts)).^2+(sum(sin(bin_centers)'.*this_bin_counts)).^2)/10;
%     [~,ind_pd] = max(this_bin_counts);
%     this_pd = bin_centers(ind_pd);
%     polarplot([this_pd this_pd],[0 pimp_factor*this_mvl],'Parent',pax,...
%         'LineStyle','-','Color','r','LineWidth',2);
%     pax.Title.String = strcat(char(labels_miniscope_cells(counter)),sprintf('[MVL=%.2f]',this_mvl));
%
%     all_mvl = [all_mvl;this_mvl];
%     all_pd = [all_pd;this_pd];
% end

f1_2 = figure('Name','Mean curves Polar');
for counter = 1:n_traces
    pos = get_position(n_rows,n_columns,counter);
    pax = polaraxes('Parent',f1_2,'Position',pos);

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
        'LineStyle','-','LineWidth',2,'Color',g_colors(counter,:),...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    polarplot(bin_centers_plot,this_bin_counts_plot_plus_sem,'Parent',pax,...
        'LineStyle','--','LineWidth',1,'Color',g_colors(counter,:),...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    polarplot(bin_centers_plot,this_bin_counts_plot_minus_sem,'Parent',pax,...
        'LineStyle','--','LineWidth',1,'Color',g_colors(counter,:),...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    if mod(counter,n_columns)~=1
        set(pax,'RTick',[],'RTickLabel',[],'ThetaTick',[],'ThetaTickLabel',[]);
        set(pax,'RTickLabel',[],'ThetaTickLabel',[]);
    end
    pax.ThetaZeroLocation='top';
    pax.Title.String = strcat(char(labels_miniscope_cells(counter)));
    pax.RLim = [min(this_bin_counts_plot_minus_sem) max(this_bin_counts_plot_plus_sem)];
end

f1_3 = figure('Name','Mean curves Cartesian');
for counter = 1:n_traces
    pos = get_position(n_rows,n_columns,counter,[.05,.05,.01;.05,.05,.05]);
    ax = axes('Parent',f1_3,'Position',pos);

    hold(ax,'on');
    this_bin_counts = bin_counts(:,counter);
    this_bin_counts_plus_sem = bin_counts(:,counter)+bin_counts_sem(:,counter);
    this_bin_counts_plus_std = bin_counts(:,counter)+bin_counts_std(:,counter);
    this_bin_counts_minus_sem = bin_counts(:,counter)-bin_counts_sem(:,counter);
    this_bin_counts_minus_std = bin_counts(:,counter)-bin_counts_std(:,counter);


    plot(bin_centers,this_bin_counts,'Parent',ax,...
        'LineStyle','-','LineWidth',2,'Color',g_colors(counter,:),...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    plot(bin_centers,this_bin_counts_plus_sem,'Parent',ax,...
        'LineStyle','--','LineWidth',1,'Color',g_colors(counter,:),...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
    plot(bin_centers,this_bin_counts_minus_sem,'Parent',ax,...
        'LineStyle','--','LineWidth',1,'Color',g_colors(counter,:),...
        'Marker','none','MarkerFaceColor',g_colors(counter,:),'MarkerEdgeColor',g_colors(counter,:));
%     % Patch
%     patch('XData',[bin_centers_plot;(bin_centers_plot)],...
%         'YData',[this_bin_counts_plus_sem;(this_bin_counts_minus_sem)],'Parent',ax,...
%         'FaceAlpha',.5,'EdgeColor',g_colors(counter,:),'FaceColor',g_colors(counter,:));

    ax.XLim=[bin_centers(1) bin_centers(end)];
    ax.XTick = 0:pi/2:2*pi;
    grid(ax,'on');
    ax.XTickLabel = {'0';'90';'180';'270';'360'};
    ax.Title.String = strcat(char(labels_miniscope_cells(counter)));
%     if counter>6
%         ax.YLim = [min(this_bin_counts_minus_sem) max(this_bin_counts_plus_sem)];
%     else
%         ax.YLim = [0 .5]; 
%     end
    ax.YLim = [min(this_bin_counts_minus_sem) max(this_bin_counts_plus_sem)];
    line('XData',[pi pi],'YData',ax.YLim,'Parent',ax,'Color','r');
end

end