% Article REM 3d - Figure 3
% Synthesis fUS Correlation

function script_Figure3(rec_list,reg_group)
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
fName = sprintf('Fig3_%s-%s',rec_list,reg_group);
folder_save = fullfile(pwd,'Figure3');
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end

% list of time groups
list_ref = {'Ref-Index-REM';'Ref-Index-REM-PHASIC';'Ref-Index-REM-PHASIC-2'};

% Storing
L.list_ref = list_ref;
L.fName = fName;
L.folder_save = folder_save;
L.rec_list = rec_list;
L.reg_group = reg_group;

% Loading/Browsing data
if exist(fullfile(folder_save,strcat(fName,'.mat')),'file')
    fprintf('Loading [%s]... ',fName);
    load(fullfile(folder_save,strcat(fName,'.mat')),'S','P');
    fprintf(' done.\n');
    fprintf('Data Loaded [%s-%s] (%d files)\n',L.rec_list,L.reg_group,length(L.list_files));
else
    [S,P] = browse_data(L);
end

tt_data = plot1(L,P,S,'Rmax');
% tt_data = plot1(L,P,S,'Tmax');
% tt_data = plot1(L,P,S,'Xmax');
tt_data = plot2(L,P,S);

end

function [S,P] = browse_data(L)

folder_save = L.folder_save;
fName = L.fName;
list_regions = L.list_regions;
list_ref = L.list_ref;
list_files = L.list_files;

container = 'F:\SHARED_DATASET\NEUROLAB\NLab_Statistics\fUS_Correlation';
time_group = 'CURRENT';
list_files=strrep(list_files,'R_nlab','R');
    
% Buidling struct S
S = struct('reference','','region','','recording','',...
    'r_max',[],'t_max',[],'x_max',[],...
    'r_min',[],'t_min',[],'x_min',[],...
    'r_abs',[],'t_abs',[],'x_abs',[],...
    'ref_time',[],'RT_pattern',[]);...    
S(length(list_ref),length(list_regions)).r_max = [];
ref_time = [-10:.1:10];
    
counter = 0;
for index = 1:length(list_files)
    
    cur_file = char(list_files(index));
    for i = 1:length(list_ref)
        cur_ref = char(list_ref(i));
        % Loading fUS_Statistics
        d = dir(fullfile(container,cur_file,time_group,cur_ref,'Correlation_pattern.mat'));
        if isempty(d)
            %warning('Absent file fUS Correlation [File: %s, Ref: %s]',cur_file,cur_ref);
            fprintf(' >>> Absent file fUS Correlation [File: %s, Ref: %s]\n',cur_file,cur_ref);
            continue;
        elseif length(d)>1
            warning('Multiple files fUS Correlation [File: %s, Ref: %s]',cur_file,cur_ref);
            d = d(1);
        end
        data_fus = load(fullfile(d.folder,d.name));
        fprintf('fUS Correlation loaded [File: %s, Ref: %s]\n',cur_file,cur_ref);
        counter = counter +1;
    
        % Collecting fUS data  
        % removing ref-index if needed
        if length(data_fus.labels)>size(data_fus.RT_pattern,1)
            ind_rm=find(strcmp(data_fus.labels,strrep(cur_ref,'Ref-',''))==1);
            data_fus.labels(ind_rm)=[];
        end
        
        for j=1:length(list_regions) 
            cur_region = char(list_regions(j));
            index_region = find(strcmp(data_fus.labels,cur_region)==1);
            if length(index_region)>1
                index_region = index_region(end);
            end
            
            if isempty(index_region)
                continue;
            end
            % Getting data
            S(i,j).reference = [S(i,j).reference;{cur_ref}];
            S(i,j).region = [S(i,j).region;{cur_region}];
            S(i,j).recording = [S(i,j).recording;{cur_file}];
            S(i,j).r_max = [S(i,j).r_max;data_fus.r_max(index_region)];
            S(i,j).t_max = [S(i,j).t_max;data_fus.t_max(index_region)];
            S(i,j).x_max = [S(i,j).x_max;data_fus.x_max(index_region)];
            S(i,j).r_min = [S(i,j).r_min;data_fus.r_min(index_region)];
            S(i,j).t_min = [S(i,j).t_min;data_fus.t_min(index_region)];
            S(i,j).x_min = [S(i,j).x_min;data_fus.x_min(index_region)];
            if abs(S(i,j).r_max)>abs(S(i,j).r_min)
                S(i,j).r_abs = [S(i,j).r_abs;data_fus.r_max(index_region)];
                S(i,j).t_abs = [S(i,j).t_abs;data_fus.t_max(index_region)];
                S(i,j).x_abs = [S(i,j).x_abs;data_fus.x_max(index_region)];
            else
                S(i,j).r_abs = [S(i,j).r_abs;data_fus.r_min(index_region)];
                S(i,j).t_abs = [S(i,j).t_abs;data_fus.t_min(index_region)];
                S(i,j).x_abs = [S(i,j).x_abs;data_fus.x_min(index_region)];
            end
            
            RT_pattern = interp1(data_fus.x_,data_fus.RT_pattern(index_region,:),ref_time);
            S(i,j).RT_pattern = [S(i,j).RT_pattern; RT_pattern];
            %S(i,j).x_ = [S(i,j).x_;data_fus.x_];
            S(i,j).ref_time = ref_time;
            %fprintf('File[%s] Rmax[%.2f]\n',cur_file,data_fus.r_max(index_region));
            
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
P.n_columns = length(list_ref);
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
fprintf('Synthesis Data Saved [%s]\n',fullfile(folder_save,strcat(fName,'.mat')));

end

function tt_data = plot1(L,P,S,str)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
list_ref = L.list_ref;
%list_files = L.list_files;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax1 = axes('Parent',panel,'Position',[.125 .1 .15 .8]);
ax2 = axes('Parent',panel,'Position',[.45 .1 .15 .8]);
ax3 = axes('Parent',panel,'Position',[.775 .1 .15 .8]);
%ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
clrmenu(f);
switch str
    case 'Rmax'
        f.Name = strcat(fName,'-A-Rmax');
    case 'Tmax'
        f.Name = strcat(fName,'-A-Tmax');
    case 'Xmax'
        f.Name = strcat(fName,'-A-Xmax');
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
m = 0;
for i =1:length(list_ref)
    for j = 1:length(list_regions)
        m = max(m,length(S(i,j).r_max));
    end
end
dots_data = NaN(m,length(list_regions),length(list_ref));
for i =1:length(list_ref)
    for j = 1:length(list_regions)
        %temp = S(i,j).r_max;    
        switch str
            case 'Rmax'
                temp = S(i,j).r_max;
            case 'Tmax'
                temp = S(i,j).t_max;
            case 'Xmax'
                temp = S(i,j).x_max;
        end 
        dots_data(1:length(temp),j,i) = temp;
    end
end

tt_data = NaN(length(list_ref),length(list_regions));
ebar_data = NaN(length(list_ref),length(list_regions));
for i =1:length(list_ref)
    for j = 1:length(list_regions)
        %temp = S(i,j).r_max;
        switch str
            case 'Rmax'
                temp = S(i,j).r_max;
            case 'Tmax'
                temp = S(i,j).t_max;
            case 'Xmax'
                temp = S(i,j).x_max;
        end
        tt_data(i,j) = mean(temp,'omitnan');
        ebar_data(i,j) = std(temp,[],'omitnan');
    end
end

% Bar Plot
n_groups = length(list_ref);
n_bars = length(list_regions);


all_axes = [ax1;ax2;ax3];
all_titles = list_ref;
for k=1:length(all_axes)
    ax = all_axes(k);
    hold(ax,'on');
    
    % Sorting
    [~,ind_sorted] = sort(tt_data(k,:),'ascend');
    %ind_sorted = 1:size(tt_data,2);
    ebar_data_sorted = ebar_data(:,ind_sorted);

    b = barh(diag(tt_data(k,ind_sorted)),'stacked','Parent',ax);
    for i=1:length(b)
        %bar color
        b(i).FaceColor = f_colors(ind_sorted(i),:);
        b(i).EdgeColor = 'k';
        b(i).LineWidth = .1;
        % errorbars
        e = errorbar(b(i).YData(i),b(i).XData(i),-ebar_data_sorted(k,i),ebar_data_sorted(k,i),...
            'horizontal','Parent',ax);
        e.Color='k';
        % dots
        temp = dots_data(:,ind_sorted(i),k);
        temp(isnan(temp))=[];
        l = line('XData',temp,'YData',b(i).XData(i)*ones(size(temp)),...
            'LineStyle','none','Marker','.','MarkerSize',5,...
            'MarkerFaceColor','k','Parent',ax);
    end
    % Axis limits
    ax.YTick = 1:n_bars;
    ax.YTickLabel = list_regions;
    ax.Title.String = char(all_titles(k));
    grid(ax,'on');
    switch str
        case 'Rmax'
            ax.XLim = [-.5 1];
        case 'Tmax'
            ax.XLim = [500 2000];
        case 'Xmax'
            ax.XLim = [-10 10];
    end
    for i=1:length(b)
        text(ax.XLim(2),b(i).XData(i),sprintf('%.2f',b(i).YData(i)),'Parent',ax);
    end
end


% dummy_data = rand(length(list_ref),length(list_regions));
% xtick_labs = list_ref;
% leg_labs = list_regions;
% 
% % Dummy axes for legend
% b = bar(dummy_data,'Parent',ax_dummy);
% for i=1:length(b)
%     %bar color
% %     ind_color = max(round(i*length(cmap)/n_bars-1)+1,1);
% %     b(i).FaceColor = cmap(ind_color,:);
%     b(i).FaceColor = f_colors(i,:);
%     b(i).EdgeColor = 'k';
%     b(i).LineWidth = .1;
% end
% leg = legend(ax_dummy,leg_labs,'Visible','on');
% ax_dummy.Position = [2 1 1 1];
% 
% % Legend Position
% panel = leg.Parent;
% panel.Units = 'characters';
% %leg.Units = 'characters';
% pos = panel.Position;
% leg.Position = [.8 .1 .15 .8];
% panel.Units = 'normalized';
% leg.Units = 'normalized';

f.Units = 'pixels';
f.Position = [195          59        1045         919];

%fullname = fullfile(folder_save,strcat(fName,'-A.pdf'));
switch str
    case 'Rmax'
        fullname = fullfile(folder_save,strcat(f.Name,'pdf'));
    case 'Tmax'
        fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
    case 'Xmax'
        fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
end
saveas(f,fullname);

plot_atlas(list_regions,'Values',tt_data(1,:)',...
    'SaveName',fullfile(folder_save,strcat('PlotAtlas-',f.Name,'.pdf')),...
    'DisplayMode','bilateral','VisibleName','off');

end

function tt_data = plot2(L,P,S)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
list_ref = L.list_ref;
%list_files = L.list_files;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax1 = axes('Parent',panel,'Position',[.05 .05 .4 .4]);
ax2 = axes('Parent',panel,'Position',[.05 .55 .4 .4]);
ax3 = axes('Parent',panel,'Position',[.55 .05 .4 .9]);
%ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
clrmenu(f);
f.Name = strcat(fName,'-B');
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
for i =1:length(list_ref)
    for j = 1:length(list_regions)
        m = max(m,length(S(i,j).r_max));
    end
end
dots_data = NaN(m,length(list_regions),length(list_ref));
for i =1:length(list_ref)
    for j = 1:length(list_regions)
        temp = S(i,j).r_max;     
        dots_data(1:length(temp),j,i) = temp;
    end
end

tt_data = NaN(length(list_ref),length(list_regions));
ebar_data = NaN(length(list_ref),length(list_regions));
for i =1:length(list_ref)
    for j = 1:length(list_regions)
        temp = S(i,j).r_max;
        tt_data(i,j) = mean(temp,'omitnan');
        ebar_data(i,j) = std(temp,[],'omitnan');
    end
end

% Finding QW AW REM 
index_rem = find(strcmp(list_ref,'Ref-Index-REM')==1);
index_remphasic = find(strcmp(list_ref,'Ref-Index-REM-PHASIC')==1);
index_remphasic2 = find(strcmp(list_ref,'Ref-Index-REM-PHASIC-2')==1);

% Bar Plot
n_groups = length(list_ref);
n_bars = length(list_regions);


% Ax1
hold(ax1,'on');
for i=1:length(list_regions)
    %bar color
    line('XData',tt_data(index_rem,i),'YData',tt_data(index_remphasic,i),...
        'LineStyle','none','Marker','+','MarkerSize',15,'LineWidth',2,...
        'MarkerFaceColor',f_colors(i,:),'MarkerEdgeColor',f_colors(i,:),'Parent',ax1);
    % dots
    line('XData',dots_data(:,i,index_rem),'YData',dots_data(:,i,index_remphasic),...
        'LineStyle','none','Marker','.','MarkerSize',5,'Tag','dots',...
        'MarkerFaceColor',f_colors(i,:),'MarkeredgeColor',f_colors(i,:),'Parent',ax1);
    % text
    text(tt_data(index_rem,i)+.05,tt_data(index_remphasic,i)-.05,char(list_regions(i)),...
        'Color',f_colors(i,:),'Parent',ax1);
end
% Axis limits
line('XData',[-1 1],'YData',[-1 1],'Color',[.5 .5 .5],'Parent',ax1);
ax1.XLim = [0 1];
ax1.YLim = [0 1];
ax1.XLabel.String = list_ref(index_rem);
ax1.YLabel.String = list_ref(index_remphasic);
ax1.Title.String = 'REM vs REM-PHASIC';
grid(ax1,'on');


% Ax2
hold(ax2,'on');
for i=1:length(list_regions)
    %bar color
    line('XData',tt_data(index_rem,i),'YData',tt_data(index_remphasic2,i),...
        'LineStyle','none','Marker','+','MarkerSize',15,'LineWidth',2,...
        'MarkerFaceColor',f_colors(i,:),'MarkerEdgeColor',f_colors(i,:),'Parent',ax2);
    % dots
    line('XData',dots_data(:,i,index_rem),'YData',dots_data(:,i,index_remphasic2),...
        'LineStyle','none','Marker','.','MarkerSize',5,'Tag','dots',...
        'MarkerFaceColor',f_colors(i,:),'MarkeredgeColor',f_colors(i,:),'Parent',ax2);
    % text
    text(tt_data(index_rem,i)+.05,tt_data(index_remphasic2,i)-.05,char(list_regions(i)),...
        'Color',f_colors(i,:),'Parent',ax2);
end
% Axis limits
line('XData',[-1 1],'YData',[-1 1],'Color',[.5 .5 .5],'Parent',ax2);
ax2.XLim = [0 1];
ax2.YLim = [0 1];
ax2.XLabel.String = list_ref(index_rem);
ax2.YLabel.String = list_ref(index_remphasic2);
ax2.Title.String = 'REM vs REM-PHASIC-2';
grid(ax2,'on');

dots_visibility = 'off';
dots = findobj([ax1;ax2],'Tag','dots');
for i = 1:length(dots)
    dots(i).Visible = dots_visibility;
end


% dummy_data = rand(length(list_ref),length(list_regions));
% xtick_labs = list_ref;
% leg_labs = list_regions;
% 
% % Dummy axes for legend
% b = bar(dummy_data,'Parent',ax_dummy);
% for i=1:length(b)
%     %bar color
% %     ind_color = max(round(i*length(cmap)/n_bars-1)+1,1);
% %     b(i).FaceColor = cmap(ind_color,:);
%     b(i).FaceColor = f_colors(i,:);
%     b(i).EdgeColor = 'k';
%     b(i).LineWidth = .1;
% end
% leg = legend(ax_dummy,leg_labs,'Visible','on');
% ax_dummy.Position = [2 1 1 1];
% 
% % Legend Position
% panel = leg.Parent;
% panel.Units = 'characters';
% %leg.Units = 'characters';
% pos = panel.Position;
% leg.Position = [.8 .1 .15 .8];
% panel.Units = 'normalized';
% leg.Units = 'normalized';

f.Units = 'pixels';
f.Position = [195          59        1045         919];

%fullname = fullfile(folder_save,strcat(fName,'-A.pdf'));
fullname = fullfile(folder_save,strcat(f.Name,'pdf'));
saveas(f,fullname);

end
