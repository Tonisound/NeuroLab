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
L = get_lists(rec_list,reg_group);
fName = sprintf('Fig3_%s-%s',rec_list,reg_group);
folder_save = fullfile(pwd,'Figure3');
if ~exist(folder_save,'dir')
    mkdir(folder_save);
end

% % Exclude some regions
% list_exclude = {'CCallosum';'Cerebellum';'BrainStem';'Ventricles'};
% ind_exclude = contains(L.list_regions,list_exclude);
% L.list_regions(ind_exclude)=[];
% L.label_regions(ind_exclude)=[];

% list of time groups

% list_ref = {'Ref-Index-REM';'Ref-Index-REM-PHASIC';'Ref-Index-REM-PHASIC-2'};
list_ref = {'Ref-Index-REM';'Ref-Index-REM-PHASIC';'Ref-Index-REM-TONIC'};
% list_ref = {'Ref-Index-QW';'Ref-Index-AW';'Ref-Index-NREM'};
% list_ref = {'Ref-Index-WAKE';'Ref-Index-SLEEP';'Ref-Index-REM-TONIC'};

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

% Plotting/Saving Data
only_txt = false;
% tt_data = plot1(L,P,S,'Rmax',only_txt);
% tt_data = plot1(L,P,S,'Tmax',only_txt);
% tt_data = plot1(L,P,S,'Xmax',only_txt);
tt_data = plot2(L,P,S,'Mean',only_txt);
tt_data = plot2(L,P,S,'Median',only_txt);

end

function [S,P] = browse_data(L)

folder_save = L.folder_save;
fName = L.fName;
list_regions = L.list_regions;
list_ref = L.list_ref;
list_files = L.list_files;

% container = 'F:\SHARED_DATASET\NEUROLAB\NLab_Statistics\fUS_Correlation';
container = 'F:\Antoine\OneDrive - McGill University\Antoine-fUSDataset\NEUROLAB\NLab_Statistics\fUS_Correlation';
time_group = 'CURRENT';
list_files=strrep(list_files,'R_nlab','R');

% Buidling struct S
S = struct('reference','','region','','recording','',...
    'r_max',[],'t_max',[],'x_max',[],...
    'r_min',[],'t_min',[],'x_min',[],...
    'r_abs',[],'t_abs',[],'x_abs',[],...
    'ref_time',[],'RT_pattern',[]);...
    S(length(list_ref),length(list_regions)).r_max = [];
ref_time = (-20:.1:20);

% Buidling struct R
R = struct('reference','','recording','',...
    'Rmax_map',[],'Tmax_map',[],'RT_pattern',[]);...
R(length(list_files),length(list_ref)).recording = [];

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
        R(index,i).reference = {cur_ref};
        R(index,i).recording = {cur_file};
        R(index,i).Rmax_map = data_fus.Rmax_map;
        R(index,i).Tmax_map = data_fus.Tmax_map;
%         R(index,i).RT_pattern = data_fus.RT_pattern;
        
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
            %             if sum(isnan(data_fus.RT_pattern(index_region,:)))==length(data_fus.RT_pattern(index_region,:))
            %                 continue;
            %             end
            
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
colormap(f,'jet');
P.Colormap = f.Colormap;
P.f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
% P.f_colors =    [0.2422    0.1504    0.6603;
%     0.2504    0.1650    0.7076;
%     0.2578    0.1818    0.7511;
%     0.2647    0.1978    0.7952;
%     0.2706    0.2147    0.8364;
%     0.2751    0.2342    0.8710;
%     0.2783    0.2559    0.8991;
%     0.2803    0.2782    0.9221;
%     0.2813    0.3006    0.9414;
%     0.2810    0.3228    0.9579;
%     0.2795    0.3447    0.9717;
%     0.2760    0.3667    0.9829;
%     0.2699    0.3892    0.9906;
%     0.1248    0.6459    0.8883;
%     0.0952    0.6798    0.8598;
%     0.0689    0.6948    0.8394;
%     0.0297    0.7082    0.8163;
%     0.0036    0.7203    0.7917;
%     0.2470    0.7918    0.5567;
%     0.2906    0.7973    0.5188;
%     0.3406    0.8008    0.4789;
%     0.6720    0.7793    0.2227;
%     0.7242    0.7698    0.1910;
%     0.7738    0.7598    0.1646;
%     0.8203    0.7498    0.1535;
%     0.8634    0.7406    0.1596;
%     0.9035    0.7330    0.1774;
%     0.9393    0.7288    0.2100;
%     0.9728    0.7298    0.2394;
%     0.9597    0.9135    0.1423;
%     0.9628    0.9373    0.1265;
%     0.9691    0.9606    0.1064;
%     0.9769    0.9839    0.0805];
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
save(fullfile(folder_save,strcat(fName,'.mat')),'L','R','S','P','-v7.3');
fprintf('Synthesis Data Saved [%s]\n',fullfile(folder_save,strcat(fName,'.mat')));

end

function tt_data = plot1(L,P,S,str,only_txt)

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


% Save in txt file
fid = fopen(fullfile(folder_save,strcat(f.Name,'.txt')),'w');
fwrite(fid,sprintf('Region \t'));
for j =1:length(list_ref)
    fwrite(fid,sprintf('%s \t ', char(list_ref(j))));
end
fwrite(fid,newline);
for i =1:length(list_regions)
    fwrite(fid,sprintf('%s \t ', char(list_regions(i))));
    for j =1:length(list_ref)
        fwrite(fid,sprintf('%.4f \t ', tt_data(j,i)));
    end
    if i~=length(list_regions)
        fwrite(fid,newline);
    end
end
fclose(fid);
fprintf('Data Saved in txt file [%s].\n',fullfile(folder_save,strcat(f.Name,'.txt')));

% Early Break
if only_txt == true
    warning('Early Break: Text File saved only.');
    return;
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
            ax.XLim = [500 4000];
        case 'Xmax'
            ax.XLim = [-20 20];
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
        fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
    case 'Tmax'
        fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
    case 'Xmax'
        fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
end
saveas(f,fullname);

end

function tt_data = plot2(L,P,S,str,only_txt)

fName = L.fName;
folder_save = L.folder_save;
list_regions = L.list_regions;
label_regions = L.label_regions;
list_ref = L.list_ref;
%list_files = L.list_files;

% Drawing results
f = figure;
panel = uipanel('Parent',f,'Position',[0 0 1 1]);
ax1 = axes('Parent',panel,'Position',[.05 .1 .25 .3]);
ax2 = axes('Parent',panel,'Position',[.05 .6 .25 .3]);
ax3 = axes('Parent',panel,'Position',[.4 .05 .15 .9]);
ax3b = axes('Parent',panel,'Position',[.6 .05 .15 .9]);
ax4 = axes('Parent',panel,'Position',[.8 .05 .15 .9]);
%ax_dummy = axes('Parent',panel,'Position',[.1 .1 .8 .8],'Visible','off');
switch str
    case 'Mean'
        f.Name = strcat(fName,'-B-Mean');
    case 'Median'
        f.Name = strcat(fName,'-B-Median');
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
        temp = S(i,j).r_max;
        dots_data(1:length(temp),j,i) = temp;
    end
end
dots_data2 = NaN(m,length(list_regions),length(list_ref));
std_data = NaN(length(list_regions),length(list_ref));
sem_data = NaN(length(list_regions),length(list_ref));

for i =1:length(list_ref)
    for j = 1:length(list_regions)
        temp = S(i,j).x_max;
        dots_data2(1:length(temp),j,i) = temp;
        std_data(j,i) = std(temp);
        sem_data(j,i) = std(temp)/sqrt(length(temp));
    end
end

tt_data = NaN(length(list_ref),length(list_regions));
ebar_data = NaN(length(list_ref),length(list_regions));
n_recordings = NaN(length(list_ref),length(list_regions));

for i =1:length(list_ref)
    for j = 1:length(list_regions)
        temp = S(i,j).r_max;
        switch str
            case 'Mean'
                tt_data(i,j) = mean(temp,'omitnan');
            case 'Median'
                tt_data(i,j) = median(temp,'omitnan');
        end
        %tt_data(i,j) = mean(temp,'omitnan');
        %ebar_data(i,j) = std(temp,[],'omitnan');
        n_recordings(i,j) = length(temp);
        ebar_data(i,j) = std(temp,[],'omitnan')./sqrt(n_recordings(i,j));
    end
end
n_max_recordings = max(n_recordings);

% Save in txt file
fid = fopen(fullfile(folder_save,strcat(f.Name,'.txt')),'w');
fwrite(fid,sprintf('Region \t'));
for j =1:length(list_ref)
    fwrite(fid,sprintf('%s \t ', char(list_ref(j))));
end
fwrite(fid,newline);
for i =1:length(list_regions)
    fwrite(fid,sprintf('%s[%d] \t ', char(list_regions(i)), n_max_recordings(i)));
    for j =1:length(list_ref)
        fwrite(fid,sprintf('%.3f+/-%.3f \t ',tt_data(j,i),ebar_data(j,i)));
    end
    if i~=length(list_regions)
        fwrite(fid,newline);
    end
end
fclose(fid);
fprintf('Data Saved in txt file [%s].\n',fullfile(folder_save,strcat(f.Name,'.txt')));

% Early Break
if only_txt == true
    warning('Early Break: Text File saved only.');
    return;
end

ref_time = (-20:.01:20)';
rt_data = NaN(length(list_regions),length(ref_time),length(list_ref));
for i =1:length(list_ref)
    for j = 1:length(list_regions)
        temp = S(i,j).RT_pattern;
        switch str
            case 'Mean'
                temp=mean(temp);
            case 'Median'
                temp=median(temp);
        end
%         if ~isempty(S(i,j).RT_pattern)
%             rt_data(j,:,i)=interp1(S(i,j).ref_time(:),temp(:),ref_time);
%         else
%             rt_data(j,:,i)=NaN(size(ref_time));
%         end
        rt_data(j,:,i)=interp1(S(i,j).ref_time(:),temp(:),ref_time);
    end
end


% Finding patterns
pattern1 = char(list_ref(1));
pattern2 = char(list_ref(2));
pattern3 = char(list_ref(3));
% pattern1 = 'Ref-Index-REM';
% pattern2 = 'Ref-Index-REM-PHASIC';
% pattern3 = 'Ref-Index-REM-PHASIC-2';
index_pattern1 = find(strcmp(list_ref,pattern1)==1);
index_pattern2 = find(strcmp(list_ref,pattern2)==1);
index_pattern3 = find(strcmp(list_ref,pattern3)==1);

% Bar Plot
n_groups = length(list_ref);
n_bars = length(list_regions);


% % Sorting rt_data
% [A,ind_max_a] = max(rt_data(:,:,1),[],2,'omitnan');
% [~,ind_sorted_a] = sort(A,'ascend');
% [B,ind_max_b] = max(rt_data(:,:,2),[],2,'omitnan');
% [~,ind_sorted_b] = sort(B,'ascend');
% [C,ind_max_c] = max(rt_data(:,:,3),[],2,'omitnan');
% [~,ind_sorted_c] = sort(C,'ascend');

% No sorting
ind_sorted_a=1:length(list_regions);
ind_sorted_c=1:length(list_regions);
ind_sorted_b=1:length(list_regions);

% % Manual sorting
% ind_sorted_a = fliplr([25 11 27 30 41 22 ...
%     38 52 31 32 1 39 ...
%     44 40 6 17 36 7 19 5 18 ...
%     45 43 ...
%     15 46 34 21 16 48 42 49 20 9 50 26 53 35 13 2 24 12 ...
%     47 33 23 28 3 14 37 29 4 ...
%     51 8 10]);
% 
% ind_sorted_c = fliplr([11 25 27 30 41 22 ...
%     38 52 31 32 39 1 ...
%     6 44 17 36 40 7 19 5 18 ...
%     45 43 ...
%     15 34 46 16 21 48 20 53 26 49 50 42 9 35 2 13 12 24 ...
%     47 23 33 3 28 14 37 29 4 ...
%     51 8 10]);


% Ax1 & Ax2: Display mode
show_scatter = false; % display mode: scatter plot
if ~show_scatter
    show_bars = false; % display mode: bar plot (otherwise: marker plot)
end

% Ax1
if show_scatter
    % Scatter plot
    hold(ax1,'on');
    for i=1:length(list_regions)
        %bar color
        line('XData',tt_data(index_pattern1,i),'YData',tt_data(index_pattern2,i),...
            'LineStyle','none','Marker','+','MarkerSize',15,'LineWidth',1,...
            'MarkerFaceColor',f_colors(i,:),'MarkerEdgeColor',f_colors(i,:),'Parent',ax1);
        % dots
        line('XData',dots_data(:,i,index_pattern1),'YData',dots_data(:,i,index_pattern2),...
            'LineStyle','none','Marker','.','MarkerSize',5,'Tag','dots',...
            'MarkerFaceColor',f_colors(i,:),'MarkeredgeColor',f_colors(i,:),'Parent',ax1);
        % text
        text(tt_data(index_pattern1,i)+.05,tt_data(index_pattern2,i)-.05,char(label_regions(i)),...
            'Color',f_colors(i,:),'Parent',ax1);
    end
    % Axis limits
    line('XData',[-1 1],'YData',[-1 1],'Color',[.5 .5 .5],'Parent',ax1);
    ax1.XLim = [0 1];
    ax1.YLim = [0 1];
    ax1.XLabel.String = list_ref(index_pattern1);
    ax1.YLabel.String = list_ref(index_pattern2);
    ax1.Title.String = sprintf('%s vs %s',char(list_ref(index_pattern1)),char(list_ref(index_pattern2)));
    grid(ax1,'on');
    
else
    % Bar/Marker plot
    hold(ax1,'on');
    bdata = (tt_data(index_pattern2,:)./tt_data(index_pattern1,:))';
    bdata = bdata(ind_sorted_a);
    for i=1:length(list_regions)
        %bar color
        if show_bars
            b = barh(i,bdata(i)-1,'Parent',ax1);
            b.FaceColor = f_colors(ind_sorted_a(i),:);
            b.EdgeColor = [.5 .5 .5];
        else
            line('XData',bdata(i)-1,'YData',i,...
                'LineStyle','none','Marker','o','MarkerSize',10,'LineWidth',1,...
                'MarkerFaceColor',f_colors(ind_sorted_a(i),:),'MarkerEdgeColor',[.5 .5 .5],'Parent',ax1);
        end
    end
    % Axis limits
    ax1.XLim = [-.4 .4];
    ax1.XTick = [-.4 -.2 0 .2 .4];
    ax1.XTickLabel = {'-40%','-20%','0%','+20%','+40%'};
    ax1.YTickLabel = label_regions(ind_sorted_a);
    %ax1.YTickLabel = label_regions;
    ax1.YLim = [.5 length(list_regions)+.5];
    ax1.Title.String = sprintf('%s / %s',char(list_ref(index_pattern2)),char(list_ref(index_pattern1)));
    ax1.YTick = 1:length(list_regions);
    grid(ax1,'on');
end


% Ax2
if show_scatter
    % Scatter plot
    hold(ax2,'on');
    for i=1:length(list_regions)
        %bar color
        line('XData',tt_data(index_pattern1,i),'YData',tt_data(index_pattern3,i),...
            'LineStyle','none','Marker','+','MarkerSize',15,'LineWidth',1,...
            'MarkerFaceColor',f_colors(i,:),'MarkerEdgeColor',f_colors(i,:),'Parent',ax2);
        % dots
        line('XData',dots_data(:,i,index_pattern1),'YData',dots_data(:,i,index_pattern3),...
            'LineStyle','none','Marker','.','MarkerSize',5,'Tag','dots',...
            'MarkerFaceColor',f_colors(i,:),'MarkeredgeColor',f_colors(i,:),'Parent',ax2);
        % text
        try
            text(tt_data(index_pattern1,i)+.05,tt_data(index_pattern3,i)-.05,char(label_regions(i)),...
                'Color',f_colors(i,:),'Parent',ax2);
        catch
            %tt_data
        end
    end
    % Axis limits
    line('XData',[-1 1],'YData',[-1 1],'Color',[.5 .5 .5],'Parent',ax2);
    ax2.XLim = [0 1];
    ax2.YLim = [0 1];
    ax2.XLabel.String = list_ref(index_pattern1);
    ax2.YLabel.String = list_ref(index_pattern3);
    ax2.Title.String = sprintf('%s vs %s',char(list_ref(index_pattern1)),char(list_ref(index_pattern3)));
    grid(ax2,'on');
    
else
    % Bar/Marker Plot
    hold(ax2,'on');
    bdata = (tt_data(index_pattern3,:)./tt_data(index_pattern1,:))';
    bdata = bdata (ind_sorted_c);
    
    for i=1:length(list_regions)
        %bar color
        if show_bars
            b = barh(i,bdata(i)-1,'Parent',ax2);
            b.FaceColor = f_colors(ind_sorted_c(i),:);
            b.EdgeColor = [.5 .5 .5];
        else
            line('XData',bdata(i)-1,'YData',i,...
                'LineStyle','none','Marker','o','MarkerSize',10,'LineWidth',1,...
                'MarkerFaceColor',f_colors(ind_sorted_c(i),:),'MarkerEdgeColor',[.5 .5 .5],'Parent',ax2);
        end
        
    end
    % Axis limits
    ax2.XLim = [-.2 .2];
    ax2.XTick = [-.2 -.1 0 .1 .2];
    ax2.XTickLabel = {'-20%','-10%','0%','+10%','+20%'};
    ax2.YTickLabel = label_regions(ind_sorted_c);
    %ax2.YTickLabel = label_regions;
    
    ax2.YLim = [.5 length(list_regions)+.5];
    ax2.Title.String = sprintf('%s / %s',char(list_ref(index_pattern3)),char(list_ref(index_pattern1)));
    ax2.YTick = 1:length(list_regions);
    grid(ax2,'on');
end


dots_visibility = 'off';
dots = findobj([ax1;ax2],'Tag','dots');
for i = 1:length(dots)
    dots(i).Visible = dots_visibility;
end


% Ax3
hold(ax3,'on');
im = imagesc(rt_data(ind_sorted_a,:,1),'XData',ref_time,'Parent',ax3);
% peak
% line('XData',ref_time(ind_max_a(ind_sorted_a)),'YData',1:length(list_regions),...
%     'LineStyle','none','Marker','o','MarkerSize',3,...
%     'MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax3);
ax3.YLim = [.5 length(list_regions)+.5];
ax3.XLim = [ref_time(1) ref_time(end)];
% ax3.YTickLabel = list_regions(ind_sorted_a);
ax3.YTickLabel = label_regions(ind_sorted_a);
ax3.YTick = 1:length(list_regions);
ax3.CLim = [min(min(rt_data(:,:,1),[],'omitnan'),[],'omitnan') max(max(rt_data(:,:,1),[],'omitnan'),[],'omitnan')];
colorbar(ax3,'southoutside');
ax3.Title.String = char(list_ref(1));

% % half-width
% for k =1:size(im.CData,1)
%     [~,ind_max]=max(im.CData(k,:));
%     line('XData',im.XData(ind_max),'YData',k,...
%         'LineStyle','none','Marker','o','MarkerSize',2,...
%         'MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax3);
%     line('XData',[im.XData(ind_max)-std_data(ind_sorted_a(k),1) im.XData(ind_max)+std_data(ind_sorted_a(k),1)],'YData',[k k],...
%         'LineStyle','-','Marker','none','MarkerSize',2,...
%         'Color','k','MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax3);
% end
% dots_to_display
dots_to_display = dots_data2(:,ind_sorted_a,1);
amp_noise = .25;
mf_color = [.5 .5 .5];
mf_size = 1;
for k =1:size(im.CData,1)
    noise = amp_noise*(-.5+rand(size(dots_to_display(:,k))));
    line('XData',dots_to_display(:,k),'YData',k*(ones(size(dots_to_display(:,k))))+noise,...
        'LineStyle','none','Marker','o','MarkerSize',mf_size,...
        'MarkerFaceColor',mf_color,'MarkeredgeColor',mf_color,'Parent',ax3);
end 

ax3.YDir = 'reverse';
ax3.CLim = [0 .8];

% Ax3b
hold(ax3b,'on');
im = imagesc(rt_data(ind_sorted_b,:,2),'XData',ref_time,'Parent',ax3b);
% peak
% line('XData',ref_time(ind_max_b(ind_sorted_b)),'YData',1:length(list_regions),...
%     'LineStyle','none','Marker','o','MarkerSize',3,...
%     'MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax3);
ax3b.YLim = [.5 length(list_regions)+.5];
ax3b.XLim = [ref_time(1) ref_time(end)];
% ax3b.YTickLabel = list_regions(ind_sorted_b);
ax3b.YTickLabel = label_regions(ind_sorted_b);
ax3b.YTick = 1:length(list_regions);
ax3b.CLim = [min(min(rt_data(:,:,2),[],'omitnan'),[],'omitnan') max(max(rt_data(:,:,2),[],'omitnan'),[],'omitnan')];
colorbar(ax3b,'southoutside');
ax3b.Title.String = char(list_ref(2));
% % half-width
% for k =1:size(im.CData,1)
%     [~,ind_max]=max(im.CData(k,:));
%     line('XData',im.XData(ind_max),'YData',k,...
%         'LineStyle','none','Marker','o','MarkerSize',2,...
%         'MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax3b);
%     line('XData',[im.XData(ind_max)-std_data(ind_sorted_b(k),1) im.XData(ind_max)+std_data(ind_sorted_b(k),1)],'YData',[k k],...
%         'LineStyle','-','Marker','none','MarkerSize',2,...
%         'Color','k','MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax3b);
% end
% dots_to_display
dots_to_display = dots_data2(:,ind_sorted_b,2);
for k =1:size(im.CData,1)
    noise = amp_noise*(-.5+rand(size(dots_to_display(:,k))));
    line('XData',dots_to_display(:,k),'YData',k*(ones(size(dots_to_display(:,k))))+noise,...
        'LineStyle','none','Marker','o','MarkerSize',mf_size,...
        'MarkerFaceColor',mf_color,'MarkeredgeColor',mf_color,'Parent',ax3b);
end 

ax3b.YDir = 'reverse';
ax3b.CLim = [0 .8];


% Ax4
hold(ax4,'on');
im = imagesc(rt_data(ind_sorted_c,:,3),'XData',ref_time,'Parent',ax4);
% peak
% line('XData',ref_time(ind_max_b(ind_sorted_c)),'YData',1:length(list_regions),...
%     'LineStyle','none','Marker','o','MarkerSize',3,...
%     'MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax4);
ax4.YLim = [.5 length(list_regions)+.5];
ax4.XLim = [ref_time(1) ref_time(end)];
ax4.YTickLabel = label_regions(ind_sorted_c);
% ax4.YTickLabel = list_regions(ind_sorted_c);
ax4.YTick = 1:length(list_regions);
ax4.CLim = [min(min(rt_data(:,:,3),[],'omitnan'),[],'omitnan') max(max(rt_data(:,:,3),[],'omitnan'),[],'omitnan')];
colorbar(ax4,'southoutside');
ax4.Title.String = char(list_ref(3));
% % half-width
% for k =1:size(im.CData,1)
%     [~,ind_max]=max(im.CData(k,:));
%     line('XData',im.XData(ind_max),'YData',k,...
%         'LineStyle','none','Marker','o','MarkerSize',2,...
%         'MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax4);
%     line('XData',[im.XData(ind_max)-std_data(ind_sorted_c(k),3) im.XData(ind_max)+std_data(ind_sorted_c(k),3)],'YData',[k k],...
%         'LineStyle','-','Marker','none','MarkerSize',2,...
%         'Color','k','MarkerFaceColor','k','MarkeredgeColor','k','Parent',ax4);
% end
% dots_to_display
dots_to_display = dots_data2(:,ind_sorted_c,3);
for k =1:size(im.CData,1)
    noise = amp_noise*(-.5+rand(size(dots_to_display(:,k))));
    line('XData',dots_to_display(:,k),'YData',k*(ones(size(dots_to_display(:,k))))+noise,...
        'LineStyle','none','Marker','o','MarkerSize',mf_size,...
        'MarkerFaceColor',mf_color,'MarkeredgeColor',mf_color,'Parent',ax4);
end 


ax4.YDir = 'reverse';
ax4.CLim = [0 .8];


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
f.Position = [195          59        1245         919];

fullname = fullfile(folder_save,strcat(f.Name,'.pdf'));
saveas(f,fullname);

end
