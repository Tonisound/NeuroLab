% Article RUN
% Figure 2A
% Hemodynamic Response for a given time group

function script_Figure2A(cur_list,timegroup,gather_regions)

if nargin <3
    gather_regions = false;
end

[D,P,R,S,list_regions] = browse_data(cur_list,timegroup,gather_regions);
plot1(P,R,list_regions,cur_list,timegroup,gather_regions);
plot2(P,S,list_regions,cur_list,timegroup,gather_regions);

end

function [D,P,R,S,list_regions] = browse_data(cur_list,timegroup,gather_regions)

%close all;
global DIR_STATS;

folder = fullfile(DIR_STATS,'fUS_PeriEventHistogram');
all_files = dir(fullfile(folder,'*_E'));
index =0;

list_coronal = {'20141216_225758_E';'20141226_154835_E';'20150223_170742_E';'20150224_175307_E';...
    '20150225_154031_E';'20150226_173600_E';'20150619_132607_E';'20150620_175137_E';...
    '20150714_191128_E';'20150715_181141_E';'20150716_130039_E';'20150717_133756_E';...
    '20150724_170457_E';'20150726_152241_E';'20150728_134238_E';'20151126_170516_E';...
    '20151201_144024_E';'20151202_141449_E';'20151203_113703_E';'20160622_191334_E';...
    '20160623_123336_E';'20160624_120239_E';'20160628_171324_E';'20160629_134749_E';...
    '20160629_191304_E'};
%list_coronal = {'20150223_170742_E';'20150224_175307_E';'20150225_154031_E'};
list_diagonal = {'20150227_134434_E';'20150304_150247_E';'20150305_190451_E';'20150306_162342_E';...
    '20150718_135026_E';'20150722_121257_E';'20150723_123927_E';'20150724_131647_E';...
    '20150725_130514_E';'20150725_160417_E';'20150727_114851_E';'20151127_120039_E';...
    '20151128_133929_E';'20151204_135022_E';'20160622_122940_E';'20160623_163228_E';...
    '20160623_193007_E';'20160624_171440_E';'20160625_113928_E';'20160625_163710_E';...
    '20160630_114317_E';'20160701_130444_E'};

% list of references to search (in order)
% list_ref = {'SPEED';'ACCEL'};
% list_ref = {'heta'};
% timegroup = 'RIGHT_RUNS';
% cur_list = 'DIAGONAL';

% Buidling struct D
D = struct('file','','Doppler_ref','','str_ref','','timegroup','','plane','','rat_name','','rat_id','',...
    'labels_fus','','labels_lfp','','labels_cfc','','EventSelection','');
for i = 1:length(all_files)
    cur_file = char(all_files(i).name);
    
   % timegroup
    dd = dir(fullfile(folder,cur_file,timegroup,'RecordingInfo.mat'));
    if ~isempty(dd)
        data_dd = load(fullfile(folder,cur_file,timegroup,'RecordingInfo.mat'));
        %all_regions = {ddd(:).name}';
    else
        continue;
    end
    
    % updating struct D
    index = index+1;
    D(index).file = cur_file;
    D(index).Doppler_ref = data_dd.Doppler_ref;
    D(index).str_ref = data_dd.str_ref;
    D(index).timegroup = timegroup;
    D(index).rat_name = data_dd.rat_name;
    D(index).rat_id = data_dd.rat_id;
    
    D(index).labels_fus = data_dd.labels_fus;
    D(index).labels_lfp = data_dd.labels_lfp;
    D(index).labels_cfc = data_dd.labels_cfc;
    D(index).EventSelection = data_dd.EventSelection;
    
    if sum(contains(list_coronal,cur_file))>0
        D(index).plane = 'CORONAL';
    elseif sum(contains(list_diagonal,cur_file))>0
        D(index).plane = 'DIAGONAL';
    else
        D(index).plane = 'UNDEFINED';
    end
end

% list_regions
if strcmp(cur_list,'CORONAL')
    list_regions = {'AC-L.mat';'AC-R.mat';'S1BF-L.mat';'S1BF-R.mat';'LPtA-L.mat';'LPtA-R.mat';'RS-L.mat';'RS-R.mat';...
        'DG-L.mat';'DG-R.mat';'CA1-L.mat';'CA1-R.mat';'CA2-L.mat';'CA2-R.mat';'CA3-L.mat';'CA3-R.mat';...
        'dThal-L.mat';'dThal-R.mat';'Po-L.mat';'Po-R.mat';'VPM-L.mat';'VPM-R.mat';...
        'HypothalRg-L.mat';'HypothalRg-R.mat'};
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
    
elseif  strcmp(cur_list,'DIAGONAL')
    list_regions = {'AntCortex-L.mat';'AMidCortex-L.mat';'PMidCortex-R.mat';'PostCortex-R.mat';...
        'DG-R.mat';'CA3-R.mat';'CA1-R.mat';'dHpc-R.mat';'vHpc-R.mat';...
        'dThal-R.mat';'vThal-R.mat';'Thalamus-L.mat';'Thalamus-R.mat';'CPu-L.mat';'CPu-R.mat';...
        'HypothalRg-L.mat';'HypothalRg-R.mat'};
    ind_keep = strcmp({D(:).plane}',cur_list);
    D = D(ind_keep);
else
    list_regions =    {'Neocortex-L.mat';'Neocortex-R.mat';...
        'dHpc-L.mat';'dHpc-R.mat';...
        'Thalamus-L.mat';'Thalamus-R.mat';...
        'HypothalRg-L.mat';'HypothalRg-R.mat'};
end
    
% Buidling struct S
% All_trials
S = struct('Ydata',[],'Xdata',[],'ind_end',[],'ind_start',[],'label_events','','region','',...
    't_start',[],'t_end',[],'file','','str_ref','','rat_name','','rat_id','');
S(length(list_regions)).Ydata = [];

% Average per recording
R = struct('ref_time',[],'m',[],'s',[],'ind_start',[],'ind_end',[],'labels','','str_popup','');
R(length(list_regions)).Ydata = [];

lmax = 5000;
    
for index = 1:length(D)
    
    cur_file = D(index).file;
    str_ref = D(index).str_ref;
    timegroup = D(index).timegroup;
    fullpath = fullfile(folder,cur_file,timegroup);
    rat_name = D(index).rat_name;
    rat_id = D(index).rat_id;
    
    % Loading rmax, tmax
    data_fus = load(fullfile(fullpath,'fUS_Data.mat'));
    for i=1:length(list_regions)
        
        region_name = strrep(char(list_regions(i)),'.mat','');
        ind_keep = find(strcmp(data_fus.fUS_Selection(:,1),region_name)==1);
        
        if ~isempty(ind_keep)        
            Ydata_temp = cat(2,data_fus.Ydata(:,:,ind_keep),NaN(size(data_fus.Ydata,1),lmax-size(data_fus.Ydata,2)));
            S(i).Ydata = [S(i).Ydata;Ydata_temp];
            Xdata_temp = cat(2,data_fus.ref_time,NaN(1,lmax-length(data_fus.ref_time)));
            Xdata_temp = repmat(Xdata_temp,[size(Ydata_temp,1),1]);
            S(i).Xdata = [S(i).Xdata;Xdata_temp];
            S(i).label_events = [S(i).label_events;data_fus.label_events];
            S(i).t_start = [S(i).t_start;data_fus.Time_indices(:,2)-data_fus.Time_indices(1,1)];
            S(i).t_end = [S(i).t_end;data_fus.Time_indices(:,3)-data_fus.Time_indices(1,1)];
            
            S(i).region = region_name;
            S(i).ind_start = [S(i).ind_start;data_fus.ind_start];
            S(i).ind_end = [S(i).ind_end;data_fus.ind_end];
            
%             S(i).rat_name = [S(i).rat_name;repmat({D(index).rat_name},[size(Ydata_temp,1),1])];
%             S(i).rat_id = [S(i).rat_id;repmat({D(index).rat_id},[size(Ydata_temp,1),1])];
%             S(i).file = [S(i).file;repmat({cur_file},[size(Ydata_temp,1),1])];
%             S(i).str_ref =[S(i).str_ref;repmat({D(index).str_ref},[size(Ydata_temp,1),1])];      
            S(i).rat_name = [S(i).rat_name;{D(index).rat_name};repmat({''},[size(Ydata_temp,1),1])];
            S(i).rat_id = [S(i).rat_id;{D(index).rat_id};repmat({''},[size(Ydata_temp,1),1])];
            S(i).file = [S(i).file;{cur_file};repmat({''},[size(Ydata_temp,1),1])];
            S(i).str_ref =[S(i).str_ref;{D(index).str_ref};repmat({''},[size(Ydata_temp,1),1])];

        end
    end
    
    data_ar = load(fullfile(fullpath,'AverageResponse.mat'));
    for i=1:length(list_regions)
        
        region_name = strrep(char(list_regions(i)),'.mat','');
        ind_keep = find(strcmp(data_ar.labels,region_name)==1);
        if ~isempty(ind_keep)
            R(i).ind_start = [R(i).ind_start;mean(data_ar.ind_start)];
            R(i).ind_end = [R(i).ind_end;mean(data_ar.ind_end)];
            R(i).region = region_name;
            R(i).str_popup = [R(i).str_popup;{data_ar.str_popup}];
            
            R(i).ref_time = [R(i).ref_time;[data_ar.ref_time,NaN(1,lmax-length(data_ar.ref_time))]];
            R(i).m = [R(i).m;[data_ar.m(:,:,i),NaN(1,lmax-length(data_ar.ref_time))]];
            R(i).s = [R(i).s;[data_ar.s(:,:,i),NaN(1,lmax-length(data_ar.ref_time))]];
        end
    end
end

% Setting Parameters
f = figure('Visible','off');
colormap(f,'parula');
P.Colormap = f.Colormap;
P.f_colors = f.Colormap(round(1:64/length(R):64),:);
close(f);

P.margin_w = .01;
P.margin_h = .02;
if gather_regions
    P.n_columns = 4;
else
    P.n_columns = 8;
end
P.n_rows = ceil(length(R)/P.n_columns);
P.val1 = -1;
P.val2 = 1;
P.tick_width =.5;
P.thresh_average = .5;
P.all_markers = {'none';'none';'none'};
P.all_linestyles = {'--';':';'_'};
if gather_regions
    P.patch_alpha = .1;
else
    P.patch_alpha = .3;
end

end

function plot1(P,R,list_regions,cur_list,timegroup,gather_regions)

% Drawing results
f = figure;
f.Name = sprintf('Fig2A_SynthesisA_%s-%s',cur_list,timegroup);

f.Colormap = P.Colormap;
f_colors = P.f_colors;
margin_w = P.margin_w;
margin_h = P.margin_h;
n_columns = P.n_columns;
n_rows = P.n_rows;
val1 = P.val1;
val2 = P.val2;
tick_width = P.tick_width;
thresh_average = P.thresh_average;
all_markers = P.all_markers;
all_linestyles = P.all_linestyles;
patch_alpha = P.patch_alpha;


% Creating axes
all_axes = [];
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>length(list_regions)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',f);
        ax.Position= [x+2*margin_w y+margin_h (1/n_columns)-3*margin_w (1/n_rows)-3*margin_h];
        ax.XAxisLocation ='origin';
        ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        all_axes = [all_axes;ax];
    end
end

%gather_regions = true;
if gather_regions
    labels_gathered = strrep(list_regions,'-L','');
    labels_gathered = strrep(labels_gathered,'-R','');
    [C, ~, ic] = unique(labels_gathered,'stable');
    % Reposition axes
    delete(all_axes(length(C)+1:end));
    n_rows = ceil(length(C)/n_columns);
    for ii = 1:n_rows
        for jj = 1:n_columns
            index = (ii-1)*n_columns+jj;
            if index>length(C)
                continue;
            end
            x = mod(index-1,n_columns)/n_columns;
            y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
            ax = all_axes(index);
            ax.Position= [x+2*margin_w y+margin_h (1/n_columns)-3*margin_w (1/n_rows)-3*margin_h];       
        end
    end
    all_axes = all_axes(ic);
else
    labels_gathered = list_regions;
end
labels_gathered=regexprep(labels_gathered,'.mat','');

% Plotting
for index = 1:length(R)
    
    ax = all_axes(index);
    if contains(R(index).region,'-L')
        marker = char(all_markers(1));
        linestyle = char(all_linestyles(1));
    elseif contains(R(index).region,'-R')
        marker = char(all_markers(2));
        linestyle = char(all_linestyles(2));
    else
        marker = char(all_markers(3));
        linestyle = char(all_linestyles(3));
    end
    
    % Main line
    for j=1:size(R(index).ref_time,1)
        N = size(R(index).ref_time,1);
        ref_time = R(index).ref_time(j,:);
        m = R(index).m(j,:);
        s = R(index).s(j,:);
        ind_start = R(index).ind_start(j,:);
        ind_end = R(index).ind_end(j,:);
        
        line('XData',ref_time,'YData',m,'Tag',char(list_regions(index)),...
            'Color',f_colors(index,:),'LineWidth',1,'Linestyle',linestyle,...
            'Marker',marker','MarkerSize',1,'MarkerFaceColor',f_colors(index,:),...
            'MarkerEdgeColor',f_colors(index,:),'Parent',ax)
        title(ax,sprintf('%s [n=%d]',char(labels_gathered(index)),N));
        %grid(ax,'on');
        
        %Patch
        p_xdat = [ref_time,fliplr(ref_time)];
        p_ydat = [m-s,fliplr(m+s)];
        patch('XData',p_xdat(~isnan(p_ydat)),'YData',p_ydat(~isnan(p_ydat)),...
            'FaceColor',f_colors(index,:),'FaceAlpha',patch_alpha,'EdgeColor','none',...
            'LineWidth',.25,'Parent',ax);
        % ticks on graph
        ax.YLim = [-5;20];
        line('XData',[ref_time(R(index).ind_start(j)),ref_time(R(index).ind_start(j))],...
            'YData',[val1*ax.YLim(2) val2*ax.YLim(2)],...
            'LineWidth',tick_width,'Tag','Ticks','Color',[.5 .5 .5],'Parent',ax);
        line('XData',[ref_time(floor(R(index).ind_end(j))),ref_time(floor(R(index).ind_end(j)))],...
            'YData',[val1*ax.YLim(2) val2*ax.YLim(2)],...
            'LineWidth',tick_width,'Tag','Ticks','Color',[.5 .5 .5],'Parent',ax);
    end
    
    % axes limits
    %ax.YLim = [min(R(index).m(:),[],'omitnan') max(R(index).m(:),[],'omitnan')];
    ind_keep = find(sum(~isnan(R(index).m),1)/size(R(index).m,1)>thresh_average);
    ax.XLim = [ref_time(ind_keep(1)), ref_time(ind_keep(end))];
    %ax.YLim = [-5;20];

end

% % Legend once all has been drawn
% all_axes_unique = unique(all_axes);
% for i = 1:length(all_axes_unique)
%     ax = all_axes_unique(i);
%     l = findobj(ax,'Type','line','-not','Tag','Ticks','-not','Tag','');
%     legend(ax,l,regexprep({l(:).Tag}','.mat',''));
% end

f.Units = 'pixels';
f.Position = [195          59        1045         919];

global DIR_STATS;
folder = fullfile(DIR_STATS,'fUS_PeriEventHistogram');
fullname = fullfile(folder,sprintf('%s%s',f.Name,'.pdf'));
saveas(f,fullname);
%saveas(f,fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s%s',f.Name,'.pdf')));
fprintf('Figure Saved [%s].\n',fullname);

end

function plot2(P,S,list_regions,cur_list,timegroup,gather_regions)

% Drawing results
f = figure;
f.Name = sprintf('Fig2A_SynthesisB_%s-%s',cur_list,timegroup);

f.Colormap = P.Colormap;
f_colors = P.f_colors;
margin_w = P.margin_w;
margin_h = P.margin_h;
n_columns = P.n_columns;
n_rows = P.n_rows;
val1 = P.val1;
val2 = P.val2;
tick_width = P.tick_width;
thresh_average = P.thresh_average;
all_markers = P.all_markers;
all_linestyles = P.all_linestyles;
patch_alpha = P.patch_alpha;


% Creating axes
all_axes = [];
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>length(list_regions)
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',f);
        ax.Position= [x+2*margin_w y+margin_h (1/n_columns)-3*margin_w (1/n_rows)-3*margin_h];
        ax.XAxisLocation ='origin';
        ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        all_axes = [all_axes;ax];
    end
end

%gather_regions = false;
if gather_regions
    labels_gathered = strrep(list_regions,'-L','');
    labels_gathered = strrep(labels_gathered,'-R','');
    [C, ~, ic] = unique(labels_gathered,'stable');
    % Reposition axes
    delete(all_axes(length(C)+1:end));
    n_rows = ceil(length(C)/n_columns);
    for ii = 1:n_rows
        for jj = 1:n_columns
            index = (ii-1)*n_columns+jj;
            if index>length(C)
                continue;
            end
            x = mod(index-1,n_columns)/n_columns;
            y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
            ax = all_axes(index);
            ax.Position= [x+2*margin_w y+margin_h (1/n_columns)-3*margin_w (1/n_rows)-3*margin_h];       
        end
    end
    all_axes = all_axes(ic);
else
    labels_gathered = list_regions;
end
labels_gathered=regexprep(labels_gathered,'.mat','');

% Plotting
for index = 1:length(S)
    
    if isempty(S(index).region)
        continue;
    end
    
    ax = all_axes(index);
    if contains(S(index).region,'-L')
        marker = char(all_markers(1));
        linestyle = char(all_linestyles(1));
    elseif contains(S(index).region,'-R')
        marker = char(all_markers(2));
        linestyle = char(all_linestyles(2));
    else
        marker = char(all_markers(3));
        linestyle = char(all_linestyles(3));
    end
    
%     % all trials
%     for j=1:size(S(index).Xdata,1)
%         ref_time = S(index).Xdata(j,:);
%         ydata = S(index).Ydata(j,:);
%         ind_start = S(index).ind_start(j);
%         ind_end = S(index).ind_end(j);
%     
%         %trial
%         line('XData',ref_time,'YData',ydata,...
%             'Color',f_colors(index,:),'LineWidth',.1,'Linestyle',linestyle,...
%             'Marker','none','MarkerSize',1,'MarkerFaceColor','none',...
%             'MarkerEdgeColor',f_colors(index,:),'Parent',ax)
%         % ticks on graph
%         line('XData',[ref_time(ind_start),ref_time(ind_start)],...
%             'YData',[val1*ax.YLim(2) val2*ax.YLim(2)],...
%             'LineWidth',tick_width,'Tag','Ticks','Color',[.5 .5 .5],'Parent',ax);
%         line('XData',[ref_time(ind_end),ref_time(ind_end)],...
%             'YData',[val1*ax.YLim(2) val2*ax.YLim(2)],...
%             'LineWidth',tick_width,'Tag','Ticks','Color',[.5 .5 .5],'Parent',ax);        
%     end
    
    %average
    N = size(S(index).Xdata,1);
    ref_time = mean(S(index).Xdata,'omitnan');
    m = mean(S(index).Ydata,'omitnan');
    s = std(S(index).Ydata,[],'omitnan');
    modifier = sqrt(sum(~isnan(S(index).Ydata)));
    modifier(modifier==0)=1;
    sem = s./modifier;
    
    line('XData',ref_time,'YData',m,'Tag',char(list_regions(index)),...
        'Color',f_colors(index,:),'LineWidth',1,'Linestyle',linestyle,...
        'Marker',marker','MarkerSize',3,'MarkerFaceColor','none',...
        'MarkerEdgeColor',f_colors(index,:),'Parent',ax)
    %grid(ax,'on');
    
    %Patch
    p_xdat = [ref_time,fliplr(ref_time)];
    p_ydat = [m-sem,fliplr(m+sem)];
    %p_ydat = [m-s,fliplr(m+s)];
    patch('XData',p_xdat(~isnan(p_ydat)),'YData',p_ydat(~isnan(p_ydat)),...
        'FaceColor',f_colors(index,:),'FaceAlpha',patch_alpha,'EdgeColor','none',...
        'LineWidth',.25,'Parent',ax);
        
    title(ax,sprintf('%s [n=%d]',char(labels_gathered(index)),N));
    %grid(ax,'on');
    
    % axes limits
    ind_keep = find(sum(~isnan(S(index).Ydata),1)/size(S(index).Ydata,1)> thresh_average);
    ax.XLim = [ref_time(ind_keep(1))-.5, ref_time(ind_keep(end))];
    ax.YLim = [-5;20];
    %ax.XTick = ref_time(ind_keep(1):500:ind_keep(end));
    %ax.XTickLabel = {'.5';'1.0';'1.5';'2.0'};
    
    % ticks on graph
    ind_start_m = round(mean(S(index).ind_start));
    ind_end_m = round(mean(S(index).ind_end));
    line('XData',[ref_time(ind_start_m),ref_time(ind_start_m)],...
        'YData',[val1*ax.YLim(2) val2*ax.YLim(2)],...
        'LineWidth',tick_width,'Tag','Ticks','Color',[.5 .5 .5],'Parent',ax);
    line('XData',[ref_time(ind_end_m),ref_time(ind_end_m)],...
        'YData',[val1*ax.YLim(2) val2*ax.YLim(2)],...
        'LineWidth',tick_width,'Tag','Ticks','Color',[.5 .5 .5],'Parent',ax);
     
end

% Legend once all has been drawn
all_axes_unique = unique(all_axes);
for i = 1:length(all_axes_unique)
    ax = all_axes_unique(i);
    l = findobj(ax,'Type','line','-not','Tag','Ticks','-not','Tag','');
    legend(ax,l,regexprep({l(:).Tag}','.mat',''));
end

f.Units = 'pixels';
f.Position = [195          59        1045         919];

global DIR_STATS;
folder = fullfile(DIR_STATS,'fUS_PeriEventHistogram');
fullname = fullfile(folder,sprintf('%s%s',f.Name,'.pdf'));
saveas(f,fullname);
%saveas(f,fullfile('C:\Users\Antoine\Desktop\PeriEvent',sprintf('%s%s',f.Name,'.pdf')));
fprintf('Figure Saved [%s].\n',fullname);

end