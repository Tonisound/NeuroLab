function script_polar_plot_PA(n_bins,step_interp)

global DIR_SAVE FILES CUR_FILE;
close all;

if nargin<1
    n_bins = 72;
end
if nargin<2
    step_interp = .5;
end


% % Loading Reference events and Building Time frame
% d_fus = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_fUS','*.mat'));
% d_lfp = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_LFP','*.mat'));
% d_ext = dir(fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Sources_ext','*.mat'));
% d = [d_fus;d_lfp;d_ext];
% input_file = fullfile(DIR_SAVE,FILES(CUR_FILE).nlab,'Events','PS-All.csv');
% [R,EventHeader,MetaData] = read_csv_events(input_file);
% 
% 
% % Loading traces
% str_traces = strrep({d(:).name}','.mat','');
% [ind_traces,v] = listdlg('Name','Trace Selection','PromptString','Select traces to display',...
%     'SelectionMode','multiple','ListString',str_traces,'ListSize',[300 500]);
% if v==0 || isempty(ind_traces)
%     return;
% else
%     d_selected = d(ind_traces);
% end
% 
% 
% % counter = 0; % S2 between 0 and 180 degrees
% counter = .5; % S1 between 0 and 180 degrees
% n_events = size(R,1);
% X_events = [];
% Y_events = [];
% window_peth = -60:1:60;
% Xq_peth_start = [];
% Xq_peth_end = [];
% 
% for i=1:n_events
%     X_events = [X_events;R(i,1)];
%     Y_events = [Y_events;counter];
%     X_events = [X_events;R(i,2)];
%     Y_events = [Y_events;counter+.5];
%     Xq_peth_start = [Xq_peth_start;R(i,1)+window_peth'];
%     Xq_peth_end = [Xq_peth_end;R(i,2)+window_peth'];
%     counter=counter+1;
% end
% 
% Xq = X_events(1):step_interp:X_events(end);
% Yq = interp1(X_events,Y_events,Xq);
% % Yphase = rescale(mod(Yq,1),-pi,pi);
% Yphase = rescale(mod(Yq,1),0,2*pi);
% 
% all_labels = [];
% all_Y = [];
% all_Y_peth_start = NaN(n_events,length(window_peth),length(d_selected));
% all_Y_peth_end = NaN(n_events,length(window_peth),length(d_selected));
% 
% for j=1:length(d_selected)
%     cur_d = d_selected(j);
%     cur_label = strrep(cur_d.name,'.mat','');
%     cur_label = strrep(cur_label,'_','-');
%     data = load(fullfile(cur_d.folder,cur_d.name));
%     if contains(cur_d.folder,'Sources_LFP')
%         data.X = data.x_start:data.f:data.x_end;
%     end
%     Y = interp1(data.X,data.Y,Xq);
%     Y = Y(:);
%     all_labels = [all_labels;{cur_label}];
%     all_Y = [all_Y,Y];
%     Y_peth_start = interp1(data.X,data.Y,Xq_peth_start);
%     all_Y_peth_start(:,:,j)=reshape(Y_peth_start,[length(window_peth),n_events])';
%     Y_peth_end = interp1(data.X,data.Y,Xq_peth_end);
%     all_Y_peth_end(:,:,j)=reshape(Y_peth_end,[length(window_peth),n_events])';
% end
% 
% n_traces = length(d_selected);
% g_colors = get_colors(n_traces,'parula');
% n_columns = 6;
% n_rows = ceil(n_traces/n_columns);
% 
% 
% % Normalizing data
% for i =1:size(all_Y,2)
%     all_Y(:,i) = rescale(all_Y(:,i),0,1);
% end


% Data vector stored in all_Y (array of column vectors)
% Phase vector stored in Yphase (in radians)

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

    % Generating pvalue
    pvalue = PAC_stats(Yphase,all_Y(:,counter)); 
    mvl_x = mean(cos(bin_centers)'.*this_bin_counts);
    mvl_y = mean(sin(bin_centers)'.*this_bin_counts);
    this_mvl = sqrt(mvl_x.^2+mvl_y.^2);

    if mvl_x>0
        this_pd = atan(mvl_y/mvl_x);
    else
        this_pd = atan(mvl_y/mvl_x)+pi;
    end
    this_pd_rad = mod(this_pd*180,360);
    
    polarplot([this_pd this_pd],[min(this_bin_counts_plot_minus_sem) mean(this_bin_counts_plot)],'Parent',pax,...
        'LineStyle','-','Color','r','LineWidth',2);
    pax.ThetaZeroLocation='right';
    pax.ThetaDir='counterclockwise';
    pax.Title.String = strcat(char(all_labels(counter)),sprintf(' [PD=%.2f-MVL=%.2f-p=%.4f]',this_pd_rad,this_mvl,pvalue));
    pax.RLim = [min(this_bin_counts_plot_minus_sem) max(this_bin_counts_plot_plus_sem)];
end
f1_3.OuterPosition = [0 .5 1 .5];

end