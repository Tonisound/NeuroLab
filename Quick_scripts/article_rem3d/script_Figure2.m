% Article REM 3d - Figure 2
% Synthesis fUS episode statistics

function script_Figure2(rec_list,reg_group)
% rec_list = CORONAL|SAGITTAL|ALL
% reg_group = GROUPS|RIGHT-GROUPS|LEFT-GROUPS|VESSEL-GROUPS

close all;

if nargin <1
    rec_list = 'ALL';
end
if nargin <2
    reg_group = 'GROUPS';
end

% Generate Lists
L = generate_lists(rec_list,reg_group);
fName = sprintf('Fig2_%s-%s',rec_list,reg_group);
folder_save = fullfile(pwd,'Figure2');
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end
list_group = {'QW';'AW';'NREM';'REM';};
% list_group = {'QW';'AW';'NREM';'REM';'REM-TONIC';'REM-PHASIC';};

% Storing
L.list_group = list_group;
L.fName = fName;
L.folder_save = folder_save;
L.rec_list = rec_list;
L.reg_group = reg_group;

% Loading/Browsing data
if exist(fullfile(folder_save,strcat(fName,'.mat')),'file')
    fprintf('Loading [%s]... ',fName);
    load(fullfile(folder_save,strcat(fName,'.mat')),'L','S','P');
    fprintf(' done.\n');
    fprintf('Data Loaded [%s-%s] (%d files)\n',L.rec_list,L.reg_group,length(L.list_files));
else
    [S,P] = browse_data(L);
end

% Plotting/Saving Data
tt_data = plot1(L,P,S);
% plot_atlas(L.list_regions,'Values',tt_data(4,:)',...
%     'SaveName',fullfile('Figure2','REM-Median-Agregated.pdf'),'DisplayMode','bilateral','VisibleName','off');
tt_data = plot2(L,P,S,'Ydata');
% plot_atlas(L.list_regions,'Values',tt_data(4,:)',...
%     'SaveName',fullfile('Figure2','REM-Median-Agregated.pdf'),'DisplayMode','bilateral','VisibleName','off');
tt_data = plot2(L,P,S,'Ymean');
% plot_atlas(L.list_regions,'Values',tt_data(4,:)',...
%     'SaveName',fullfile('Figure2','REM-Mean-per-recording.pdf'),'DisplayMode','bilateral','VisibleName','off');

end

function [S,P] = browse_data(L)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
list_group = L.list_group;
list_files = L.list_files;

% Location of source files
container = 'F:\SHARED_DATASET\NEUROLAB\NLab_Statistics\fUS_Statistics';
    
% Buidling struct S
S = struct('t_data',[],'x_data',[],'y_data',[],'y_mean',[],...
    'group','','region','','recording','');
S(length(list_group),length(list_regions)).y_data = [];
    
counter = 0;
for index = 1:length(list_files)
    
    cur_file = char(list_files(index));
    % Loading fUS_Statistics
    d = dir(fullfile(container,cur_file,'*_fUS_Statistics_WHOLE.mat'));
    if isempty(d)
        warning('Absent file fUS Statistics [File: %s]',cur_file);
        continue;
    elseif length(d)>1
        warning('Multiple files fUS Statistics [File: %s]',cur_file);
        d = d(1);  
    end
    data_fus = load(fullfile(d.folder,d.name));
    counter = counter+1;
    fprintf('fUS Statistics loaded [File: %s]\n',cur_file);
    
    % Collecting fUS data
    for i=1:length(list_group)
        cur_group = char(list_group(i));
        index_group = find(strcmp(data_fus.label_episodes,cur_group)==1);
        
        for j=1:length(list_regions) 
            cur_region = char(list_regions(j));
            index_region = find(strcmp(data_fus.label_channels,cur_region)==1);
            if length(index_region)>1
                index_region = index_region(end);
            end
            
            % Getting data
            Sdata=data_fus.S(index_group,index_region);
            if ~isempty(Sdata)
                S(i,j).group = cur_group;
                S(i,j).region = cur_region;
                S(i,j).recording = [S(i,j).recording;{cur_file}];
                S(i,j).t_data = [S(i,j).t_data;Sdata.t_data(:)];
                S(i,j).x_data = [S(i,j).x_data;Sdata.x_data(:)];
                S(i,j).y_data = [S(i,j).y_data;Sdata.y_data(:)];
                S(i,j).y_mean = [S(i,j).y_mean;mean(Sdata.y_data(:),'omitnan')];
            end
        end
    end
end
fprintf('Data Browsed [%d files loaded].\n',counter);

% Setting Parameters
f = figure('Visible','off');
colormap(f,'parula');
P.Colormap = f.Colormap;
P.f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
close(f);

P.margin_w = .01;
P.margin_h = .02;
P.n_columns = length(list_group);
P.n_rows = 1;
P.val1 = -1;
P.val2 = 1;
P.tick_width =.5;
P.thresh_average = .5;
P.all_markers = {'none';'none';'none'};
P.all_linestyles = {'--';':';'-'};
P.patch_alpha = .1;

% Saving Data
save(fullfile(folder_save,strcat(fName,'.mat')),'L','S','P','-v7.3');
fprintf('Data Saved [%s]\n',fullfile(folder_save,strcat(fName,'.pdf')));

end

function tt_data = plot1(L,P,S)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
list_group = L.list_group;
%list_files = L.list_files;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax = axes('Parent',panel,'Position',[.1 .1 .8 .8]);
ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
clrmenu(f);
f.Name = strcat(fName,'-A');
f.Renderer = 'Painters';
f.PaperPositionMode='manual';

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


% Getting data
m = 0;
for i =1:length(list_group)
    for j = 1:length(list_regions)
        m = max(m,length(S(i,j).y_data));
    end
end
tt_data = NaN(m,length(list_regions),length(list_group));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        temp = S(i,j).y_data; 
        tt_data(1:length(temp),j,i) = temp;
    end
end

dummy_data = rand(length(list_group),length(list_regions));
xtick_labs = list_group;
leg_labs = list_regions;

% Box Plot
n_groups = size(tt_data,3);
n_bars = size(tt_data,2);
hold(ax,'on');
% gpwidth = min(.8,n_groups/(n_groups+1.5));
gpwidth = .85;
for i=1:n_groups
    positions = i-gpwidth/2:gpwidth/(n_bars-1):i+gpwidth/2;
%     ind_colors = 1:63/(n_bars-1):64;
%     colors = cmap(round(ind_colors),:);
    boxplot(tt_data(:,:,i),...
        'MedianStyle','target',...
        'positions',positions,...
        'colors',f_colors,...colors,...
        'OutlierSize',.1,...
        'symbol','',...
        'PlotStyle','compact',...
        'Widths',gpwidth/(n_bars+1),...
        'Parent',ax);

end
hold(ax,'off');
ax.Position = [.05 .05 .8 .9];

% Dummy axes for legend
b = bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    b(i).FaceColor = f_colors(i,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible','on');
ax_dummy.Position = [2 1 1 1];

% Axis limits
%ax.YLim = [min(tt_data(:)) max(tt_data(:))];
ax.YLim = [-40 80];
ax.XLim = [.5 n_groups+.5];
ax.XTick = 1:n_groups;
ax.XTickLabel = xtick_labs;
ax.Title.String = 'Synthesis Episode Statistics';
grid(ax,'on');

% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.875*pos(3) .05*pos(4) .1*pos(3) .9*pos(4)];
panel.Units = 'normalized';
leg.Units = 'normalized';

f.Units = 'pixels';
f.Position = [195          59        1045         919];

fullname = fullfile(folder_save,strcat(fName,'-A.pdf'));
saveas(f,fullname);

end

function tt_data = plot2(L,P,S,str)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
list_group = L.list_group;
%list_files = L.list_files;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax1 = axes('Parent',panel,'Position',[.2 .1 .2 .8]);
ax2 = axes('Parent',panel,'Position',[.6 .1 .2 .8]);
ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
clrmenu(f);
switch str
    case 'Ymean'
        f.Name = strcat(fName,'-B-MeanPerRecording');
    case 'Ydata'
        f.Name = strcat(fName,'-B-MeanAgregated');
end
f.Renderer = 'Painters';
f.PaperPositionMode='manual';

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

% Getting data
%tt_data = rand(10000,length(list_regions),length(list_group));
m = 0;
for i =1:length(list_group)
    for j = 1:length(list_regions)
        switch str
            case 'Ydata'
                m = max(m,length(S(i,j).y_data));  
            case 'Ymean'
                m = max(m,length(S(i,j).y_mean)); 
        end
    end
end

dots_data = NaN(m,length(list_regions),length(list_group));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        switch str
            case 'Ydata'
                temp = S(i,j).y_data;
            case 'Ymean'
                temp = S(i,j).y_mean;
        end 
        dots_data(1:length(temp),j,i) = temp;
    end
end

tt_data = NaN(length(list_group),length(list_regions));
ebar_data = NaN(length(list_group),length(list_regions));
n_samples = NaN(length(list_group),length(list_regions));
for i =1:length(list_group)
    for j = 1:length(list_regions)
        switch str
            case 'Ydata'
                temp = S(i,j).y_data;
            case 'Ymean'
                temp = S(i,j).y_mean;
        end
        tt_data(i,j) = mean(temp,'omitnan');
        n_samples(i,j)=sum(~isnan(temp));
        ebar_data(i,j) = std(temp,[],'omitnan')./sqrt(n_samples(i,j));
    end
end

% Box Plot
n_groups = length(list_group);
n_bars = length(list_regions);

% Finding QW AW REM 
index_rem = find(strcmp(list_group,'REM')==1);
index_aw = find(strcmp(list_group,'AW')==1);
index_qw = find(strcmp(list_group,'QW')==1);
tt_data2 = (tt_data(index_rem,:)-tt_data(index_qw,:))./(tt_data(index_aw,:)-tt_data(index_qw,:));

% Sorting
[~,ind_sorted_rem] = sort(tt_data(index_rem,:),'ascend');
ebar_data_sorted = ebar_data(:,ind_sorted_rem);
[~,ind_sorted_aw] = sort(tt_data2,'ascend');

% Ax1
hold(ax1,'on');
b1 = barh(diag(tt_data(index_rem,ind_sorted_rem)),'stacked','Parent',ax1);
for i=1:length(b1)
    %bar color
    b1(i).FaceColor = f_colors(ind_sorted_rem(i),:);
    b1(i).EdgeColor = 'k';
    b1(i).LineWidth = .1;
    % errorbars
    e = errorbar(b1(i).YData(i),b1(i).XData(i),-ebar_data_sorted(index_rem,i),ebar_data_sorted(index_rem,i),...
        'horizontal','Parent',ax1);
    e.Color='k';
    % dots
    temp = dots_data(:,ind_sorted_rem(i),index_rem);
    temp(isnan(temp))=[];
%     line('XData',temp,'YData',b1(i).XData(i)*ones(size(temp)),...
%         'LineStyle','none','Marker','.','MarkerSize',5,...
%         'MarkerFaceColor','k','Parent',ax1); 
end

% Axis limits
ax1.YTick = 1:n_bars;
ax1.YTickLabel = list_regions(ind_sorted_rem);
ax1.Title.String = 'REM sorted';
%grid(ax1,'on');


% Ax2
b2 = barh(diag(tt_data2(ind_sorted_aw)),'stacked','Parent',ax2);
for i=1:length(b2)
    %bar color
    b2(i).FaceColor = f_colors(ind_sorted_aw(i),:);
    b2(i).EdgeColor = 'k';
    b2(i).LineWidth = .1;
end

% Axis limits
ax2.YTick = 1:n_bars;
ax2.YTickLabel = list_regions(ind_sorted_aw);
ax2.Title.String = 'REM-QW/AW-QW sorted';
%grid(ax2,'on');


dummy_data = rand(length(list_group),length(list_regions));
xtick_labs = list_group;
leg_labs = list_regions;

% Dummy axes for legend
b = bar(dummy_data,'Parent',ax_dummy);
for i=1:length(b)
    %bar color
    b(i).FaceColor = f_colors(i,:);
    b(i).EdgeColor = 'k';
    b(i).LineWidth = .1;
end
leg = legend(ax_dummy,leg_labs,'Visible','on');
ax_dummy.Position = [2 1 1 1];


% Legend Position
panel = leg.Parent;
panel.Units = 'characters';
%leg.Units = 'characters';
pos = panel.Position;
leg.Position = [.8 .1 .15 .8];
panel.Units = 'normalized';
leg.Units = 'normalized';

f.Units = 'pixels';
f.Position = [195          59        1045         919];

fullname = fullfile(folder_save,strcat(fName,'-B.pdf'));
saveas(f,fullname);

end
